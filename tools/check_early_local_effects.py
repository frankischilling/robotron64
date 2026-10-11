"""Execute two excluded early render helpers with complete matched support units.

The independent geometry and matrix oracles cover finite CPU fixtures. This
guard does not claim original source storage, instruction ownership, or RDP
rendering. Real helper code executes without substituted ABI stubs.
"""
from pathlib import Path
import contextlib
import hashlib
import io
import itertools
import json
import math
import struct
from importlib.metadata import version
from unicorn import Uc, UcError, UC_ARCH_MIPS, UC_MODE_MIPS32, UC_MODE_BIG_ENDIAN, UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as reg
from capstone import Cs, CS_ARCH_MIPS, CS_MODE_MIPS32, CS_MODE_BIG_ENDIAN
from rom import ROOT, validate
from toolchain import install
from compare_runtime import MATCHING_BLOCKS, CANDIDATE_BLOCKS, validate_candidate_ranges
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from manifest import load_manifest
FAMILY = 'early-local-effect-execution'
OUTPUT = ROOT / 'build' / FAMILY
SUPPORT = ('graphics_mode_dispatch', 'graphics_modes', 'graphics_pool', 'debug_noop', 'palette', 'object_recovery_fixed_trig', 'short_sine', 'short_cosine', 'frame_transform', 'renderer_matrix_submit')
NAMES = ('history_prism', 'ground_disc')

def u32(v):
    return v & 0xffffffff

def s32(v):
    return (v & 0x7fffffff) - (v & 0x80000000)

def w(v):
    return struct.pack('>I', u32(v))

def trunc(v, d):
    return abs(v) // d * (-1 if v < 0 else 1)

def trig(angle, table):
    a = angle & 4095
    v = table[1023 - (a & 1023)] if a & 1024 else table[a & 1023]
    return trunc(-v if a & 2048 else v, 8)
VERT = 0x800cdbd0
COMMAND = 0x80200000
STACK = 0x803f0000
BOOT = 0x80000200
RETURN = 0x80000300
STOP = 0x80000080
STATE = (0x80123ae4, 0x80126b84, 0x8007d5d8, 0x800c85b8, 0x80123ae8, 0x8007d6a8, 0x8007d910, 0x80123b14, 0x80123b18)
calls = {0x8004729c, 0x80047048, 0x80047094, 0x80048dc0, 0x8003c14c, 0x8003cc88, 0x8003cc58, 0x8005fc20, 0x8005fbb0, 0x8004d4b4, 0x80047d88}

def execute(name, code, case, evidence, assert_model=True):
    support, owned, targets, table = (evidence[key] for key in ['support', 'owned', 'targets', 'table'])
    base, frame, mode, args, camera, matrix, rgb, matrix_slot, matrix_half = case
    entry = targets[name][0]
    uc = Uc(UC_ARCH_MIPS, UC_MODE_MIPS32 | UC_MODE_BIG_ENDIAN)
    uc.mem_map(0, 0x400000)
    uc.mem_map(0x80000000, 0x400000)

    def write(address, data):
        address &= 0x1fffffff
        uc.mem_write(address, data)
        uc.mem_write(address | 0x80000000, data)

    def read(address, size):
        return bytes(uc.mem_read(address & 0x1fffffff, size))

    def word(address, value):
        write(address, w(value))

    def load(address):
        return int.from_bytes(read(address, 4), 'big')

    def vector(address):
        return struct.unpack('>3i', read(address, 12))

    def mirror(uc, access, address, size, value, user):
        uc.mem_write(address ^ 0x80000000, (value & (1 << size * 8) - 1).to_bytes(size, 'big'))
    uc.hook_add(UC_HOOK_MEM_WRITE, mirror)
    for address, data in support + [(entry, code)]:
        write(address, data)
    fpu = [0x3f800101 + i * 257 for i in range(12)]
    boot = b''.join((w(v) for v in [0x3c08802a, 0x35080000] + [0xc5000000 | i + 20 << 16 | i * 4 for i in range(12)] + [0x3c088000, 0x35080000 | entry & 65535, 0x1000008, 0]))
    finish = b''.join((w(v) for v in [0x3c08802a, 0x35080100] + [0xe5000000 | i + 20 << 16 | i * 4 for i in range(12)] + [0x3c088000, 0x35080080, 0x1000008, 0]))
    write(BOOT, boot)
    write(RETURN, finish)
    write(0x802a0000, b''.join((w(v) for v in fpu)))
    write(0x802a0100, b'm' * 48)
    write(VERT, b'\xa5' * (22000 * 16))
    write(COMMAND - 16, b'\xc7' * 16)
    write(COMMAND, b'i' * 4096)
    write(COMMAND + 4096, b'\xd8' * 16)
    write(0x80126b90, b'{' * 32000)
    values = {0x80138254: COMMAND, 0x80126b84: base, 0x80123b20: frame, 0x80123ae4: 137, 0x8007d5d8: mode, 0x800c85b8: 1, 0x80123ae8: 37, 0x8007d6a8: matrix_slot, 0x8007d910: matrix_half, 0x80123b14: 5, 0x80123b18: 9, 0x80123b00: 0, 0x8007cd8c: 2, 0x8007cd90: 4, 0x80138270: rgb[0], 0x80138274: rgb[1], 0x8013826c: rgb[2]}
    for address, value in values.items():
        word(address, value)
    write(0x8007bb38, bytes((v & 255 for v in rgb)) + b'-')
    write(0x800c8bd8, b'e' * 40)
    write(0x800c8bd8 + 28, b''.join((w(v) for v in camera)))
    write(0x800cd250, b''.join((w(v) for v in matrix)))
    initial_palette = read(0x8007bb34, 1024)
    initial_camera = read(0x800c8bd8, 40)
    initial_matrix = read(0x800cd250, 36)
    stack_start = STACK - 1056
    stack = bytes((i * 29 + base & 255 for i in range(1120)))
    write(stack_start, stack)
    touched = set()
    allowed = [(STACK - 1024, STACK + 32), (VERT, VERT + 22000 * 16), (COMMAND, COMMAND + 4096), (0x80126b90, 0x80126b90 + 32000), (0x802a0100, 0x802a0130)]
    mutable = {0x80138254, 0x80126b84, 0x80123ae4, 0x8007d5d8, 0x800c85b8, 0x80123ae8, 0x8007d6a8}
    allowed += [(address, address + 4) for address in mutable]
    reads = allowed + [(address, address + 4) for address in values] + [(0x8007bb34, 0x8007bb34 + 1024), (0x800c8bd8, 0x800c8bd8 + 40), (0x800cd250, 0x800cd250 + 36), (0x802a0000, 0x802a0030)] + [(address, address + len(data)) for address, data in owned]
    executable = [(entry, entry + len(code)), (BOOT, BOOT + len(boot)), (RETURN, RETURN + len(finish))] + [(address, address + len(data)) for address, data in support if address not in {a for a, _ in owned}]
    trace = []
    instructions = [0]
    done = [False]

    def memory_write(uc, access, address, size, value, user):
        address |= 0x80000000
        assert any((a <= address and address + size <= b for a, b in allowed)), ('Write guard', hex(address), size, name, case)
        if stack_start <= address < STACK + 32:
            touched.update(range(address, address + size))

    def memory_read(uc, access, address, size, value, user):
        address |= 0x80000000
        assert any((a <= address and address + size <= b for a, b in reads)), ('Read guard', hex(address), size, name, case)

    def hook(uc, address, size, user):
        address |= 0x80000000
        instructions[0] += 1
        if address == STOP:
            done[0] = True
            uc.emu_stop()
            return
        assert any((a <= address and address + size <= b for a, b in executable)), ('Escaped code', hex(address), name, case)
        if address not in calls:
            return
        a = [uc.reg_read(r) & 0xffffffff for r in [reg.UC_MIPS_REG_A0, reg.UC_MIPS_REG_A1, reg.UC_MIPS_REG_A2]]
        if address == 0x8004d4b4:
            value = ['transform', list(vector(a[2])), a[1]]
        elif address == 0x80047d88:
            value = ['matrix', list(vector(a[0] + 40)), a[1]]
        elif address == 0x8003c14c:
            value = ['palette', a[1]]
        elif address == 0x80047048:
            value = ['allocate', load(0x80126b84), load(0x80123b20)]
        elif address == 0x80048dc0:
            value = ['warning', a[0]]
        else:
            value = [hex(address), s32(a[0])]
        trace.append(value)
    uc.hook_add(UC_HOOK_MEM_READ, memory_read)
    uc.hook_add(UC_HOOK_MEM_WRITE, memory_write)
    uc.hook_add(UC_HOOK_CODE, hook)
    saved = {getattr(reg, 'UC_MIPS_REG_' + key): 0x51000001 + index * 0x1010101 for index, key in enumerate(['S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP'])}
    for key, value in saved.items():
        uc.reg_write(key, value)
    uc.reg_write(reg.UC_MIPS_REG_SP, STACK)
    uc.reg_write(reg.UC_MIPS_REG_GP, 0xabcd1234)
    uc.reg_write(reg.UC_MIPS_REG_RA, RETURN)
    uc.reg_write(reg.UC_MIPS_REG_CP0_STATUS, uc.reg_read(reg.UC_MIPS_REG_CP0_STATUS) | 1 << 29)
    for register, value in zip([reg.UC_MIPS_REG_A0, reg.UC_MIPS_REG_A1, reg.UC_MIPS_REG_A2, reg.UC_MIPS_REG_A3], args):
        uc.reg_write(register, u32(value))
    uc.emu_start(BOOT, 0, count=0x186a0)
    assert done[0] and uc.reg_read(reg.UC_MIPS_REG_SP) == STACK and (uc.reg_read(reg.UC_MIPS_REG_GP) == 0xabcd1234), ('Return/SP/GP', name, case)
    assert all((uc.reg_read(key) == value for key, value in saved.items())), ('Saved integer registers', name, case)
    assert read(0x802a0100, 48) == b''.join((w(v) for v in fpu)), ('Saved FPU registers', name, case)
    actual_stack = read(stack_start, len(stack))
    assert all((value == stack[index] for index, value in enumerate(actual_stack) if stack_start + index not in touched)), ('Stack guard', name, case)
    assert read(0x8007bb34, 1024) == initial_palette and read(0x800c8bd8, 40) == initial_camera and (read(0x800cd250, 36) == initial_matrix), ('Readonly inputs', name, case)
    assert all((load(address) == u32(value) for address, value in values.items() if address not in mutable)), ('Readonly globals', name, case)
    end = load(0x80138254)
    assert COMMAND <= end <= COMMAND + 4096
    assert read(end, COMMAND + 4096 - end) == b'i' * (COMMAND + 4096 - end), ('Command tail', name, case)
    assert read(COMMAND - 16, 16) == b'\xc7' * 16 and read(COMMAND + 4096, 16) == b'\xd8' * 16, ('Command guard', name, case)
    vertices = read(VERT + base * 16, 11 * 16)
    command = read(COMMAND, end - COMMAND)
    state = [load(a) for a in STATE]
    sdk = read(0x80126b90, 32000)
    output = dict(trace=trace, vertices=vertices.hex(), commands=command.hex(), state=state, sdk_sha256=hashlib.sha256(sdk).hexdigest())
    if assert_model:
        active = base - frame <= 9800
        count = (8 if name == 'history_prism' else 11) if active else 0
        assert state[0] == (base + 8 if name == 'history_prism' and active else base if active else 0xffffffff)
        assert state[1] == base + count and state[7:9] == [5, 9]
        assert read(VERT, base * 16) == b'\xa5' * (base * 16) and read(VERT + (base + count) * 16, (22000 - base - count) * 16) == b'\xa5' * ((22000 - base - count) * 16), ('Vertex guard', name, case)
        expected_vertices = bytearray(b'\xa5' * (11 * 16))

        def vertex(index, position, color):
            expected_vertices[index * 16:index * 16 + 6] = b''.join((struct.pack('>H', v & 65535) for v in position))
            expected_vertices[index * 16 + 12:index * 16 + 16] = bytes((v & 255 for v in color))
        if name == 'history_prism':
            assert state[5] == matrix_slot and state[6] == matrix_half
            if active:
                quarter = (args[0] & 4095) >> 10
                height = trunc(s32(args[1] * 370), 16)
                alpha = trunc(s32(args[1] * 64), 16)
                positions = [(50, 0, 100), (50, 0, 0), (50, height, 0), (50, height, 100), (-50, 0, 100), (-50, 0, 0), (-50, height, 0), (-50, height, 100)] if quarter in [0, 2] else [(100, 0, 50), (-100, 0, 50), (-100, height, 50), (100, height, 50), (100, 0, -50), (-100, 0, -50), (-100, height, -50), (100, height, -50)]
                for i, p in enumerate(positions):
                    vertex(i, p, (*rgb, alpha))
                assert command == b''.join((w(a) + w(b) for a, b in [(0x400207f, VERT + base * 16), (0xb1020406, 0x20600), (0xb10c0a08, 0xc080e), (0xb10c0e06, 0xc0604), (0xb1060e08, 0x60800), (0xb1040c0a, 0x40a02)]))
            else:
                assert command == b''
        else:
            assert state[2:5] == [1, 0, 160] and state[5] == matrix_slot + 1 and (state[6] == matrix_half)
            relative = [s32(args[0] - camera[0]) >> 1, s32(-camera[1]) >> 1, s32(args[2] - camera[2]) >> 1]
            projected = [s32(sum((s32(relative[i] * matrix[row * 3 + i]) >> 15 for i in range(3)))) for row in range(3)]
            projected = [max(-32000, min(32000, v)) for v in projected]
            offset = (matrix_slot * 2 + matrix_half) * 64
            packed = []
            for part in [0, 1]:
                for column in range(3):
                    packed += [(matrix[row * 3 + column] >> 15 if part == 0 else matrix[row * 3 + column] << 1) & 65535 for row in range(3)] + [0]
                packed += [v & 65535 for v in projected] + [1] if part == 0 else [0, 0, 0, 0]
            assert sdk[offset:offset + 64] == b''.join((struct.pack('>H', v) for v in packed)), ('SDK matrix oracle', case)
            assert sdk[:offset] == b'{' * offset and sdk[offset + 64:] == b'{' * (32000 - offset - 64)
            if active:
                color = (0, 0, 0) if args[3] else rgb
                vertex(0, (0, 0, 0), (*color, 160 if args[3] else 0))
                for i in range(1, 11):
                    angle = (i - 1) * 4096 // 10
                    vertex(i, (trig(angle + 1024, table) * 200 >> 12, 0, trig(angle, table) * 200 >> 12), (*color, 160))
                primitive = b''.join((w(a) + w(b) for a, b in [(0x4002caf, VERT + base * 16)] + [(0xbf000000, (1 if i == 10 else i + 1) << 9 | i << 1) for i in range(1, 11)]))
                assert command.endswith(primitive), ('Primitive oracle', case)
        if name == 'history_prism':
            assert trace[0] == ['allocate', base, frame]
            assert sum((t[0] == '0x80047094' for t in trace)) == int(active)
        else:
            assert trace[:2] == [['0x8004729c', 2], ['0x8004729c', 1]]
            assert [t[0] for t in trace[2:5]] == ['transform', 'matrix', 'allocate']
            assert sum((t[0] == '0x80047094' for t in trace)) == int(active)
        assert sum((t[0] == 'warning' for t in trace)) == int(not active)
        assert vertices == bytes(expected_vertices), ('Vertex oracle', name, case)
        assert sum((t[0] == 'palette' for t in trace)) == int(name == 'ground_disc' and active)
        assert sum((t[0] == '0x8003cc88' for t in trace)) == (10 if name == 'ground_disc' and active else 0)
        assert sum((t[0] == '0x8003cc58' for t in trace)) == (10 if name == 'ground_disc' and active else 0)
    return (output, instructions[0])

def main():
    install('5.3')
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    records = tuple((row for row in CANDIDATE_BLOCKS if row[0] in NAMES))
    assert {row[0] for row in records} == set(NAMES)
    validate_candidate_ranges(records, load_manifest())
    support, owned, proofs, targets, comparisons = ([], [], {}, {}, {})
    guard_files = [Path(__file__).relative_to(ROOT).as_posix()]
    guard_hashes = {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest() for path in guard_files}
    for name in SUPPORT:
        _, source, start, end = next((row for row in MATCHING_BLOCKS if row[0] == name))
        with contextlib.redirect_stdout(io.StringIO()):
            q = compare_block(name, source, start, start - 0x80000000 + 3072, end - 0x80000000 + 3072, target, FAMILY + '-support', layout)
        assert q['matches'] and (not q['different_words']), name
        work = ROOT / 'build' / (FAMILY + '-support') / name
        support.append((start, (work / (name + '.bin')).read_bytes()))
        sections, _ = elf_sections_and_symbols(work / (name + '.elf'))
        for section in source_sections(source):
            if section['rom'] is not None:
                data = sections[section['section']]['bytes']
                assert len(data) == section['size']
                assert data == target[section['rom']:section['rom'] + section['size']]
                owned.append((section['vram'], data))
                support.append((section['vram'], data))
        proofs[name] = q
        print('Matched complete support:', name, flush=True)
    table = [math.floor(32767 * math.sin(i * math.pi / 2046)) for i in range(1024)]
    assert b''.join((struct.pack('>h', v) for v in table)) == next((data for address, data in owned if address == 0x8008dbb0))
    for name, source, start, end in records:
        offset = start - 0x80000000 + 3072
        with contextlib.redirect_stdout(io.StringIO()):
            q = compare_block(name, source, start, offset, offset + end - start, target, FAMILY + '-candidates', layout)
        work = ROOT / 'build' / (FAMILY + '-candidates') / name
        sections, symbols = elf_sections_and_symbols(work / (name + '.raw.o'))
        size = symbols[f'func_{start:X}']['size']
        assert not any(sections['.text']['bytes'][size:]), (name, 'Live bytes after function')
        assert all((not data['bytes'] for key, data in sections.items() if key in ['.data', '.rodata', '.sdata']))
        linked, _ = elf_sections_and_symbols(work / (name + '.elf'))
        candidate = linked['.text']['bytes'][:size]
        retail = target[offset:offset + end - start]
        targets[name] = (start, retail, candidate)
        q['natural_bytes'] = size
        q['frame'] = next(-int.from_bytes(candidate[i + 2:i + 4], 'big', signed=True)
                          for i in range(0, size, 4)
                          if candidate[i:i + 2] == b'\x27\xBD'
                          and int.from_bytes(candidate[i + 2:i + 4], 'big', signed=True) < 0)
        q['candidate_sha256'] = hashlib.sha256(candidate).hexdigest()
        q['retail_sha256'] = hashlib.sha256(retail).hexdigest()
        comparisons[name] = q
        print(name, size, '/', len(retail), 'bytes;', len(q['different_words']), 'differing words', flush=True)
    evidence = dict(support=support, owned=owned, targets=targets, table=table)
    identity = (32767, 0, 0, 0, 32767, 0, 0, 0, 32767)
    skew = (32767, 200, -100, 400, 32767, 50, -60, 75, 32767)
    flip = (-32768, 0, 0, 0, 0, 32767, 0, -32768, 0)
    allocations = [(0, 0), (7, 0), (9800, 0), (9801, 0), (21989, 21989)]
    cases = []
    for allocation, angle, size, rgb in itertools.product(allocations, [0, 1023, 1024, 2047, 2048, 3072, 4095, -1], [0, 1, 16, -1, 0x7fffffff, -0x80000000], [(3, 77, 251), (0, 0, 0), (-1, 256, 0x12345678)]):
        cases.append(('history_prism', (*allocation, 1, (angle, size), (0, 0, 0), identity, rgb, 0, 0)))
    for allocation, camera, matrix, black, mode in itertools.product(allocations, [(0, 0, 0), (401, -305, 71), (-1, 1, -3), (0x30d40, -0x30d41, 0x15f90)], [identity, skew, flip], [0, 1, -7], [1, 2, 18]):
        cases.append(('ground_disc', (*allocation, mode, (12345, 0x76543210, -23456, black), camera, matrix, (3, 77, 251), 7, 1)))
    counts = {name: 0 for name in NAMES}
    digest = hashlib.sha256()
    steps = 0
    for name, case in cases:
        expected, a = execute(name, targets[name][1], case, evidence)
        actual, b = execute(name, targets[name][2], case, evidence)
        assert actual == expected, ('Paired behavior', name, case, [key for key in expected if expected[key] != actual[key]])
        counts[name] += 1
        steps += a + b
        digest.update(json.dumps([name, case, expected], sort_keys=True).encode())
        if sum(counts.values()) % 200 == 0:
            print('Guarded pairs:', sum(counts.values()), '/', len(cases), flush=True)
    selected = {'history_prism': (7, 0, 1, (1024, 16), (0, 0, 0), identity, (3, 77, 251), 0, 0), 'ground_disc': (7, 0, 18, (12345, 0x76543210, -23456, 1), (401, -305, 71), skew, (3, 77, 251), 7, 1)}
    controls = []
    for name in NAMES:
        case = selected[name]
        expected, _ = execute(name, targets[name][1], case, evidence)
        instructions = list(Cs(CS_ARCH_MIPS, CS_MODE_MIPS32 | CS_MODE_BIG_ENDIAN).disasm(targets[name][2], targets[name][0]))
        low = 8319 if name == 'history_prism' else 11439
        anchors = [('vertex_packet', lambda i: i.mnemonic == 'ori' and int.from_bytes(i.bytes[2:4], 'big') == low)]
        if name == 'ground_disc':
            anchors += [('center_alpha', lambda i: i.mnemonic == 'addiu' and int.from_bytes(i.bytes[2:4], 'big') == 160), ('commit_count', lambda i: i.mnemonic == 'addiu' and i.op_str.startswith('$a0, $zero,') and (int.from_bytes(i.bytes[2:4], 'big') == 11))]
        for label, predicate in anchors:
            instruction = next((i for i in instructions if predicate(i)))
            bad = bytearray(targets[name][2])
            index = instruction.address - targets[name][0]
            bad[index + 3] ^= 1
            actual, _ = execute(name, bytes(bad), case, evidence, False)
            assert actual != expected, ('Instruction control escaped', name, label)
            controls.append(dict(name=name + '_' + label, kind='guest', rejected_by='Paired memory or call trace'))
    mutations = {'history_prism': [('height', 'size * 370', 'size * 371'), ('quadrant', 'angle /= 1024', 'angle /= 512'), ('quad_winding', 'RENDERER_QUAD(7, 6, 5, 4)', 'RENDERER_QUAD(4, 5, 6, 7)'), ('commit', 'D_80123AE4 += 8', 'D_80123AE4 += 7')], 'ground_disc': [('camera_y', '-D_800C8BD8.position[1]', 'y - D_800C8BD8.position[1]'), ('radius', 'func_8003CC88(angle) * 200', 'func_8003CC88(angle) * 201'), ('perimeter_count', 'count = 10', 'count = 9'), ('alpha', 'alpha = 160', 'alpha = 159')]}
    for name, source, start, end in records:
        text = (ROOT / source).read_text()
        case = selected[name]
        expected, _ = execute(name, targets[name][1], case, evidence)
        for label, old, new in mutations[name]:
            assert old in text, ('Source mutation anchor', name, label)
            path = OUTPUT / 'control-sources' / (name + '-' + label + '.c')
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text.replace('../../../include/', str(ROOT / 'include') + '/').replace(old, new))
            with contextlib.redirect_stdout(io.StringIO()):
                compare_block(name + '-' + label, path.relative_to(ROOT).as_posix(), start, start - 0x80000000 + 3072, end - 0x80000000 + 3072, target, FAMILY + '-controls', layout)
            work = ROOT / 'build' / (FAMILY + '-controls') / (name + '-' + label)
            sections, symbols = elf_sections_and_symbols(work / (name + '-' + label + '.elf'))
            size = symbols[f'func_{start:X}']['size']
            code = sections['.text']['bytes'][:size]
            try:
                actual, _ = execute(name, code, case, evidence)
            except (AssertionError, UcError) as error:
                reason = str(error)
            else:
                assert actual != expected, ('Source control escaped', name, label)
                reason = 'Paired memory or call trace'
            controls.append(dict(name=name + '_' + label, kind='source', rejected_by=reason))
    assert len(controls) == 12
    layout.verify()
    for report in list(proofs.values()) + list(comparisons.values()):
        for path, sha in report['inputs_sha256'].items():
            assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == sha, ('Changed comparison input', path)
    for path, sha in guard_hashes.items():
        assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == sha, ('Changed guard input', path)
    receipt = dict(paired_cases=len(cases), counts=counts, principal_executions=2 * len(cases), instructions=steps, trace_sha256=digest.hexdigest(), comparison=comparisons, real_support=proofs, controls=controls, guard_inputs_sha256=guard_hashes, abi_stubs=0, source_ownership_added=0, emulator_version=version('unicorn'), limits=['Finite guarded CPU cases; RSP/RDP commands are not executed.', 'The two candidate bodies remain excluded because their complete instruction comparisons differ.', 'The original local storage declarations remain unproved, including the disc draw frame.', 'Void routines have no asserted incidental V0/V1 return contract.', 'Stack interiors are bounded and ABI checked, not compared byte for byte.'])
    OUTPUT.mkdir(parents=True, exist_ok=True)
    (OUTPUT / 'report.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('Early local effect guard:', len(cases), 'paired cases;', len(controls), 'rejected controls; no new ownership', flush=True)
if __name__ == '__main__':
    main()
