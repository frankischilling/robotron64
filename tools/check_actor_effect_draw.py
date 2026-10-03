"""Execute the matching effect callback with real fixed-matrix helpers.

Renderer submissions use recorded ABI stubs. The fixtures check selection,
signed arithmetic, display-list writes and memory preservation independently.
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


NAME = 'actor_effect_draw'
SUPPORT = ('frame_transform', 'fixed_math')
ACTOR, RESOURCE, COMMANDS = 0x80210010, 0x80211000, 0x80230010
TABLE, MATRIX = 0x80072C00, 0x800CD250
MATRICES = ((32767, 0, 0, 0, 32767, 0, 0, 0, 32767),
            (0, -32768, 0, 32767, 0, 0, 0, 0, 16384))


def signed(value):
    return (value + 0x80000000) % 0x100000000 - 0x80000000


def divide(value, divisor):
    return -(abs(value) // divisor) if value < 0 else value // divisor


def run_draw(code, support, table, case):
    requested, phase, matrix_index, handle, fixture = case
    table = bytearray(table)
    if fixture != 'retail':
        for index in range(31):
            table[index * 40 + 36:index * 40 + 40] = word(RESOURCE + index * 88)
    if fixture == 'duplicate':
        table[17 * 40 + 36:17 * 40 + 40] = table[6 * 40 + 36:6 * 40 + 40]
    if fixture == 'nonzero_billboard':
        table[28:32] = word(-7)
    resource = RESOURCE + 31 * 88 if requested == -1 else struct.unpack_from(
        '>I', table, requested * 40 + 36)[0]
    assert resource != 0
    selected = next((i for i in range(31) if struct.unpack_from(
        '>I', table, i * 40 + 36)[0] == resource), 0)
    config = struct.unpack_from('>8i2I', table, selected * 40)
    frame, frame_delta, scale, scale_delta, height, flag, flag_delta, billboard, palette, _ = config
    uc, write, execute = machine(code, support)
    write(TABLE, bytes(table))
    actor = bytearray(b'\xA5' * 124)
    object_index = 7 if matrix_index else 0
    actor[12:14] = struct.pack('>h', object_index)
    actor[0x24:0x28] = word(resource)
    actor[0x4C:0x50] = word(phase)
    actor_guard = b'\xC7' * 16 + bytes(actor) + b'\xC7' * 16
    write(ACTOR - 16, actor_guard)
    resource_data = bytearray(b'\xA6' * 88)
    resource_data[0x24:0x26] = struct.pack('>h', handle)
    write(resource, bytes(resource_data))
    object_address = 0x800BF918 + object_index * 120
    record = bytearray(b'\xA8' * 120)
    position = (-3001, 7001, -5999)
    camera = (1000, -2000, 4000)
    record[0x54:0x60] = b''.join(word(n) for n in position)
    record_guard = b'\xC8' * 16 + bytes(record) + b'\xC8' * 16
    write(object_address - 16, record_guard)
    view = b'\xA9' * 28 + b''.join(word(n) for n in camera)
    write(0x800C8BD8, view)
    matrix = b''.join(word(n) for n in MATRICES[matrix_index])
    write(MATRIX, matrix)
    palette_data = b'\xAA' * 64
    write(palette, palette_data)
    texture = word(0x80260000) + word(0xABABABAB)
    texture_address = 0x8007BAC4 + handle * 8
    write(texture_address, texture)
    write(COMMANDS - 16, b'\xCC' * 64)
    write(0x80138254, word(COMMANDS))
    trace = []
    arg_counts = {0x8004729C: 1, 0x80049AD8: 1, 0x8004ABBC: 1,
                  0x80047A08: 2, 0x8004A6B4: 1, 0x8004A938: 1}
    arg_registers = (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1)

    def boundary(uc, address, size, user):
        args = [uc.reg_read(r) for r in arg_registers[:arg_counts[address]]]
        call = [hex(address), args]
        if address == 0x80047A08:
            submitted = bytes(uc.mem_read(args[1] & 0x1FFFFFFF, 36))
            assert args[0] == object_address + 0x38
            if billboard:
                assert args[1] == MATRIX
            else:
                assert 0x802FFF78 <= args[1] <= 0x80300000 - 36
            assert submitted == (matrix if billboard else b''.join(word(n) for n in MATRICES[0]))
            call.append(submitted.hex())
        trace.append(call)
        for i, name in enumerate(('V0', 'V1', 'A0', 'A1', 'A2', 'A3',
                                  'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9')):
            uc.reg_write(getattr(regs, 'UC_MIPS_REG_' + name), 0xB2340000 + i * 256)
        uc.reg_write(regs.UC_MIPS_REG_PC, uc.reg_read(regs.UC_MIPS_REG_RA))

    for address in arg_counts:
        uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)
    uc.reg_write(regs.UC_MIPS_REG_A0, ACTOR)
    # The retail object loop also passes the object base as its second argument.
    uc.reg_write(regs.UC_MIPS_REG_A1, object_address)
    execute(0x80005560)
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == 0
    interpolation = lambda base, delta: signed(base + divide(signed(delta * phase), 256))
    expected_scale = interpolation(scale, scale_delta) >> 4
    relative = tuple((position[i] + (height * 12 if i == 1 else 0) - camera[i]) >> 1 for i in range(3))
    projected = [signed(sum(signed(relative[j] * MATRICES[matrix_index][i * 3 + j]) >> 15
                            for j in range(3))) for i in range(3)]
    record[0x3C:0x48] = word(expected_scale) * 3
    record[0x60:0x6C] = b''.join(word(n) for n in projected)
    assert bytes(uc.mem_read((object_address - 16) & 0x1FFFFFFF, 152)) == b'\xC8' * 16 + bytes(record) + b'\xC8' * 16
    packets = b''.join(word(n) for n in (0xE7000000, 0, 0xBA000C02, 0x2000,
                                        0xBA001001, 0, 0xBA001301, 0x80000))
    assert bytes(uc.mem_read((COMMANDS - 16) & 0x1FFFFFFF, 64)) == b'\xCC' * 16 + packets + b'\xCC' * 16
    assert bytes(uc.mem_read(0x138254, 4)) == word(COMMANDS + 32)
    expected_texture = (0x80260000 + interpolation(frame, frame_delta) * 1024) & 0xFFFFFFFF
    expected_trace = [[hex(0x8004729C), [15]], [hex(0x80049AD8), [palette]],
                      [hex(0x8004ABBC), [interpolation(flag, flag_delta) & 0xFFFFFFFF]],
                      [hex(0x80047A08), [object_address + 0x38, MATRIX if billboard else trace[3][1][1]]],
                      [hex(0x8004A938 if billboard else 0x8004A6B4), [expected_texture]]]
    assert [call[:2] for call in trace] == expected_trace
    for address, expected in ((ACTOR - 16, actor_guard), (resource, bytes(resource_data)),
                              (TABLE, bytes(table)), (0x800C8BD8, view), (MATRIX, matrix),
                              (palette, palette_data), (texture_address, texture)):
        assert bytes(uc.mem_read(address & 0x1FFFFFFF, len(expected))) == expected
    return dict(selected=selected, billboard=bool(billboard), object=bytes(record).hex(),
                commands=packets.hex(), trace=trace)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, retail, support, comparisons = [], [], [], {}
    for name in (NAME,) + SUPPORT:
        _, source, start, end = next(r for r in MATCHING_BLOCKS if r[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target,
                               family='actor-effect-execution', layout=layout)
        assert report['matches'], name
        comparisons[name] = report
        data = (ROOT / 'build/actor-effect-execution' / name / (name + '.bin')).read_bytes()
        if name == NAME:
            compiled.append((start, data))
            retail.append((start, target[0x6160:0x6414]))
        else:
            support.append((start, data))
    source = 'src/game/actor_effects/draw_config.c'
    ownership = source_sections(source)
    assert len(ownership) == 1
    table_report = compare_unit(source, ownership, target, layout)
    sections, _ = elf_sections_and_symbols(comparison_directory(source) / 'compiled.elf')
    table = sections[ownership[0]['section']]['bytes']
    assert len(table) == 1240
    counts = dict(cases=0, retail_configuration=0, synthetic_configuration=0,
                  fallback=0, duplicate_first_match=0, billboard=0, identity=0)
    digest = hashlib.sha256()

    def check(case):
        expected = run_draw(retail, support, table, case)
        actual = run_draw(compiled, support, table, case)
        assert actual == expected, case
        counts['cases'] += 1
        counts['retail_configuration' if case[4] == 'retail' else 'synthetic_configuration'] += 1
        counts['billboard' if actual['billboard'] else 'identity'] += 1
        if case[0] == -1:
            assert actual['selected'] == 0
            counts['fallback'] += 1
        if case[4] == 'duplicate':
            assert actual['selected'] == 6
            counts['duplicate_first_match'] += 1
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
        if counts['cases'] % 250 == 0:
            print('Compared', counts['cases'], 'effect draw cases.', flush=True)

    for index in range(31):
        if struct.unpack_from('>I', table, index * 40 + 36)[0]:
            for matrix_index in range(2):
                check((index, 255, matrix_index, 3, 'retail'))
    for index, phase, matrix_index, handle in itertools.product(range(31),
            (-257, -1, 0, 1, 255, 256, 511), range(2), (-1, 0, 3)):
        check((index, phase, matrix_index, handle, 'synthetic'))
    for phase, matrix_index in itertools.product((-257, 0, 256), range(2)):
        check((-1, phase, matrix_index, 3, 'retail'))
        check((17, phase, matrix_index, 3, 'duplicate'))
        check((0, phase, matrix_index, 3, 'nonzero_billboard'))
    result = dict(matches=True, counts=counts, comparisons=comparisons,
                  table_comparison=table_report, trace_sha256=digest.hexdigest(),
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  machine_helper_sha256=hashlib.sha256((ROOT / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
                  target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['The complete callback, frame transform and identity matrix routines are freshly matched and executed.',
                          'Retail table pointers and synthetic copies exercise first-match, duplicate and fallback selection.',
                          'Renderer state, palette, flag, matrix and texture submissions use recorded integer ABI stubs.',
                          'The six renderer callees, texture contents, allocator and full-game drawing are not executed.',
                          'Actor, resource, configuration, camera, texture record, palette and object/command guards are checked.',
                          'The oracle uses pinned 32-bit arithmetic; null resources and invalid object storage are not exercised.'])
    output = ROOT / 'build/actor-effect-execution/report.json'
    output.write_text(json.dumps(result, indent=2) + '\n')
    print('Passed actor effect execution:', counts, output, flush=True)


if __name__ == '__main__':
    main()
