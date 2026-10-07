"""Check complete movie storage and execute its consumers against retail."""

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

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UC_MEM_WRITE
from unicorn import mips_const as regs

from check_actor_group_path import SENTINEL, machine, word
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import source_sections
from rom import ROOT, validate


TRACKS, CONFIG, ACTIVE = 0x800B00B8, 0x800B14B0, 0x800B1BE0
CONFIG_POINTER, CURRENT = 0x800B14A8, 0x800972A0
INPUT, LOADED, INTEGER, FLOAT, STACK = 0x80210010, 0x80218010, 0x80219010, 0x8021A010, 0x80300000
SUPPORT = ('movie_reset', 'movie_files', 'movie_callback', 'game_memory', 'game_string_append')
STORAGE = (('src/game/movie_storage/tracks.c', TRACKS, 5100),
           ('src/game/movie_storage/configuration.c', CONFIG, 1836))
ENTRIES = {'reset': 0x80002EE0, 'lookup': 0x80003A7C, 'load': 0x80003A7C,
           'release': 0x80003CF8, 'callback': 0x8000440C}
CALLER_SAVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                    ('V0', 'V1', 'A0', 'A1', 'A2', 'A3',
                     'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'HI', 'LO'))
PRESERVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                  ('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP', 'SP', 'GP', 'RA'))
CONSTANTS = {'prefix': 0x8008F8B0, 'path_suffix': 0x8008F8B8,
             'new_suffix': 0x8008F8C0, 'track_diagnostic': 0x8008F8C8,
             'header_suffix': 0x8008F8E0, 'integer_suffix': 0x8008F8E8,
             'float_suffix': 0x8008F8F0, 'callback_diagnostic': 0x8008F8F8}


def pattern(size, seed):
    return bytearray((i * 37 + (i >> 8) * 11 + seed) & 255 for i in range(size))


def run(code, ranges, constants, kind, seed, slot=0, channels=0, filename=b'clip.old'):
    uc, write, _ = machine(code, list(constants.values()))
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA57281D9)
    saved = {r: uc.reg_read(r) for r in PRESERVED}
    panel_start = TRACKS - 16
    panels = {'movie': (panel_start, pattern(ACTIVE + 20 - panel_start, seed)),
              'current': (CURRENT - 16, pattern(36, seed + 1)),
              'input': (INPUT - 16, pattern(72, seed + 2)),
              'loaded': (LOADED - 16, pattern(236, seed + 3))}
    movie = panels['movie'][1]
    for i in range(25):
        p = 16 + i * 204
        movie[p + 0x34:p + 0x38] = word(1000 + i)
        movie[p + 0x74:p + 0x78] = word(1)
        movie[p + 0x84:p + 0x88] = word(channels & 1)
        movie[p + 0x88:p + 0x8C] = word((channels >> 1) & 1)
        movie[p + 0xC4:p + 0xC8] = word(INTEGER + i * 4)
        movie[p + 0xC8:p + 0xCC] = word(FLOAT + i * 4)
    movie[CONFIG_POINTER - panel_start:CONFIG_POINTER - panel_start + 4] = word(CONFIG)
    panels['current'][1][16:20] = word(TRACKS + 3 * 204)
    assert len(filename) < 40 and b'\0' not in filename
    panels['input'][1][16:17 + len(filename)] = filename + b'\0'
    header = panels['loaded'][1]
    header[16 + 0x84:16 + 0x88] = word(channels & 1)
    header[16 + 0x88:16 + 0x8C] = word((channels >> 1) & 1)
    if kind == 'load':
        p = 16 + slot * 204
        movie[p + 0x74:p + 0x78] = word(0)
    elif kind == 'callback':
        movie[CONFIG - panel_start + 0x664:CONFIG - panel_start + 0x668] = word(slot)
    expected = {name: bytearray(data) for name, (_, data) in panels.items()}
    writes, wanted_trace, trace = Counter(), [], []
    writable = []
    wanted_return = None
    selected = TRACKS + slot * 204

    def store(address, data):
        start = address - panel_start
        expected['movie'][start:start + len(data)] = data
        writable.append((address, address + len(data)))

    if kind == 'reset':
        store(TRACKS, bytes(5100))
        store(CONFIG, bytes(1836))
        store(ACTIVE, word(0))
    elif kind == 'lookup':
        wanted_return = slot
        uc.reg_write(regs.UC_MIPS_REG_A0, 1000 + slot)
        uc.reg_write(regs.UC_MIPS_REG_A1, INPUT)
    elif kind == 'load':
        wanted_return = slot
        store(selected, bytes(header[16:220]))
        store(selected + 0x74, word(1))
        store(selected + 0x34, word(9001))
        expected['current'][16:20] = word(selected)
        writable.append((CURRENT, CURRENT + 4))
        prefix = constants['prefix'][1][:-1] + filename
        if b'.' in prefix:
            path = prefix.split(b'.', 1)[0] + constants['path_suffix'][1][:-1]
        else:
            path = prefix + constants['new_suffix'][1][:-1]
        header_path = path.split(b'.', 1)[0] + constants['header_suffix'][1][:-1]
        wanted_trace += [('load', header_path.hex(), LOADED), ('release', LOADED)]
        if channels & 1:
            wanted_trace.append(('load', path.split(b'.', 1)[0].hex() + constants['integer_suffix'][1][:-1].hex(), INTEGER))
            store(selected + 0xC4, word(INTEGER))
        if channels & 2:
            wanted_trace.append(('load', path.split(b'.', 1)[0].hex() + constants['float_suffix'][1][:-1].hex(), FLOAT))
            store(selected + 0xC8, word(FLOAT))
        uc.reg_write(regs.UC_MIPS_REG_A0, 9001)
        uc.reg_write(regs.UC_MIPS_REG_A1, INPUT)
    elif kind == 'release':
        store(selected + 0x74, word(0))
        if channels & 1:
            wanted_trace.append(('release', INTEGER + slot * 4))
        if channels & 2:
            wanted_trace.append(('release', FLOAT + slot * 4))
        uc.reg_write(regs.UC_MIPS_REG_A0, slot)
    elif kind == 'callback':
        store(CONFIG + 0x648 + slot * 8, word(0x80002EE0) + word(-17))
        store(CONFIG + 0x664, word(slot + 1))
        uc.reg_write(regs.UC_MIPS_REG_A0, 0x80002EE0)
        uc.reg_write(regs.UC_MIPS_REG_A1, 0xFFFFFFEF)
    else:
        raise ValueError(kind)
    for address, data in panels.values():
        write(address, bytes(data))
    lower, upper = STACK - 0x610, STACK + 32
    write(lower, bytes([0xD7]) * 16)
    write(upper, bytes([0xE9]) * 16)
    stack_range = (lower + 16, upper)
    readable = [(TRACKS, TRACKS + 5100), (CONFIG, CONFIG + 1836),
                (ACTIVE, ACTIVE + 4), (CONFIG_POINTER, CONFIG_POINTER + 4),
                (CURRENT, CURRENT + 4), (INPUT, INPUT + 40), (LOADED, LOADED + 204)]
    readable += [(address, address + len(data)) for address, data in constants.values()]
    readable.append(stack_range)

    def contains(address, size, bounds):
        return any(start <= address and address + size <= end for start, end in bounds)

    def access(uc, access, address, size, value, user):
        address = (address & 0x1FFFFFFF) | 0x80000000
        assert contains(address, size, user), ('Memory bounds', kind, hex(address), size)
        if access == UC_MEM_WRITE and not contains(address, size, [stack_range]):
            writes[(address, size)] += 1

    uc.hook_add(UC_HOOK_MEM_READ, access, user_data=readable)
    uc.hook_add(UC_HOOK_MEM_WRITE, access, user_data=writable + [stack_range])

    def string(address):
        result = bytearray()
        for i in range(256):
            assert contains(address + i, 1, readable), ('String read bounds', hex(address + i))
            value = uc.mem_read((address + i) & 0x1FFFFFFF, 1)[0]
            if value == 0:
                return result.hex()
            result.append(value)
        raise AssertionError('Unterminated resource path')

    boundaries = {0x8003C64C, 0x8003C698, 0x8001C0D0}
    allowed_code = list(ranges) + [(SENTINEL, SENTINEL + 4)]

    def instruction(uc, address, size, user):
        if address in boundaries:
            args = [uc.reg_read(r) for r in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1)]
            if address == 0x8003C64C:
                assert len(trace) < len(wanted_trace) and wanted_trace[len(trace)][0] == 'load', 'Unexpected load'
                returned = wanted_trace[len(trace)][2]
                event = ('load', string(args[0]), returned)
                assert contains(args[1], 4, [stack_range]), 'Resource size destination'
                uc.mem_write(args[1] & 0x1FFFFFFF, word(204 if returned == LOADED else 32))
            elif address == 0x8003C698:
                event, returned = ('release', args[0]), 0
            else:
                raise AssertionError(('Unexpected diagnostic', kind, args[0]))
            assert len(trace) < len(wanted_trace) and event == wanted_trace[len(trace)], ('Call oracle', event, wanted_trace[len(trace):])
            trace.append(event)
            ra = uc.reg_read(regs.UC_MIPS_REG_RA)
            for i, register in enumerate(CALLER_SAVED):
                uc.reg_write(register, 0xA1387500 + i * 17)
            uc.reg_write(regs.UC_MIPS_REG_V0, returned)
            uc.reg_write(regs.UC_MIPS_REG_PC, ra)
        else:
            assert contains(address, size, allowed_code), ('Code bounds', kind, hex(address))

    uc.hook_add(UC_HOOK_CODE, instruction)
    uc.emu_start(ENTRIES[kind], 0, count=200000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, 'Consumer did not return'
    assert all(uc.reg_read(r) == value for r, value in saved.items()), ('O32 preservation', kind)
    assert trace == wanted_trace, ('Missing service call', kind)
    if wanted_return is not None:
        assert uc.reg_read(regs.UC_MIPS_REG_V0) == wanted_return, ('Return', kind, slot)
    for name, (address, data) in panels.items():
        assert bytes(uc.mem_read(address & 0x1FFFFFFF, len(data))) == bytes(expected[name]), ('Complete guarded object', kind, name, slot, channels)
    assert bytes(uc.mem_read(lower & 0x1FFFFFFF, 16)) == bytes([0xD7]) * 16
    assert bytes(uc.mem_read(upper & 0x1FFFFFFF, 16)) == bytes([0xE9]) * 16
    if kind == 'reset':
        expected_writes = Counter({(address, 1): 1 for base, size in ((TRACKS, 5100), (CONFIG, 1836)) for address in range(base, base + size)})
        expected_writes[(ACTIVE, 4)] = 1
        assert writes == expected_writes, 'Complete reset footprint'
    return hashlib.sha256(b''.join(bytes(expected[name]) for name in sorted(expected)) + json.dumps(trace).encode()).hexdigest()


def prepare_images():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    data = {}
    for source, address, size in STORAGE:
        records = source_sections(source)
        assert len(records) == 1 and records[0]['rom'] is None
        assert (records[0]['vram'], records[0]['size']) == (address, size)
        data[source] = compare_unit(source, records, target, layout)
    comparisons, original, compiled = {}, [], []
    directory = ROOT / 'build/movie-storage-check'
    for name, source, start, end in MATCHING_BLOCKS:
        if name not in SUPPORT:
            continue
        report = compare_block(name, source, start, start - 0x7FFFF400, end - 0x7FFFF400,
                               target, family='movie-storage-check', layout=layout)
        assert report['matches'], (name, report['different_words'])
        comparisons[name] = report
        original.append((start, target[start - 0x7FFFF400:end - 0x7FFFF400]))
        compiled.append((start, (directory / name / (name + '.bin')).read_bytes()))
    assert set(comparisons) == set(SUPPORT)
    constants = {}
    for name, address in CONSTANTS.items():
        offset = address - 0x7FFFF400
        end = target.index(0, offset) + 1
        assert 0 < end - offset < 128
        constants[name] = (address, target[offset:end])
    ranges = tuple((address, address + len(blob)) for address, blob in original)
    return target, layout, data, comparisons, original, compiled, ranges, constants


MUTATIONS = {
    'reset_short': ('src/game/movie_reset.c', 'sizeof(D_800B00B8)', 'sizeof(D_800B00B8) - 1', dict(kind='reset')),
    'last_track': ('src/game/movie_files.c', 'index < MOVIE_TRACK_COUNT', 'index < MOVIE_TRACK_COUNT - 1', dict(kind='lookup', slot=24)),
    'header_short': ('src/game/movie_files.c', 'sizeof(MovieTrackState)', 'sizeof(MovieTrackState) - 1', dict(kind='load', slot=24)),
    'release_channel': ('src/game/movie_files.c', 'if (D_800B00B8[index].integerChannelCount != 0)', 'if (D_800B00B8[index].integerChannelCount == 0)', dict(kind='release', slot=24, channels=1)),
    'callback_frame': ('src/game/movie_callback.c', '.frame = frame;', '.frame = frame + 1;', dict(kind='callback', slot=2)),
}


def mutation_check(name):
    if ROOT.parent.name != '.local' or not ROOT.name.startswith('movie-storage-' + name + '-'):
        raise ValueError('Source mutations require an isolated audit directory')
    target, layout, _, _, original, compiled, ranges, constants = prepare_images()
    relative, old, new, case = MUTATIONS[name]
    assert run(original, ranges, constants, seed=173, **case) == run(compiled, ranges, constants, seed=173, **case), 'Mutation positive control'
    path = ROOT / relative
    content = path.read_text()
    assert content.count(old) == 1, ('Mutation anchor', name)
    path.write_text(content.replace(old, new))
    _, _, start, end = next(row for row in MATCHING_BLOCKS if row[1] == relative)
    report = compare_block('mutated', relative, start, start - 0x7FFFF400, end - 0x7FFFF400,
                           target, family='movie-storage-mutations', layout=layout)
    assert not report['matches'], 'Unchanged mutation'
    blob = (ROOT / 'build/movie-storage-mutations/mutated/mutated.bin').read_bytes()
    candidate = [(a, b) for a, b in compiled if a != start] + [(start, blob)]
    bounds = tuple((a, a + len(b)) for a, b in candidate)
    try:
        run(candidate, bounds, constants, seed=173, **case)
    except AssertionError as error:
        print(json.dumps({'name': name, 'control_passed': True, 'mutation_rejected': True,
                          'different_words': len(report['different_words']), 'reason': str(error)}))
        return
    raise ValueError('Movie storage checker missed mutation: ' + name)


def check_mutations():
    results = []
    for name in MUTATIONS:
        with tempfile.TemporaryDirectory(prefix='movie-storage-' + name + '-', dir=ROOT / '.local') as temporary:
            root = Path(temporary)
            assert root.resolve().parent == (ROOT / '.local').resolve()
            for folder in ('src', 'include', 'config', 'tools', 'docs'):
                shutil.copytree(ROOT / folder, root / folder)
            shutil.copy2(ROOT / 'Makefile', root / 'Makefile')
            (root / '.local').mkdir()
            (root / '.local/toolchain').symlink_to(ROOT / '.local/toolchain', target_is_directory=True)
            (root / 'baseroms/us').mkdir(parents=True)
            (root / 'baseroms/us/baserom.z64').symlink_to(ROOT / 'baseroms/us/baserom.z64')
            result = subprocess.run([sys.executable, str(root / 'tools/check_movie_storage.py'), '--mutation', name], capture_output=True, text=True)
            if result.returncode:
                raise ValueError(f'Movie storage mutation {name} failed:\n{result.stdout}\n{result.stderr}')
            record = json.loads(result.stdout.splitlines()[-1])
            assert record['control_passed'] and record['mutation_rejected']
            results.append(record)
    return results


def main(mutations=False):
    _, layout, data, comparisons, original, compiled, ranges, constants = prepare_images()
    cases = []
    for seed in (0, 173, 255):
        cases.append(dict(kind='reset', seed=seed))
        for slot in range(25):
            cases.append(dict(kind='lookup', seed=seed, slot=slot))
            for kind, channels in itertools.product(('load', 'release'), range(4)):
                cases.append(dict(kind=kind, seed=seed, slot=slot, channels=channels,
                                  filename=b'clip.old' if slot % 2 else b'clip'))
        for slot in range(3):
            cases.append(dict(kind='callback', seed=seed, slot=slot))
    results = []
    for case in cases:
        retail = run(original, ranges, constants, **case)
        recovered = run(compiled, ranges, constants, **case)
        assert retail == recovered, case
        results.append({'case': {key: value.hex() if isinstance(value, bytes) else value for key, value in case.items()}, 'sha256': recovered})
    controls = check_mutations() if mutations else []
    layout.verify()
    report = {'matches': True, 'paired_cases': len(cases), 'target_executions': len(cases) * 2,
              'bss_bytes': 6936, 'storage': data, 'comparisons': comparisons,
              'case_kinds': dict(Counter(case['kind'] for case in cases)),
              'cases_sha256': hashlib.sha256(json.dumps(results, sort_keys=True).encode()).hexdigest(),
              'mutations': controls, 'versions': {name: version(name) for name in ('unicorn', 'capstone', 'pyelftools')},
              'limitations': ['Resource load/free and diagnostic services are recorded clobbering integer ABI boundaries.',
                              'Fixtures have valid pointers and bounded names. All 25 valid track slots and three valid callback slots are exercised.',
                              'Exhausted track/callback allocations, invalid indices and overflowing paths are not repaired or executed.',
                              'Channel payloads, callbacks, interpolation, rendering and complete movie/gameplay behavior are not executed.']}
    path = ROOT / 'build/movie-storage-check/report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: report[key] for key in ('matches', 'paired_cases', 'target_executions', 'bss_bytes')}))
    print(f'Rejected {len(controls)} source mutations; report: {path.relative_to(ROOT)}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mutation', choices=MUTATIONS)
    parser.add_argument('--mutations', action='store_true')
    args = parser.parse_args()
    mutation_check(args.mutation) if args.mutation else main(args.mutations)
