"""Execute matching rotation and path code against retail MIPS instructions.

Arithmetic callees and their initialized tables are freshly compiled and
matched. Completion and object-angle submission use recorded ABI stubs.
"""

import hashlib
import itertools
import json
import math
import struct
from importlib.metadata import version
from pathlib import Path

import unicorn
from unicorn import Uc, UC_ARCH_MIPS, UC_MODE_MIPS32, UC_MODE_BIG_ENDIAN, UC_HOOK_CODE, UC_HOOK_MEM_WRITE, UC_HOOK_MEM_READ
from unicorn import mips_const as regs
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS, CANDIDATE_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate
from actor_path_model import oracle as path_oracle


SUPPORT = ('object_recovery_fixed_trig', 'short_sine', 'short_cosine',
           'object_recovery_angle_scale', 'object_recovery_direction_angle',
           'object_recovery_angle_table', 'fixed_geometry_setup')
CHECKED_UNITS = ('actor_group_rotate', 'actor_group_path')
SENTINEL = 0x80000080
ACTOR, PARAMETER, POOL = 0x80210000, 0x80211000, 0x80212000


def word(value):
    return struct.pack('>I', value & 0xFFFFFFFF)


def machine(code, support):
    uc = Uc(UC_ARCH_MIPS, UC_MODE_MIPS32 | UC_MODE_BIG_ENDIAN)
    uc.mem_map(0, 0x400000)
    uc.mem_map(0x80000000, 0x400000)

    def write(address, data):
        uc.mem_write(address & 0x1FFFFFFF, data)
        uc.mem_write(address | 0x80000000, data)

    def mirror(uc, access, address, size, value, user):
        uc.mem_write(address ^ 0x80000000,
                     (value & ((1 << (size * 8)) - 1)).to_bytes(size, 'big'))

    uc.hook_add(UC_HOOK_MEM_WRITE, mirror)
    for address, data in support + code:
        write(address, data)
    saved = tuple(getattr(regs, 'UC_MIPS_REG_' + name)
                  for name in ('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP'))
    original = {register: 0xA2340000 + i * 256 for i, register in enumerate(saved)}
    for register, value in original.items():
        uc.reg_write(register, value)
    uc.reg_write(regs.UC_MIPS_REG_SP, 0x80300000)
    uc.reg_write(regs.UC_MIPS_REG_RA, SENTINEL)
    stopped = [False]

    def stop(uc, address, size, user):
        stopped[0] = True
        uc.emu_stop()

    uc.hook_add(UC_HOOK_CODE, stop, begin=SENTINEL, end=SENTINEL)

    def execute(entry):
        uc.emu_start(entry, 0, count=20000)
        if not stopped[0]:
            raise ValueError('Callback did not return within the instruction limit')
        assert uc.reg_read(regs.UC_MIPS_REG_SP) == 0x80300000
        assert all(uc.reg_read(register) == value for register, value in original.items())

    return uc, write, execute


def run_rotation(code, support, case):
    entry, angle, x, y, offset = case
    uc, write, execute = machine(code, support)
    source = 0x80201010
    write(source - 16, b'\xA5' * 64)
    write(source, word(x) + word(y) + word(0x5C507F11))
    uc.reg_write(regs.UC_MIPS_REG_A0, source + offset)
    uc.reg_write(regs.UC_MIPS_REG_A1, source)
    uc.reg_write(regs.UC_MIPS_REG_A2, angle & 0xFFFFFFFF)
    execute(entry)
    phase = (1024 - angle if entry == 0x8000E720 else angle) & 4095

    def fixed_sine(value):
        half = value & 2047
        index = min(half, 2047 - half)
        magnitude = math.floor(32767 * math.sin(index * math.pi / 2046)) // 8
        return -magnitude if value & 2048 else magnitude

    cosine, negative_sine = fixed_sine((phase + 1024) & 4095), -fixed_sine(phase)
    expected = bytearray(b'\xA5' * 64)
    expected[16:28] = word(x) + word(y) + word(0x5C507F11)
    for axis, value in enumerate((x * cosine - y * negative_sine,
                                  x * negative_sine + cosine * y)):
        wrapped = ((value + 0x80000000) & 0xFFFFFFFF) - 0x80000000
        result = abs(wrapped) // 4096 * (-1 if wrapped < 0 else 1)
        start = 16 + offset + axis * 4
        expected[start:start + 4] = word(result)
    observed = bytes(uc.mem_read((source - 16) & 0x1FFFFFFF, 64))
    assert observed == bytes(expected), ('Independent rotation arithmetic and memory oracle', case)
    return observed.hex()


def path_machine(code, helpers):
    code_ranges = [(start, end) for name, source, start, end in MATCHING_BLOCKS
                   if name in SUPPORT]
    data_ranges = [(address, address + len(data)) for address, data in helpers
                   if not any(start <= address < end for start, end in code_ranges)]
    uc, write, execute = machine(code, helpers)
    code_ranges += [(address, address + len(data)) for address, data in code]
    code_ranges += [(SENTINEL, SENTINEL + 4), (0x8000E5C8, 0x8000E5CC),
                    (0x80039514, 0x80039518)]
    state = [(ACTOR, ACTOR + 124), (PARAMETER, PARAMETER + 36),
             (POOL, POOL + 9096), (0x800AE4F4, 0x800AE4F8)]
    stack = (0x802FFE00, 0x80300020)
    canaries = []
    for start, end in state[:3] + [stack]:
        for address, data in ((start - 16, b'\xD7' * 16), (end, b'\xE9' * 16)):
            write(address, data)
            canaries.append((address, data))
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA578ABCD)

    def normalized(address):
        return (address & 0x1FFFFFFF) | 0x80000000

    def inside(address, size, ranges):
        return any(start <= address and address + size <= end for start, end in ranges)

    def instruction(uc, address, size, user):
        assert not address & 3 and inside(normalized(address), 4, code_ranges), (
            'Path instruction bounds', hex(address))

    def read(uc, access, address, size, value, user):
        assert inside(normalized(address), size, state + data_ranges + [stack]), (
            'Path read bounds', hex(address), size)

    def store(uc, access, address, size, value, user):
        assert inside(normalized(address), size, [(ACTOR, ACTOR + 124), stack]), (
            'Path write bounds', hex(address), size)

    def guarded(entry):
        handles = [uc.hook_add(UC_HOOK_CODE, instruction),
                   uc.hook_add(UC_HOOK_MEM_READ, read),
                   uc.hook_add(UC_HOOK_MEM_WRITE, store)]
        try:
            execute(entry)
        finally:
            for handle in handles:
                uc.hook_del(handle)
        assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xA578ABCD
        for address, expected in canaries:
            assert bytes(uc.mem_read(address & 0x1FFFFFFF, len(expected))) == expected, (
                'Path canary', hex(address))

    return uc, write, guarded


def run_path(code, support, case):
    count, index, progress_kind, speed, angle, group = case
    uc, write, execute = path_machine(code, support)
    actor = bytearray(b'\xA5' * 124)
    actor[12:14] = struct.pack('>h', 17)
    actor[0x28:0x2C] = word(PARAMETER)
    actor[0x4C:0x50] = word(index)
    lengths = (61, 420, 719, 1200)
    progress = (0, lengths[index] - 1, lengths[index])[progress_kind]
    actor[0x50:0x54] = word(progress)
    write(ACTOR, bytes(actor))
    parameter = word(7) + word(9) + word(group) + word(speed) + word(angle) + b'\xA7' * 16
    write(PARAMETER, parameter)
    pool = bytearray(b'\xA9' * 9096)
    path = 0x4E8 + group * 604
    pool[path:path + 4] = word(count)
    points = ((-3000, 700), (5000, -4000), (-101, 303), (9000, 17), (210, -270))
    for i, point in enumerate(points):
        pool[path + 4 + i * 8:path + 12 + i * 8] = word(point[0]) + word(point[1])
    for i, length in enumerate(lengths):
        pool[path + 404 + i * 4:path + 408 + i * 4] = word(length)
    write(POOL, bytes(pool))
    write(0x800AE4F4, word(POOL))
    trace = []

    def boundary(uc, address, size, user):
        args = [uc.reg_read(register) for register in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1)]
        trace.append([hex(address), args, bytes(uc.mem_read(ACTOR & 0x1FFFFFFF, 124)).hex()])
        if address == 0x8000E5C8:
            assert args == [ACTOR, 1]
        else:
            assert address == 0x80039514 and args[0] == 17
        for i, name in enumerate(('V0', 'V1', 'A0', 'A1', 'A2', 'A3',
                                  'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9')):
            uc.reg_write(getattr(regs, 'UC_MIPS_REG_' + name), 0xB2340000 + i * 256)
        uc.reg_write(regs.UC_MIPS_REG_PC, uc.reg_read(regs.UC_MIPS_REG_RA))

    for address in (0x8000E5C8, 0x80039514):
        uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)
    uc.reg_write(regs.UC_MIPS_REG_A0, ACTOR)
    uc.reg_write(regs.UC_MIPS_REG_A1, 0x12345678)
    execute(0x8000E894)
    assert bytes(uc.mem_read(PARAMETER & 0x1FFFFFFF, 36)) == parameter
    assert bytes(uc.mem_read(POOL & 0x1FFFFFFF, 9096)) == bytes(pool)
    result = bytes(uc.mem_read(ACTOR & 0x1FFFFFFF, 124))
    assert result[0x68:0x6C] == actor[0x68:0x6C]
    assert len(trace) == 1
    observed = dict(actor=result.hex(), trace=trace)
    assert observed == path_oracle(case), ('Independent actor path state/call oracle', case, observed)
    return observed


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    candidate, retail, support = [], [], []
    comparisons = {}
    compiled_hashes, target_hashes = {}, {}
    for name in CHECKED_UNITS + SUPPORT:
        records = MATCHING_BLOCKS + CANDIDATE_BLOCKS
        _, source, start, end = next(record for record in records if record[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target,
                               family='actor-group-execution', layout=layout)
        directory = ROOT / 'build/actor-group-execution' / name
        data = (directory / (name + '.bin')).read_bytes()
        comparisons[name] = report
        if name in CHECKED_UNITS and not report['matches']:
            raise ValueError('Complete actor-group source does not match: ' + name)
        compiled_hashes[name] = hashlib.sha256(data).hexdigest()
        target_hashes[name] = hashlib.sha256(target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]).hexdigest()
        if name in CHECKED_UNITS:
            candidate.append((start, data))
            retail.append((start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
        else:
            if not report['matches']:
                raise ValueError('Arithmetic support does not match: ' + name)
            support.append((start, data))
            sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
            for owned in source_sections(source):
                if owned['rom'] is not None:
                    if name == 'short_sine' and owned['vram'] == 0x8008DBB0:
                        mathematical = struct.pack('>1024h', *(math.floor(32767 * math.sin(index * math.pi / 2046))
                            for index in range(1024)))
                        assert sections[owned['section']]['bytes'] == mathematical
                    support.append((owned['vram'], sections[owned['section']]['bytes']))
    table_source = 'src/game/actor_groups/direction_table.c'
    table = compare_unit(table_source, source_sections(table_source), target, layout)
    sections, _ = elf_sections_and_symbols(ROOT / 'build/data-comparison' / Path(table_source).with_suffix('') / 'compiled.elf')
    support.append((0x8007C338, sections['.actor_direction_table']['bytes']))
    digest = hashlib.sha256()
    counts = dict(rotation=0, path=0, completed=0, interpolated=0)

    def check(kind, case):
        run = run_rotation if kind == 'rotation' else run_path
        expected = run(retail, support, case)
        actual = run(candidate, support, case)
        assert actual == expected, dict(case=case, expected=expected, actual=actual)
        digest.update(json.dumps([kind, case, actual], sort_keys=True).encode())
        counts[kind] += 1
        if kind == 'path':
            counts['completed' if actual['trace'][0][0] == '0x8000e5c8' else 'interpolated'] += 1
        if (counts['rotation'] + counts['path']) % 500 == 0:
            print('Compared', counts['rotation'], 'rotation and', counts['path'], 'path cases.', flush=True)

    entries = (0x8000E720, 0x8000E7E0)
    offsets = (-4, 0, 4, 12)
    for entry, angle in itertools.product(entries, range(4096)):
        check('rotation', (entry, angle, 1001, -3007, offsets[angle & 3]))
    coordinates = ((0, 0), (1, -1), (-1, 1), (32767, -32768), (-65000, 65000),
                   (0x7FFFFFFF, -0x80000000), (-17, -29), (4096, -4096))
    for entry, angle, coordinate, offset in itertools.product(entries, (-1, 4096, 8192, 0x7FFFFFFF, -0x80000000), coordinates, offsets):
        check('rotation', (entry, angle, *coordinate, offset))
    for count in (2, 3, 5):
        for index, progress, speed, angle, group in itertools.product(range(count - 1), range(3),
                (-0x80000000, -333, -14, -13, -1, 0, 1, 13, 14, 100, 1000, 0x7FFFFFFF),
                (0, 1, 511, 1023, 1024, 2047, 2048, 3072, 4095, 4096, -1, -0x80000000), (0, 9)):
            check('path', (count, index, progress, speed, angle, group))
    for angle in range(4096):
        check('path', (2, 0, 1, 13, angle, 0))
    result = dict(matches=True, counts=counts, trace_sha256=digest.hexdigest(), comparisons=comparisons,
                  compiled_code_sha256=compiled_hashes, target_code_sha256=target_hashes,
                  table_comparison=table, checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  oracle_sha256=hashlib.sha256((ROOT / 'tools/actor_path_model.py').read_bytes()).hexdigest(),
                  target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['Seven complete matching arithmetic units and two matching initialized tables execute compiled code.',
                          'All 1024 short-sine values agree with the mathematical generator; every rotation run checks an independent wrapped-arithmetic and guarded-buffer oracle.',
                          'Completion and object-angle submission use ABI-clobbering stubs and record arguments and actor state.',
                          'All 4096 masked angles and the listed wrap, overlap, coordinate, path, progress and speed cases are checked.',
                          'Each retail and candidate path execution independently checks full actor memory and call snapshots against a wrapped-integer model.',
                          'Path execution checks instruction/read/write bounds, surrounding canaries, GP, stack and saved registers.',
                          'Signed overflow cases characterize the pinned compiler and target; they do not establish portable ISO C behavior.',
                          'Zero distances and invalid indices/counts are not exercised; complete game behavior remains unverified.',
                          'The two rotation procedures and the complete path callback are independently instruction matched.'])
    output = ROOT / 'build/actor-group-execution/report.json'
    output.write_text(json.dumps(result, indent=2) + '\n')
    print('Passed actor-group execution:', counts, output, flush=True)


if __name__ == '__main__':
    main()
