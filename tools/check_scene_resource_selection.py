"""Audit complete scene resource selection against retail and independent byte oracles.

All callees execute freshly matched C. The six-entry dispatch table is compiled
and compared with code; neither range receives source ownership from this audit.
"""
from pathlib import Path
import argparse
import hashlib
import itertools
import json
import random
import re
import subprocess
import sys
import tempfile
from importlib.metadata import version
from collections import Counter
from rom import ROOT as R
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL
from check_movie_storage import PRESERVED, pattern
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot, comparison_input_hashes, external_assignments
from compiler import compile_source, profile_for_source
from toolchain import installed_identity
from trim_padding import trim
from compare_data import compare_unit, data_input_hashes
from owned_sections import source_sections
from check_boss_trigger import fpu_code, FPU_OUT, FPU_BITS, SEED_FPU, READ_FPU
from owned_sections import elf_sections_and_symbols
from rom import validate
DEFAULT_SOURCE = 'src/game/scene_arrivals/select.c'
BUILD = R / 'build/scene-selection-audit'
DATA_SOURCE = 'src/game/scene_arrivals/storage.c'
START = 0x80021c3c
SCENE, SCENE_SIZE = (0x800b9a78, 3348)
FLAGS, FACTOR0, FACTOR1 = (0x800b8f78, 0x800b00b0, 0x800b14a4)
STACK, OUTPUT, ANIMATION = (0x80300000, 0x80210010, 0x80220010)
MODEL, FILL, SELECT, LOOKUP = (0x8007a1cc, 0x8003b694, 0x80021c14, 0x8003941c)
POOLS = ((0, 0x800af1f0, 36, 104), (3, 0x800ace58, 8, 88), (1, 0x8009f560, 16, 88))
DEFAULT = 0x800ac998
SUPPORT = ('game_memory', 'object_model_access', 'save_menu_conditional_copy')

def signed(v):
    return (v + 0x80000000) % 0x100000000 - 0x80000000

def divide(v):
    return -(abs(v) // 2) if v < 0 else v // 2

def fixture(case):
    scene = pattern(SCENE_SIZE, 37)
    count = case.get('total', len(case.get('records', ())))
    for i in range(min(max(count, 0), 273)):
        scene[68 + i * 12:68 + (i + 1) * 12] = bytes(12)
    for i, record in enumerate(case.get('records', ())):
        trigger, state, resource, category, delay, amount = record
        o = 68 + i * 12
        scene[o:o + 8] = bytes((trigger, state, resource, category)) + (delay & 65535).to_bytes(2, 'big') + (amount & 65535).to_bytes(2, 'big')
    scene[3272:3276] = word(count)
    return (scene, count)

def oracle(case, scene, count):
    counts = [0] * 360
    for i in range(max(count, 0)):
        o = 68 + i * 12
        trigger, state, resource, category = scene[o:o + 4]
        delay = int.from_bytes(scene[o + 4:o + 6], 'big', signed=True)
        amount = int.from_bytes(scene[o + 6:o + 8], 'big', signed=True)
        if state and category in (0, 1, 3):
            index = category * 36 + resource
            assert index < 360, 'Cases keep the accumulation address inside the real 360-word local table'
            if trigger == 0:
                counts[index] = max(counts[index], delay + amount)
            elif trigger == 2:
                counts[index] = max(counts[index], delay)
            else:
                counts[index] = signed(counts[index] + amount)
    first = list(counts)
    if case.get('flags', 0) & 0x80000000:
        for i in range(4):
            counts[3 * 36 + 4 + i] = signed(counts[3 * 36 + i] * 3)
    for base, factor in ((17, case.get('factor1', 1)), (9, case.get('factor0', 1))):
        for i in range(4):
            counts[base + 4 + i] = signed(counts[base + 4 + i] + counts[base + i] * factor)
    selected = [DEFAULT]
    lookups = []
    for category, address, n, stride in POOLS:
        for index in range(n):
            amount = counts[category * 36 + index]
            if amount:
                capacity = case.get('capacity', 2)
                lookups.append(case.get('model_index', index % 8))
                if divide(signed(capacity)) <= amount:
                    selected.append(address + index * stride)
    return (first, counts, selected, lookups)

def run(image, dispatch, helpers, case):
    scene, total = fixture(case)
    first, counts, expected_selects, expected_lookup = oracle(case, scene, total)
    frame = -int.from_bytes(image[2:4], 'big', signed=True)
    data = [(0x80091a08, dispatch)]
    pool_data = {}
    kind = {DEFAULT: 173}
    for category, address, n, stride in POOLS:
        blob = pattern(n * stride, 91 + category)
        for index in range(n):
            slot = (category * 40 + index) * 16
            blob[index * stride + 1] = category * 47 + index * 7 + 11 & 255
            blob[index * stride + 40:index * stride + 44] = word(ANIMATION + slot)
            kind[address + index * stride] = blob[index * stride + 1]
            record = pattern(16, 137)
            record[10:12] = (case.get('model_index', index % 8) & 65535).to_bytes(2, 'big')
            data.append((ANIMATION + slot, bytes(record)))
        pool_data[address] = bytes(blob)
        data.append((address, bytes(blob)))
    data.append((DEFAULT, bytes((71, 173))))
    model_index = case.get('model_index')
    model_indices = [model_index] if model_index is not None else list(range(8))
    capacities = {MODEL + i * 16: word(case.get('capacity', 2)) for i in model_indices}
    data.extend(capacities.items())
    uc, write, _ = machine([(START, image)], helpers + data + fpu_code())
    uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS, uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | 1 << 29)
    uc.emu_start(SEED_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    write(FPU_OUT - 16, bytes(pattern(80, 211)))
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xa57281d9)
    saved = {reg: uc.reg_read(reg) for reg in PRESERVED}
    scene_before = bytes(scene)
    panels = {SCENE: (scene_before, 16), OUTPUT: (bytes(pattern(400, 177)), 16), FLAGS: (word(case.get('flags', 0)), 16), FACTOR0: (word(case.get('factor0', 1)), 16), FACTOR1: (word(case.get('factor1', 1)), 16)}
    for address, (blob, guard) in panels.items():
        write(address - guard, b'\xa5' * guard + blob + b'Z' * guard)
    low = STACK - frame - 16
    stack = pattern(frame + 48, 143)
    arg = STACK - low
    stack[arg:arg + 8] = word(OUTPUT) + word(case.get('enabled', 1))
    initial_stack = bytes(stack)
    write(low, bytes(stack))
    uc.reg_write(regs.UC_MIPS_REG_A0, OUTPUT)
    uc.reg_write(regs.UC_MIPS_REG_A1, case.get('enabled', 1) & 0xffffffff)
    state = {'table': None, 'observer': False}
    calls = []
    lookups = []
    model_reads = []
    reads = Counter()
    executable = [(START, START + len(image)), (SENTINEL, SENTINEL + 4)] + [(a, a + len(b)) for a, b in helpers + fpu_code()]
    readable = [(SCENE, SCENE + SCENE_SIZE), (FLAGS, FLAGS + 4), (FACTOR0, FACTOR0 + 4), (FACTOR1, FACTOR1 + 4), (STACK - frame, STACK + 8), (0x80091a08, 0x80091a08 + len(dispatch))]
    readable += [(a, a + len(b)) for a, b in data]

    def norm(a):
        return a & 0x1fffffff | 0x80000000

    def inside(a, n, ranges):
        return any((x <= a and a + n <= y for x, y in ranges))

    def get(a, n=4):
        return bytes(uc.mem_read(a & 0x1fffffff, n))

    def ins(uc, a, n, user):
        a = norm(a)
        assert inside(a, n, executable), ('code bound', hex(a))
        if a == FILL:
            pointer = uc.reg_read(regs.UC_MIPS_REG_A0)
            assert state['table'] is None and uc.reg_read(regs.UC_MIPS_REG_A1) == 0 and (uc.reg_read(regs.UC_MIPS_REG_A2) == 1440)
            assert STACK - frame <= pointer and pointer + 1440 <= STACK, 'table allocation extent'
            state['table'] = pointer
        if a == SELECT:
            p = uc.reg_read(regs.UC_MIPS_REG_A0)
            flag = uc.reg_read(regs.UC_MIPS_REG_A1)
            resource = uc.reg_read(regs.UC_MIPS_REG_A2)
            assert int.from_bytes(get(p), 'big') == STACK, 'helper writes argument spill rather than caller output'
            assert len(calls) < len(expected_selects) and flag == STACK + 4 and (resource == expected_selects[len(calls)]), ('selection call', hex(resource), expected_selects)
            if not calls:
                assert get(state['table'], 1440) == b''.join((word(v) for v in first)), 'pre-transform totals'
            calls.append(resource)
        if a == LOOKUP:
            lookups.append(signed(uc.reg_read(regs.UC_MIPS_REG_A0)))

    def read(uc, access, a, n, value, user):
        a = norm(a)
        assert inside(a, n, readable), ('read bound', hex(a), n, hex(uc.reg_read(regs.UC_MIPS_REG_PC)))
        if a == FLAGS:
            assert n == 4, 'full scene-status word read'
        if a in capacities:
            assert n == 4
            model_reads.append(a)
        if a in (FLAGS, FACTOR0, FACTOR1):
            reads[a] += 1

    def store(uc, access, a, n, value, user):
        a = norm(a)
        allowed = [(FPU_OUT, FPU_OUT + 48)] if state['observer'] else [(STACK - frame, STACK + 8)]
        assert inside(a, n, allowed), ('write bound', hex(a), n, hex(uc.reg_read(regs.UC_MIPS_REG_PC)))
    uc.hook_add(UC_HOOK_CODE, ins)
    uc.hook_add(UC_HOOK_MEM_READ, read)
    uc.hook_add(UC_HOOK_MEM_WRITE, store)
    uc.emu_start(START, 0, count=0x1d4c0)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, 'bounded return'
    assert all((uc.reg_read(reg) == v for reg, v in saved.items())), 'integer ABI preservation'
    assert calls == expected_selects and lookups == expected_lookup, ('ordered helper calls', calls, lookups)
    assert model_reads == [MODEL + i * 16 for i in expected_lookup], 'model read addresses'
    assert get(state['table'], 1440) == b''.join((word(v) for v in counts)), 'complete transformed table'
    wanted = kind[calls[-1]] if case.get('enabled', 1) else OUTPUT
    assert get(STACK) == word(wanted), 'mutable first argument spill'
    assert get(STACK + 4) == word(case.get('enabled', 1)), 'immutable enabled argument'
    assert reads[FLAGS] == 1 and reads[FACTOR0] == 1 and (reads[FACTOR1] == 1), 'captured status and multipliers'
    for address, (blob, guard) in panels.items():
        assert get(address - guard, guard + len(blob) + guard) == b'\xa5' * guard + blob + b'Z' * guard, ('unchanged panel', hex(address))
    for address, blob in pool_data.items():
        assert get(address, len(blob)) == blob, 'read-only resource pool'
    assert get(low, 16) == initial_stack[:16] and get(STACK + 8, 24) == initial_stack[-24:], 'stack canaries'
    state['observer'] = True
    uc.emu_start(READ_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    assert get(FPU_OUT, 48) == b''.join((word(v) for v in FPU_BITS)), 'FPU ABI preservation'
    assert get(FPU_OUT - 16, 16) == bytes(pattern(80, 211))[:16] and get(FPU_OUT + 48, 16) == bytes(pattern(80, 211))[-16:], 'FPU observer canaries'
    return hashlib.sha256(b''.join((word(v) for v in counts)) + word(wanted) + b''.join((word(v) for v in calls))).hexdigest()

def cases():
    for total in (0, -1, -0x80000000):
        yield dict(total=total)
    for trigger in range(256):
        yield dict(records=[(trigger, 1, 3, 0, -1, 7)])
    for category, state, trigger in itertools.product((0, 1, 2, 3, 4, 255), (0, 1, 2, 255), (0, 1, 2, 5, 6, 255)):
        yield dict(records=[(trigger, state, 0, category, 5, -3)])
    for flags, factor0, factor1 in itertools.product((0, 0x80000000, 0x7fffffff, 0xffffffff), (-0x80000000, -1, 0, 1, 0x7fffffff), (-1, 0, 3)):
        records = [(1, 1, i, 0, 0, 2) for i in range(9, 25)] + [(1, 1, i, 3, 0, 3) for i in range(4)]
        yield dict(records=records, flags=flags, factor0=factor0, factor1=factor1)
    for capacity, enabled, model in itertools.product((-0x80000000, -3, -1, 0, 1, 2, 3, 8, 0x7fffffff), (0, 1, -1), (-2, -1, 0, 7)):
        yield dict(records=[(1, 1, 0, 0, 0, 1), (2, 2, 0, 3, 3, -7), (0, 255, 0, 1, -1, 5)], capacity=capacity, enabled=enabled, model_index=model)
    for category, index in itertools.product((0, 1, 3), (0, 1, 7, 8, 15, 16, 35, 36, 72, 128, 251)):
        if category * 36 + index < 360:
            yield dict(records=[(1, 1, index, category, 0, 2)])
    for total in (255, 256, 257, 273):
        yield dict(total=total, records=[(i % 7, 1, i % 8, (0, 1, 3)[i % 3], i - 128, 1) for i in range(total)])
    for delay, amount in itertools.product((-32768, -1, 0, 1, 32767), repeat=2):
        for trigger in (0, 1, 2):
            yield dict(records=[(trigger, 1, 0, 0, delay, amount)])
    rng = random.Random(0x21c3c20261007)
    for _ in range(1000):
        records = []
        for _ in range(rng.randrange(61)):
            category = rng.choice((0, 1, 2, 3, 4, 255))
            maximum = min(255, 359 - category * 36) if category in (0, 1, 3) else 255
            records.append((rng.randrange(256), rng.choice((0, 1, 2, 255)), rng.randrange(maximum + 1), category, rng.randint(-32768, 32767), rng.randint(-32768, 32767)))
        yield dict(records=records, flags=rng.getrandbits(32), factor0=signed(rng.getrandbits(32)), factor1=signed(rng.getrandbits(32)), capacity=signed(rng.getrandbits(32)), enabled=rng.choice((0, 1, -1)))

def negative_controls(source_path, target, layout, helpers, original, dispatch, image, table, folder):
    source = source_path.read_text()
    ordinary = dict(records=[(1, 1, 0, 0, 0, 1)])
    variants = [
        ('destination-spill', 'selected = &output;', 'selected = (int **)output;', ordinary),
        ('disabled-default', '    func_80021C14((int **)&selected, &enabled, (unsigned char *)D_800AC998);', '', dict(total=0)),
        ('trigger-zero-sum', 'amount += arrival->delay;', 'amount += 0;', dict(records=[(0, 1, 0, 0, 4, 7)])),
        ('trigger-two-delay', 'counts[category][arrival->resourceIndex] < arrival->delay', 'counts[category][arrival->resourceIndex] < arrival->count', dict(records=[(1, 1, 0, 0, 0, 7), (2, 1, 0, 0, 5, 9)])),
        ('nonzero-state', 'D_800B9A78.arrivals[index].state != 0', 'D_800B9A78.arrivals[index].state == 1', dict(records=[(1, 2, 0, 0, 0, 1)])),
        ('category-filter', 'category == 0 || category == 1 || category == 3', 'category == 0 || category == 1 || category == 2 || category == 3', dict(records=[(1, 1, 0, 2, 0, 1)])),
        ('full-word-status', '(D_800B8F78.word00.value >> 31) != 0', 'D_800B8F78.word00.fields.flags00 < 0', dict(total=0, flags=2147483648)),
        ('captured-factor', 'counts[0][index] * D_800B14A4', 'counts[0][index] * *(volatile int *)&D_800B14A4', dict(records=[(1, 1, 17, 0, 0, 2)], factor1=3)),
        ('row-one-offset', 'counts[1][index]', 'counts[2][index]', dict(records=[(1, 1, 0, 1, 0, 1)])),
        ('threshold-equality', ' / 2 <=', ' / 2 <', ordinary),
        ('last-entry', 'index != 16', 'index != 15', dict(records=[(1, 1, 15, 1, 0, 1)])),
        ('max-aggregation', 'if (counts[category][arrival->resourceIndex] < amount)', 'if (1)', dict(records=[(0, 1, 0, 0, 5, 7), (0, 1, 0, 0, 0, 1)])),
        ('signed-delay', 'amount += arrival->delay;', 'amount += (unsigned short)arrival->delay;', dict(records=[(0, 1, 0, 0, -1, 1)])),
        ('row-alias', 'arrival->resourceIndex]', '(arrival->resourceIndex % 36)]', dict(records=[(1, 1, 36, 0, 0, 1)])),
    ]
    floor = re.sub('(func_8003941C\\([^;]+?\\)) / 2', '(\\1 >> 1)', source)
    variants.append(('division-rounding', source, floor, dict(records=[(1, 1, 0, 0, 0, -2)], capacity=-3)))
    results = []
    for name, old, new, case in variants:
        assert old in source and old != new, name
        mutated = re.sub('#include "([^"]+)"', lambda match: '#include "' + str(source_path.parent.joinpath(match[1]).resolve()) + '"', source.replace(old, new))
        path = folder / (name + '.c')
        path.write_text(mutated)
        proof, mutant_image, mutant_table = compile_candidate('mutant-' + name, path, target, layout)
        run(original, dispatch, helpers, case)
        run(image, table, helpers, case)
        try:
            run(mutant_image, mutant_table, helpers, case)
        except AssertionError as error:
            results.append(dict(name=name, rejected=True, reason=str(error), source_sha256=hashlib.sha256(mutated.encode()).hexdigest(), different_words=len(proof['different_words'])))
        else:
            raise AssertionError(('negative control escaped', name))
        assert comparison_input_hashes(path.relative_to(R).as_posix()) == proof['inputs_sha256'], 'Mutation input changed during execution'
    for name, replacement, field in (('integer-ABI', 0x24100000, 'restore'), ('FPU-ABI', 0x4480a000, 'nop')):
        mutant = bytearray(image)
        offsets = [i for i in range(0, len(image), 4) if (int.from_bytes(image[i:i + 4], 'big') & 0xffff0000 == 0x8fb00000 if field == 'restore' else image[i:i + 4] == bytes(4))]
        assert offsets, name
        position = offsets[-1] if field == 'restore' else offsets[0]
        mutant[position:position + 4] = word(replacement)
        try:
            run(bytes(mutant), table, helpers, ordinary)
        except AssertionError as error:
            results.append(dict(name=name, rejected=True, reason=str(error)))
        else:
            raise AssertionError(('negative binary control escaped', name))
    return results

def compile_candidate(name, source, target, layout):
    """Compare complete natural code and generated switch data without owning either."""
    source = Path(source)
    if not source.is_absolute():
        source = R / source
    relative = source.relative_to(R).as_posix()
    directory = BUILD / name
    directory.mkdir(parents=True, exist_ok=True)
    inputs = comparison_input_hashes(relative)
    profile = profile_for_source(relative)
    identity = installed_identity(profile['version'])
    raw = directory / 'raw.o'
    compile_source(relative, raw)
    sections, symbols = elf_sections_and_symbols(raw)
    function = symbols['func_80021C3C']
    live_size = function['size']
    assert function['type'] == 2 and function['value'] == 0 and (live_size > 0), 'single natural function extent'
    assert len([symbol for symbol in symbols.values() if symbol['type'] == 2 and symbol.get('index') != 0]) == 1, 'extra defined procedures'
    for section, record in sections.items():
        if record['size'] and record['flags'] & 2:
            assert section in ('.text', '.rodata', '.reginfo', '.MIPS.abiflags'), ('unowned candidate allocation', section)
    image = trim(raw.read_bytes(), '.text', live_size)
    if sections.get('.rodata', {}).get('size', 0):
        image = trim(image, '.rodata', 24)
    obj = directory / 'compiled.o'
    obj.write_bytes(image)
    undefined = {line.split()[-1] for line in subprocess.check_output(['mips-linux-gnu-nm', '-u', str(obj)], text=True).splitlines()}
    script = directory / 'candidate.ld'
    script.write_text(external_assignments(undefined, layout.addresses) + 'SECTIONS { .text 0x80021C3C : SUBALIGN(4) { *(.text) } .rodata 0x80091A08 : SUBALIGN(4) { *(.rodata) } /DISCARD/ : { *(.reginfo .MIPS.abiflags) } }\n')
    elf = directory / 'compiled.elf'
    subprocess.run(['mips-linux-gnu-ld', '-EB', '-T', str(script), '-e', 'func_80021C3C', '-o', str(elf), str(obj)], check=True)
    linked, symbols = elf_sections_and_symbols(elf)
    assert symbols['func_80021C3C']['value'] == START and symbols['func_80021C3C']['size'] == live_size
    actual = linked['.text']['bytes']
    table = linked.get('.rodata', {}).get('bytes', b'')
    expected = target[0x2283c:0x22c44]
    wanted = target[0x92608:0x92620]

    def differences(a, b, address):
        return [dict(vram=hex(address + i), expected=b[i:i + 4].hex(), actual=a[i:i + 4].hex()) for i in range(0, max(len(a), len(b)), 4) if a[i:i + 4] != b[i:i + 4]]
    report = dict(source=relative, compiler_profile=profile, toolchain_identity=identity, inputs_sha256=inputs, expected_size=len(expected), actual_size=len(actual), matches=actual == expected and table == wanted, different_words=differences(actual, expected, START), matching_source_claim=False, generated_dispatch=dict(vram='0x80091A08', expected_size=24, actual_size=len(table), matches=table == wanted, different_words=differences(table, wanted, 0x80091a08)), expected_alignment=dict(vram='0x80022044', size=12, bytes=target[0x22c44:0x22c50].hex(), included_in_function=False), text_sha256=hashlib.sha256(actual).hexdigest(), dispatch_sha256=hashlib.sha256(table).hexdigest())
    layout.verify()
    assert comparison_input_hashes(relative) == inputs, 'Candidate inputs changed during compilation'
    (directory / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    return (report, actual, table)

def compare_candidate_block(name, source, target, layout):
    """Expose the compound excluded comparison to the runtime candidate runner."""
    return compile_candidate(name, source, target, layout)[0]

def layout_probes():
    """Check the C layouts against retail offsets and canonical Ghidra type evidence."""
    layouts = {'SceneResourceWord00Fields': (4,
                                   2,
                                   (('flags00', 0, 1),
                                    ('unknown01', 1, 1),
                                    ('value02', 2, 2))),
     'SceneResourceWord00': (4, 4, (('value', 0, 4), ('fields', 0, 4))),
     'SceneResourceState': (416,
                            4,
                            (('word00', 0, 4),
                             ('value04', 4, 2),
                             ('unknown06', 6, 2),
                             ('unknown08', 8, 4),
                             ('unknown0C', 12, 4),
                             ('resourceLimits', 16, 200),
                             ('secondaryLimits', 216, 200))),
     'ActorResource68Internal': (104,
                                 4,
                                 (('unknown00', 0, 6),
                                  ('flags06', 6, 2),
                                  ('speed', 8, 4),
                                  ('unknown0C', 12, 4),
                                  ('step10', 16, 2),
                                  ('unknown12', 18, 6),
                                  ('current18', 24, 2),
                                  ('rate1A', 26, 2),
                                  ('unknown1C', 28, 12),
                                  ('firstAnimation28', 40, 4),
                                  ('unknown2C', 44, 52),
                                  ('updateTime60', 96, 4),
                                  ('arrivalDelay', 100, 4))),
     'ActorAnimation': (16,
                        2,
                        (('objectIndex', 0, 2),
                         ('field02', 2, 2),
                         ('track', 4, 2),
                         ('frameIndex', 6, 2),
                         ('field08', 8, 2),
                         ('loopIndex', 10, 2),
                         ('frameDuration', 12, 2),
                         ('sound', 14, 1),
                         ('soundMode', 15, 1))),
     'SceneArrival': (12,
                      2,
                      (('trigger', 0, 1),
                       ('state', 1, 1),
                       ('resourceIndex', 2, 1),
                       ('category', 3, 1),
                       ('delay', 4, 2),
                       ('count', 6, 2),
                       ('x', 8, 2),
                       ('y', 10, 2))),
     'SceneDefinition': (3348, 4, (('arrivals', 68, 3072), ('arrivalCount', 3272, 4)))}
    expected = {}
    declarations = []
    for name, (size, alignment, fields) in layouts.items():
        expected['sizeof(' + name + ')'] = size
        declarations.append('struct Align' + name + ' { char prefix; ' + name + ' value; };')
        expected['OFFSET(struct Align' + name + ',value)'] = alignment
        for field, offset, width in fields:
            expected['OFFSET(' + name + ',' + field + ')'] = offset
            expected['sizeof(((' + name + '*)0)->' + field + ')'] = width
    source = BUILD / 'layout.c'
    obj = BUILD / 'layout.o'
    header = '\n'.join(('#include "' + str(R / 'include' / name) + '"' for name in ('scene_definition.h', 'actor_resource_internal.h')))
    source.write_text(header + '\n#define OFFSET(T,F) ((unsigned int)&((T*)0)->F)\n' + '\n'.join(declarations) + '\nunsigned int selection_layout[] = { ' + ', '.join(expected) + ' };\n')
    relative = source.relative_to(R).as_posix()
    inputs = comparison_input_hashes(relative)
    compile_source(relative, obj)
    sections, symbols = elf_sections_and_symbols(obj)
    symbol = symbols['selection_layout']
    section = next((record for record in sections.values() if record['index'] == symbol['index']))
    actual = section['bytes'][symbol['value']:symbol['value'] + symbol['size']]
    assert len(actual) == len(expected) * 4, 'layout probe extent'
    values = {expression: int.from_bytes(actual[i * 4:i * 4 + 4], 'big') for i, expression in enumerate(expected)}
    assert values == expected, ('C layout disagreement', values, expected)
    assert comparison_input_hashes(relative) == inputs, 'Layout inputs changed'
    return dict(count=len(expected), values=values, inputs_sha256=inputs)

def main(source):
    target = (R / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    BUILD.mkdir(parents=True, exist_ok=True)
    probes = layout_probes()
    helpers = []
    proofs = {}
    for name in SUPPORT:
        _, path, first, end = next((block for block in MATCHING_BLOCKS if block[0] == name))
        proof = compare_block(name, path, first, first - 0x80000000 + 3072, end - 0x80000000 + 3072, target, 'scene-selection-audit', layout)
        assert proof['matches'], ('support mismatch', name)
        proofs[name] = proof
        helpers.append((first, (BUILD / name / (name + '.bin')).read_bytes()))
    storage = compare_unit(DATA_SOURCE, source_sections(DATA_SOURCE), target, layout)
    candidate, image, table = compile_candidate('candidate', source, target, layout)
    inputs = dict(candidate['inputs_sha256'])
    for proof in (*proofs.values(), storage, probes):
        inputs.update(proof['inputs_sha256'])
    for relative in ('tools/check_scene_resource_selection.py', 'tools/check_actor_group_path.py', 'tools/check_movie_storage.py', 'tools/check_boss_trigger.py', 'tools/compare_startup.py', 'tools/compare_runtime.py', 'tools/compare_data.py', 'tools/trim_padding.py', 'tools/rom.py'):
        inputs[relative] = hashlib.sha256((R / relative).read_bytes()).hexdigest()
    artifact_hashes = {str(path.relative_to(R)): hashlib.sha256(path.read_bytes()).hexdigest() for path in (BUILD / 'candidate/compiled.elf', *(BUILD / name / (name + '.elf') for name in SUPPORT))}
    original = target[0x2283c:0x22c44]
    dispatch = target[0x92608:0x92620]
    digest = hashlib.sha256()
    case_digest = hashlib.sha256()
    count = 0
    for case in cases():
        expected = run(original, dispatch, helpers, case)
        actual = run(image, table, helpers, case)
        assert actual == expected, case
        digest.update(expected.encode())
        case_digest.update(json.dumps(case, sort_keys=True).encode())
        count += 1
    source_path = R / source
    with tempfile.TemporaryDirectory(prefix='mutations-', dir=BUILD) as directory:
        controls = negative_controls(source_path, target, layout, helpers, original, dispatch, image, table, Path(directory))
    layout.verify()
    assert all((hashlib.sha256((R / path).read_bytes()).hexdigest() == value for path, value in inputs.items())), 'Input changed during audit'
    assert all((hashlib.sha256((R / path).read_bytes()).hexdigest() == value for path, value in artifact_hashes.items())), 'Compiled artifact changed during audit'
    report = dict(paired_cases=count, case_corpus_sha256=case_digest.hexdigest(), outcomes_sha256=digest.hexdigest(), matching_source_claim=False, versions={name: version(name) for name in ('unicorn', 'capstone', 'pyelftools')}, candidate_comparison=candidate, layout_probes=probes, support_comparisons=proofs, scene_storage_comparison=storage, rejected_mutations=controls, inputs_sha256=inputs, artifacts_sha256=artifact_hashes)
    (BUILD / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Passed scene selection:', count, 'paired cases,', len(controls), 'rejected mutations,', probes['count'], 'layout probes')
    print('Complete candidate comparison:', candidate['actual_size'], 'compiled bytes /', candidate['expected_size'], 'retail bytes;', len(candidate['different_words']), 'differing code words;', len(candidate['generated_dispatch']['different_words']), 'differing dispatch words')
    print('Report:', (BUILD / 'report.json').relative_to(R))
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', default=DEFAULT_SOURCE, help='excluded C candidate relative to the repository')
    main(parser.parse_args().source)
