"""Execute matching image setup, matrix, palette, quad and allocation code.

Mode selection and the fatal formatter use recorded integer ABI stubs. An
independent oracle checks CPU commands, matrix/vertex bytes and state ordering.
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
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


NAMES = ('renderer_image_setup_ci', 'renderer_image_setup_rgba')
SUPPORT = ('renderer_matrix_transform', 'fixed_math', 'short_sine', 'short_cosine',
           'renderer_texture_defaults', 'renderer_platform', 'renderer_image_quad_ci',
           'renderer_image_quad_rgba', 'graphics_pool', 'debug_noop')
COMMANDS, ARENA, VERTICES = 0x80220010, 0x80126B90, 0x800CDBD0
TEXTURE, CURSOR, BUFFER, DISPLAY_LIST = 0x80210010, 0x8007D6A8, 0x8007D910, 0x80138254
SCALES = (4, -16, 4097, 0x7FFFFFFF)
POSITIONS = ((0, 1, -1), (32000, -32000, 12345),
             (32001, -32001, 17), (0x7FFFFFFF, -0x80000000, -32001))


def signed(value):
    return (value + 0x80000000) % 0x100000000 - 0x80000000


def half(value):
    return struct.pack('>H', value & 0xFFFF)


def packets(values):
    return b''.join(word(first) + word(second) for first, second in values)


def run_setup(code, support, case):
    rgba, scale_index, position_index, cursor, buffer, vertex_case, mutate, alignment = case
    scale, position = SCALES[scale_index], POSITIONS[position_index]
    vertex = (0, 21996, 9801)[vertex_case]
    frame_vertex = vertex if vertex_case == 1 else 0
    rejected = vertex_case == 2
    effective_scale = -31 if mutate and not rgba else scale
    effective_position = (-32001, 32001, -19) if mutate and not rgba else position
    clamped = tuple(max(-32000, min(32000, n)) for n in effective_position)
    uc, write, execute = machine(code, support)
    write(0x802FF000, b'\xA9' * 4096)
    matrix_arena = bytearray(b'\xA7' * 32000)
    vertex_arena = bytearray(b'\xA8' * 352000)
    commands = bytearray(b'\xAC' * 512)
    texture = b'\xC1' * 64
    palette = b'\xC2' * 512
    write(TEXTURE - 16, texture)
    write(0x8007D6D0, palette)
    write(ARENA - 16, b'\xC7' * 16 + matrix_arena + b'\xC7' * 16)
    write(VERTICES - 16, b'\xC8' * 16 + vertex_arena + b'\xC8' * 16)
    write(COMMANDS - 16, b'\xCC' * 16 + commands + b'\xCC' * 16)
    for address, value in ((CURSOR, cursor), (BUFFER, buffer), (DISPLAY_LIST, COMMANDS),
                           (0x8008CB34, scale), (0x80123AE8, 37),
                           (0x80126B84, vertex), (0x80123B20, frame_vertex),
                           (0x80123B00, 0xDEAD1234), (0x80123B04, 0xDEAD5678)):
        write(address, word(value))
    for i, value in enumerate(position):
        write(0x8013D9A0 + i * 4, word(value))
    trace = []
    caller_saved = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                         ('V0', 'V1', 'A0', 'A1', 'A2', 'A3', 'T0', 'T1',
                          'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'HI', 'LO'))

    def boundary(uc, address, size, user):
        a0 = uc.reg_read(regs.UC_MIPS_REG_A0)
        a1 = uc.reg_read(regs.UC_MIPS_REG_A1)
        trace.append(hex(address))
        if address == 0x8004729C:
            assert a0 == 15
            if mutate:
                write(0x8008CB34, word(-31))
                for i, value in enumerate((-32001, 32001, -19)):
                    write(0x8013D9A0 + i * 4, word(value))
        elif address == 0x80047570:
            assert a0 == 0x80300000 - (0x80 if rgba else 0x78) + (0x2C if rgba else 0x24)
            draw = bytes(uc.mem_read(a0 & 0x1FFFFFFF, 60))
            assert draw[4:16] == word(effective_scale) * 3
            assert draw[16:28] == word(0) * 3
            assert draw[40:52] == b''.join(word(n) for n in effective_position)
            return
        elif address == 0x800496E0:
            stack = uc.reg_read(regs.UC_MIPS_REG_SP)
            args = [uc.reg_read(r) for r in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                            regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)]
            args.append(int.from_bytes(uc.mem_read((stack + 16) & 0x1FFFFFFF, 4), 'big'))
            assert args == [0x80095360, 250, 250, 0x80095394, 160]
            assert bytes(uc.mem_read(CURSOR & 0x1FFFFFFF, 4)) == word(250)
        else:
            if address in (0x8004AD64, 0x8004B098):
                assert [a0, a1] == [TEXTURE + alignment, 40 if rgba else 20]
                assert bytes(uc.mem_read(0x123AE8, 4)) == word(128 if rgba else 255)
            if address == 0x80049AD8:
                assert a0 == 0x8007D6D0
            return
        for i, register in enumerate(caller_saved):
            uc.reg_write(register, 0xB2340000 + i * 256)
        uc.reg_write(regs.UC_MIPS_REG_PC, uc.reg_read(regs.UC_MIPS_REG_RA))

    watched = (0x8004729C, 0x80047570, 0x800496E0, 0x8004ABC8,
               0x80049AD8, 0x8004AD64, 0x8004B098, 0x80048DC0)
    for address in watched:
        uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)
    uc.reg_write(regs.UC_MIPS_REG_A0, TEXTURE + alignment)
    execute(0x8004AFA4 if rgba else 0x8004ACA4)

    # Zero angles yield a product of two cosines in each diagonal.
    cosine_product = (32767 * 32767) >> 15
    diagonal = (signed(cosine_product * effective_scale) >> 4,
                signed(cosine_product * effective_scale) >> 4,
                signed(cosine_product * effective_scale) >> 4)
    integers = [diagonal[0] >> 15, 0, 0, 0, 0, diagonal[1] >> 15, 0, 0,
                0, 0, diagonal[2] >> 15, 0, *clamped, 1]
    fractions = [diagonal[0] << 1, 0, 0, 0, 0, diagonal[1] << 1, 0, 0,
                 0, 0, diagonal[2] << 1, 0, 0, 0, 0, 0]
    packed = b''.join(half(n) for n in integers + fractions)
    offset = cursor * 128 + buffer * 64
    matrix_arena[offset:offset + 64] = packed
    matrix_packet = (0x01020040, ARENA + offset - 0x80000000)
    defaults = [(0xE7000000, 0), (0xBA000801, 0), (0xB9000002, 0),
                (0xBA000C02, 0x2000), (0xBA001001, 0), (0xBA001301, 0x80000),
                (0xBB000001, 0x80008000)]
    values = [matrix_packet] + defaults if rgba else defaults + [(0xBA001301, 0), matrix_packet]
    if rgba:
        values += [(0xBA001301, 0), (0xBA000E02, 0), (0xB900031D, 0x00553078)]
    else:
        values += [(0xFD100000, 0x8007D6D0), (0xE8000000, 0), (0xF5000100, 0x07000000),
                   (0xE6000000, 0), (0xF0000000, 0x073FC000), (0xE7000000, 0), (0xBA000E02, 0x8000)]
    address = TEXTURE + alignment if rgba else (TEXTURE + alignment) & ~7
    values += [(0xE7000000, 0), (0xFD100000 if rgba else 0xFD500000, address),
               (0xF5100000 if rgba else 0xF5500000, 0x07080200), (0xE6000000, 0),
               (0xF3000000, 0x073FF100 if rgba else 0x071FF200), (0xE7000000, 0),
               (0xF5101000 if rgba else 0xF5480800, 0x00080200), (0xF2000000, 0x0007C07C)]
    if not rejected:
        extent = 40 if rgba else 20
        y = -extent if rgba else extent
        positions = ((extent, y), (-extent, y), (-extent, -y), (extent, -y))
        texcoords = ((0, 0), (4096, 0), (4096, 4096), (0, 4096))
        for i, ((x, y), (u, v)) in enumerate(zip(positions, texcoords)):
            start = (vertex + i) * 16
            vertex_arena[start:start + 6] = half(x) + half(y) + half(0)
            vertex_arena[start + 8:start + 12] = half(u) + half(v)
            vertex_arena[start + 12:start + 16] = bytes((255, 255, 255, 128 if rgba else 255))
        values += [(0x0400103F, VERTICES + vertex * 16),
                   (0xB1020406, 0x00020600) if rgba else (0xB1040200, 0x00040006)]
    emitted = packets(values)
    commands[:len(emitted)] = emitted
    initial = ['0x80047570', '0x8004729c', '0x8004abc8'] if rgba else ['0x8004729c', '0x8004abc8', '0x80047570']
    if cursor == 249:
        initial.insert(1 if rgba else 3, '0x800496e0')
    expected_trace = initial + ([] if rgba else ['0x80049ad8']) + [hex(0x8004B098 if rgba else 0x8004AD64)]
    if rejected:
        expected_trace += ['0x80048dc0']
    assert trace == expected_trace, (case, trace, expected_trace)
    # The four words immediately before the matrix arena include the live
    # dynamic vertex cursor at +4; its intentional change is checked too.
    matrix_prefix = b'\xC7' * 4 + word(vertex + (0 if rejected else 4)) + b'\xC7' * 8
    for address, expected in ((ARENA - 16, matrix_prefix + matrix_arena + b'\xC7' * 16),
                              (VERTICES - 16, b'\xC8' * 16 + vertex_arena + b'\xC8' * 16),
                              (COMMANDS - 16, b'\xCC' * 16 + commands + b'\xCC' * 16),
                              (TEXTURE - 16, texture), (0x8007D6D0, palette),
                              (CURSOR, word(cursor + 1)), (BUFFER, word(buffer)),
                              (DISPLAY_LIST, word(COMMANDS + len(emitted))),
                              (0x80126B84, word(vertex + (0 if rejected else 4))),
                              (0x80123AE4, word(-1 if rejected else vertex)),
                              (0x80123AE8, word(128 if rgba else 255)),
                              (0x80123B00, word(TEXTURE + alignment if rgba else TEXTURE)),
                              (0x80123B04, word(TEXTURE + alignment if rgba else 0x8007D6D0)),
                              (0x8008CB34, word(-31 if mutate else scale)),
                              (0x8013D9A0, b''.join(word(n) for n in ((-32001, 32001, -19) if mutate else position)))):
        assert bytes(uc.mem_read(address & 0x1FFFFFFF, len(expected))) == expected, (case, hex(address))
    return dict(matrix=packed.hex(), commands=emitted.hex(), trace=trace,
                vertex_sha256=hashlib.sha256(vertex_arena).hexdigest())


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, retail, support, comparisons = [], [], [], {}
    for name in NAMES + SUPPORT:
        _, source, start, end = next(r for r in MATCHING_BLOCKS if r[0] == name)
        comparison = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                                   end - 0x80000000 + 0xC00, target,
                                   family='renderer-image-setup-execution', layout=layout)
        assert comparison['matches'], name
        comparisons[name] = comparison
        directory = ROOT / 'build/renderer-image-setup-execution' / name
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
    counts = dict(cases=0, indexed=0, rgba=0, matrix_diagnostic=0, vertex_rejected=0, mode_mutation=0)
    digest = hashlib.sha256()
    for case in itertools.product(range(2), range(4), range(4), (0, 249), range(2), range(3), range(2), (0, 7)):
        expected = run_setup(retail, support, case)
        actual = run_setup(compiled, support, case)
        assert actual == expected, case
        counts['cases'] += 1
        counts['rgba' if case[0] else 'indexed'] += 1
        counts['matrix_diagnostic'] += int(case[3] == 249)
        counts['vertex_rejected'] += int(case[5] == 2)
        counts['mode_mutation'] += int(case[6])
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
    result = dict(matches=True, counts=counts, comparisons=comparisons,
                  trace_sha256=digest.hexdigest(), target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  machine_helper_sha256=hashlib.sha256((ROOT / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['Both complete wrappers and ten matching supporting units execute freshly compiled code.',
                          'Only mode selection and the fatal formatter use recorded integer ABI stubs.',
                          'Independent matrix, vertex, command and state oracles check entire guarded arenas.',
                          'Mode mutation checks the indexed-after-mode and RGBA-before-mode placement snapshots.',
                          'Unknown local draw fields are not assumed initialized or used by these callees.',
                          'The final valid matrix slot, last four vertices, allocator rejection and address alignment are exercised.',
                          'Invalid matrix selectors/storage, RSP/RDP rendering and full-game execution are outside this proof.'])
    output = ROOT / 'build/renderer-image-setup-execution/report.json'
    output.write_text(json.dumps(result, indent=2) + '\n')
    print('Passed image setup execution:', counts, output, flush=True)


if __name__ == '__main__':
    main()
