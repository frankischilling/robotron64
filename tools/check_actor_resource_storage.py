"""Check complete resource BSS, flag reset and the already-loaded loader path."""

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


# Counts, strides and flag offsets come from the complete retail reset.
POOLS = (
    ('primary', 0x800B1BE8, 244, 88, 6, 'src/game/actor_resources/primary.c'),
    ('enemies', 0x800AF1F0, 36, 104, 6, 'src/game/actor_resources/enemies.c'),
    ('child_variants', 0x800ACE58, 8, 88, 6, 'src/game/actor_resources/child_variants.c'),
    ('secondary', 0x8009AA00, 16, 92, 6, 'src/game/actor_resources/secondary.c'),
    ('small', 0x8009AFD8, 4, 88, 6, 'src/game/actor_resources/small.c'),
    ('player', 0x8009B138, 1, 88, 6, 'src/game/actor_resources/player.c'),
    ('early', 0x8009EA18, 5, 96, 10, 'src/game/actor_resources/early.c'),
    ('child', 0x800AC998, 11, 92, 6, 'src/game/actor_groups/child_resources.c'),
)
RESET, LOADER, STACK = 0x8001D260, 0x8001CF68, 0x80300000
ARENA_START, ARENA_END = 0x8009A9F0, 0x800B6FD8
STACK_START, STACK_END = STACK - 0xD0, STACK + 32
SUPPORT = ('actor_resource_reset', 'actor_resource_load')
FLAGS = tuple(base + index * stride + flag
              for name, base, count, stride, flag, source in POOLS
              for index in range(count))
RESET_COUNTS = Counter(FLAGS + tuple(0x800B1BE8 + index * 88 + 6 for index in range(16)))
PRESERVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                  ('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP', 'SP', 'GP', 'RA'))
SAVES = {STACK - 0xC0 + offset: getattr(regs, 'UC_MIPS_REG_' + name)
         for offset, name in ((0x1C, 'S0'), (0x20, 'S1'), (0x24, 'S2'),
                              (0x28, 'S3'), (0x2C, 'S4'), (0x30, 'S5'), (0x34, 'RA'))}


def normalized(address):
    return address | 0x80000000


def initial_arena(seed, pattern):
    arena = bytearray((index * 37 + (index >> 8) * 11 + seed) & 255
                      for index in range(ARENA_END - ARENA_START))
    for index, address in enumerate(FLAGS):
        loaded = (False, True, index % 2 == 0, index % 2 != 0)[pattern]
        offset = address - ARENA_START
        arena[offset] = (arena[offset] & 127) | (128 if loaded else 0)
    return arena


def run(code, seed, pattern, loader=None):
    uc, write, execute = machine(code, [])
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA57281D9)
    preserved = {register: uc.reg_read(register) for register in PRESERVED}
    initial = initial_arena(seed, pattern)
    expected = bytearray(initial)
    stack = bytearray((index * 19 + seed) & 255 for index in range(STACK_END - STACK_START))
    expected_stack = bytearray(stack)
    reads, writes = Counter(), Counter()
    if loader is None:
        for address in FLAGS:
            expected[address - ARENA_START] &= 127
        expected_reads = Counter({(address, 1): count for address, count in RESET_COUNTS.items()})
        expected_writes = expected_reads.copy()
        entry = RESET
    else:
        address, load_geometry = loader
        assert address + 6 in FLAGS and address + 10 not in FLAGS
        initial[address + 6 - ARENA_START] |= 128
        expected = bytearray(initial)
        expected_reads = Counter({(address + 6, 2): 1, **{(saved, 4): 1 for saved in SAVES}})
        expected_writes = Counter({(saved, 4): 1 for saved in SAVES})
        for saved, register in SAVES.items():
            offset = saved - STACK_START
            expected_stack[offset:offset + 4] = word(preserved[register])
        uc.reg_write(regs.UC_MIPS_REG_A0, address)
        uc.reg_write(regs.UC_MIPS_REG_A1, load_geometry & 0xFFFFFFFF)
        entry = LOADER
    write(ARENA_START, bytes(initial))
    write(STACK_START, bytes(stack))
    code_ranges = tuple((address, address + len(data)) for address, data in code)

    def guard_code(uc, address, size, user):
        assert any(start <= address < end for start, end in code_ranges) or address == SENTINEL, (
            'Unexpected instruction or callee', hex(address), loader)

    def guard_read(uc, access, address, size, value, user):
        key = (normalized(address), size)
        reads[key] += 1
        assert reads[key] <= expected_reads[key], ('Unexpected read', hex(key[0]), size, loader)

    def guard_write(uc, access, address, size, value, user):
        key = (normalized(address), size)
        writes[key] += 1
        assert writes[key] <= expected_writes[key], ('Unexpected write', hex(key[0]), size, loader)
        if loader is None:
            wanted = expected[key[0] - ARENA_START]
        else:
            wanted = preserved[SAVES[key[0]]]
        assert value & ((1 << (size * 8)) - 1) == wanted, ('Store value', hex(key[0]), value, wanted)

    uc.hook_add(UC_HOOK_CODE, guard_code)
    uc.hook_add(UC_HOOK_MEM_READ, guard_read)
    uc.hook_add(UC_HOOK_MEM_WRITE, guard_write)
    execute(entry)
    assert reads == expected_reads, ('Complete read trace', loader, reads - expected_reads,
                                     expected_reads - reads)
    assert writes == expected_writes, ('Complete write trace', loader, writes - expected_writes,
                                       expected_writes - writes)
    assert all(uc.reg_read(register) == value for register, value in preserved.items()), 'O32 preservation'
    observed = bytes(uc.mem_read(ARENA_START & 0x1FFFFFFF, len(expected)))
    assert observed == expected, ('Complete pools and guarded gaps', loader, seed, pattern)
    observed_stack = bytes(uc.mem_read(STACK_START & 0x1FFFFFFF, len(expected_stack)))
    assert observed_stack == expected_stack, ('Complete stack image', loader, seed, pattern)
    if loader is not None:
        assert uc.reg_read(regs.UC_MIPS_REG_V0) == 2, ('Already-loaded result', loader)
    return {'seed': seed, 'pattern': pattern, 'loader': loader,
            'reads': sum(reads.values()), 'writes': sum(writes.values()),
            'arena_sha256': hashlib.sha256(observed).hexdigest(),
            'stack_sha256': hashlib.sha256(observed_stack).hexdigest()}


def prepare_images():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    data = {}
    for name, base, count, stride, flag, source in POOLS:
        records = source_sections(source)
        assert len(records) == 1 and records[0]['rom'] is None
        assert (records[0]['vram'], records[0]['size']) == (base, count * stride)
        data[source] = compare_unit(source, records, target, layout)
    comparisons, original, compiled = {}, [], []
    directory = ROOT / 'build/actor-resource-storage-check'
    for name, source, start, end in MATCHING_BLOCKS:
        if name not in SUPPORT:
            continue
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target,
                               family='actor-resource-storage-check', layout=layout)
        assert report['matches'], (name, report['different_words'])
        comparisons[name] = report
        original.append((start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
        compiled.append((start, (directory / name / (name + '.bin')).read_bytes()))
    assert set(comparisons) == set(SUPPORT)
    return target, layout, data, comparisons, original, compiled


MUTATIONS = {
    'primary_short': ('i < 244', 'i < 243'),
    'primary_overrun': ('i < 244', 'i < 245'),
    'primary_loaded': ('for (i = 0; i < 244; i++) {\n        D_800B1BE8[i].flags06.bits.loaded = 0;',
                       'for (i = 0; i < 244; i++) {\n        D_800B1BE8[i].flags06.bits.loaded = 1;'),
    'duplicate_short': ('for (i = 0; i < 16; i++) {\n        D_800B1BE8[i]',
                        'for (i = 0; i < 15; i++) {\n        D_800B1BE8[i]'),
    'secondary_short': ('for (i = 0; i < 16; i++) {\n        D_8009AA00[i]',
                        'for (i = 0; i < 15; i++) {\n        D_8009AA00[i]'),
    'early_flags_zero': ('D_8009EA18[i].flags0A.bits.loaded = 0;', 'D_8009EA18[i].flags0A.value = 0;'),
}


def mutation_check(name):
    if ROOT.parent.name != '.local' or not ROOT.name.startswith('actor-resource-storage-' + name + '-'):
        raise ValueError('Source mutations require an isolated audit directory')
    target, layout, _, _, original, compiled = prepare_images()
    control = run(original, 173, 1)
    assert run(compiled, 173, 1) == control, ('Mutation positive control', name)
    source = ROOT / 'src/game/actor_resource_reset.c'
    contents = source.read_text()
    old, new = MUTATIONS[name]
    assert contents.count(old) == 1, ('Mutation anchor', name)
    source.write_text(contents.replace(old, new))
    report = compare_block('reset_mutated', 'src/game/actor_resource_reset.c', RESET,
                           0x1DE60, 0x1DFF0, target,
                           family='actor-resource-storage-mutations', layout=layout)
    assert not report['matches'], ('Unchanged mutation', name)
    directory = ROOT / 'build/actor-resource-storage-mutations/reset_mutated'
    candidate = [(address, data) for address, data in compiled if address != RESET]
    candidate.append((RESET, (directory / 'reset_mutated.bin').read_bytes()))
    try:
        run(candidate, 173, 1)
    except AssertionError as error:
        print(json.dumps({'name': name, 'control_passed': True, 'mutation_rejected': True,
                          'different_words': len(report['different_words']), 'reason': str(error)}))
        return
    raise ValueError('Independent resource storage guard missed mutation: ' + name)


def check_mutations():
    results = []
    local = ROOT / '.local'
    local.mkdir(exist_ok=True)
    for name in MUTATIONS:
        with tempfile.TemporaryDirectory(prefix='actor-resource-storage-' + name + '-', dir=local) as temporary:
            root = Path(temporary)
            assert root.resolve().parent == local.resolve()
            for folder in ('src', 'include', 'config', 'tools', 'docs'):
                shutil.copytree(ROOT / folder, root / folder)
            shutil.copy2(ROOT / 'Makefile', root / 'Makefile')
            (root / '.local').mkdir()
            (root / '.local/toolchain').symlink_to(ROOT / '.local/toolchain', target_is_directory=True)
            (root / 'baseroms/us').mkdir(parents=True)
            (root / 'baseroms/us/baserom.z64').symlink_to(ROOT / 'baseroms/us/baserom.z64')
            result = subprocess.run([sys.executable, str(root / 'tools/check_actor_resource_storage.py'),
                                     '--mutation', name], capture_output=True, text=True)
            if result.returncode:
                raise ValueError(f'Resource storage mutation {name} failed:\n{result.stderr}')
            record = json.loads(result.stdout.splitlines()[-1])
            assert record['control_passed'] and record['mutation_rejected']
            results.append(record)
    return results


def main(mutations=False):
    target, layout, data, comparisons, original, compiled = prepare_images()
    reset_cases = list(itertools.product((0, 173, 255), range(4)))
    results = []
    for seed, pattern in reset_cases:
        retail = run(original, seed, pattern)
        recovered = run(compiled, seed, pattern)
        assert retail == recovered, (seed, pattern)
        results.append(recovered)
    loader_results = []
    for name, base, count, stride, flag, source in POOLS:
        if flag != 6:
            continue
        for index, geometry in itertools.product(range(count), (0, 1, -17)):
            case = (base + index * stride, geometry)
            retail = run(original, 173, 2, case)
            recovered = run(compiled, 173, 2, case)
            assert retail == recovered, (name, index, geometry)
            loader_results.append({'pool': name, 'index': index, **recovered})
    report = {'matches': True, 'rom_sha256': hashlib.sha256(target).hexdigest(),
              'unicorn': version('unicorn'), 'new_bss_bytes': 28312,
              'already_owned_child_bytes': 1012, 'complete_pool_bytes_checked': 29324,
              'guarded_arena_bytes': ARENA_END - ARENA_START,
              'reset_cases_per_image': len(reset_cases), 'reset_flag_stores_per_case': 341,
              'already_loaded_cases_per_image': len(loader_results),
              'total_function_executions': 2 * (len(reset_cases) + len(loader_results)),
              'data_comparisons': data, 'code_comparisons': comparisons,
              'reset_results': results, 'already_loaded_results': loader_results,
              'mutations': check_mutations() if mutations else [],
              'checker_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'limits': ['All eight pools and the guarded gaps are checked against an independent byte model.',
                         'Reset permits only the 341 original flag-byte reads and stores, including sixteen repeated primary records.',
                         'Every compatible record is checked on the already-loaded path with three geometry arguments; no callee may execute.',
                         'Instruction and memory bounds, complete stack images, SP, GP, RA and saved integer registers are checked.',
                         'The loader path that loads geometry, texture maps, bitmaps and animations is outside this proof.',
                         'BSS ownership adds no functions, initialized ROM bytes or proof of complete gameplay.']}
    layout.verify()
    directory = ROOT / 'build/actor-resource-storage-check'
    (directory / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(f'Resource storage: 28,312 new BSS bytes; {len(reset_cases)} reset and '
          f'{len(loader_results)} already-loaded cases per image; '
          f"{report['total_function_executions']} function executions")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mutations', action='store_true', help='also run isolated source mutation checks')
    parser.add_argument('--mutation', choices=MUTATIONS, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.mutation:
        mutation_check(args.mutation)
    else:
        main(args.mutations)
