"""Compare the excluded bonus child candidate with retail MIPS execution."""

import hashlib
import itertools
import json
import struct
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE
from unicorn import mips_const as regs
from check_actor_group_path import SUPPORT, machine, word
from compare_data import compare_unit, comparison_directory
from compare_runtime import MATCHING_BLOCKS, CANDIDATE_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


PARENT, CHILD, TARGET = 0x80210000, 0x80220010, 0x80211000
RESOURCES = 0x800AC998
FLOAT_CLOBBER = 0x80000100
SUPPORT_UNITS = SUPPORT + ('scene_service_noop',)
NAME = 'actor_group_bonus_child'


def run_child(code, support, case):
    kind, allocated, index, random, speed, angle, slot, scale, point = case
    # Unicorn exposes MIPS FPU register IDs but does not implement their writes.
    # Execute mtc1 instructions in the ABI stub instead of changing FPU state
    # through that unavailable register API.
    clobber = word(0x3C013F80)
    clobber += b''.join(word(0x44810000 | (i << 11)) for i in range(20))
    clobber += word(0x03E00008) + word(0)
    uc, write, execute = machine(code + [(FLOAT_CLOBBER, clobber)], support)
    uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS,
                 uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | (1 << 29))
    parent = bytearray(b'\xA5' * 124)
    parent[8:10] = struct.pack('>h', angle)
    parent[0x60:0x6C] = word(-2000) + word(7000) + word(2000)
    write(PARENT, bytes(parent))
    child = bytearray(b'\xA6' * 124)
    child[12:14] = struct.pack('>h', 17)
    child[0x24:0x28] = word(RESOURCES + kind * 92)
    child[0x60:0x6C] = parent[0x60:0x6C]
    write(CHILD - 16, b'\xC7' * 156)
    write(CHILD, bytes(child))
    initial_child = bytes(uc.mem_read((CHILD - 16) & 0x1FFFFFFF, 156))
    target = bytearray(b'\xA8' * 124)
    target[0x60:0x6C] = word(point[0]) + word(point[1]) + word(1900)
    write(TARGET, bytes(target))
    resources = bytearray(b'\xA9' * 1012)
    resources[kind * 92 + 8:kind * 92 + 16] = word(speed) + word(scale)
    write(RESOURCES, bytes(resources))
    sessions = bytearray(b'\xAA' * (3508 * 2))
    sessions[slot * 3508 + 8:slot * 3508 + 12] = word(TARGET)
    write(0x8009B190, bytes(sessions))
    write(0x800AD168, word(slot))
    trace = []
    argument_counts = {0x800283D4: 3, 0x8000CE34: 1, 0x8004CDE8: 0,
                       0x800399E4: 2, 0x80039514: 2, 0x80039BE4: 2}
    arguments = (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                 regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)

    def boundary(uc, address, size, user):
        args = [uc.reg_read(r) for r in arguments[:argument_counts[address]]]
        trace.append([hex(address), args,
                      bytes(uc.mem_read(CHILD & 0x1FFFFFFF, 124)).hex()])
        if address == 0x800283D4:
            assert args == [5, RESOURCES + kind * 92, PARENT + 0x60]
            result = CHILD if allocated else 0
        elif address == 0x8000CE34:
            assert args == [4]
            result = 0x8000C2F4
        elif address == 0x8004CDE8:
            result = random
        else:
            assert args[0] == 17
            if address == 0x80039BE4:
                assert args[1] == 3
            result = 0
        for i, name in enumerate(('V0', 'V1', 'A0', 'A1', 'A2', 'A3',
                                  'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9')):
            uc.reg_write(getattr(regs, 'UC_MIPS_REG_' + name), 0xB2340000 + i * 256)
        uc.reg_write(regs.UC_MIPS_REG_V0, result & 0xFFFFFFFF)
        uc.reg_write(regs.UC_MIPS_REG_PC, FLOAT_CLOBBER)

    for address in argument_counts:
        uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)
    uc.reg_write(regs.UC_MIPS_REG_A0, PARENT)
    uc.reg_write(regs.UC_MIPS_REG_A1, index)
    uc.reg_write(regs.UC_MIPS_REG_A2, kind)
    execute(0x8000F030)
    assert bytes(uc.mem_read(PARENT & 0x1FFFFFFF, 124)) == bytes(parent)
    assert bytes(uc.mem_read(TARGET & 0x1FFFFFFF, 124)) == bytes(target)
    assert bytes(uc.mem_read(RESOURCES & 0x1FFFFFFF, 1012)) == bytes(resources)
    assert bytes(uc.mem_read(0x9B190, len(sessions))) == bytes(sessions)
    assert bytes(uc.mem_read(0xAD168, 4)) == word(slot)
    output = bytes(uc.mem_read((CHILD - 16) & 0x1FFFFFFF, 156))
    assert output[:16] == initial_child[:16] and output[-16:] == initial_child[-16:]
    returned = uc.reg_read(regs.UC_MIPS_REG_V0)
    assert returned == (CHILD if allocated else 0)
    if allocated:
        expected_calls = [0x800283D4]
        if kind == 4:
            expected_calls.append(0x8000CE34)
        elif kind != 9:
            expected_calls.append(0x800399E4)
        if kind != 9:
            expected_calls.append(0x8004CDE8)
        expected_calls.extend((0x80039514, 0x80039BE4))
        assert [int(call[0], 16) for call in trace] == expected_calls
        if kind not in (4, 9):
            numerator = (scale << 13) & 0xFFFFFFFF
            if numerator & 0x80000000:
                numerator -= 0x100000000
            scale_bits = struct.unpack('>I', struct.pack('>f', numerator / 40960.0))[0]
            assert trace[1][1] == [17, scale_bits]
        assert output[16 + 0x68:16 + 0x6C] == word(-1000)
        assert output[16 + 0x3C:16 + 0x40] == word(PARENT)
        if kind == 9:
            assert output[16:20] == word(0x80005560)
        elif kind == 4:
            assert output[16:20] == word(0x8000C2F4)
    else:
        assert output == initial_child and len(trace) == 1
    return dict(child=output.hex(), returned=returned, trace=trace)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, retail, support = [], [], []
    comparisons = {}
    for name in (NAME,) + SUPPORT_UNITS:
        records = CANDIDATE_BLOCKS if name == NAME else MATCHING_BLOCKS
        _, source, start, end = next(r for r in records if r[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target,
                               family='actor-bonus-execution', layout=layout)
        directory = ROOT / 'build/actor-bonus-execution' / name
        data = (directory / (name + '.bin')).read_bytes()
        comparisons[name] = report
        if name == NAME:
            compiled.append((start, data))
            retail.append((start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
        else:
            if not report['matches']:
                raise ValueError('Support unit does not match: ' + name)
            support.append((start, data))
            sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
            for owned in source_sections(source):
                if owned['rom'] is not None:
                    support.append((owned['vram'], sections[owned['section']]['bytes']))
    table_source = 'src/game/actor_groups/direction_table.c'
    table = compare_unit(table_source, source_sections(table_source), target, layout)
    sections, _ = elf_sections_and_symbols(comparison_directory(table_source) / 'compiled.elf')
    support.append((0x8007C338, sections['.actor_direction_table']['bytes']))
    counts = dict(cases=0, allocation_failed=0, draw_callback=0, fixed_callback=0, scaled=0)
    digest = hashlib.sha256()

    def check(case):
        expected = run_child(retail, support, case)
        actual = run_child(compiled, support, case)
        assert actual == expected, dict(case=case, expected=expected, actual=actual)
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
        kind, allocated = case[:2]
        counts['cases'] += 1
        counts['allocation_failed' if not allocated else
               'draw_callback' if kind == 4 else 'fixed_callback' if kind == 9 else 'scaled'] += 1
        if counts['cases'] % 250 == 0:
            print('Compared', counts['cases'], 'bonus child cases.', flush=True)

    for case in itertools.product((4, 9, 6), (False, True), (0, 4, 11),
                                  (-0x80000000, -9, -1, 0, 8192), (-60, 0, 200),
                                  (-1, 1024, 4095), (0, 1)):
        check((*case, 1280, (-3000, -4000)))
    for kind, scale, point in itertools.product((0, 6, 10), (-1, 0, 51200, 262143),
            ((-2000, 7000), (-2000, -4000), (5000, 7000), (5000, -4000))):
        check((kind, True, 4, -9, 200, 1, 0, scale, point))
    result = dict(matches=True, counts=counts, comparisons=comparisons,
                  table_comparison=table, trace_sha256=digest.hexdigest(),
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  machine_helper_sha256=hashlib.sha256((ROOT / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
                  target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  code_sha256={name: hashlib.sha256((ROOT / 'build/actor-bonus-execution' /
                                name / (name + '.bin')).read_bytes()).hexdigest() for name in comparisons},
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['Eight complete matching support units and two matching initialized tables execute compiled code.',
                          'Allocation, draw selection, RNG, scale submission, angle submission and mode submission use recorded ABI stubs.',
                          'The allocator boundary returns a prepared child or null; allocator, drawing and full-game behavior are not verified.',
                          'Stubs clobber caller-saved integer and float registers; actor, target, resource, session and child guards are checked.',
                          'Signed overflow characterizes only the pinned compiler and target; invalid kinds and allocation aliasing are not exercised.',
                          'Execution agreement does not establish instruction matching for the excluded bonus child function.'])
    output = ROOT / 'build/actor-bonus-execution/report.json'
    output.write_text(json.dumps(result, indent=2) + '\n')
    print('Passed bonus child execution:', counts, output, flush=True)


if __name__ == '__main__':
    main()
