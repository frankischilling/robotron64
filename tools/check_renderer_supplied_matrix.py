"""Check matching matrix scaling, SDK packing and post-write diagnostics.

Only the overflow formatter uses a recorded integer ABI stub. Each execution
is checked against an independent arithmetic and guarded-memory oracle.
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
from compare_data import compare_unit, comparison_directory
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


NAME = 'renderer_matrix_scale'
DRAW, INPUT, COMMANDS, ARENA = 0x80210010, 0x80211010, 0x80220010, 0x80126B90
CURSOR, BUFFER, DISPLAY_LIST = 0x8007D6A8, 0x8007D910, 0x80138254
MATRICES = ((32767, 0, 0, 0, 32767, 0, 0, 0, 32767),
            (0, -32768, 0, 32767, 0, 0, 0, 0, 16384),
            (-70001, 12345, 65535, 17, -999, 40001, 131071, -65537, -1),
            (0x7FFFFFFF, -0x80000000, 1, -1, 0x12345678, -0x12345678, 0, 15, -15))
SCALES = ((16, 16, 16), (-16, 31, 0), (4097, -8193, 65535),
          (0x7FFFFFFF, -0x80000000, -1))
POSITIONS = ((0, 1, -1), (32000, -32000, 12345), (32001, -32001, 32001),
             (-32001, 32001, -32001), (0x7FFFFFFF, -0x80000000, 0),
             (31999, -31999, -17))


def signed(value):
    return (value + 0x80000000) % 0x100000000 - 0x80000000


def half(value):
    return struct.pack('>H', value & 0xFFFF)


def run_submission(code, diagnostics, case):
    matrix_index, scale_index, position_index, cursor, buffer, diagnostic_change = case
    uc, write, execute = machine(code, [])
    matrix = MATRICES[matrix_index]
    scales = SCALES[scale_index]
    position = POSITIONS[position_index]
    draw = bytearray(b'\xA5' * 60)
    draw[4:16] = b''.join(word(n) for n in scales)
    draw[40:52] = b''.join(word(n) for n in position)
    draw_guard = b'\xC5' * 16 + bytes(draw) + b'\xC5' * 16
    input_guard = b'\xC6' * 16 + b''.join(word(n) for n in matrix) + b'\xC6' * 16
    arena = bytearray(b'\xA7' * 32000)
    command_guard = b'\xC8' * 40
    write(DRAW - 16, draw_guard)
    write(INPUT - 16, input_guard)
    write(ARENA - 16, b'\xC7' * 16 + bytes(arena) + b'\xC7' * 16)
    write(COMMANDS - 16, command_guard)
    write(CURSOR, word(cursor))
    write(BUFFER, word(buffer))
    write(DISPLAY_LIST, word(COMMANDS))
    write(0x800953A0, diagnostics)
    trace = []
    clamped = tuple(max(-32000, min(32000, n)) for n in position)
    scaled = tuple(signed(n * scales[i // 3]) >> 4 for i, n in enumerate(matrix))
    integer = [scaled[r * 3 + c] >> 15 for c in range(3) for r in range(3)]
    fractional = [scaled[r * 3 + c] << 1 for c in range(3) for r in range(3)]
    integer = integer[:3] + [0] + integer[3:6] + [0] + integer[6:9] + [0] + list(clamped) + [1]
    fractional = fractional[:3] + [0] + fractional[3:6] + [0] + fractional[6:9] + [0] + [0] * 4
    packed = b''.join(half(n) for n in integer + fractional)
    offset = cursor * 128 + buffer * 64
    arena[offset:offset + 64] = packed
    command = word(0x01020040) + word(ARENA + offset - 0x80000000)

    def boundary(uc, address, size, user):
        args = [uc.reg_read(r) for r in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                         regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)]
        stack = uc.reg_read(regs.UC_MIPS_REG_SP)
        args.append(int.from_bytes(uc.mem_read((stack + 16) & 0x1FFFFFFF, 4), 'big'))
        assert args == [0x800953A0, cursor + 1, 250, 0x800953D4, 247]
        # The retail diagnostic runs after both matrix and command submission.
        assert bytes(uc.mem_read((ARENA + offset) & 0x1FFFFFFF, 64)) == packed
        assert bytes(uc.mem_read(COMMANDS & 0x1FFFFFFF, 8)) == command
        assert bytes(uc.mem_read(DISPLAY_LIST & 0x1FFFFFFF, 4)) == word(COMMANDS + 8)
        assert bytes(uc.mem_read(CURSOR & 0x1FFFFFFF, 4)) == word(cursor + 1)
        trace.append(args)
        if diagnostic_change:
            write(CURSOR, word(cursor + 11))
        for i, name in enumerate(('V0', 'V1', 'A0', 'A1', 'A2', 'A3',
                                  'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9')):
            uc.reg_write(getattr(regs, 'UC_MIPS_REG_' + name), 0xB2340000 + i * 256)
        uc.reg_write(regs.UC_MIPS_REG_PC, uc.reg_read(regs.UC_MIPS_REG_RA))

    uc.hook_add(UC_HOOK_CODE, boundary, begin=0x800496E0, end=0x800496E0)
    uc.reg_write(regs.UC_MIPS_REG_A0, DRAW)
    uc.reg_write(regs.UC_MIPS_REG_A1, INPUT)
    execute(0x80047A08)
    draw[40:52] = b''.join(word(n) for n in clamped)
    for address, expected in ((DRAW - 16, b'\xC5' * 16 + bytes(draw) + b'\xC5' * 16),
                              (INPUT - 16, input_guard),
                              (ARENA - 16, b'\xC7' * 16 + bytes(arena) + b'\xC7' * 16),
                              (COMMANDS - 16, b'\xC8' * 16 + command + b'\xC8' * 16),
                              (BUFFER, word(buffer)), (0x800953A0, diagnostics),
                              (DISPLAY_LIST, word(COMMANDS + 8)),
                              (CURSOR, word(cursor + 1 + (10 if diagnostic_change else 0)))):
        assert bytes(uc.mem_read(address & 0x1FFFFFFF, len(expected))) == expected
    result = cursor + (10 if diagnostic_change else 0)
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == result
    assert len(trace) == (1 if cursor == 249 else 0)
    return dict(draw=bytes(draw).hex(), matrix=packed.hex(), command=command.hex(),
                result=result, diagnostic=trace)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    _, source, start, end = next(r for r in MATCHING_BLOCKS if r[0] == NAME)
    comparison = compare_block(NAME, source, start, 0x48608, 0x48988, target,
                               family='renderer-supplied-matrix-execution', layout=layout)
    assert comparison['matches']
    compiled = (ROOT / 'build/renderer-supplied-matrix-execution' / NAME / (NAME + '.bin')).read_bytes()
    dsource = 'src/game/renderer_diagnostics/supplied_matrix.c'
    ownership = source_sections(dsource)
    assert len(ownership) == 1
    data_comparison = compare_unit(dsource, ownership, target, layout)
    sections, _ = elf_sections_and_symbols(comparison_directory(dsource) / 'compiled.elf')
    diagnostics = sections[ownership[0]['section']]['bytes']
    assert len(diagnostics) == 64
    counts = dict(cases=0, diagnostic=0, diagnostic_cursor_change=0)
    digest = hashlib.sha256()
    for matrix, scale, position, cursor, buffer in itertools.product(range(4), range(4), range(6), (0, 248, 249), range(2)):
        for change in (False, True) if cursor == 249 else (False,):
            case = (matrix, scale, position, cursor, buffer, change)
            expected = run_submission([(start, target[0x48608:0x48988])], diagnostics, case)
            actual = run_submission([(start, compiled)], diagnostics, case)
            assert actual == expected, case
            counts['cases'] += 1
            counts['diagnostic'] += int(cursor == 249)
            counts['diagnostic_cursor_change'] += int(change)
            digest.update(json.dumps([case, actual], sort_keys=True).encode())
    result = dict(matches=True, counts=counts, comparison=comparison,
                  data_comparison=data_comparison, trace_sha256=digest.hexdigest(),
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  machine_helper_sha256=hashlib.sha256((ROOT / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
                  target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['The complete supplied-matrix routine and both diagnostic strings are freshly matched.',
                          'A 32-bit arithmetic oracle checks row scaling, transposed SDK planes and coordinate clamping.',
                          'The entire guarded matrix arena, draw state, input, command and cursors are checked.',
                          'The overflow formatter uses a recorded integer ABI stub, including optional cursor mutation.',
                          'The write-before-check sequence is exercised at the final valid matrix index, 249.',
                          'Out-of-arena cursors, invalid selectors, aliased inputs, RSP rendering and full-game execution are not exercised.'])
    output = ROOT / 'build/renderer-supplied-matrix-execution/report.json'
    output.write_text(json.dumps(result, indent=2) + '\n')
    print('Passed supplied-matrix execution:', counts, output, flush=True)


if __name__ == '__main__':
    main()
