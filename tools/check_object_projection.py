"""Audit excluded projection source with real preloaded retail callees.

Execution equivalence never overrides an instruction mismatch. Loader miss
paths are excluded; the loader executes retail fallback, without callee stubs.
"""
import hashlib
import itertools
import json
import random
from importlib.metadata import version

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols
from rom import ROOT, validate

ENTRY, LOADER, BLEND = 0x8003B2B0, 0x8004BD00, 0x8003F818
CACHE, OUTPUT, STACK = 0x8007A1C4, 0x800C8C10, 0x80300000
POOL, REFERENCE, CONTEXT = 0x80200000, 0x80210000, 0x80230000
FAMILY = 'object-projection-execution'


def locate(data, address, size):
    for base, block in data.items():
        if base <= address and address + size <= base + len(block):
            return block, address - base
    raise AssertionError(('Outside initialized data', hex(address), size))


def put(data, address, value):
    block, offset = locate(data, address, len(value))
    block[offset:offset + len(value)] = value


def get(data, address, size):
    block, offset = locate(data, address, size)
    return bytes(block[offset:offset + size])


def initial(case):
    count, frames, frame, clock, start, index, reference_index, alias, seed = case
    source_limit = 0x2000
    if index == reference_index and alias == 0:
        phase = ((clock - start) & 4095) // 512 * 10
        extent = max(0, count * frames + count, count * frame + count,
                     count * phase + min(count, 12)) * 8
        source_limit = max(source_limit, extent + 32)
        assert source_limit <= 0xF000, ('Source fixture extent', case, source_limit)
    ranges = [(CACHE - 32, CACHE + 400 * 16 + 32),
              (OUTPUT - 0x300, OUTPUT + 0x2000),
              (POOL - 0x400, POOL + source_limit),
              (REFERENCE - 32, REFERENCE + 0x10000),
              (CONTEXT - 16, CONTEXT + 32),
              (0x8009B158, 0x8009B178), (0x800BEF54, 0x800BEF7C),
              (0x8007BB04, 0x8007BB24)]
    data = {a: bytearray((i * 37 + seed * 17 + i // 7) & 255
                        for i in range(b - a)) for a, b in ranges}
    ordered = sorted(ranges)
    assert all(b <= c for (_, b), (c, _) in zip(ordered, ordered[1:])), 'Fixture ranges overlap'
    source, reference = POOL, REFERENCE
    if alias == 1:
        source = OUTPUT - count * frames * 8
    elif alias == 2:
        source = OUTPUT + 2 - count * frames * 8
    elif alias == 3:
        reference = OUTPUT
    elif alias == 4:
        source = OUTPUT - count * frames * 8
        reference = OUTPUT + 8
    elif alias == 5:
        source += 2
        reference += 2
    for item in range(400):
        address = CACHE + item * 16
        put(data, address, word(REFERENCE))
        put(data, address + 4, word(count))
        put(data, address + 8, word(frames))
        put(data, address + 12, b'\x01\xA9\x00\x00')
    reference_count = count if alias in (3, 4) else count + 1
    put(data, CACHE + reference_index * 16, word(reference))
    put(data, CACHE + reference_index * 16 + 4, word(reference_count))
    put(data, CACHE + index * 16, word(source))
    put(data, CACHE + index * 16 + 4, word(count))
    put(data, CACHE + index * 16 + 8, word(frames))
    put(data, 0x8009B168, word(CONTEXT))
    put(data, CONTEXT + 10, (reference_index & 65535).to_bytes(2, 'big'))
    put(data, 0x800BEF64, word(start))
    put(data, 0x800BEF6C, word(clock))
    return data


def oracle(initial_data, case):
    data = {a: bytearray(b) for a, b in initial_data.items()}
    count, frames, frame, clock, start, index, reference_index, alias, seed = case
    source = int.from_bytes(get(data, CACHE + index * 16, 4), 'big')
    reference = int.from_bytes(get(data, CACHE + reference_index * 16, 4), 'big')
    reference_count = int.from_bytes(get(data, CACHE + reference_index * 16 + 4, 4), 'big')
    phase = (((clock - start) & 0xFFFFFFFF) & 4095) // 512 * 10
    first = (source + count * frame * 8) & 0xFFFFFFFF
    second = (reference + reference_count * phase * 8) & 0xFFFFFFFF
    writes = []

    def store(address, value):
        put(data, address, value)
        writes.append((address, address + len(value)))

    store(0x8007BB14, word(1))
    for point in range(count):
        address = second if point < 12 else first
        for field in range(3):
            store(OUTPUT + point * 8 + field * 2,
                  get(data, address + point * 8 + field * 2, 2))
    footer = (source + count * frames * 8) & 0xFFFFFFFF
    for point in range(count):
        # Retail copies the first word before reading the second. This matters
        # when source and destination partially overlap.
        for offset in (0, 4):
            store(OUTPUT + count * 8 + point * 8 + offset,
                  get(data, footer + point * 8 + offset, 4))
    selected = CACHE + 254 * 16
    store(selected, word(OUTPUT))
    store(selected + 12, b'\x01')
    store(selected + 13, b'\x01')
    store(selected + 8, word(1))
    store(selected + 4, get(data, CACHE + index * 16 + 4, 4))
    trace = [(LOADER, (0xFFFFFFFF, reference_index, 0xFFFFFFFF)),
             (BLEND, (count & 0xFFFFFFFF, OUTPUT, first, second))]
    return data, writes, trace


def execute(code, support, case):
    data = initial(case)
    expected, allowed, expected_trace = oracle(data, case)
    uc, write, _ = machine([(ENTRY, code)], support)
    for address, block in data.items():
        write(address, bytes(block))
    # Projection reserves 0x40 bytes and its retail loader reserves 0x148.
    # Surround the complete nested frame and incoming argument area with canaries.
    stack_floor = STACK - 0x188
    stack_start = stack_floor - 32
    stack = bytes((i * 43 + case[-1]) & 255
                  for i in range(STACK + 48 - stack_start))
    write(stack_start, stack)
    allowed.append((stack_floor, STACK + 16))
    writable = {address for a, b in allowed for address in range(a, b)}
    readable = [(a, a + len(b)) for a, b in data.items()]
    readable.append((stack_floor, STACK + 16))
    executable = [(ENTRY, ENTRY + len(code))] + [(a, a + len(b)) for a, b in support]
    saved = {getattr(regs, 'UC_MIPS_REG_' + name):
             uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + name))
             for name in ('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP')}
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xABCD1234)
    uc.reg_write(regs.UC_MIPS_REG_A0, case[5])
    uc.reg_write(regs.UC_MIPS_REG_A1, case[2] & 0xFFFFFFFF)
    touched, trace = set(), []

    def guard_write(uc, access, address, size, value, user):
        address |= 0x80000000
        assert all(address + i in writable for i in range(size)), ('Write guard', hex(address), size, case)
        if stack_start <= address < STACK + 16:
            touched.update(range(address, address + size))

    def guard_read(uc, access, address, size, value, user):
        address |= 0x80000000
        assert any(a <= address and address + size <= b for a, b in readable), ('Read guard', hex(address), size, case)

    def guard_code(uc, address, size, user):
        assert address == SENTINEL or any(a <= address and address + size <= b for a, b in executable), ('Escaped code', hex(address), case)
        if address in (LOADER, BLEND):
            names = ('A0', 'A1', 'A2') if address == LOADER else ('A0', 'A1', 'A2', 'A3')
            trace.append((address, tuple(uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + name)) for name in names)))

    uc.hook_add(UC_HOOK_MEM_WRITE, guard_write)
    uc.hook_add(UC_HOOK_MEM_READ, guard_read)
    uc.hook_add(UC_HOOK_CODE, guard_code)
    uc.emu_start(ENTRY, 0, count=100000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, 'No return'
    assert uc.reg_read(regs.UC_MIPS_REG_SP) == STACK, 'Stack pointer'
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xABCD1234, 'Global pointer'
    assert all(uc.reg_read(register) == value for register, value in saved.items()), 'Saved registers'
    assert trace == expected_trace, ('Call arguments', trace, expected_trace, case)
    digest = hashlib.sha256()
    for address, block in expected.items():
        actual = bytes(uc.mem_read(address & 0x1FFFFFFF, len(block)))
        assert actual == bytes(block), ('Independent memory oracle', hex(address), case)
        digest.update(actual)
    actual_stack = bytes(uc.mem_read(stack_start & 0x1FFFFFFF, len(stack)))
    assert all(value == stack[i] for i, value in enumerate(actual_stack)
               if stack_start + i not in touched), 'Stack canary'
    digest.update(json.dumps(trace).encode())
    return digest.hexdigest()


def source_fault_controls(target, layout, support, baseline_code):
    """Compile each faulty C form and its unchanged positive pair with IDO."""
    directory = ROOT / '.local/object-projection-execution-controls'
    directory.mkdir(parents=True, exist_ok=True)
    source = (ROOT / 'src/game/object_runtime_projection.c').read_text()
    faults = {
        'phase_period': (' / 512 * 10;', ' / 256 * 10;'),
        'phase_mask': ('clockDifference & 0xFFF', 'clockDifference & 0x7FF'),
        'first_frame': ('data + count * frame)', 'data + count * (frame + 1))'),
        'reference_phase': ('pointCount * phase)', 'pointCount * (phase + 1))'),
        'footer_frame': ('source += count * ANIMATION_CACHE[index].frameCount;',
                         'source += count * (ANIMATION_CACHE[index].frameCount + 1);'),
        'footer_destination': ('output = D_800C8C10 + count;', 'output = D_800C8C10 + count + 1;'),
        'source_record_stride': ('*output++ = *source++;', '*output++ = *source; source += 2;'),
        'destination_record_stride': ('*output++ = *source++;', '*output = *source++; output += 2;'),
        'loaded_flag': ('ANIMATION_CACHE[254].loaded = 1;', 'ANIMATION_CACHE[254].loaded = 0;'),
        'dirty_flag': ('ANIMATION_CACHE[254].unknown0D = 1;', 'ANIMATION_CACHE[254].unknown0D = 0;'),
        'published_frames': ('ANIMATION_CACHE[254].frameCount = 1;', 'ANIMATION_CACHE[254].frameCount = 2;'),
        'published_count': ('ANIMATION_CACHE[254].pointCount = ANIMATION_CACHE[index].pointCount;',
                            'ANIMATION_CACHE[254].pointCount = ANIMATION_CACHE[index].pointCount + 1;'),
        'output_overrun': ('ANIMATION_CACHE[254].frameCount = 1;',
                           'ANIMATION_CACHE[254].frameCount = 1; ((unsigned char *)D_800C8C10)[0x2000] = 0;'),
    }
    case = (13, 3, 1, 4095, 0, 137, 254, 0, 7)
    expected = execute(target[0x3BEB0:0x3C028], support, case)

    def compile_control(name, text):
        path = directory / (name + '.c')
        path.write_text(text)
        compare_block(name, path.relative_to(ROOT).as_posix(), ENTRY,
                      0x3BEB0, 0x3C028, target, FAMILY, layout)
        build = ROOT / 'build' / FAMILY / name
        sections, symbols = elf_sections_and_symbols(build / (name + '.raw.o'))
        live = symbols['func_8003B2B0']['size']
        assert not any(sections['.text']['bytes'][live:]), 'Control alignment'
        assert not any(sections.get(section, {}).get('size', 0)
                       for section in ('.data', '.sdata', '.rodata', '.rdata', '.bss')), 'Control data'
        return (build / (name + '.bin')).read_bytes()[:live], hashlib.sha256(path.read_bytes()).hexdigest()

    results = []
    for name, (before, after) in faults.items():
        assert source.count(before) == 1, ('Fault insertion', name)
        positive, _ = compile_control(name + '_positive', source)
        assert positive == baseline_code, ('Positive compilation', name)
        assert execute(positive, support, case) == expected, ('Positive execution', name)
        faulty, source_hash = compile_control(name, source.replace(before, after, 1))
        assert faulty != baseline_code, ('Unchanged fault', name)
        try:
            execute(faulty, support, case)
        except (AssertionError, ValueError) as error:
            results.append(dict(name=name, source_sha256=source_hash,
                                code_sha256=hashlib.sha256(faulty).hexdigest(),
                                detected=str(error)[:220], positive_passed=True))
        else:
            raise AssertionError(('Undetected source fault', name))
        print('Separately compiled projection fault detected', name, flush=True)
    return results


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    _, source, start, end = next(x for x in MATCHING_BLOCKS if x[0] == 'model_normals_blend')
    support_report = compare_block('blend', source, start, start - 0x80000000 + 0xC00,
                                   end - 0x80000000 + 0xC00, target, FAMILY, layout)
    assert support_report['matches'], 'Complete real callee match'
    blend = (ROOT / 'build' / FAMILY / 'blend/blend.bin').read_bytes()
    support = [(LOADER, target[0x4C900:0x4CC88]), (BLEND, blend)]
    report = compare_block('projection', 'src/game/object_runtime_projection.c', ENTRY,
                           0x3BEB0, 0x3C028, target, FAMILY, layout)
    directory = ROOT / 'build' / FAMILY / 'projection'
    sections, symbols = elf_sections_and_symbols(directory / 'projection.raw.o')
    live = symbols['func_8003B2B0']['size']
    assert sections['.text']['bytes'][live:] == bytes(sections['.text']['size'] - live), 'Compiler alignment'
    candidate = (directory / 'projection.bin').read_bytes()[:live]
    retail = target[0x3BEB0:0x3C028]
    clocks = ((0, 0), (511, 0), (512, 0), (4095, 0), (4096, 0),
              (-1, 0), (0x7FFFFFFF, -0x80000000), (-0x80000000, 0x7FFFFFFF))
    cases = []
    for seed, (count, frames, clock) in enumerate(itertools.product((-7, -1, 0, 1, 2, 3, 11, 12, 13, 24), (0, 1, 3), clocks)):
        cases.append((count, frames, seed % 3, *clock, (0, 137, 254)[seed % 3],
                      (1, 254, 399)[seed % 3], 0, seed))
    for seed, (count, frames, alias) in enumerate(itertools.product((1, 3, 12, 13), (0, 1, 3), (1, 2, 3, 4, 5))):
        cases.append((count, frames, 0, 0, 0, 137, 254, alias, seed))
    rng = random.Random(0x3B2B0)
    for seed in range(64):
        cases.append((rng.randrange(25), rng.randrange(4), rng.randrange(3),
                      rng.randrange(-0x80000000, 0x80000000), rng.randrange(-0x80000000, 0x80000000),
                      rng.randrange(400), rng.randrange(400), 0, seed))
    for seed, (index, count, frames, clock) in enumerate(itertools.product(
            (0, 1, 137, 254, 255, 399), (-1, 0, 1, 12, 13, 32), (0, 2), (512, 4095))):
        cases.append((count, frames, 0, clock, 0, index, index, 0, seed + 1000))
    for seed, (count, frames, clock) in enumerate(itertools.product((64, 128, 255, 511), (0, 1), (0, 512))):
        cases.append((count, frames, 1, clock, 0, 137, 254, 0, seed + 2000))
    assert len(cases) == 524
    digest = hashlib.sha256()
    for index, case in enumerate(cases):
        a, b = execute(retail, support, case), execute(candidate, support, case)
        assert a == b, ('Retail candidate comparison', case)
        digest.update(json.dumps((case, a)).encode())
        if (index + 1) % 64 == 0:
            print('Projection cache-hit guarded cases', index + 1, flush=True)
    mutations = []
    for name, offset, replacement in (('footer source stride', 0x13C, '24420010'),
                                       ('footer destination', 0xEC, '00105900'),
                                       ('ready and dirty flags', 0x14C, '24020002')):
        changed = bytearray(retail)
        changed[offset:offset + 4] = bytes.fromhex(replacement)
        try:
            execute(bytes(changed), support, (13, 3, 1, 512, 0, 137, 254, 0, 7))
        except (AssertionError, ValueError) as error:
            mutations.append(dict(name=name, detected=str(error)[:180]))
        else:
            raise AssertionError(('Undetected mutation', name))
    controls = source_fault_controls(target, layout, support, candidate)
    result = dict(status='Excluded candidate preloaded execution audit; not source ownership.',
                  instruction_matches=report['matches'], source_owned=False,
                  retail_instruction_bytes=376, candidate_live_bytes=live,
                  compiler_raw_bytes=sections['.text']['size'], cases=len(cases),
                  retail_sha256=hashlib.sha256(retail).hexdigest(),
                  candidate_sha256=hashlib.sha256(candidate).hexdigest(),
                  rom_sha256=hashlib.sha256(target).hexdigest(),
                  unicorn_version=version('unicorn'),
                  trace_sha256=digest.hexdigest(), mutations=mutations,
                  compiled_source_controls=controls,
                  comparison=report, freshly_matched_support=support_report,
                  retail_loader=dict(instruction_bytes=904, sha256=hashlib.sha256(support[0][1]).hexdigest(), source_owned=False),
                  audit_source_sha256=hashlib.sha256((ROOT / 'tools/check_object_projection.py').read_bytes()).hexdigest(),
                  audit_inputs_sha256={path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest()
                                       for path in ('tools/check_object_projection.py',
                                                    'tools/check_actor_group_path.py',
                                                    'tools/compare_runtime.py',
                                                    'tools/compare_startup.py',
                                                    'tools/owned_sections.py',
                                                    'tools/rom.py')},
                  limits=['Preloaded or skipped-index loader paths only; file loading and miss paths are not covered.',
                          'No callee stubs. The loader executes retail fallback, not recovered C.',
                          'This audit adds no source-owned instructions or data; visual gameplay remains unproved.'])
    layout.verify()
    (ROOT / 'build' / FAMILY / 'report.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: result[key] for key in ('status', 'instruction_matches', 'candidate_live_bytes', 'cases', 'trace_sha256')}), flush=True)


if __name__ == '__main__':
    main()
