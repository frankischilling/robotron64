"""Verify complete text BSS ownership and guarded reset/allocation behavior."""

import argparse
import hashlib
import itertools
import json
import struct
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from importlib.metadata import version

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs

from check_actor_group_path import SENTINEL, machine, word
from compare_data import compare_unit, comparison_directory
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


BASE, STRIDE, COUNT = 0x800B6FF8, 268, 30
SIZE, STRING, STACK = STRIDE * COUNT, 0x80201010, 0x80300000
SOURCE = 'src/game/text_records.c'
WIDTH_SOURCES = ('src/game/text_widths/lowercase.c', 'src/game/text_widths/digits.c')
WIDTH_BASE, WIDTH_SIZE = 0x80072B40, 144
SUPPORT = ('text', 'game_memory')
CALLER_SAVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                     ('V0', 'V1', 'A0', 'A1', 'A2', 'A3',
                      'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9'))
PRESERVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                  ('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP', 'SP', 'GP'))

# Only these matching routines and recorded call boundaries may execute.
CODE_RANGES = ((0x800005E0, 0x8000060C), (0x80000918, 0x80000ACC),
               (0x8003B4FC, 0x8003B520), (0x8003B694, 0x8003B6E4),
               (0x8003B704, 0x8003B734), (0x80000750, 0x80000754),
               (0x8001C0D0, 0x8001C0D4), (SENTINEL, SENTINEL + 4))


def run(code, case):
    free, length, seed, scale, mode, options = case
    uc, write, _ = machine(code, [])
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA57281D9)
    preserved = {register: uc.reg_read(register) for register in PRESERVED}
    guard = bytes(range(0xA0, 0xB0))
    initial = bytearray((index * 37 + seed) & 255 for index in range(SIZE))
    for index in range(COUNT):
        initial[index * STRIDE] |= 128
    if free is not None:
        initial[free * STRIDE] &= 127
    expected = bytearray(initial)
    text = bytes((32, 65, 170, 122, 33)[index % 5] for index in range(length))
    write(BASE - 16, guard + bytes(initial) + guard)
    write(STRING - 16, guard + text + b'\0' + guard)
    write(STACK - 128, guard)
    incoming_home = bytes((index * 11 + seed) & 255 for index in range(32))
    write(STACK, incoming_home)
    write(STACK + len(incoming_home), guard)
    trace = []
    expected_trace = []
    clipped = min(length, 60)
    if free is not None:
        start = free * STRIDE
        flags = int.from_bytes(expected[start:start + 4], 'big')
        flags = (flags & ~(0x3FFFF << 11)) | ((options & 0x3FFFF) << 11) | 0xC0000000
        expected[start:start + 4] = word(flags)
        expected[start + 8:start + 12] = word(mode)
        expected[start + 0x64:start + 0x68] = word(24)
        expected[start + 0x68:start + 0x74] = word(scale) * 3
        expected[start + 0x74:start + 0x78] = word(clipped)
        expected[start + 0x100:start + 0x10C] = word(0xDEADBEEF) * 3
        expected[start + 0x24:start + 0x24 + clipped + 1] = text[:clipped] + b'\0'
        for index, character in enumerate(text[:clipped]):
            object_index = -1
            if character != 32:
                object_index = (-1, 41, 0x7FFF, 0x8000, 0x12345)[len(expected_trace) % 5]
                expected_trace.append([0x80000750,
                    [character, scale & 0xFFFFFFFF, mode & 0xFFFFFFFF, options & 0x200],
                    object_index & 0xFFFFFFFF])
            offset = start + 0x78 + index * 2
            expected[offset:offset + 2] = struct.pack('>H', object_index & 0xFFFF)
    else:
        expected_trace.append([0x8001C0D0, [0x8008F64C], 0])

    def boundary(uc, address, instruction_size, user):
        registers = (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                     regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)
        count = 4 if address == 0x80000750 else 1
        arguments = [uc.reg_read(register) for register in registers[:count]]
        assert len(trace) < len(expected_trace), ('Unexpected boundary call', case, hex(address))
        expected_event = expected_trace[len(trace)]
        assert [address, arguments] == expected_event[:2], (case, address, arguments, expected_event)
        trace.append(expected_event)
        return_address = uc.reg_read(regs.UC_MIPS_REG_RA)
        for index, register in enumerate(CALLER_SAVED):
            uc.reg_write(register, 0xB1230000 + index * 257)
        uc.reg_write(regs.UC_MIPS_REG_V0, expected_event[2])
        uc.reg_write(regs.UC_MIPS_REG_PC, return_address)

    for address in (0x80000750, 0x8001C0D0):
        uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)

    def inside(address, size, ranges):
        address = (address & 0x1FFFFFFF) | 0x80000000
        return any(start <= address and address + size <= end for start, end in ranges)

    stack_range = (STACK - 112, STACK + len(incoming_home))
    read_ranges = ((BASE, BASE + SIZE), (STRING, STRING + len(text) + 1), stack_range)
    write_ranges = ((BASE, BASE + SIZE), stack_range)

    def instruction(uc, address, size, user):
        assert size == 4 and inside(address, size, CODE_RANGES), ('Instruction bounds', hex(address), case)

    def memory_read(uc, access, address, size, value, user):
        assert inside(address, size, read_ranges), ('Read bounds', hex(address), size, case)

    def memory_write(uc, access, address, size, value, user):
        assert inside(address, size, write_ranges), ('Write bounds', hex(address), size, case)

    uc.hook_add(UC_HOOK_CODE, instruction)
    uc.hook_add(UC_HOOK_MEM_READ, memory_read)
    uc.hook_add(UC_HOOK_MEM_WRITE, memory_write)
    for register, value in zip((regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3),
                               (STRING, scale, mode, options)):
        uc.reg_write(register, value & 0xFFFFFFFF)

    def execute(entry):
        uc.reg_write(regs.UC_MIPS_REG_RA, SENTINEL)
        uc.emu_start(entry, 0, count=250000)
        assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
        assert all(uc.reg_read(register) == value for register, value in preserved.items())

    def read(address, length):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, length))

    execute(0x80000918)
    assert trace == expected_trace, ('Call sequence', case, trace, expected_trace)
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == (0xFFFFFFFF if free is None else free)
    assert read(BASE - 16, SIZE + 32) == guard + bytes(expected) + guard, ('Allocation image', case)
    assert read(STRING - 16, len(text) + 33) == guard + text + b'\0' + guard
    assert read(STACK - 128, 16) == guard
    assert read(STACK + len(incoming_home), 16) == guard
    allocation_hash = hashlib.sha256(read(BASE, SIZE)).hexdigest()
    execute(0x800005E0)
    assert read(BASE - 16, SIZE + 32) == guard + bytes(SIZE) + guard, ('Complete reset image', case)
    assert read(STACK - 128, 16) == guard
    assert read(STACK + len(incoming_home), 16) == guard
    return {'case': case, 'array_after_allocate_sha256': allocation_hash,
            'glyph_calls': len(trace) if free is not None else 0,
            'exhaustion_calls': int(free is None), 'reset_bytes': SIZE}


def prepare_images():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    directory = ROOT / 'build/text-storage-check'
    directory.mkdir(parents=True, exist_ok=True)
    data = compare_unit(SOURCE, source_sections(SOURCE), target, layout)
    comparisons, original, compiled = {}, [], []
    for name, source, start, end in MATCHING_BLOCKS:
        if name not in SUPPORT:
            continue
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target,
                               family='text-storage-check', layout=layout)
        assert report['matches'], (name, report['different_words'])
        comparisons[name] = report
        original.append((start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
        compiled.append((start, (directory / name / (name + '.bin')).read_bytes()))
        sections, _ = elf_sections_and_symbols(directory / name / (name + '.elf'))
        for owned in source_sections(source):
            if owned['rom'] is not None:
                original.append((owned['vram'], target[owned['rom']:owned['rom'] + owned['size']]))
                compiled.append((owned['vram'], sections[owned['section']]['bytes']))
    assert set(comparisons) == set(SUPPORT)
    return target, layout, data, comparisons, original, compiled


def prepare_widths(target, layout, original, compiled):
    reports = {}
    for source in WIDTH_SOURCES:
        records = source_sections(source)
        reports[source] = compare_unit(source, records, target, layout)
        sections, _ = elf_sections_and_symbols(comparison_directory(source) / 'compiled.elf')
        for record in records:
            original.append((record['vram'], target[record['rom']:record['rom'] + record['size']]))
            compiled.append((record['vram'], sections[record['section']]['bytes']))
    return reports


def run_width(code, case, tables):
    enabled, character = case
    uc, write, _ = machine(code, [])
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA57281D9)
    preserved = {register: uc.reg_read(register) for register in PRESERVED}
    guard = bytes(range(0xA0, 0xB0))
    write(WIDTH_BASE - 16, guard)
    write(WIDTH_BASE + WIDTH_SIZE, guard)
    home = bytes(range(16))
    write(STACK - 16, guard + home + guard)

    def normalized(address):
        return (address & 0x1FFFFFFF) | 0x80000000

    def instruction(uc, address, size, user):
        address = normalized(address)
        assert size == 4 and (0x80000460 <= address < 0x80000518 or address == SENTINEL), (
            'Width instruction bounds', hex(address), case)

    def memory_read(uc, access, address, size, value, user):
        address = normalized(address)
        assert (WIDTH_BASE <= address and address + size <= WIDTH_BASE + WIDTH_SIZE or
                STACK + 4 <= address and address + size <= STACK + 8), (
            'Width read bounds', hex(address), size, case)

    def memory_write(uc, access, address, size, value, user):
        address = normalized(address)
        assert STACK + 4 <= address and address + size <= STACK + 8, (
            'Width write bounds', hex(address), size, case)

    uc.hook_add(UC_HOOK_CODE, instruction)
    uc.hook_add(UC_HOOK_MEM_READ, memory_read)
    uc.hook_add(UC_HOOK_MEM_WRITE, memory_write)
    uc.reg_write(regs.UC_MIPS_REG_A0, enabled & 0xFFFFFFFF)
    uc.reg_write(regs.UC_MIPS_REG_A1, character)
    uc.reg_write(regs.UC_MIPS_REG_RA, SENTINEL)
    uc.emu_start(0x80000460, 0, count=256)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, ('Width return', case)
    assert all(uc.reg_read(register) == value for register, value in preserved.items()), ('Width ABI', case)
    width = 5
    if enabled:
        if ord('a') <= character <= ord('z'):
            width = tables[character - ord('a')]
        elif 170 <= character <= 179:
            width = tables[26 + character - 170]
        elif ord('0') <= character <= ord('9'):
            width = tables[26 + character - ord('0')]
        elif character == ord(' '):
            width = 2
        elif character == ord('-'):
            width = 4
    result = uc.reg_read(regs.UC_MIPS_REG_V0)
    assert result == width + 1, ('Width model', case, result, width + 1)
    assert bytes(uc.mem_read((WIDTH_BASE - 16) & 0x1FFFFFFF, WIDTH_SIZE + 32)) == (
        guard + struct.pack('>36i', *tables) + guard), ('Width table guards', case)
    expected_home = home[:4] + word(character) + home[8:]
    assert bytes(uc.mem_read((STACK - 16) & 0x1FFFFFFF, 48)) == (
        guard + expected_home + guard), ('Width argument-home bounds', case)
    return {'case': case, 'result': result}


MUTATIONS = {
    'reset_short': ('func_8003B694(D_800B6FF8, 0, sizeof(D_800B6FF8));',
                    'func_8003B694(D_800B6FF8, 0, sizeof(D_800B6FF8) - 4);', (29, 1, 173, 17, 11, 0x200)),
    'reset_overrun': ('func_8003B694(D_800B6FF8, 0, sizeof(D_800B6FF8));',
                      'func_8003B694(D_800B6FF8, 0, sizeof(D_800B6FF8) + 4);', (29, 1, 173, 17, 11, 0x200)),
    'last_slot': ('slot < 30', 'slot < 29', (29, 1, 173, 17, 11, 0x200)),
    'active_flag': ('record->active = 1;', 'record->active = 0;', (0, 1, 173, 17, 11, 0x200)),
    'length_cap': ('func_8003B4FC(text) < 60 ? func_8003B4FC(text) : 60',
                   'func_8003B4FC(text) < 59 ? func_8003B4FC(text) : 59', (29, 60, 173, 17, 11, 0x200)),
}


def mutation_check(name):
    if ROOT.parent.name != '.local' or not ROOT.name.startswith('text-storage-' + name + '-'):
        raise ValueError('Source mutations require an isolated audit directory')
    target, layout, _, _, original, compiled = prepare_images()
    old, new, case = MUTATIONS[name]
    control = run(original, case)
    assert run(compiled, case) == control, ('Mutation positive control', name)
    source = ROOT / 'src/game/text.c'
    contents = source.read_text()
    assert contents.count(old) == 1, ('Mutation anchor', name)
    source.write_text(contents.replace(old, new))
    report = compare_block('text_mutated', 'src/game/text.c', 0x80000450, 0x1050, 0x1B48,
                           target, family='text-storage-mutations', layout=layout)
    assert not report['matches'], ('Unchanged mutation', name)
    directory = ROOT / 'build/text-storage-mutations/text_mutated'
    candidate = [(address, data) for address, data in compiled if address != 0x80000450]
    candidate.append((0x80000450, (directory / 'text_mutated.bin').read_bytes()))
    # Constants are unchanged and independently checked by compare_block.
    try:
        run(candidate, case)
    except AssertionError as error:
        print(json.dumps({'name': name, 'control_passed': True, 'mutation_rejected': True,
                          'different_words': len(report['different_words']), 'reason': str(error)}))
        return
    raise ValueError('Independent text storage guard missed mutation: ' + name)


def check_mutations():
    results = []
    local = ROOT / '.local'
    local.mkdir(exist_ok=True)
    for name in MUTATIONS:
        with tempfile.TemporaryDirectory(prefix='text-storage-' + name + '-', dir=local) as temporary:
            root = Path(temporary)
            assert root.resolve().parent == local.resolve()
            for folder in ('src', 'include', 'config', 'tools', 'docs'):
                shutil.copytree(ROOT / folder, root / folder)
            shutil.copy2(ROOT / 'Makefile', root / 'Makefile')
            (root / '.local').mkdir()
            (root / '.local/toolchain').symlink_to(ROOT / '.local/toolchain', target_is_directory=True)
            (root / 'baseroms/us').mkdir(parents=True)
            (root / 'baseroms/us/baserom.z64').symlink_to(ROOT / 'baseroms/us/baserom.z64')
            result = subprocess.run([sys.executable, str(root / 'tools/check_text_storage.py'),
                                     '--mutation', name], capture_output=True, text=True)
            if result.returncode:
                raise ValueError(f'Text storage mutation {name} failed:\n{result.stderr}')
            record = json.loads(result.stdout.splitlines()[-1])
            assert record['control_passed'] and record['mutation_rejected']
            results.append(record)
    return results


def main(mutations=False):
    target, layout, data, comparisons, original, compiled = prepare_images()
    width_data = prepare_widths(target, layout, original, compiled)
    cases = [(free, length, seed, scale, mode, options)
             for free, length, seed in itertools.product((None, *range(COUNT)), (0, 1, 59, 60, 61, 79), (0, 173))
             for scale, mode, options in ((17, 11, 0x200), (-12345, -7, 0xFFFABCDE))]
    results = []
    for case in cases:
        retail = run(original, case)
        recovered = run(compiled, case)
        assert retail == recovered, case
        results.append(recovered)
    tables = struct.unpack('>36i', target[0x73740:0x737D0])
    width_cases = list(itertools.product((0, 1, -17, -0x80000000), range(256)))
    width_results = []
    for case in width_cases:
        retail = run_width(original, case, tables)
        recovered = run_width(compiled, case, tables)
        assert retail == recovered, case
        width_results.append(recovered)
    report = {'matches': True, 'rom_sha256': hashlib.sha256(target).hexdigest(),
              'unicorn': version('unicorn'), 'cases': len(cases),
              'paired_allocation_reset_cases': len(cases),
              'executions_per_image': len(cases) * 2 + len(width_cases),
              'allocation_reset_function_executions': len(cases) * 4,
              'width_cases_per_image': len(width_cases),
              'total_function_executions': len(cases) * 4 + len(width_cases) * 2,
              'data_comparison': data, 'code_comparisons': comparisons,
              'width_data_comparisons': width_data, 'width_results': width_results,
              'results': results, 'mutations': check_mutations() if mutations else [],
              'checker_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'limits': ['All thirty allocation slots, exhaustion and reset are checked against the complete independent array model.',
                         'Instruction, read and write bounds, pool/string/stack canaries, SP, GP and saved integer registers are checked.',
                         'Glyph creation and the exhaustion message use recorded, clobbering O32 boundaries; rendering is outside the proof.',
                         'Matching byte clear, string length and bounded string copy execute compiled instructions.',
                         'All 256 byte-valued characters and four enabled values are checked for the matching width routine; both complete width tables are independently compiled and compared.',
                         'BSS ownership contributes no ROM bytes, new functions or proof of complete gameplay.']}
    layout.verify()
    directory = ROOT / 'build/text-storage-check'
    (directory / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(f'Text storage: {SIZE} BSS bytes, {WIDTH_SIZE} initialized width bytes; '
          f'{len(cases)} allocation/reset and {len(width_cases)} width cases per image')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mutations', action='store_true', help='also run isolated source mutation checks')
    parser.add_argument('--mutation', choices=MUTATIONS, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.mutation:
        mutation_check(args.mutation)
    else:
        main(args.mutations)
