"""Check excluded tube candidates against retail with real matched CPU helpers.

Independent vertex, packet, matrix and allocator oracles cover finite cases.
The check grants no instruction ownership and does not execute the RSP/RDP.
"""
import contextlib
import hashlib
import io
import itertools
import json
import math
import struct
from pathlib import Path
from importlib.metadata import version

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UcError
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL
from check_early_local_effects import s32, trig
from compare_data import compare_unit, comparison_directory
from compare_runtime import MATCHING_BLOCKS, CANDIDATE_BLOCKS, validate_candidate_ranges
from compare_startup import compare_block, SymbolLayoutSnapshot
from manifest import load_manifest
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate

FAMILY = 'early-render-tube-execution'
OUTPUT = ROOT / 'build' / FAMILY
POOL, COMMANDS, STACK, MATRICES = 0x800CDBD0, 0x80200000, 0x80300000, 0x80126B90
CAMERA, VIEW, ANGLE, DEPTH, PALETTE = 0x800C8BD8, 0x800CD250, 0x800730D8, 0x800730DC, 0x800730E0
CURSOR, ALLOCATOR, FRAME_BASE, MODE = 0x80123AE4, 0x80126B84, 0x80123B20, 0x8007D5D8
ALPHA, FLAG, SLOT, HALF, DL_CURSOR = 0x80123AE8, 0x800C85B8, 0x8007D6A8, 0x8007D910, 0x80138254
SUPPORT = ('graphics_mode_dispatch', 'graphics_modes', 'graphics_pool', 'debug_noop',
           'object_recovery_fixed_trig', 'short_sine', 'short_cosine', 'frame_transform',
           'renderer_matrix_submit', 'fixed_geometry_setup', 'fixed_geometry', 'fixed_math')
NAMES = ('early_render_tube', 'early_render_tube_wide')
IDENTITY = (32767, 0, 0, 0, 32767, 0, 0, 0, 32767)
SKEW = (32767, 200, -100, 400, 32767, 50, -60, 75, 32767)


def fixed_sine(angle, table):
    angle &= 4095
    value = table[1023 - (angle & 1023)] if angle & 1024 else table[angle & 1023]
    return -value if angle & 2048 else value


def oracle(name, case, table, colors):
    base, frame, angle, depth, mode, camera, matrix, slot, half = case
    wide = name == 'early_render_tube_wide'
    segments = 16 if wide else 8
    count = segments * 64
    active = base - frame <= 9800
    pool = bytearray(b'\xA5' * (22000 * 16))
    if active:
        for ring in range(16):
            z0 = 100 + ring * 2000
            z1 = z0 + 2000
            for segment in range(segments):
                phase = segment * (4096 // segments)
                next_phase = phase + 4096 // segments
                x0 = trig(phase + 1024, table) * 1000 >> 12
                y0 = trig(phase, table) * 1000 >> 12
                x1 = trig(next_phase + 1024, table) * 1000 >> 12
                y1 = trig(next_phase, table) * 1000 >> 12
                positions = ((x0, y0, z0), (x1, y1, z0), (x1, y1, z1), (x0, y0, z1))
                indices = (ring + segment, ring + segment + 1, ring + segment + 2, ring + segment + 1)
                for corner, (position, color) in enumerate(zip(positions, indices)):
                    offset = (base + (ring * segments + segment) * 4 + corner) * 16
                    pool[offset:offset + 6] = struct.pack('>3h', *position)
                    pool[offset + 12:offset + 16] = bytes([v & 255 for v in colors[(color & 7) * 3:(color & 7) * 3 + 3]] + [128])
    packets = [(0x01020040, MATRICES - 0x80000000 + (slot * 2 + half) * 64)]
    if mode != 1:
        if mode == 18:
            packets.append((0xB9000002, 0))
        packets.extend(((0xE7000000, 0), (0xB6000000, 0x60000), (0xB7000000, 0x205),
                        (0xFCFFFFFF, 0xFFFE793C), (0xB900031D, 0x005049D8)))
    packets.append((0xB6000000, 0x2000))
    if active:
        for i in range(segments * 16):
            packets.extend(((0x0400103F, POOL + (base + i * 4) * 16), (0xB1020406, 0x00020600)))
        packets.append((0xB7000000, 0x2000))
    commands = b''.join(word(a) + word(b) for a, b in packets)
    relative = [s32(-v) >> 1 for v in camera]
    if not wide:
        relative[2] = s32(depth - camera[2]) >> 1
    projected = [max(-32000, min(32000, s32(sum(s32(relative[i] * matrix[row * 3 + i]) >> 15 for i in range(3))))) for row in range(3)]
    cosine, sine = fixed_sine(angle + 1024, table), fixed_sine(angle, table)
    rotation = tuple(s32(32767 * v) >> 15 for v in (cosine, -sine, 0, sine, cosine, 0, 0, 0, 32767))
    packed = []
    for part in (0, 1):
        for column in range(3):
            packed.extend([(rotation[row * 3 + column] >> 15 if part == 0 else rotation[row * 3 + column] << 1) & 65535 for row in range(3)] + [0])
        packed.extend([v & 65535 for v in projected] + [1] if part == 0 else [0] * 4)
    matrices = bytearray(b'{' * 32000)
    offset = (slot * 2 + half) * 64
    matrices[offset:offset + 64] = b''.join(struct.pack('>H', v) for v in packed)
    commits = [(i + 1) * segments * 4 for i in range(16)] if active else []
    next_depth = s32(depth + 1000)
    state = {ANGLE: (angle + 16) & 0xFFFFFFFF if wide else angle & 0xFFFFFFFF,
             DEPTH: depth & 0xFFFFFFFF if wide else 0 if next_depth > 32000 else next_depth & 0xFFFFFFFF,
             CURSOR: base + count if active else 0xFFFFFFFF,
             ALLOCATOR: base + sum(commits), FRAME_BASE: frame, MODE: 1,
             ALPHA: 37 if mode == 1 else 160, FLAG: 1 if mode == 1 else 0,
             SLOT: slot + 1, HALF: half, DL_CURSOR: COMMANDS + len(commands)}
    return dict(pool=bytes(pool), commands=commands, matrices=bytes(matrices), state=state,
                commits=commits, warning=not active, projected=projected)


def execute(name, code, case, evidence):
    base, frame, angle, depth, mode, camera, matrix, slot, half = case
    entry = evidence['targets'][name][0]
    expected = oracle(name, case, evidence['table'], evidence['colors'])
    uc, write, _ = machine([(entry, code)], evidence['support'])
    initial = {ANGLE: angle, DEPTH: depth, CURSOR: 137, ALLOCATOR: base, FRAME_BASE: frame,
               MODE: mode, ALPHA: 37, FLAG: 1, SLOT: slot, HALF: half, DL_CURSOR: COMMANDS}
    for a, v in initial.items():
        write(a, word(v))
    write(POOL, b'\xA5' * (22000 * 16))
    write(COMMANDS - 16, b'\xC7' * 16 + b'i' * 8192 + b'\xD8' * 16)
    write(MATRICES, b'{' * 32000)
    camera_bytes = b'e' * 28 + b''.join(word(v) for v in camera)
    view_bytes = b''.join(word(v) for v in matrix)
    write(CAMERA, camera_bytes)
    write(VIEW, view_bytes)
    stack_start = STACK - 1056
    stack = bytes((i * 29 + base) & 255 for i in range(1120))
    write(stack_start, stack)
    writable = [(STACK - 1024, STACK), (POOL, POOL + 22000 * 16),
                (COMMANDS, COMMANDS + 8192), (MATRICES, MATRICES + 32000)]
    mutable = {ANGLE, DEPTH, CURSOR, ALLOCATOR, MODE, ALPHA, FLAG, SLOT, DL_CURSOR}
    writable.extend((a, a + 4) for a in mutable)
    readable = writable + [(a, a + 4) for a in initial] + [(CAMERA, CAMERA + 40), (VIEW, VIEW + 36)]
    readable.extend((a, a + len(b)) for a, b in evidence['owned'])
    executable = [(entry, entry + len(code))] + evidence['code_ranges']
    saved = {getattr(regs, 'UC_MIPS_REG_' + key): uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + key))
             for key in ('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP')}
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xABCD1234)
    touched, commits, warnings, phases, projected = set(), [], [], [], []
    steps = [0]

    def memory_write(uc, access, address, size, value, user):
        address |= 0x80000000
        assert any(a <= address and address + size <= b for a, b in writable), ('Write bounds', hex(address), size, name, case)
        if stack_start <= address < STACK:
            touched.update(range(address, address + size))

    def memory_read(uc, access, address, size, value, user):
        address |= 0x80000000
        assert any(a <= address and address + size <= b for a, b in readable), ('Read bounds', hex(address), size, name, case)

    def instruction(uc, address, size, user):
        steps[0] += 1
        assert address == SENTINEL or any(a <= address and address + size <= b for a, b in executable), ('Escaped code', hex(address), name, case)
        if address == 0x80047094:
            commits.append(uc.reg_read(regs.UC_MIPS_REG_A0))
        elif address == 0x80048DC0:
            warnings.append(uc.reg_read(regs.UC_MIPS_REG_A0))
        elif address in (0x8003CC58, 0x8003CC88):
            phases.append((address, uc.reg_read(regs.UC_MIPS_REG_A0)))
        elif address == 0x80047D88:
            pointer = uc.reg_read(regs.UC_MIPS_REG_A0)
            projected.append(list(struct.unpack('>3i', bytes(uc.mem_read((pointer + 40) & 0x1FFFFFFF, 12)))))
    uc.hook_add(UC_HOOK_MEM_WRITE, memory_write)
    uc.hook_add(UC_HOOK_MEM_READ, memory_read)
    uc.hook_add(UC_HOOK_CODE, instruction)
    uc.emu_start(entry, 0, count=100000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, ('Return limit', name, case)
    assert uc.reg_read(regs.UC_MIPS_REG_SP) == STACK and uc.reg_read(regs.UC_MIPS_REG_GP) == 0xABCD1234
    assert all(uc.reg_read(a) == b for a, b in saved.items()), ('Saved registers', name, case)
    read = lambda a, size: bytes(uc.mem_read(a & 0x1FFFFFFF, size))
    actual_stack = read(stack_start, len(stack))
    assert all(v == stack[i] for i, v in enumerate(actual_stack) if stack_start + i not in touched), ('Stack canary', name, case)
    assert read(POOL, 22000 * 16) == expected['pool'], ('Vertex oracle', name, case)
    assert read(MATRICES, 32000) == expected['matrices'], ('SDK matrix oracle', name, case)
    commands = expected['commands']
    assert read(COMMANDS - 16, 16 + 8192 + 16) == b'\xC7' * 16 + commands + b'i' * (8192 - len(commands)) + b'\xD8' * 16, ('Command oracle', name, case)
    assert all(read(a, 4) == word(v) for a, v in expected['state'].items()), ('State oracle', name, case)
    assert read(CAMERA, 40) == camera_bytes and read(VIEW, 36) == view_bytes
    for a, b in evidence['owned']:
        if a != ANGLE:
            assert read(a, len(b)) == b, ('Support data', hex(a), name, case)
    assert commits == expected['commits'] and len(warnings) == int(expected['warning']), ('Call oracle', commits, warnings, name, case)
    assert projected == [expected['projected']], ('Projected position trace', name, case)
    segments = 16 if name == 'early_render_tube_wide' else 8
    expected_phases = []
    if not expected['warning']:
        for _ in range(16):
            for phase in range(0, 4096, 4096 // segments):
                expected_phases.extend(((0x8003CC88, phase), (0x8003CC58, phase),
                                        (0x8003CC88, phase + 4096 // segments), (0x8003CC58, phase + 4096 // segments)))
    assert phases == expected_phases, ('Trigonometric call oracle', name, case)
    digest = hashlib.sha256(expected['pool'] + commands + expected['matrices'])
    digest.update(json.dumps([expected['state'], commits, phases], sort_keys=True).encode())
    return digest.hexdigest(), steps[0]


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    records = tuple(row for row in CANDIDATE_BLOCKS if row[0] in NAMES)
    assert len(records) == len(NAMES)
    validate_candidate_ranges(records, load_manifest())
    support, owned, proofs, targets, comparisons, code_ranges = [], [], {}, {}, {}, []
    for name in SUPPORT:
        _, source, start, end = next(row for row in MATCHING_BLOCKS if row[0] == name)
        with contextlib.redirect_stdout(io.StringIO()):
            q = compare_block(name, source, start, start - 0x80000000 + 0xC00, end - 0x80000000 + 0xC00, target, FAMILY + '-support', layout)
        assert q['matches'] and not q['different_words'], name
        work = ROOT / 'build' / (FAMILY + '-support') / name
        code = (work / (name + '.bin')).read_bytes()
        support.append((start, code))
        code_ranges.append((start, start + len(code)))
        sections, _ = elf_sections_and_symbols(work / (name + '.elf'))
        for section in source_sections(source):
            if section['rom'] is not None:
                data = sections[section['section']]['bytes']
                assert data == target[section['rom']:section['rom'] + section['size']]
                owned.append((section['vram'], data))
                support.append((section['vram'], data))
        proofs[name] = q
    data_source = 'src/game/early_render_tube_data.c'
    data_records = source_sections(data_source)
    data_proof = compare_unit(data_source, data_records, target, layout)
    sections, _ = elf_sections_and_symbols(comparison_directory(data_source) / 'compiled.elf')
    for section in data_records:
        data = sections[section['section']]['bytes']
        owned.append((section['vram'], data))
        support.append((section['vram'], data))
    state_data = next(b for a, b in owned if a == ANGLE)
    assert len(state_data) == 104
    colors = struct.unpack('>24i', state_data[8:])
    table = list(struct.unpack('>1024h', next(b for a, b in owned if a == 0x8008DBB0)))
    assert table == [math.floor(32767 * math.sin(i * math.pi / 2046)) for i in range(1024)]
    for name, source, start, end in records:
        offset = start - 0x80000000 + 0xC00
        with contextlib.redirect_stdout(io.StringIO()):
            q = compare_block(name, source, start, offset, offset + end - start, target, FAMILY + '-candidates', layout)
        work = ROOT / 'build' / (FAMILY + '-candidates') / name
        raw, symbols = elf_sections_and_symbols(work / (name + '.raw.o'))
        size = symbols[f'func_{start:08X}']['size']
        assert symbols[f'func_{start:08X}']['value'] == 0 and not any(raw['.text']['bytes'][size:])
        assert all(key in ('.text', '.reginfo', '.MIPS.abiflags') or not (section['flags'] & 2 and section['size']) for key, section in raw.items()), 'Unexpected candidate data'
        linked, _ = elf_sections_and_symbols(work / (name + '.elf'))
        code = linked['.text']['bytes'][:size]
        targets[name] = (start, target[offset:offset + end - start], code)
        q['natural_bytes'] = size
        q['frame'] = -int.from_bytes(code[2:4], 'big', signed=True)
        assert code[:2] == bytes.fromhex('27bd')
        comparisons[name] = q
        print(name, size, '/', end - start, 'bytes;', len(q['different_words']), 'differing words', flush=True)
    evidence = dict(support=support, owned=owned, targets=targets, table=table, colors=colors, code_ranges=code_ranges)
    cases = []
    for allocation, angle, mode in itertools.product(((0, 0), (7, 0), (9800, 0), (9801, 0), (13296, 13296)), (0, 1023, 4095, -1), (1, 18)):
        base, frame = allocation
        for depth in (0, 31000, 31001, 32000):
            cases.append((base, frame, angle, depth, mode, (401, -305, 71) if mode == 18 else (0, 0, 0), SKEW if angle == -1 else IDENTITY, 7, angle & 1))
    digest = hashlib.sha256()
    steps, counts = 0, {name: 0 for name in NAMES}
    for name in NAMES:
        for case in cases:
            a, count_a = execute(name, targets[name][1], case, evidence)
            b, count_b = execute(name, targets[name][2], case, evidence)
            assert a == b, ('Retail pair', name, case)
            counts[name] += 1
            steps += count_a + count_b
            digest.update(json.dumps([name, case, a]).encode())
        print('Guarded tube pairs:', name, counts[name], flush=True)
    controls = []
    for name, source, start, end in records:
        text = (ROOT / source).read_text().replace('../../include/', str(ROOT / 'include') + '/')
        mutations = (('radius', '* 1000 >> 12', '* 1001 >> 12'), ('palette', 'color & 7', 'color & 3'),
                     ('alpha', '= 128;', '= 127;'), ('quad_packet', '0xB1020406', '0xB1020604'),
                     ('cumulative_commit', 'D_80123AE4 - firstVertex', 'D_80123AE4 - firstVertex + 1'),
                     ('bands', 'ring < 16', 'ring < 15'))
        if name == 'early_render_tube':
            mutations += (('depth_wrap', 'D_800730DC > 32000', 'D_800730DC >= 32000'),)
        else:
            mutations += (('rotation_step', 'D_800730D8 += 16', 'D_800730D8 += 17'),)
        case = (7, 0, 1023, 31000, 18, (401, -305, 71), SKEW, 7, 1)
        for label, old, new in mutations:
            assert old in text, (name, label)
            path = OUTPUT / 'control-sources' / (name + '-' + label + '.c')
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text.replace(old, new))
            with contextlib.redirect_stdout(io.StringIO()):
                compare_block(name + '-' + label, path.relative_to(ROOT).as_posix(), start, start - 0x80000000 + 0xC00, end - 0x80000000 + 0xC00, target, FAMILY + '-controls', layout)
            work = ROOT / 'build' / (FAMILY + '-controls') / (name + '-' + label)
            sections, symbols = elf_sections_and_symbols(work / (name + '-' + label + '.elf'))
            code = sections['.text']['bytes'][:symbols[f'func_{start:08X}']['size']]
            try:
                execute(name, code, case, evidence)
            except (AssertionError, UcError) as error:
                controls.append(dict(name=name, mutation=label, detected=str(error)[:250]))
            else:
                raise AssertionError(('Mutation escaped', name, label))
    assert len(controls) == 14
    layout.verify()
    for report in [*proofs.values(), *comparisons.values(), data_proof]:
        for path, sha in report['inputs_sha256'].items():
            assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == sha, path
    guard_files = (Path(__file__).relative_to(ROOT).as_posix(), 'tools/check_actor_group_path.py', 'tools/check_early_local_effects.py')
    receipt = dict(paired_cases=sum(counts.values()), counts=counts, instructions=steps, controls=controls,
                   abi_stubs=0, source_ownership_added=0, trace_sha256=digest.hexdigest(), comparisons=comparisons,
                   real_support=proofs, data_proof=data_proof, emulator_version=version('unicorn'),
                   guard_inputs_sha256={p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in guard_files},
                   limits=['Finite CPU fixtures; RSP/RDP rendering and full gameplay are not executed.',
                           'Both complete instruction comparisons remain nonmatching and excluded from ROM ownership.',
                           'Stack bounds and saved integer registers are checked; original local declarations remain unproved.',
                           'Matrix overflow and out-of-pool allocator indices are excluded; allocator warning uses real matched code.'])
    OUTPUT.mkdir(parents=True, exist_ok=True)
    (OUTPUT / 'report.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('Tube guard:', sum(counts.values()), 'paired cases;', len(controls), 'rejected controls; no new instruction ownership', flush=True)


if __name__ == '__main__':
    main()
