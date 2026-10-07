"""Check complete player/save BSS with real copies and recorded service boundaries."""

import argparse
from collections import Counter
import hashlib
from importlib.metadata import version
import itertools
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs

from check_actor_group_path import SENTINEL, machine, word
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import source_sections
from rom import ROOT, validate


PLAYERS, PLAYER_SIZE, PLAYER_COUNT = 0x8009B190, 3508, 2
SESSION, SESSION_SIZE = 0x800AD138, 328
CONFIGURATION, CONFIGURATION_SIZE = 0x800AD2F8, 32
IMAGE, IMAGE_SIZE = 0x800AD318, 4096
SOURCE, STACK = 0x80210010, 0x80300000
COPY = 0x8003B520
ENTRIES = {'options_capture': 0x8002FE00, 'slot_capture': 0x8002FE68,
           'options_restore': 0x8002FF40, 'slot_restore': 0x8002FFC8,
           'clear': 0x80032D00, 'write': 0x80030420}
SUPPORT = ('game_memory', 'save_options_capture', 'save_slot_capture',
           'save_options_restore', 'save_slot_restore', 'player_fields_clear',
           'save_file_write')
STORAGE = (('src/game/save_storage/players.c', PLAYERS, 7016),
           ('src/game/save_storage/configuration.c', CONFIGURATION, 32),
           ('src/game/save_storage/image.c', IMAGE, 4096))
BOUNDARIES = {0x8001A2C4: 0, 0x80051888: 1, 0x80051854: 1,
              0x8004C378: 2, 0x8004C3AC: 2, 0x8004C5DC: 4,
              0x8004C648: 1, 0x80030054: 0}
TRACKED = {COPY: 3, ENTRIES['options_capture']: 1,
           ENTRIES['options_restore']: 1, **BOUNDARIES}
CALLER_SAVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                    ('V0', 'V1', 'A0', 'A1', 'A2', 'A3',
                     'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9'))
PRESERVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                  ('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP', 'SP', 'GP', 'RA'))


def pattern(size, seed):
    return bytearray((index * 37 + (index >> 8) * 11 + seed) & 255
                     for index in range(size))


def run(code, ranges, kind, seed, player=0, slot=0, connected=1,
        handle=7, transferred=4096, clear_failed=0):
    uc, write, _ = machine(code, [])
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA57281D9)
    preserved = {register: uc.reg_read(register) for register in PRESERVED}
    panels = {
        'players': (PLAYERS - 16, pattern(7016 + 32, seed)),
        'session': (SESSION - 16, pattern(SESSION_SIZE + 32, seed + 1)),
        'save': (CONFIGURATION - 16, pattern(CONFIGURATION_SIZE + IMAGE_SIZE + 32, seed + 2)),
        'source': (SOURCE - 16, pattern(4096 + 32, seed + 3)),
        'templates': (0x80075D78, pattern(456, seed + 4)),
        'checksum_cache': (0x80077BF0, pattern(36, seed + 5)),
        'selection': (0x800BB148, pattern(36, seed + 6)),
    }
    panels['session'][1][16 + 0x30:16 + 0x34] = word(player)
    panels['selection'][1][16:20] = word(slot)
    expected = {name: bytearray(data) for name, (address, data) in panels.items()}
    p, session, save = expected['players'], expected['session'], expected['save']
    source = expected['source'][16:16 + 4096]
    config_offset, image_offset = 16, 48
    traces, expected_trace = [], []
    io_image = None
    checksum_reads = Counter()
    result = None
    responses = {0x8004C378: connected, 0x8004C3AC: handle, 0x8004C5DC: transferred}

    def call(address, *arguments):
        expected_trace.append([address, list(arguments)])

    def capture_options(destination, offset):
        call(ENTRIES['options_capture'], destination)
        call(COPY, destination, CONFIGURATION, 24)
        options = (save[16:48] + p[16 + 0x34:16 + 0x38] +
                   p[16 + PLAYER_SIZE + 0x34:16 + PLAYER_SIZE + 0x38])
        save[offset:offset + 40] = options

    def restore_options(address, offset):
        call(ENTRIES['options_restore'], address)
        call(COPY, CONFIGURATION, address, 24)
        save[16:48] = source[offset:offset + 32]
        p[16 + 0x34:16 + 0x38] = source[offset + 32:offset + 36]
        p[16 + PLAYER_SIZE + 0x34:16 + PLAYER_SIZE + 0x38] = source[offset + 36:offset + 40]
        call(0x8001A2C4)
        call(0x80051888, int.from_bytes(source[offset + 28:offset + 32], 'big'))
        call(0x80051854, int.from_bytes(source[offset + 24:offset + 28], 'big'))

    if kind == 'clear':
        for index in range(2):
            for offset in (8, 0x1C):
                start = 16 + index * PLAYER_SIZE + offset
                p[start:start + 4] = word(0)
    elif kind == 'options_capture':
        destination = IMAGE + 0xFA8
        uc.reg_write(regs.UC_MIPS_REG_A0, destination)
        capture_options(destination, image_offset + 0xFA8)
    elif kind == 'slot_capture':
        destination = IMAGE + 0x1C8 + slot * 444
        offset = image_offset + 0x1C8 + slot * 444
        uc.reg_write(regs.UC_MIPS_REG_A0, destination)
        start = 16 + player * PLAYER_SIZE + 0xD6C
        p[start:start + 4] = session[16 + 0x28:16 + 0x2C]
        for index in range(2):
            call(COPY, destination + 76 + index * 160, PLAYERS + index * PLAYER_SIZE, 160)
            save[offset + 76 + index * 160:offset + 76 + (index + 1) * 160] = p[
                16 + index * PLAYER_SIZE:16 + index * PLAYER_SIZE + 160]
            save[offset + 396 + index * 4:offset + 400 + index * 4] = p[
                16 + index * PLAYER_SIZE + 0xD6C:16 + index * PLAYER_SIZE + 0xD70]
        call(COPY, destination, SESSION, 76)
        save[offset:offset + 76] = session[16:16 + 76]
        capture_options(destination + 404, offset + 404)
    elif kind == 'options_restore':
        uc.reg_write(regs.UC_MIPS_REG_A0, SOURCE)
        restore_options(SOURCE, 0)
    elif kind == 'slot_restore':
        uc.reg_write(regs.UC_MIPS_REG_A0, SOURCE)
        for index in range(2):
            call(COPY, PLAYERS + index * PLAYER_SIZE, SOURCE + 76 + index * 160, PLAYER_SIZE)
            p[16 + index * PLAYER_SIZE:16 + (index + 1) * PLAYER_SIZE] = source[
                76 + index * 160:76 + index * 160 + PLAYER_SIZE]
        call(COPY, SESSION, SOURCE, 76)
        session[16:16 + 76] = source[:76]
        restore_options(SOURCE + 404, 404)
    elif kind == 'write':
        uc.reg_write(regs.UC_MIPS_REG_A0, clear_failed)
        call(0x8004C378, 0, 0)
        if connected:
            call(COPY, IMAGE, 0x80075D88, 20)
            call(COPY, IMAGE + 20, 0x80075DA0, 400)
            save[48:68] = expected['templates'][16:36]
            save[68:468] = expected['templates'][40:440]
            capture_options(IMAGE + 0xFA8, 48 + 0xFA8)
            call(0x8004C3AC, 0, 0x80094018)
            if handle in (0, -1):
                result = 0
            else:
                checksum = (0x12345678 + sum(int.from_bytes(save[48 + i:52 + i], 'big')
                            for i in range(0, 1011 * 4, 4))) & 0xFFFFFFFF
                save[48 + 0xFD0:48 + 0xFD4] = word(checksum)
                io_image = bytes(save[48:48 + 4096])
                call(0x8004C5DC, IMAGE, 256, 16, handle)
                call(0x8004C648, handle)
                if transferred == 4096:
                    expected['checksum_cache'][16:20] = word(checksum)
                    result = 1
                else:
                    result = -3
        else:
            result = -2
        if handle not in (0, -1) or not connected:
            if result <= 0 and clear_failed:
                start = 48 + 0x1A8 + slot * 4
                save[start:start + 4] = word(0)
            else:
                call(0x80030054)
    else:
        raise ValueError(kind)

    for address, data in panels.values():
        write(address, bytes(data))
    lower_guard = bytes(range(0xA0, 0xB0))
    upper_guard = bytes(range(0xB0, 0xC0))
    write(STACK - 0x190, lower_guard)
    write(STACK, bytes(pattern(32, seed + 7)) + upper_guard)
    allowed = tuple((address, address + len(data)) for address, data in panels.values())
    stack_range = (STACK - 0x180, STACK + 32)

    def guard_code(uc, address, size, user):
        assert (any(start <= address < end for start, end in ranges) or
                address in BOUNDARIES or address == SENTINEL), ('Unexpected code', hex(address))
        if address in TRACKED:
            arguments = [uc.reg_read(getattr(regs, 'UC_MIPS_REG_A' + str(i)))
                         for i in range(TRACKED[address])]
            event = [address, arguments]
            assert len(traces) < len(expected_trace) and event == expected_trace[len(traces)], (
                'Call trace', event, expected_trace[len(traces):len(traces) + 1])
            traces.append(event)
        if address == 0x8004C5DC:
            observed = bytes(uc.mem_read(IMAGE & 0x1FFFFFFF, 4096))
            assert observed == io_image, 'Complete write buffer and checksum'
        if address in BOUNDARIES:
            return_address = uc.reg_read(regs.UC_MIPS_REG_RA)
            for index, register in enumerate(CALLER_SAVED):
                uc.reg_write(register, 0xABCD0000 + index * 0x111)
            uc.reg_write(regs.UC_MIPS_REG_V0, responses.get(address, 0) & 0xFFFFFFFF)
            uc.reg_write(regs.UC_MIPS_REG_PC, return_address)

    def guard_read(uc, access, address, size, value, user):
        address |= 0x80000000
        assert any(start <= address and address + size <= end for start, end in allowed + (stack_range,)), (
            'Unexpected read', hex(address), size)
        if IMAGE <= address < IMAGE + 1011 * 4 and size == 4:
            checksum_reads[address] += 1

    def guard_write(uc, access, address, size, value, user):
        address |= 0x80000000
        mutable = tuple((start, end) for start, end in allowed
                        if start not in (SOURCE - 16, 0x80075D78))
        assert any(start <= address and address + size <= end for start, end in mutable + (stack_range,)), (
            'Unexpected write', hex(address), size)

    uc.hook_add(UC_HOOK_CODE, guard_code)
    uc.hook_add(UC_HOOK_MEM_READ, guard_read)
    uc.hook_add(UC_HOOK_MEM_WRITE, guard_write)
    uc.emu_start(ENTRIES[kind], 0, count=200000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, 'Instruction bound or missing return'
    assert all(uc.reg_read(register) == value for register, value in preserved.items()), 'O32 preservation'
    assert traces == expected_trace, 'Complete call trace'
    wanted_reads = Counter({IMAGE + i * 4: 1 for i in range(1011)}) if io_image is not None else Counter()
    assert checksum_reads == wanted_reads, 'Checksum covers exactly 1011 words'
    for name, (address, data) in panels.items():
        observed = bytes(uc.mem_read(address & 0x1FFFFFFF, len(data)))
        assert observed == expected[name], ('Complete guarded object', kind, name, seed, player, slot)
    assert bytes(uc.mem_read((STACK - 0x190) & 0x1FFFFFFF, 16)) == lower_guard, 'Lower stack guard'
    assert bytes(uc.mem_read((STACK + 32) & 0x1FFFFFFF, 16)) == upper_guard, 'Upper stack guard'
    if result is not None:
        assert uc.reg_read(regs.UC_MIPS_REG_V0) == result & 0xFFFFFFFF, 'File write result'
    return {'kind': kind, 'seed': seed, 'player': player, 'slot': slot,
            'connected': connected, 'handle': handle, 'transferred': transferred,
            'clear_failed': clear_failed, 'trace': traces,
            'checksum_word_reads': sum(checksum_reads.values()),
            'objects_sha256': {name: hashlib.sha256(data).hexdigest() for name, data in expected.items()}}


def prepare_images():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    data = {}
    for source, base, size in STORAGE:
        records = source_sections(source)
        assert len(records) == 1 and records[0]['rom'] is None
        assert (records[0]['vram'], records[0]['size']) == (base, size)
        data[source] = compare_unit(source, records, target, layout)
    comparisons, original, compiled, ranges = {}, [], [], []
    for name, source, start, end in MATCHING_BLOCKS:
        if name not in SUPPORT:
            continue
        report = compare_block(name, source, start, start - 0x7FFFF400, end - 0x7FFFF400,
                               target, family='save-state-storage-check', layout=layout)
        assert report['matches'], (name, report)
        comparisons[name] = report
        original.append((start, target[start - 0x7FFFF400:end - 0x7FFFF400]))
        path = ROOT / 'build/save-state-storage-check' / name / (name + '.bin')
        compiled.append((start, path.read_bytes()))
        ranges.append((COPY, 0x8003B594) if name == 'game_memory' else (start, end))
    assert set(comparisons) == set(SUPPORT)
    return target, layout, data, comparisons, original, compiled, tuple(ranges)


MUTATIONS = {
    'one_player': ('src/game/player_fields_clear.c', 'index < 2', 'index < 1', 'clear'),
    'capture_full_player': ('src/game/save_slot_capture.c', 'sizeof(SavedPlayerState)',
                            'sizeof(GamePlayerState)', 'slot_capture'),
    'restore_saved_prefix': ('src/game/save_slot_restore.c', 'sizeof(GamePlayerState)',
                             'sizeof(SavedPlayerState)', 'slot_restore'),
    'configuration_short': ('src/game/save_options_capture.c', '0x18', '0x14', 'options_capture'),
    'checksum_extra_word': ('src/game/save_file_write.c', 'word < 1011', 'word < 1012', 'write'),
    'write_short_image': ('src/game/save_file_write.c', '0x100, 0x10, handle', '0x100, 0xF, handle', 'write'),
}


def mutation_check(name):
    if ROOT.parent.name != '.local' or not ROOT.name.startswith('save-state-storage-' + name + '-'):
        raise ValueError('Source mutations require an isolated audit directory')
    target, layout, _, _, original, compiled, ranges = prepare_images()
    relative, old, new, kind = MUTATIONS[name]
    assert run(original, ranges, kind, 173) == run(compiled, ranges, kind, 173), 'Mutation positive control'
    source = ROOT / relative
    contents = source.read_text()
    assert contents.count(old) == 1, ('Mutation anchor', name)
    source.write_text(contents.replace(old, new))
    block_name, _, start, end = next(row for row in MATCHING_BLOCKS if row[1] == relative)
    report = compare_block('mutated', relative, start, start - 0x7FFFF400, end - 0x7FFFF400,
                           target, family='save-state-storage-mutations', layout=layout)
    assert not report['matches'], 'Unchanged mutation'
    candidate = [(address, code) for address, code in compiled if address != start]
    candidate.append((start, (ROOT / 'build/save-state-storage-mutations/mutated/mutated.bin').read_bytes()))
    mutated_ranges = tuple((a, b) if a != start else (a, a + len(candidate[-1][1])) for a, b in ranges)
    try:
        run(candidate, mutated_ranges, kind, 173)
    except AssertionError as error:
        print(json.dumps({'name': name, 'control_passed': True, 'mutation_rejected': True,
                          'different_words': len(report['different_words']), 'reason': str(error)}))
        return
    raise ValueError('Save storage checker missed mutation: ' + name)


def check_mutations():
    results = []
    local = ROOT / '.local'
    local.mkdir(exist_ok=True)
    for name in MUTATIONS:
        with tempfile.TemporaryDirectory(prefix='save-state-storage-' + name + '-', dir=local) as temporary:
            root = Path(temporary)
            assert root.resolve().parent == local.resolve()
            for folder in ('src', 'include', 'config', 'tools', 'docs'):
                shutil.copytree(ROOT / folder, root / folder)
            shutil.copy2(ROOT / 'Makefile', root / 'Makefile')
            (root / '.local').mkdir()
            (root / '.local/toolchain').symlink_to(ROOT / '.local/toolchain', target_is_directory=True)
            (root / 'baseroms/us').mkdir(parents=True)
            (root / 'baseroms/us/baserom.z64').symlink_to(ROOT / 'baseroms/us/baserom.z64')
            result = subprocess.run([sys.executable, str(root / 'tools/check_save_state_storage.py'),
                                     '--mutation', name], capture_output=True, text=True)
            if result.returncode:
                raise ValueError(f'Save storage mutation {name} failed:\n{result.stderr}')
            record = json.loads(result.stdout.splitlines()[-1])
            assert record['control_passed'] and record['mutation_rejected']
            results.append(record)
    return results


def main(mutations=False):
    target, layout, data, comparisons, original, compiled, ranges = prepare_images()
    cases = []
    for seed in (0, 173, 255):
        for kind in ('clear', 'options_capture', 'options_restore', 'slot_restore'):
            cases.append(dict(kind=kind, seed=seed))
        for player, slot in itertools.product(range(2), range(8)):
            cases.append(dict(kind='slot_capture', seed=seed, player=player, slot=slot))
        for connected, clear_failed, slot, handle, transferred in itertools.product(
                (0, 1, -1), (0, 1), range(8), (0, -1, 7), (4095, 4096, 4097)):
            cases.append(dict(kind='write', seed=seed, connected=connected,
                              clear_failed=clear_failed, slot=slot, handle=handle, transferred=transferred))
    results = []
    for case in cases:
        retail = run(original, ranges, **case)
        recovered = run(compiled, ranges, **case)
        assert retail == recovered, case
        results.append(recovered)
    mutation_results = check_mutations() if mutations else []
    layout.verify()
    report = {'matches': True, 'paired_cases': len(cases), 'target_executions': len(cases) * 2,
              'bss_bytes': 11144, 'storage': data, 'comparisons': comparisons,
              'cases': results, 'mutations': mutation_results,
              'versions': {name: version(name) for name in ('unicorn', 'capstone', 'pyelftools')},
              'boundaries': {hex(address): count for address, count in BOUNDARIES.items()},
              'limitations': ['File services, audio/configuration application and menu refresh use ABI stubs.',
                              'Save-file reading, callback effects, hardware and full gameplay are not executed.',
                              'Restore fixtures provide the complete retail read span beyond saved prefixes.',
                              'Other player views retain their historical N64 ABI and aliasing assumptions.']}
    path = ROOT / 'build/save-state-storage-check/report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: report[key] for key in ('matches', 'paired_cases', 'target_executions', 'bss_bytes')}))
    print(f'Rejected {len(mutation_results)} source mutations; report: {path.relative_to(ROOT)}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mutation', choices=MUTATIONS)
    parser.add_argument('--mutations', action='store_true')
    args = parser.parse_args()
    mutation_check(args.mutation) if args.mutation else main(args.mutations)
