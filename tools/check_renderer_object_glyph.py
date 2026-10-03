"""Check complete object glyph and callback instructions with real callees.

The fatal formatter is the only ABI stub. Independent oracles check glyph
selection, transforms, packed matrices, guarded vertices/commands and the
surviving return register. This does not resolve the provisional C return type.
"""

import hashlib
import itertools
import json
import struct
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word
from check_renderer_image_setup import half, packets, signed
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


NAMES = ('renderer_object_glyph', 'object_helpers_draw_mode')
SUPPORT = ('renderer_glyph_map', 'frame_transform', 'renderer_matrix_transform',
           'fixed_math', 'short_sine', 'short_cosine', 'graphics_pool',
           'debug_noop', 'graphics_state_helpers')
COMMANDS, ARENA, VERTICES = 0x80220010, 0x80126B90, 0x800CDBD0
CURSOR, BUFFER, DISPLAY_LIST = 0x8007D6A8, 0x8007D910, 0x80138254
FONT, DRAW, OBJECT, CAMERA_MATRIX = 0x8007DB20, 0x80210010, 0x80210110, 0x800CD250
SCENES = (0x8007751C, 0x800773C4, 0x800772F0, 0x80077BCC, 0x80077B70,
          0x80076BD8, 0x800AF1A8, 0x8007726C, 0x80076B70, 0x80076BA4,
          0x80076B14, 0x800766BC, 0x800763F0, 0x8007628C, 0, 0x80234560)
IDENTITY = ((32767, 0, 0), (0, 32767, 0), (0, 0, 32767))
MATRICES = (IDENTITY, ((0, 32767, 0), (-32767, 0, 0), (0, 0, 32767)),
            ((16384, 8192, -4096), (4096, -32767, 8192), (32767, 16384, 3)),
            ((0x7FFFFFFF, 0x40000000, -0x7FFFFFFF), (32767, -131072, 8192),
             (-17, 1024, 0x7FFFFFFF)))
POSITIONS = ((0, 1, -1), (64001, -64001, 12345), (17, -19, 23),
             (0x7FFFFFFF, -0x80000000, -32001))
SCALES = ((16, 32, 48), (-16, 0, 4097), (0x7FFFFFFF, -0x80000000, 65537), (7, 11, -31))
ANGLES = ((0, 0, 0), (1024, 0, 0), (0, 1024, 0), (0, 0, -1024))
COLORS = ((4, 17, 63), (0x1234, -1, 0xABCDEF00), (257, -257, 300), (255, 0, 128))


def glyph_index(character):
    codes = {ord(c): i for i, c in enumerate('ABCDEFGHIJKLMNOPQRSTUVWXYZ')}
    codes.update({ord(c): i for i, c in enumerate('abcdefghijklmnopqrstuvwxyz')})
    codes.update({ord(c): 36 + i for i, c in enumerate('0123456789')})
    codes.update({170 + i: 36 + i for i in range(10)})
    codes.update({ord(c): i for i, c in enumerate('_?=+/-.%!*', 26)})
    codes.update({31: 46, 11: 47, 12: 48, 13: 49, ord('^'): 50, ord(','): 51,
                  ord('#'): 53, ord('"'): 54, ord(':'): 55, ord('@'): 56, ord("'"): 57})
    return codes.get(character & 255, 0)


def qmul(a, b):
    return signed(a * b) >> 15


def packed_matrix(scales, angles, position):
    # The four angle fixtures use exact quadrant endpoints of the SDK table.
    sine = {0: 0, 1024: 32767, -1024: -32767}
    cosine = {0: 32767, 1024: 0, -1024: 0}
    sx, sy, sz = (sine[a] for a in angles)
    cx, cy, cz = (cosine[a] for a in angles)
    a, b, c = scales
    rows = ((signed(qmul(cz, cy) * a) >> 4,
             signed(signed(qmul(qmul(sy, sx), cz) - qmul(sz, cx)) * a) >> 4,
             signed(signed(qmul(qmul(sy, cx), cz) + qmul(sz, sx)) * a) >> 4),
            (signed(qmul(sz, cy) * b) >> 4,
             signed(signed(qmul(qmul(sy, sx), sz) + qmul(cz, cx)) * b) >> 4,
             signed(signed(qmul(qmul(sy, cx), sz) - qmul(cz, sx)) * b) >> 4),
            (signed(-sy * c) >> 4, signed(qmul(cy, sx) * c) >> 4,
             signed(qmul(cy, cx) * c) >> 4))
    integers, fractions = [], []
    for column in range(3):
        integers += [rows[row][column] >> 15 for row in range(3)] + [0]
        fractions += [rows[row][column] << 1 for row in range(3)] + [0]
    return b''.join(half(n) for n in integers + [*position, 1] + fractions + [0] * 4)


def run_glyph(code, support, case):
    wrapped, character, mode, vertex_case, profile, cursor, buffer, scene, force = case
    if wrapped:
        mode = int(scene < 14 or force == 1)
    vertex = (0, 21996, 9801)[vertex_case]
    frame_vertex = vertex if vertex_case == 1 else 0
    rejected = vertex_case == 2
    size = 50 if mode else 100
    matrix, position, scales, angles = MATRICES[profile], POSITIONS[profile], SCALES[profile], ANGLES[profile]
    camera = (-777, 32123, -32771)
    if mode:
        local = (signed(-position[0]) >> 2, position[1] >> 2, signed(-position[2]) >> 2)
        effective_matrix = IDENTITY
    else:
        local = tuple(signed(p - q) >> 1 for p, q in zip(position, camera))
        effective_matrix = matrix
    projected = tuple(signed(sum(qmul(n, coefficient) for n, coefficient in zip(local, row)))
                      for row in effective_matrix)
    clamped = tuple(max(-32000, min(32000, n)) for n in projected)
    uc, write, execute = machine(code, support)
    write(0x802FF000, b'\xA9' * 4096)
    matrix_arena, vertex_arena, commands = bytearray(b'\xA7' * 32000), bytearray(b'\xA8' * 352000), bytearray(b'\xAC' * 256)
    write(ARENA - 16, b'\xC7' * 16 + matrix_arena + b'\xC7' * 16)
    write(VERTICES - 16, b'\xC8' * 16 + vertex_arena + b'\xC8' * 16)
    write(COMMANDS - 16, b'\xCC' * 16 + commands + b'\xCC' * 16)
    font = b'\xC1' * (58 * 1024 + 32)
    write(FONT - 16, font)
    palette = bytes((i * 13 + j * 37) & 255 for i in range(16) for j in range(4))
    write(0x8007BF24, b'\xC2' * 16 + palette + b'\xC2' * 16)
    color_index = (character & 255) % 16
    colors = tuple(palette[color_index * 4:color_index * 4 + 3]) if wrapped else COLORS[profile]
    draw = bytearray(word(0xC1234567) + b''.join(word(n) for n in scales + angles + position)
                     + b'\xD4' * 12 + word(0xD2345678) + word(0xD3456789))
    draw_address = OBJECT + 0x38 if wrapped else DRAW
    record = bytearray(b'\xD8' * 120)
    record[0x10:0x12] = bytes((character & 255, color_index))
    record[0x38:0x74] = draw
    write(draw_address - 16 if not wrapped else OBJECT - 16,
          b'\xD9' * 16 + (record if wrapped else draw) + b'\xD9' * 16)
    camera_record = bytearray(b'\xCA' * 60)
    camera_record[28:40] = b''.join(word(n) for n in camera)
    write(0x800C8BC8, b'\xCD' * 16 + camera_record + b'\xCD' * 16)
    saved_matrix = b''.join(word(n) for row in matrix for n in row)
    write(CAMERA_MATRIX - 16, b'\xCE' * 16 + saved_matrix + b'\xCE' * 16)
    for address, value in ((CURSOR, cursor), (BUFFER, buffer), (DISPLAY_LIST, COMMANDS),
                           (0x80126B84, vertex), (0x80123B20, frame_vertex),
                           (0x80123AE8, 37), (0x80123B14, 0xFFFFFFFE), (0x80123B18, 0x7FFFFFFF),
                           (0x80123B00, 0xDEAD1234), (0x8008CB20, -99), (0x800AEE9C, SCENES[scene])):
        write(address, word(value))
    for i, value in enumerate(COLORS[profile]):
        write(0x8008CB24 + i * 4, word(value))
    trace = []

    def boundary(uc, address, count, user):
        trace.append(hex(address))
        a0 = uc.reg_read(regs.UC_MIPS_REG_A0)
        if address == 0x8004A2B4:
            assert a0 == draw_address
            assert uc.reg_read(regs.UC_MIPS_REG_A2) == mode & 0xFFFFFFFF
        elif address == 0x800498F0:
            assert a0 == character & 255
        elif address == 0x8004DB34:
            assert a0 == CAMERA_MATRIX
        elif address == 0x8004D4B4:
            assert a0 == draw_address + 40
            argument = uc.reg_read(regs.UC_MIPS_REG_A2)
            assert bytes(uc.mem_read(argument & 0x1FFFFFFF, 12)) == b''.join(word(n) for n in local)
        elif address == 0x80047570:
            assert a0 == draw_address
            assert bytes(uc.mem_read((draw_address + 40) & 0x1FFFFFFF, 12)) == b''.join(word(n) for n in projected)
        elif address == 0x80047094:
            assert a0 == 4
        elif address == 0x80049DF4:
            assert [uc.reg_read(r) for r in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2)] == list(colors)
        elif address == 0x800496E0:
            stack = uc.reg_read(regs.UC_MIPS_REG_SP)
            args = [uc.reg_read(r) for r in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)]
            args.append(int.from_bytes(uc.mem_read((stack + 16) & 0x1FFFFFFF, 4), 'big'))
            assert args == [0x80095360, 250, 250, 0x80095394, 160]
            for i, name in enumerate(('V0', 'V1', 'A0', 'A1', 'A2', 'A3', 'T0', 'T1', 'T2', 'T3',
                                       'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'HI', 'LO')):
                uc.reg_write(getattr(regs, 'UC_MIPS_REG_' + name), 0xB2340000 + i * 256)
            uc.reg_write(regs.UC_MIPS_REG_PC, uc.reg_read(regs.UC_MIPS_REG_RA))

    for address in (0x8004A2B4, 0x800498F0, 0x8004DB34, 0x8004D4B4, 0x80047570,
                    0x800496E0, 0x80047048, 0x80047094, 0x80048DC0, 0x80049DF4):
        uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)
    uc.reg_write(regs.UC_MIPS_REG_A0, force if wrapped else draw_address)
    uc.reg_write(regs.UC_MIPS_REG_A1, OBJECT if wrapped else character & 0xFFFFFFFF)
    uc.reg_write(regs.UC_MIPS_REG_A2, mode & 0xFFFFFFFF)
    execute(0x8003A778 if wrapped else 0x8004A2B4)
    result = uc.reg_read(regs.UC_MIPS_REG_V0)
    assert result == (0xFFFFFFFF if rejected else vertex + 4), (case, hex(result))
    packed = packed_matrix(scales, angles, clamped)
    offset = cursor * 128 + buffer * 64
    matrix_arena[offset:offset + 64] = packed
    address = (FONT + glyph_index(character) * 1024) & ~7
    values = [(0x01020040, ARENA + offset - 0x80000000), (0xE7000000, 0), (0xFD900000, address),
              (0xF5900000, 0x07080200), (0xE6000000, 0), (0xF3000000, 0x071FF200),
              (0xE7000000, 0), (0xF5880800, 0x00080200), (0xF2000000, 0x0007C07C)]
    if not rejected:
        for i, (x, y, u, v) in enumerate(((0, size * 2, 0, 0), (-size * 2, size * 2, 3072, 0),
                                        (-size * 2, 0, 3072, 3072), (0, 0, 0, 3072))):
            start = (vertex + i) * 16
            vertex_arena[start:start + 6] = half(x) + half(y) + half(0)
            vertex_arena[start + 8:start + 12] = half(u) + half(v)
            vertex_arena[start + 12:start + 16] = bytes((255, 255, 255, 255) if i < 2 else (*[n & 255 for n in colors], 255))
        values += [(0x0400103F, VERTICES + vertex * 16), (0xB1040200, 0x00040006)]
    emitted = packets(values)
    commands[:len(emitted)] = emitted
    draw[40:52] = b''.join(word(n) for n in clamped)
    record[0x38:0x74] = draw
    final_matrix = b''.join(word(n) for row in IDENTITY for n in row) if rejected and mode else saved_matrix
    prefix = b'\xC7' * 4 + word(vertex + (0 if rejected else 4)) + b'\xC7' * 8
    expected_trace = (['0x80049df4'] if wrapped else []) + ['0x8004a2b4', '0x800498f0']
    expected_trace += (['0x8004db34'] if mode else []) + ['0x8004d4b4', '0x80047570']
    expected_trace += (['0x800496e0'] if cursor == 249 else []) + ['0x80047048', '0x80048dc0' if rejected else '0x80047094']
    assert trace == expected_trace, (case, trace, expected_trace)
    checks = [(ARENA - 16, prefix + matrix_arena + b'\xC7' * 16),
              (VERTICES - 16, b'\xC8' * 16 + vertex_arena + b'\xC8' * 16),
              (COMMANDS - 16, b'\xCC' * 16 + commands + b'\xCC' * 16),
              (FONT - 16, font), (0x8007BF24, b'\xC2' * 16 + palette + b'\xC2' * 16),
              (CAMERA_MATRIX - 16, b'\xCE' * 16 + final_matrix + b'\xCE' * 16),
              (0x800C8BC8, b'\xCD' * 16 + camera_record + b'\xCD' * 16),
              (OBJECT - 16 if wrapped else DRAW - 16, b'\xD9' * 16 + (record if wrapped else draw) + b'\xD9' * 16),
              (CURSOR, word(cursor + 1)), (BUFFER, word(buffer)), (DISPLAY_LIST, word(COMMANDS + len(emitted))),
              (0x80123AE4, word(-1 if rejected else vertex)), (0x80123AE8, word(37)),
              (0x80123B20, word(frame_vertex)), (0x80123B00, word(address)), (0x8008CB20, word(size)),
              (0x80123B14, word(0xFFFFFFFE + int(not rejected))),
              (0x80123B18, word(0x7FFFFFFF + int(not rejected))),
              (0x8008CB24, b''.join(word(n) for n in colors)), (0x800AEE9C, word(SCENES[scene]))]
    for address, expected in checks:
        assert bytes(uc.mem_read(address & 0x1FFFFFFF, len(expected))) == expected, (case, hex(address))
    return dict(return_register=hex(result), matrix=packed.hex(), commands=emitted.hex(), trace=trace,
                vertex_sha256=hashlib.sha256(vertex_arena).hexdigest(), camera_matrix=final_matrix.hex())


def cases():
    for character, mode, allocation in itertools.product(range(256), (0, 1), range(3)):
        yield (False, character, mode, allocation, character // 64, 249 if character & 1 else 0, (character >> 1) & 1, 14, 0)
    for character, mode, allocation, profile, cursor, buffer in itertools.product(
            (-1, 256, 0x1234, 255), (0, -1, 17), range(3), range(4), (0, 249), range(2)):
        yield (False, character, mode, allocation, profile, cursor, buffer, 14, 0)
    for character, scene, force, allocation in itertools.product((0, 14, 65, 97, 57, 255), range(16), (0, 1, 2), (0, 2)):
        yield (True, character, 0, allocation, scene % 4, 249 if force == 1 else 0, scene % 2, scene, force)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, retail, support, comparisons = [], [], [], {}
    for name in NAMES + SUPPORT:
        _, source, start, end = next(r for r in MATCHING_BLOCKS if r[0] == name)
        comparison = compare_block(name, source, start, start - 0x80000000 + 0xC00, end - 0x80000000 + 0xC00,
                                   target, family='renderer-object-glyph-execution', layout=layout)
        assert comparison['matches'], name
        comparisons[name] = comparison
        directory = ROOT / 'build/renderer-object-glyph-execution' / name
        data = (directory / (name + '.bin')).read_bytes()
        if name in NAMES:
            compiled.append((start, data))
            retail.append((start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
        else:
            support.append((start, data))
            sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
            for owned in source_sections(source):
                if owned['rom'] is not None:
                    support.append((owned['vram'], sections[owned['section']]['bytes']))
    counts = dict(cases=0, direct=0, callback=0, alternate_mode=0, matrix_diagnostic=0, vertex_rejected=0)
    digest = hashlib.sha256()
    for case in cases():
        expected, actual = run_glyph(retail, support, case), run_glyph(compiled, support, case)
        assert actual == expected, case
        counts['cases'] += 1
        counts['callback' if case[0] else 'direct'] += 1
        counts['alternate_mode'] += int(case[7] < 14 or case[8] == 1) if case[0] else int(case[2] != 0)
        counts['matrix_diagnostic'] += int(case[5] == 249)
        counts['vertex_rejected'] += int(case[3] == 2)
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
    result = dict(matches=True, counts=counts, comparisons=comparisons, trace_sha256=digest.hexdigest(),
                  target_rom_sha256=hashlib.sha256(target).hexdigest(), checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  machine_helper_sha256=hashlib.sha256((ROOT / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
                  oracle_helper_sha256=hashlib.sha256((ROOT / 'tools/check_renderer_image_setup.py').read_bytes()).hexdigest(),
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['The complete glyph and its matching object callback execute with nine freshly matched support units.',
                          'Only the nonreturning fatal formatter is an ABI stub; its continuation is synthetic.',
                          'All 256 input bytes, promoted argument truncation, both modes and all fourteen special scene pointers are exercised.',
                          'Independent oracles check guarded draw/object, camera, matrix, font/palette, vertex, command and state bytes.',
                          'Integer product wrap and arithmetic right shift describe the pinned compiler and MIPS behavior.',
                          'v0 is -1 on allocator rejection and the advanced vertex cursor on success; this does not establish a unique C return type.',
                          'The provisional void callee and integer callback views remain incompatible ISO C function types.',
                          'Invalid storage/selectors, full runtime-dispatch execution, RSP/RDP rendering and full-game behavior are outside this proof.'])
    output = ROOT / 'build/renderer-object-glyph-execution/report.json'
    output.write_text(json.dumps(result, indent=2) + '\n')
    print('Passed object glyph execution:', counts, output, flush=True)


if __name__ == '__main__':
    main()
