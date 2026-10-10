"""Audit the excluded line candidate with bounded CPU and independent memory checks.

Error cases stop at the fatal formatter entry and check its argument contract.
They do not substitute a returning formatter or prove its rendering behavior.
"""
import hashlib
import itertools
import json
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UC_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL
from check_boss_trigger import fpu_code, FPU_OUT, FPU_BITS, SEED_FPU, READ_FPU
from compare_startup import compare_block, SymbolLayoutSnapshot
from manifest import load_manifest
from owned_sections import elf_sections_and_symbols
from rom import ROOT, validate

ENTRY, END, FATAL = 0x800453D8, 0x80045514, 0x800496E0
VERTICES, CURRENT, FRAME_BASE, DISPLAY = 0x800CDBD0, 0x80123AE4, 0x80123B20, 0x80138254
STACK, COMMANDS = 0x80300000, 0x80220010
SOURCE = 'src/game/renderer_primitives/diagnostic_line.c'
FAMILY = 'renderer-diagnostic-line-execution'


def signed(value):
    return ((value + 0x80000000) & 0xFFFFFFFF) - 0x80000000


def merge(ranges):
    result = []
    for a, b in sorted(ranges):
        if result and a <= result[-1][1]:
            result[-1] = (result[-1][0], max(result[-1][1], b))
        else:
            result.append((a, b))
    return result


def fixtures():
    positions = (
        (0, 0, 1, 1), (-1, 1, -1, 1), (32767, -32768, 32768, -32769),
        (0x7FFFFFFF, -0x80000000, 0x12345678, -0x12345678),
        (65535, 65536, -65535, -65536), (1234, -3456, 7890, -9876),
    )
    allocations = ((0, 0), (1, 0), (9999, 0), (10000, 0), (21998, 21998),
                   (21998, 11999), (21998, 11998), (0, 1), (0, -10000),
                   (0, -0x80000000), (21998, 0x7FFFFFFF))
    aliases = ('ordinary', 'vertices', 'current', 'display_tail')
    return [(base, frame, xy, alias, seed)
            for (base, frame), xy, alias, seed in
            itertools.product(allocations, positions, aliases, range(2))]


def initial(case):
    base, frame, xy, alias, seed = case
    vertex = VERTICES + base * 16
    command = {'ordinary': COMMANDS, 'vertices': vertex,
               'current': CURRENT, 'display_tail': DISPLAY - 8}[alias]
    ranges = merge([(vertex - 16, vertex + 48), (command - 16, command + 48),
                    (CURRENT - 16, CURRENT + 20), (FRAME_BASE - 16, FRAME_BASE + 20),
                    (DISPLAY - 16, DISPLAY + 40)])
    images = {a: bytearray((i * 37 + seed * 17 + i // 7) & 255 for i in range(b - a))
              for a, b in ranges}
    def put(address, payload):
        for start, image in images.items():
            if start <= address and address + len(payload) <= start + len(image):
                image[address - start:address - start + len(payload)] = payload
                return
        raise AssertionError(('oracle range', hex(address), len(payload)))
    put(CURRENT, word(base))
    put(FRAME_BASE, word(frame))
    put(DISPLAY, word(command))
    return vertex, command, images, put


def expected(case):
    base, frame, xy, alias, seed = case
    vertex, command, images, put = initial(case)
    used = signed(base - frame + 1)
    fatal = used > 10000
    if not fatal:
        for index in range(2):
            for axis, value in enumerate((xy[index * 2], xy[index * 2 + 1], 10)):
                put(vertex + index * 16 + axis * 2, (value & 65535).to_bytes(2, 'big'))
            put(vertex + index * 16 + 12, bytes((255, 255, 0, 255)))
        put(CURRENT, word(base + 2))
        for first, second in ((0x0400081F, vertex), (0xB5000000, 0x200)):
            cursor_image = next((data, DISPLAY - address) for address, data in images.items()
                                if address <= DISPLAY and DISPLAY + 4 <= address + len(data))
            data, offset = cursor_image
            packet = int.from_bytes(data[offset:offset + 4], 'big')
            put(DISPLAY, word(packet + 8))
            put(packet, word(first))
            put(packet + 4, word(second))
    return fatal, used, {address: bytes(data) for address, data in images.items()}


def execute(binary, case, fault=None):
    base, frame, xy, alias, seed = case
    vertex, command, images, _ = initial(case)
    fatal, used, oracle = expected(case)
    floating = fpu_code()
    uc, write, _ = machine([(ENTRY, binary)], floating)
    for address, data in images.items():
        write(address, bytes(data))
    write(STACK - 0x100 - 16, b'\xE1' * 16 + b'\xA9' * 0x110 + b'\xE2' * 16)
    write(FPU_OUT - 16, b'\xE3' * 16 + b'\xA4' * 48 + b'\xE4' * 16)
    uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS, uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | (1 << 29))
    uc.emu_start(SEED_FPU, 0, count=100)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    if fault == 'saved_float':
        address = 0x80000400
        bits = FPU_BITS[0] ^ 1
        control = word(0x3C080000 | (bits >> 16)) + word(0x35080000 | (bits & 65535))
        control += word(0x4488A000) + word(0x03E00008) + word(0)
        write(address, control)
        uc.emu_start(address, 0, count=100)
        assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA578ABCD + seed * 16)
    for register, value in zip((regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3), xy):
        uc.reg_write(register, value & 0xFFFFFFFF)
    names = ['S' + str(i) for i in range(8)] + ['FP', 'GP']
    before = {name: uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + name)) for name in names}
    normalize = lambda address: (address & 0x1FFFFFFF) | 0x80000000
    inside = lambda address, size, bounds: any(a <= normalize(address) and normalize(address) + size <= b for a, b in bounds)
    reading = [(CURRENT, CURRENT + 4), (FRAME_BASE, FRAME_BASE + 4), (DISPLAY, DISPLAY + 4),
               (STACK - 56, STACK + 16)]
    writing = [(vertex, vertex + 32), (command, command + 16),
               (CURRENT, CURRENT + 4), (DISPLAY, DISPLAY + 4), (STACK - 56, STACK + 16)]
    code = [(ENTRY, ENTRY + len(binary)), (SENTINEL, SENTINEL + 4), (FATAL, FATAL + 4)]
    fp_phase, stopped, error_boundary = [False], [False], []
    writes = []

    def access(machine, kind, address, size, value, user):
        bounds = writing if kind == UC_MEM_WRITE else reading
        if fp_phase[0]:
            bounds = [(FPU_OUT, FPU_OUT + 48)] if kind == UC_MEM_WRITE else []
        assert inside(address, size, bounds), ('access', kind, hex(address), size)
        if kind == UC_MEM_WRITE and not fp_phase[0] and not inside(address, size, [(STACK - 56, STACK + 16)]):
            writes.append([hex(normalize(address)), size, value & ((1 << (size * 8)) - 1)])

    def instructions(machine, address, size, user):
        if fp_phase[0]:
            assert inside(address, size, [(a, a + len(data)) for a, data in floating] + [(SENTINEL, SENTINEL + 4)])
            return
        assert inside(address, size, code), ('code', hex(address))
        if address == ENTRY:
            if fault == 'saved_integer':
                uc.reg_write(regs.UC_MIPS_REG_S0, before['S0'] ^ 1)
        if address == FATAL:
            assert fatal, 'Unexpected fatal branch'
            arguments = [uc.reg_read(register) for register in
                         (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)]
            line = int.from_bytes(uc.mem_read((STACK - 40) & 0x1FFFFFFF, 4), 'big')
            assert arguments == [0x80095150, used & 0xFFFFFFFF, 10000, 0x80095170]
            assert line == 0x3C1
            error_boundary.append(arguments + [line])
            stopped[0] = True
            uc.emu_stop()
        elif address == SENTINEL:
            assert not fatal, 'Missing fatal branch'
            stopped[0] = True

    uc.hook_add(UC_HOOK_MEM_READ | UC_HOOK_MEM_WRITE, access)
    uc.hook_add(UC_HOOK_CODE, instructions)
    uc.emu_start(ENTRY, 0, count=500)
    assert (stopped[0] if fatal else uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL), ('missing stop', hex(uc.reg_read(regs.UC_MIPS_REG_PC)))
    assert bool(error_boundary) == fatal
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == (FATAL if fatal else SENTINEL)
    assert uc.reg_read(regs.UC_MIPS_REG_SP) == (STACK - 56 if fatal else STACK)
    if not fatal:
        assert uc.reg_read(regs.UC_MIPS_REG_RA) == SENTINEL
    assert {name: uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + name)) for name in names} == before
    for address, expected_bytes in oracle.items():
        assert bytes(uc.mem_read(address & 0x1FFFFFFF, len(expected_bytes))) == expected_bytes, ('memory oracle', hex(address), case)
    assert bytes(uc.mem_read((STACK - 0x100 - 16) & 0x1FFFFFFF, 16)) == b'\xE1' * 16
    assert bytes(uc.mem_read((STACK + 16) & 0x1FFFFFFF, 16)) == b'\xE2' * 16
    fp_phase[0] = True
    uc.reg_write(regs.UC_MIPS_REG_RA, SENTINEL)
    uc.emu_start(READ_FPU, 0, count=100)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    assert bytes(uc.mem_read((FPU_OUT - 16) & 0x1FFFFFFF, 80)) == b'\xE3' * 16 + b''.join(word(n) for n in FPU_BITS) + b'\xE4' * 16
    snapshots = {hex(a): hashlib.sha256(data).hexdigest() for a, data in oracle.items()}
    return dict(fatal=fatal, boundary=error_boundary, snapshots=snapshots, writes=writes)


def main():
    rom = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(rom)
    assert not any(row['source'] == SOURCE for row in load_manifest())
    layout = SymbolLayoutSnapshot()
    comparison = compare_block('line', SOURCE, ENTRY, 0x45FD8, 0x46114, rom, FAMILY, layout)
    build = ROOT / 'build' / FAMILY / 'line'
    sections, symbols = elf_sections_and_symbols(build / 'line.raw.o')
    natural = symbols['func_800453D8']['size']
    raw = sections['.text']['bytes']
    assert symbols['func_800453D8']['value'] == 0 and symbols['func_800453D8']['type'] == 2
    assert all(not sections.get(name, {}).get('size', 0) for name in
               ('.data', '.sdata', '.rodata', '.rdata', '.bss', '.sbss'))
    assert natural == 308 and len(raw) == 320 and not any(raw[natural:])
    assert len(comparison['different_words']) == 57 and comparison['actual_size'] == 316
    candidate = (build / 'line.bin').read_bytes()[:natural]
    retail = rom[0x45FD8:0x46114]
    cases = fixtures()
    trace = hashlib.sha256()
    errors = 0
    for index, case in enumerate(cases):
        expected_result = execute(retail, case)
        actual = execute(candidate, case)
        for key in ('fatal', 'boundary', 'snapshots'):
            assert actual[key] == expected_result[key], (index, key)
        errors += actual['fatal']
        trace.update(json.dumps([case, actual], sort_keys=True).encode())
    controls = {}
    ordinary = cases[0]
    for name in ('saved_integer', 'saved_float'):
        try:
            execute(candidate, ordinary, name)
        except AssertionError:
            controls[name] = 'rejected'
        else:
            raise AssertionError(('Undetected ABI control', name))
    for name, instruction in (('unexpected_read', 0x8C000040), ('unexpected_write', 0xAC000040), ('unexpected_code', 0x08000300), ('stack_escape', 0xAFA0FEF0)):
        try:
            execute(instruction.to_bytes(4, 'big') + retail[4:], ordinary)
        except AssertionError:
            controls[name] = 'rejected'
        else:
            raise AssertionError(('Undetected guard control', name))
    return_offset = retail.rindex(bytes.fromhex('03e00008'))
    missing_return = retail[:return_offset] + bytes.fromhex('1000ffff') + retail[return_offset + 4:]
    try:
        execute(missing_return, ordinary)
    except AssertionError:
        controls['missing_return'] = 'rejected'
    else:
        raise AssertionError('Undetected missing-return control')
    source = (ROOT / SOURCE).read_text()
    mutants = {
        'depth': ('position[2] = 10;', 'position[2] = 11;'),
        'blue': ('color[2] = 0;', 'color[2] = 255;'),
        'cursor': ('D_80123AE4 += 2;', 'D_80123AE4 += 1;'),
        'packet': ('indices = 0x00000200;', 'indices = 0x00000202;'),
        'limit': ('if (used > 10000)', 'if (used >= 10000)'),
    }
    for name, (old, new) in mutants.items():
        assert old in source
        path = ROOT / '.local' / ('diagnostic-line-mutant-' + name + '.c')
        path.write_text(source.replace('../../../include/', str(ROOT / 'include') + '/').replace(old, new))
        comparison_mutant = compare_block(name, str(path.relative_to(ROOT)), ENTRY, 0x45FD8, 0x46114,
                                         rom, FAMILY + '-mutants', layout)
        assert not comparison_mutant['matches']
        sections_mutant, symbols_mutant = elf_sections_and_symbols(ROOT / 'build' / (FAMILY + '-mutants') / name / (name + '.raw.o'))
        binary = (ROOT / 'build' / (FAMILY + '-mutants') / name / (name + '.bin')).read_bytes()
        binary = binary[:symbols_mutant['func_800453D8']['size']]
        detected = False
        for case in cases:
            try:
                execute(binary, case)
            except AssertionError:
                detected = True
                break
        assert detected, ('Undetected source mutant', name)
        controls[name] = 'rejected'
    layout.verify()
    proof = dict(source=SOURCE, comparison=comparison, candidate_natural_bytes=natural,
        raw_text_bytes=len(raw), raw_alignment_bytes=len(raw) - natural,
        comparison_window_padding_bytes=316 - natural,
        fixtures=len(cases), normal_pairs=len(cases) - errors, error_boundary_pairs=errors,
        principal_executions=len(cases) * 2, controls=controls,
        observation_sha256=trace.hexdigest(),
        fatal_formatter_body_executed=False, source_ownership_added=0,
        signature='void func_800453D8(int, int, int, int)',
        source_sha256=hashlib.sha256((ROOT / SOURCE).read_bytes()).hexdigest())
    (ROOT / 'build' / FAMILY / 'proof.json').write_text(json.dumps(proof, indent=2) + '\n')
    print('Compared', len(cases), 'line pairs;', errors, 'fatal boundaries;', len(controls), 'rejected controls.', flush=True)


if __name__ == '__main__':
    main()
