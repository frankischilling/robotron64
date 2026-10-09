"""Execute complete script-resource consumers with guarded source-owned storage."""

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


FILES, OFFSETS, SCENES = 0x80097650, 0x800A3AD8, 0x800A42B0
STRING_COUNT, SCENE_COUNT, LEVEL = 0x800A42A8, 0x800A4530, 0x800BA7A0
INPUT, LOADED, STRINGS, STACK = 0x80210010, 0x80218010, 0x8009FC50, 0x80300000
ENTRIES = {'reset': 0x8001C740, 'register': 0x8001C790, 'find': 0x8001C8C4,
           'load': 0x8001C968, 'get': 0x8001C9FC, 'release': 0x8001CA78,
           'unregister': 0x8001CAF4, 'append': 0x8001CBE8,
           'select': 0x8001F2D8, 'offset_reset': 0x80038390, 'lookup': 0x800383C4}
SUPPORT = ('script_service_cache_reset', 'script_service_files', 'script_service_cache_access',
           'script_service_commands', 'scene_file_select', 'resource_string_reset',
           'string_resource', 'game_memory', 'game_string_case_compare', 'game_character')
STORAGE = (('src/game/script_storage/files.c', FILES, 12800),
           ('src/game/script_storage/strings.c', OFFSETS, 2002),
           ('src/game/script_storage/scenes.c', SCENES, 644))
BOUNDARIES = {0x8001C0D0: None, 0x8001C49C: None, 0x8003C64C: 2,
              0x8003C698: 1, 0x8001F2CC: 2}
CALLER_SAVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                    ('V0', 'V1', 'A0', 'A1', 'A2', 'A3',
                     'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9'))
PRESERVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                  ('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP', 'SP', 'GP', 'RA'))


def pattern(size, seed):
    return bytearray((i * 37 + (i >> 8) * 11 + seed) & 255 for i in range(size))


def run(code, ranges, kind, seed, handle=0, state=0, text=b'new.dat', count=0, level=0, offset=0):
    uc, write, _ = machine(code, [])
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA57281D9)
    preserved = {r: uc.reg_read(r) for r in PRESERVED}
    panels = {'files': (FILES - 16, pattern(12832, seed)),
              'resources': (OFFSETS - 16, pattern(2684, seed + 1)),
              'level': (LEVEL - 16, pattern(36, seed + 3)),
              'input': (INPUT - 16, pattern(160, seed + 4)),
              'strings': (STRINGS - 16, pattern(544, seed + 5)),
              'loaded': (LOADED - 16, pattern(544, seed + 6))}
    files = panels['files'][1]
    offsets = panels['resources'][1]
    scenes = memoryview(offsets)[SCENES - OFFSETS:]
    for i in range(100):
        p = 16 + i * 128
        flags = int.from_bytes(files[p:p + 4], 'big') & 0x3FFFFFFF
        files[p:p + 4] = word(flags | 0xC0000000)
        files[p + 4:p + 8] = word(72 + i)
        files[p + 8:p + 12] = word(LOADED + i * 4)
        name = f'File{i}'.encode() + b'\0'
        files[p + 12:p + 12 + len(name)] = name
        path = f'levels\\File{i}'.encode() + b'\0'
        files[p + 26:p + 26 + len(path)] = path
    for i in range(1000):
        offsets[16 + i * 2:18 + i * 2] = (i % 80 * 5).to_bytes(2, 'big')
    for i in range(80):
        scenes[16 + i * 8:24 + i * 8] = word(i * 3 - 100) + word(i)
        name = f's{i:02d}'.encode() + b'\0'
        p = 16 + i * 5
        panels['strings'][1][p:p + len(name)] = name
    scenes[656:660] = word(count)
    panels['level'][1][16:20] = word(level)
    panels['input'][1][16:16 + len(text) + 1] = text + b'\0'
    if kind == 'register' and handle < 100:
        p = 16 + handle * 128
        files[p:p + 4] = word(int.from_bytes(files[p:p + 4], 'big') & 0x7FFFFFFF)
    elif kind == 'find':
        for i in range(100):
            if state == 1 or (state == 2 and i % 2 == 0) or (state == 3 and i == handle):
                p = 16 + i * 128
                files[p:p + 4] = word(int.from_bytes(files[p:p + 4], 'big') & 0x7FFFFFFF)
    elif kind in ('load', 'get', 'release', 'unregister'):
        p = 16 + handle * 128
        flags = int.from_bytes(files[p:p + 4], 'big') & 0x3FFFFFFF
        files[p:p + 4] = word(flags | (0x80000000 if state & 1 else 0) |
                             (0x40000000 if state & 2 else 0))
    if kind == 'append':
        scenes[656:660] = word(handle)
        panels['input'][1][16:52] = word(0x71) + word(999 - handle) + bytes(28)
    if kind == 'lookup':
        offsets[16 + handle * 2:18 + handle * 2] = (offset & 0xFFFF).to_bytes(2, 'big')
    expected = {name: bytearray(data) for name, (address, data) in panels.items()}
    expected_offsets = expected['resources']
    expected_scenes = memoryview(expected_offsets)[SCENES - OFFSETS:]
    wanted_trace, trace = [], []
    result = None
    selected = None

    def call(address, *args):
        wanted_trace.append([address, list(args)])

    if kind == 'reset':
        for i in range(100):
            p = 16 + i * 128
            expected['files'][p:p + 4] = word(int.from_bytes(files[p:p + 4], 'big') & 0x7FFFFFFF)
    elif kind == 'offset_reset':
        expected_offsets[16:2016] = b'\xFF' * 2000
    elif kind == 'register':
        name = text.rsplit(b'\\', 1)[-1]
        for i in range(100):
            if i != handle and f'File{i}'.encode().lower() != name.lower():
                call(0x8001C0D0, 0x800904B0)
        result = handle if handle < 100 else 0xFFFF
        if handle < 100:
            p = 16 + handle * 128
            expected['files'][p:p + 4] = word(int.from_bytes(files[p:p + 4], 'big') | 0x80000000)
            expected['files'][p + 12:p + 13 + len(name)] = name + b'\0'
            expected['files'][p + 26:p + 27 + len(text)] = text + b'\0'
            call(0x8001C49C, 0x800904D0, handle, INPUT + len(text) - len(name))
    elif kind == 'find':
        result = next((i for i in range(100) if files[16 + i * 128] & 128 and
                       f'File{i}'.encode().lower() == text.lower()), 0xFFFF)
        call(0x8001C49C, 0x80090510, result, INPUT) if result != 0xFFFF else call(0x8001C0D0, 0x8009054C, INPUT)
    elif kind in ('load', 'get', 'release', 'unregister'):
        p = 16 + handle * 128
        data = LOADED + handle * 4
        flags = int.from_bytes(files[p:p + 4], 'big')
        if kind == 'load':
            result = 0
            if state & 1:
                result = data
                if not state & 2:
                    call(0x8003C64C, FILES + handle * 128 + 26, FILES + handle * 128 + 4)
                    expected['files'][p + 4:p + 8] = word(257)
                    expected['files'][p + 8:p + 12] = word(LOADED)
                    expected['files'][p:p + 4] = word(flags | 0x40000000)
                    call(0x8001C49C, 0x80090584, handle, LOADED)
                    result = LOADED
        elif kind == 'get':
            if state == 3:
                call(0x8001C49C, 0x800905B8, data, handle)
                result = data
            else:
                call(0x8001C0D0, 0x800905F8, handle)
                result = 0
        else:
            if kind == 'unregister':
                call(0x8001C49C, 0x80090660, handle)
            if state == 3:
                call(0x8001C49C, 0x80090630, handle)
                call(0x8003C698, data)
                flags &= 0xBFFFFFFF
            if kind == 'unregister':
                flags &= 0x7FFFFFFF
            expected['files'][p:p + 4] = word(flags)
    elif kind == 'append':
        p = 16 + handle * 8
        expected_scenes[p:p + 8] = word(level) + word(999 - handle)
        expected_scenes[656:660] = word(handle + 1)
    elif kind == 'select':
        selected = next((i - 1 for i in range(1, count) if level < i * 3 - 100), None)
        result = int(selected is not None)
        if selected is not None:
            call(0x8001F2CC, STRINGS + selected * 5, 2)
    elif kind == 'lookup':
        result = (STRINGS + offset) & 0xFFFFFFFF
    else:
        raise ValueError(kind)
    argument = INPUT if kind in ('register', 'find', 'append') else (level if kind == 'select' else handle)
    uc.reg_write(regs.UC_MIPS_REG_A0, argument & 0xFFFFFFFF)
    for address, data in panels.values():
        write(address, bytes(data))
    lower, upper = bytes(range(0xA0, 0xB0)), bytes(range(0xB0, 0xC0))
    write(STACK - 0x110, lower)
    write(STACK, bytes(pattern(32, seed + 7)))
    write(STACK + 32, upper)
    read_ranges = tuple((address + 16, address + len(data) - 16) for address, data in panels.values())
    write_ranges = read_ranges[:3]
    stack_range = (STACK - 0x100, STACK + 32)
    writes, reads = Counter(), Counter()

    def guard_code(uc, address, size, user):
        assert any(a <= address < b for a, b in ranges) or address in BOUNDARIES or address == SENTINEL, ('Code bounds', hex(address))
        if address not in BOUNDARIES:
            return
        assert len(trace) < len(wanted_trace), ('Extra service call', hex(address))
        wanted = wanted_trace[len(trace)]
        arguments = [uc.reg_read(getattr(regs, 'UC_MIPS_REG_A' + str(i))) for i in range(len(wanted[1]))]
        event = [address, arguments]
        assert event == wanted, ('Service arguments and order', event, wanted)
        trace.append(event)
        if address == 0x8003C64C:
            path = f'levels\\File{handle}'.encode() + b'\0'
            assert bytes(uc.mem_read(arguments[0] & 0x1FFFFFFF, len(path))) == path, 'Load complete filename'
            write(arguments[1], word(257))
        if address == 0x8001F2CC:
            name = f's{selected:02d}'.encode() + b'\0'
            assert bytes(uc.mem_read(arguments[0] & 0x1FFFFFFF, len(name))) == name, 'Selected complete filename'
        return_address = uc.reg_read(regs.UC_MIPS_REG_RA)
        for i, register in enumerate(CALLER_SAVED):
            uc.reg_write(register, 0xABCD0000 + i * 0x111)
        uc.reg_write(regs.UC_MIPS_REG_V0, LOADED if address == 0x8003C64C else 0)
        uc.reg_write(regs.UC_MIPS_REG_PC, return_address)

    def inside(address, size, bounds):
        return any(a <= address and address + size <= b for a, b in bounds)

    def guard_read(uc, access, address, size, value, user):
        address |= 0x80000000
        assert inside(address, size, read_ranges + (stack_range,)), ('Read bounds', hex(address), size)
        reads[address, size] += 1

    def guard_write(uc, access, address, size, value, user):
        address |= 0x80000000
        assert inside(address, size, write_ranges + (stack_range,)), ('Write bounds', hex(address), size)
        writes[address, size] += 1

    uc.hook_add(UC_HOOK_CODE, guard_code)
    uc.hook_add(UC_HOOK_MEM_READ, guard_read)
    uc.hook_add(UC_HOOK_MEM_WRITE, guard_write)
    uc.emu_start(ENTRIES[kind], 0, count=500000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, 'Instruction bound or missing return'
    assert all(uc.reg_read(r) == value for r, value in preserved.items()), 'O32 preservation'
    assert trace == wanted_trace, 'Complete service trace'
    for name, (address, data) in panels.items():
        assert bytes(uc.mem_read(address & 0x1FFFFFFF, len(data))) == expected[name], ('Complete guarded object', kind, name, seed, handle, state)
    assert bytes(uc.mem_read((STACK - 0x110) & 0x1FFFFFFF, 16)) == lower, 'Lower stack guard'
    assert bytes(uc.mem_read((STACK + 32) & 0x1FFFFFFF, 16)) == upper, 'Upper stack guard'
    if result is not None:
        assert uc.reg_read(regs.UC_MIPS_REG_V0) == result & 0xFFFFFFFF, ('Return value', kind, result)
    if kind in ('reset', 'offset_reset'):
        expected_writes = Counter({(FILES + i * 128, 1): 1 for i in range(100)}) if kind == 'reset' else Counter({(OFFSETS + i * 2, 2): 1 for i in range(1000)})
        stores = Counter({key: n for key, n in writes.items() if key[0] < STACK - 0x100})
        assert stores == expected_writes, 'Complete reset write coverage'
        if kind == 'reset':
            assert reads == expected_writes, 'Complete reset read coverage'
    return {'kind': kind, 'seed': seed, 'handle': handle, 'state': state, 'text_hex': text.hex(),
            'count': count, 'level': level, 'offset': offset, 'trace': trace,
            'objects_sha256': {name: hashlib.sha256(data).hexdigest() for name, data in expected.items()}}


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
    directory = ROOT / 'build/script-resource-storage-check'
    for name, source, start, end in MATCHING_BLOCKS:
        if name not in SUPPORT:
            continue
        report = compare_block(name, source, start, start - 0x7FFFF400, end - 0x7FFFF400,
                               target, family='script-resource-storage-check', layout=layout)
        assert report['matches'], (name, report['different_words'])
        comparisons[name] = report
        original.append((start, target[start - 0x7FFFF400:end - 0x7FFFF400]))
        compiled.append((start, (directory / name / (name + '.bin')).read_bytes()))
    assert set(comparisons) == set(SUPPORT)
    ranges = tuple((a, a + len(b)) for a, b in original)
    return target, layout, data, comparisons, original, compiled, ranges


MUTATIONS = {
    'reset_short': ('src/game/script_service_cache_reset.c', 'index < 100', 'index < 99', dict(kind='reset')),
    'offset_reset_short': ('src/game/resource_string_reset.c', 'index < 1000', 'index < 999', dict(kind='offset_reset')),
    'registration_loaded': ('src/game/script_service_files.c', 'flags.bits.registered = 1', 'flags.value = 0x80000000', dict(kind='register', handle=17)),
    'load_size_pointer': ('src/game/script_service_cache_access.c', '&D_80097650[handle].size', '&D_80097650[handle].flags.value', dict(kind='load', handle=99, state=1)),
    'append_count': ('src/game/script_service_commands.c', 'D_800A4530++;', 'D_800A4530 += 2;', dict(kind='append', handle=79, level=219)),
    'select_current': ('src/game/scene_file_select.c', 'D_800A42B0[index - 1].name', 'D_800A42B0[index].name', dict(kind='select', count=80, level=100)),
    'unsigned_offset': ('src/game/string_resource.c', 'int offset = D_800A3AD8[identifier];', 'int offset = (unsigned short)D_800A3AD8[identifier];', dict(kind='lookup', handle=999, offset=-17)),
}


def mutation_check(name):
    if ROOT.parent.name != '.local' or not ROOT.name.startswith('script-resource-storage-' + name + '-'):
        raise ValueError('Source mutations require an isolated audit directory')
    target, layout, _, _, original, compiled, ranges = prepare_images()
    relative, old, new, case = MUTATIONS[name]
    assert run(original, ranges, seed=173, **case) == run(compiled, ranges, seed=173, **case), 'Mutation positive control'
    path = ROOT / relative
    content = path.read_text()
    assert content.count(old) == 1, ('Mutation anchor', name)
    path.write_text(content.replace(old, new))
    _, _, start, end = next(row for row in MATCHING_BLOCKS if row[1] == relative)
    report = compare_block('mutated', relative, start, start - 0x7FFFF400, end - 0x7FFFF400,
                           target, family='script-resource-storage-mutations', layout=layout)
    assert not report['matches'], 'Unchanged mutation'
    blob = (ROOT / 'build/script-resource-storage-mutations/mutated/mutated.bin').read_bytes()
    candidate = [(a, b) for a, b in compiled if a != start] + [(start, blob)]
    bounds = tuple((a, a + len(b)) for a, b in candidate)
    try:
        run(candidate, bounds, seed=173, **case)
    except AssertionError as error:
        print(json.dumps({'name': name, 'control_passed': True, 'mutation_rejected': True,
                          'different_words': len(report['different_words']), 'reason': str(error)}))
        return
    raise ValueError('Script resource checker missed mutation: ' + name)


def check_mutations():
    results = []
    for name in MUTATIONS:
        with tempfile.TemporaryDirectory(prefix='script-resource-storage-' + name + '-', dir=ROOT / '.local') as temporary:
            root = Path(temporary)
            assert root.resolve().parent == (ROOT / '.local').resolve()
            for folder in ('src', 'include', 'config', 'tools', 'docs'):
                shutil.copytree(ROOT / folder, root / folder)
            shutil.copy2(ROOT / 'Makefile', root / 'Makefile')
            (root / '.local').mkdir()
            (root / '.local/toolchain').symlink_to(ROOT / '.local/toolchain', target_is_directory=True)
            (root / 'baseroms/us').mkdir(parents=True)
            (root / 'baseroms/us/baserom.z64').symlink_to(ROOT / 'baseroms/us/baserom.z64')
            result = subprocess.run([sys.executable, str(root / 'tools/check_script_resource_storage.py'), '--mutation', name], capture_output=True, text=True)
            if result.returncode:
                raise ValueError(f'Script resource mutation {name} failed:\n{result.stdout}\n{result.stderr}')
            record = json.loads(result.stdout.splitlines()[-1])
            assert record['control_passed'] and record['mutation_rejected']
            results.append(record)
    return results


def main(mutations=False):
    target, layout, data, comparisons, original, compiled, ranges = prepare_images()
    cases = []
    for seed in (0, 173, 255):
        for kind in ('reset', 'offset_reset'):
            cases.append(dict(kind=kind, seed=seed))
        for handle, text in itertools.product((0, 1, 17, 99, 100), (b'NEW.DAT', b'levels\\Area\\FiLe17', b'A\\B\\C\\last')):
            cases.append(dict(kind='register', seed=seed, handle=handle, text=text))
        for handle, upper, state in itertools.product((-1, 0, 17, 99), (False, True), range(4)):
            text = b'missing' if handle == -1 else f'file{handle}'.encode()
            cases.append(dict(kind='find', seed=seed, handle=handle, state=state, text=text.upper() if upper else text))
        for kind, handle, state in itertools.product(('load', 'get', 'release', 'unregister'), (0, 17, 99), range(4)):
            cases.append(dict(kind=kind, seed=seed, handle=handle, state=state))
        for handle in range(80):
            cases.append(dict(kind='append', seed=seed, handle=handle, level=(-1, 0, 219)[handle % 3]))
        for count, level in itertools.product((0, 1, 2, 80), (-101, -100, -97, 0, 100, 300)):
            cases.append(dict(kind='select', seed=seed, count=count, level=level))
        for handle, offset in itertools.product((0, 499, 999), (-17, 0, 32767)):
            cases.append(dict(kind='lookup', seed=seed, handle=handle, offset=offset))
    results = []
    for case in cases:
        retail = run(original, ranges, **case)
        recovered = run(compiled, ranges, **case)
        assert retail == recovered, case
        results.append(recovered)
    mutation_results = check_mutations() if mutations else []
    layout.verify()
    report = {'matches': True, 'paired_cases': len(cases), 'target_executions': len(cases) * 2,
              'bss_bytes': 15446, 'storage': data, 'comparisons': comparisons,
              'cases': results, 'mutations': mutation_results,
              'versions': {name: version(name) for name in ('unicorn', 'capstone', 'pyelftools')},
              'boundaries': {hex(address): count for address, count in BOUNDARIES.items()},
              'limitations': ['Diagnostic, platform file allocation/free and scene submission use recorded integer ABI stubs.',
                              'Registered filenames fit 14 bytes; paths fit 102 bytes; required pointers are valid.',
                              'Append fixtures cover all 80 valid entries; invalid counts and overflowing copies are not repaired.',
                              'External string data is a bounded synthetic fixture, not newly source-owned storage.',
                              'Hardware I/O, callback effects, script interpretation and complete gameplay are not executed.']}
    path = ROOT / 'build/script-resource-storage-check/report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: report[key] for key in ('matches', 'paired_cases', 'target_executions', 'bss_bytes')}))
    print(f'Rejected {len(mutation_results)} source mutations; report: {path.relative_to(ROOT)}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mutation', choices=MUTATIONS)
    parser.add_argument('--mutations', action='store_true')
    args = parser.parse_args()
    mutation_check(args.mutation) if args.mutation else main(args.mutations)
