"""Execute arrival insertion with real copy, random and diagnostic helpers.

The output hook and fatal reporter are bounded ABI observers. The fatal
reporter returns synthetically; display hardware and gameplay are outside
this audit. An instruction mismatch remains excluded from source ownership.
"""

import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import hashlib
from importlib.metadata import version
import itertools
import json
from pathlib import Path
import re
import sys
import tempfile

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UcError
from unicorn import mips_const as regs

from check_actor_group_path import machine, word, SENTINEL
from check_boss_trigger import fpu_code, FPU_OUT, FPU_BITS, SEED_FPU, READ_FPU
from check_movie_storage import CALLER_SAVED, PRESERVED, pattern
from compare_runtime import MATCHING_BLOCKS
from compare_data import compare_unit, comparison_directory, data_input_hashes
from compare_startup import compare_block, comparison_input_hashes, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


ENTRY, END = 0x8001FCE4, 0x80020134
SCENE, SCENE_SIZE, ARRIVAL_OFFSET, ARRIVAL_SIZE = 0x800B9A78, 3348, 0x44, 12
RESOURCES, RESOURCE_SIZE, SEED = 0x800AF1F0, 0x68, 0x8008F120
STACK, CLOBBER = 0x80300000, 0x80000100
RANDOM, RANDOM_CORE, MOVE = 0x8004CDE8, 0x800631F0, 0x8003B594
FATAL, WARNING, OUTPUT, REPORTER = 0x8001C0D0, 0x8001C2C4, 0x80048DC0, 0x800496E0
DIAGNOSTICS = (0x800917F8, 0x80091814)
SUPPORT = ('runtime_random', 'gu_random', 'game_memory',
           'error_fatal_format', 'error_warning_format', 'geometry_debug_bridge')
DEFAULT_SOURCE = 'src/game/scene_arrivals/insert.c'
DATA_SOURCES = ('src/game/scene_arrivals/storage.c',
                'src/game/scene_arrivals/diagnostics.c',
                'src/game/diagnostics/messages.c')
MESSAGES = {'fatal': b'Arrival Info exceeds limit',
            'warning': b'Too many MAX_ARRIVAL_ENTRIES'}


def signed(value):
    return (value + 0x80000000) % 0x100000000 - 0x80000000


def divide(value, divisor):
    return -(abs(value) // divisor) if value < 0 else value // divisor


def random_value(seed):
    value = ((seed << 2) + 2) & 0xFFFFFFFF
    return ((value * (value + 1)) & 0xFFFFFFFF) >> 2


def frame(image):
    if image[:2] == b'\x27\xBD':
        return -int.from_bytes(image[2:4], 'big', signed=True)
    return 0


def prepare(case):
    scene = pattern(SCENE_SIZE, case.get('pattern', 37))
    total = case.get('total', 5)
    category, resource = case.get('category', 0), case.get('resource', 3)
    for index in range(256):
        offset = ARRIVAL_OFFSET + index * ARRIVAL_SIZE
        scene[offset:offset + 4] = bytes((5, 1, 30, 19))
    for index, state in case.get('slots', {}).items():
        offset = ARRIVAL_OFFSET + index * ARRIVAL_SIZE
        scene[offset + 1] = state
    for index in case.get('duplicates', ()):
        offset = ARRIVAL_OFFSET + index * ARRIVAL_SIZE
        scene[offset + 2:offset + 4] = bytes((resource & 255, category & 255))
    scene[0xCC8:0xCCC] = word(total)
    pool = pattern(36 * RESOURCE_SIZE, 119)
    for index in range(36):
        offset = index * RESOURCE_SIZE + 0x64
        pool[offset:offset + 4] = word(case.get('default_delay', 1200) + index * 100)
    return scene, pool


def oracle(case, scene, pool):
    scene = bytearray(scene)
    trigger, delay, count = case.get('trigger', 1), signed(case.get('delay', 500)), case.get('count', 2) & 0xFFFFFFFF
    seed = case.get('seed', 174823885) & 0xFFFFFFFF
    draws = 0
    if trigger == 4:
        trigger = 1
        delay = max(delay, 100)
        seed = random_value(seed)
        draws = 1
        delay = (seed >> 3) % divide(delay, 100)
    elif trigger == 1:
        delay = divide(delay, 100)
    diagnostics = []
    if count >= 0x8000 or delay & 0xFFFFFFFF >= 0x8000:
        diagnostics.append('fatal')
    flags = set()
    if count == 0:
        flags.add('zero-count')
        return bytes(scene), seed, draws, diagnostics, [], flags, None
    total = signed(case.get('total', 5))
    category, resource = signed(case.get('category', 0)), signed(case.get('resource', 3))
    index, state, moves = 0, 1, []

    def at(index):
        return ARRIVAL_OFFSET + index * ARRIVAL_SIZE

    def same(index):
        offset = at(index)
        return scene[offset + 3] == category and scene[offset + 2] == resource

    while index < total and scene[at(index) + 1] != 0:
        if case.get('replace', 0) and same(index):
            end = index + 1
            while end < total and scene[at(end) + 1] != 0:
                end += 1
            size = (end - index) * ARRIVAL_SIZE
            source = at(index)
            destination = at(index + 1)
            scene[destination:destination + size] = scene[source:source + size]
            moves.append((SCENE + destination, SCENE + source, size))
            flags.add('shift')
            if end == total:
                total += 1
                scene[0xCC8:0xCCC] = word(total)
            break
        index += 1
    if case.get('replace', 0):
        for other in range(index + 1, total):
            if same(other) and scene[at(other) + 1] == 1:
                scene[at(other) + 1] = 2
                flags.add('deferred-duplicate')
    else:
        for other in range(index):
            if scene[at(other) + 1] != 0 and same(other):
                state = 2
                flags.add('preceding-duplicate')
                break
    if index == total:
        total += 1
        scene[0xCC8:0xCCC] = word(total)
    default_read = None
    if state == 1 and trigger == 1 and delay == 0:
        if category == 0:
            assert 0 <= resource < 36, 'Default-delay cases stay in the retail resource pool'
            offset = resource * RESOURCE_SIZE + 0x64
            delay = divide(signed(int.from_bytes(pool[offset:offset + 4], 'big')), 100)
            default_read = RESOURCES + offset
            flags.add('resource-default')
        elif category == 3:
            delay = 10
            flags.add('category-3-default')
    if total > 256:
        total -= 1
        scene[0xCC8:0xCCC] = word(total)
        diagnostics.append('warning')
        flags.add('capacity')
    else:
        offset = at(index)
        scene[offset:offset + 4] = bytes((trigger & 255, state, resource & 255, category & 255))
        values = [delay, count]
        for key in ('x', 'y'):
            value = signed(case.get(key, -1))
            values.append(value if value == -1 else divide(value, 256))
        for delta, value in zip((4, 6, 8, 10), values):
            scene[offset + delta:offset + delta + 2] = (value & 65535).to_bytes(2, 'big')
    return bytes(scene), seed, draws, diagnostics, moves, flags, default_read


def cases():
    shapes = (
        {'total': 0}, {'total': -1}, {'total': -0x80000000},
        {'total': 5}, {'total': 5, 'slots': {0: 0}},
        {'total': 5, 'slots': {2: 0}, 'duplicates': (0, 3, 4)},
        {'total': 5, 'duplicates': (0, 1, 4)},
        {'total': 5, 'slots': {0: 2, 1: 255, 4: 3}, 'duplicates': (0, 1, 4)},
        {'total': 255, 'duplicates': (254,)},
        {'total': 256}, {'total': 256, 'slots': {255: 0}},
        {'total': 256, 'duplicates': (0, 255)},
        {'total': 256, 'slots': {1: 0}, 'duplicates': (0, 255)},
    )
    for replace, shape, category, trigger, delay in itertools.product(
            (0, 1), shapes, (0, 1, 3, 255, 256, -1),
            (0, 1, 2, 4, 5), (0, 99, 100, 501)):
        yield dict(shape, replace=replace, category=category, trigger=trigger,
                   delay=delay, resource=3, x=-257, y=0x7FFFFFFF)
    for count in (0, 1, 0x7FFF, 0x8000, 0xFFFF, 0xFFFFFFFF):
        for trigger, delay in itertools.product((0, 1, 4),
                (-0x80000000, -101, -100, -99, -1, 0, 1, 99, 100, 32767, 32768, 3276700, 0x7FFFFFFF)):
            yield {'count': count, 'trigger': trigger, 'delay': delay, 'total': 0}
    boundaries = (-0x80000000, -0x7FFFFFFF, -32769 * 256, -65536, -257, -256,
                  -255, -2, -1, 0, 1, 255, 256, 257, 32767 * 256,
                  32768 * 256, 0x7FFFFFFF)
    for x, y in itertools.product(boundaries, boundaries):
        yield {'total': 0, 'x': x, 'y': y}
    for delay, resource in itertools.product(
            (-0x80000000, -0x7FFFFFFF, -100, -99, -1, 0, 99, 100, 3276700, 0x7FFFFFFF),
            (0, 1, 35)):
        yield {'total': 0, 'resource': resource, 'delay': 0, 'default_delay': delay}
    for seed, delay in itertools.product((0, 1, 174823885, 0x80000000, 0xFFFFFFFF),
            (-1, 0, 99, 100, 101, 200, 3276700, 0x7FFFFFFF)):
        yield {'total': 0, 'seed': seed, 'trigger': 4, 'delay': delay}


def run(image, helpers, constants, case):
    scene, pool = prepare(case)
    expected, wanted_seed, draws, diagnostics, moves, flags, default_read = oracle(case, scene, pool)
    clobber = word(0x3C013F80)
    clobber += b''.join(word(0x44810000 | (i << 11)) for i in range(20))
    clobber += word(0x03E00008) + word(0)
    uc, write, _ = machine([(ENTRY, image)], helpers + list(constants.items()) + fpu_code() + [(CLOBBER, clobber)])
    uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS, uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | (1 << 29))
    uc.emu_start(SEED_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA57281D9)
    saved = {register: uc.reg_read(register) for register in PRESERVED}
    extent = frame(image) + 0x448 + 24
    panels = {
        'scene': (SCENE - 16, bytearray(b'\xA5' * 16) + scene + b'\x5A' * 16),
        'resources': (RESOURCES - 16, bytearray(b'\xA5' * 16) + pool + b'\x5A' * 16),
        'seed': (SEED - 16, bytearray(b'\xA5' * 16) + word(case.get('seed', 174823885)) + b'\x5A' * 16),
        'stack': (STACK - extent - 16, pattern(extent + 64, 173)),
        'fpu': (FPU_OUT - 16, pattern(80, 211)),
    }
    args = (case.get('replace', 0), case.get('category', 0), case.get('resource', 3),
            case.get('trigger', 1), case.get('delay', 500), case.get('count', 2),
            case.get('x', -1), case.get('y', -1))
    stack = panels['stack'][1]
    argument_offset = STACK - panels['stack'][0]
    for index, value in enumerate(args):
        stack[argument_offset + index * 4:argument_offset + index * 4 + 4] = word(value)
    initial = {name: bytes(blob) for name, (_, blob) in panels.items()}
    for start, blob in panels.values():
        write(start, bytes(blob))
    for index, value in enumerate(args[:4]):
        uc.reg_write(getattr(regs, 'UC_MIPS_REG_A' + str(index)), value & 0xFFFFFFFF)

    executable = [(ENTRY, ENTRY + len(image)), (OUTPUT, OUTPUT + 4), (REPORTER, REPORTER + 4), (SENTINEL, SENTINEL + 4)]
    executable += [(address, address + len(blob)) for address, blob in helpers + fpu_code() + [(CLOBBER, clobber)]]
    readable = [(SCENE, SCENE + SCENE_SIZE), (STACK - extent, STACK + 32), (SEED, SEED + 4)]
    readable += [(address, address + len(blob)) for address, blob in constants.items()]
    active, trace, outputs, reports, seen_moves, resource_reads = ['function'], Counter(), [], [], [], []

    def norm(address):
        return (address & 0x1FFFFFFF) | 0x80000000

    def inside(address, size, ranges):
        return any(first <= address and address + size <= last for first, last in ranges)

    def cstring(address):
        address = norm(address)
        result = bytearray()
        for index in range(500):
            assert inside(address + index, 1, readable), ('diagnostic string bounds', hex(address + index))
            value = uc.mem_read((address + index) & 0x1FFFFFFF, 1)[0]
            if value == 0:
                return bytes(result)
            result.append(value)
        raise AssertionError('Diagnostic string is not terminated within 500 bytes')

    def instruction(uc, address, size, user):
        address = norm(address)
        assert not address & 3 and inside(address, size, executable), ('instruction bounds', hex(address))
        if address in (RANDOM, FATAL, WARNING, MOVE):
            trace[address] += 1
        if address == MOVE:
            seen_moves.append(tuple(uc.reg_read(getattr(regs, 'UC_MIPS_REG_A' + str(i))) for i in range(3)))
        if address in (FATAL, WARNING):
            expected_address = DIAGNOSTICS[0 if address == FATAL else 1]
            assert uc.reg_read(regs.UC_MIPS_REG_A0) == expected_address, 'Arrival diagnostic pointer'
        if address in (OUTPUT, REPORTER):
            if address == OUTPUT:
                outputs.append(cstring(uc.reg_read(regs.UC_MIPS_REG_A0)))
            else:
                reports.append((cstring(uc.reg_read(regs.UC_MIPS_REG_A0)),
                                cstring(uc.reg_read(regs.UC_MIPS_REG_A1)),
                                cstring(uc.reg_read(regs.UC_MIPS_REG_A2)),
                                uc.reg_read(regs.UC_MIPS_REG_A3)))
            for index, register in enumerate(CALLER_SAVED):
                uc.reg_write(register, 0xB2340000 + index * 256)
            uc.reg_write(regs.UC_MIPS_REG_PC, CLOBBER)

    def read(uc, access, address, size, value, user):
        address = norm(address)
        if RESOURCES <= address < RESOURCES + len(pool):
            assert default_read is not None and address == default_read and size == 4, ('resource read gate', hex(address), size)
            resource_reads.append(address)
        else:
            assert inside(address, size, readable), ('read bounds', hex(address), size, hex(uc.reg_read(regs.UC_MIPS_REG_PC)))

    def store(uc, access, address, size, value, user):
        address = norm(address)
        allowed = [(STACK - extent, STACK + 20), (SCENE, SCENE + SCENE_SIZE), (SEED, SEED + 4)]
        if active[0] == 'observer':
            allowed = [(FPU_OUT, FPU_OUT + 48)]
        assert inside(address, size, allowed), ('write bounds', hex(address), size, hex(uc.reg_read(regs.UC_MIPS_REG_PC)))
        if SEED <= address < SEED + 4:
            assert address == SEED and size == 4, 'Random state store width'

    uc.hook_add(UC_HOOK_CODE, instruction)
    uc.hook_add(UC_HOOK_MEM_READ, read)
    uc.hook_add(UC_HOOK_MEM_WRITE, store)
    uc.emu_start(ENTRY, 0, count=250000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, 'Arrival insertion did not return within the instruction bound'
    assert all(uc.reg_read(register) == value for register, value in saved.items()), 'Arrival saved integer registers'
    assert bytes(uc.mem_read(SCENE & 0x1FFFFFFF, SCENE_SIZE)) == expected, ('scene oracle', case)
    assert bytes(uc.mem_read(RESOURCES & 0x1FFFFFFF, len(pool))) == bytes(pool), 'Arrival resource pool changed'
    assert int.from_bytes(uc.mem_read(SEED & 0x1FFFFFFF, 4), 'big') == wanted_seed, 'Random state oracle'
    assert trace[RANDOM] == draws and trace[FATAL] == diagnostics.count('fatal') and trace[WARNING] == diagnostics.count('warning'), ('arrival calls', trace, diagnostics)
    assert seen_moves == moves, ('overlapping move arguments', seen_moves, moves)
    assert resource_reads == ([default_read] if default_read is not None else []), 'Default resource read count'
    expected_outputs, expected_reports = [], []
    for diagnostic in diagnostics:
        message = MESSAGES[diagnostic]
        expected_outputs.extend((b'FATAL ERROR: ' if diagnostic == 'fatal' else b'WARNING: ', message))
        if diagnostic == 'fatal':
            expected_reports.append((b'FATAL ERROR: %s %s %d\n', message, b'errors.c', 0x4D))
    assert outputs == expected_outputs and reports == expected_reports, ('diagnostic output', outputs, reports)
    active[0] = 'observer'
    uc.reg_write(regs.UC_MIPS_REG_A0, FPU_OUT)
    uc.emu_start(READ_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    assert bytes(uc.mem_read(FPU_OUT & 0x1FFFFFFF, 48)) == b''.join(word(value) for value in FPU_BITS), 'Arrival preserved FPU registers'
    for name, (start, blob) in panels.items():
        actual = bytes(uc.mem_read(start & 0x1FFFFFFF, len(blob)))
        assert actual[:16] == initial[name][:16] and actual[-16:] == initial[name][-16:], ('arrival canary', name)
    assert bytes(uc.mem_read((STACK + 20) & 0x1FFFFFFF, 12)) == b''.join(word(value) for value in args[5:]), 'Arrival changed immutable stack arguments'
    return hashlib.sha256(expected + word(wanted_seed)).hexdigest(), flags


def compile_image(name, source, start, end, target, layout):
    result = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                           end - 0x80000000 + 0xC00, target, 'scene-arrival-audit', layout)
    directory = ROOT / 'build/scene-arrival-audit' / name
    sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
    image = (directory / (name + '.bin')).read_bytes()
    constants = {section['address']: section['bytes'] for section in sections.values()
                 if section['size'] and section['type'] == 1 and section['flags'] & 2 and not section['flags'] & 4}
    return result, image, constants


MUTATIONS = (
    ('category-default', 'delay = 10;', 'delay = 11;',
     dict(total=0, category=3, delay=0)),
    ('signed-coordinate', 'arrival->x = x / 256;',
     'arrival->x = (unsigned int)x / 256;', dict(total=0, x=-257)),
    ('coordinate-sentinel', 'if (x == -1)', 'if (x == 0)', dict(total=0, x=-1)),
    ('unsigned-count-limit', 'count > 0x7FFF', '(int)count > 0x7FFF',
     dict(total=0, count=0xFFFFFFFF)),
    ('overlap-destination', '&D_800B9A78.arrivals[index + 1]',
     '&D_800B9A78.arrivals[index]', dict(replace=1, duplicates=(0, 1, 4))),
    ('duplicate-state-gate', 'D_800B9A78.arrivals[other].state == 1',
     'D_800B9A78.arrivals[other].state != 0',
     dict(replace=1, duplicates=(0, 4), slots={4: 3})),
    ('random-call', '(func_8004CDE8() >> 3)', '0',
     dict(total=0, trigger=4, delay=200)),
)


def negative_controls(source, target, layout, candidate, original, helpers, constants):
    results = {}
    body = (ROOT / source).read_text()
    private = ROOT / 'build/scene-arrival-audit'
    with tempfile.TemporaryDirectory(prefix='mutations-', dir=private) as directory:
        for name, before, after, case in MUTATIONS:
            assert body.count(before) == 1, ('mutation site', name)
            run(original, helpers, constants, case)
            run(candidate, helpers, constants, case)
            path = Path(directory) / (name + '.c')
            # Keep the original include targets when moving the source unit.
            mutated = re.sub(r'#include "([^"]+)"',
                             lambda match: '#include "' + str(
                                 (ROOT / source).parent.joinpath(match[1]).resolve()) + '"',
                             body.replace(before, after))
            path.write_text(mutated)
            report, image, _ = compile_image('mutant_' + name,
                path.relative_to(ROOT).as_posix(), ENTRY, END, target, layout)
            try:
                run(image, helpers, constants, case)
            except (AssertionError, UcError) as error:
                results[name] = dict(rejected=True, reason=str(error),
                                    source_sha256=hashlib.sha256(mutated.encode()).hexdigest(),
                                    different_words=len(report['different_words']))
            else:
                raise AssertionError(('Arrival audit accepted source mutation', name))
    for diagnostic, case in (('fatal', dict(total=0, count=0x8000)),
                             ('warning', dict(total=256))):
        run(original, helpers, constants, case)
        run(candidate, helpers, constants, case)
        changed = dict(constants)
        blob = bytearray(changed[DIAGNOSTICS[0]])
        blob[0 if diagnostic == 'fatal' else 28] ^= 1
        changed[DIAGNOSTICS[0]] = bytes(blob)
        try:
            run(candidate, helpers, changed, case)
        except (AssertionError, UcError) as error:
            results[diagnostic + '-message'] = dict(rejected=True, reason=str(error))
        else:
            raise AssertionError(('Arrival audit accepted data mutation', diagnostic))
    return results


def main(source=DEFAULT_SOURCE):
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    checker_hash = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    blocks = {name: (source, first, last) for name, source, first, last in MATCHING_BLOCKS}
    with ThreadPoolExecutor(max_workers=3) as executor:
        tasks = {name: executor.submit(compile_image, name, *blocks[name], target, layout) for name in SUPPORT}
        support = {name: future.result() for name, future in tasks.items()}
    helpers, constants = [], {}
    for name, (result, image, data) in support.items():
        assert result['matches'], ('Arrival support instruction mismatch', name)
        helpers.append((blocks[name][1], image))
        constants.update(data)
    data_comparisons = {}
    for data_source in DATA_SOURCES:
        records = source_sections(data_source)
        assert records, ('Arrival data ownership missing', data_source)
        data_comparisons[data_source] = compare_unit(data_source, records, target, layout)
        sections, _ = elf_sections_and_symbols(comparison_directory(data_source) / 'compiled.elf')
        for record in records:
            if record['rom'] is not None:
                constants[record['vram']] = sections[record['section']]['bytes']
            else:
                assert record['vram'] == SCENE and record['size'] == SCENE_SIZE
    result, candidate, _ = compile_image('insert', source, ENTRY, END, target, layout)
    original = target[ENTRY - 0x80000000 + 0xC00:END - 0x80000000 + 0xC00]
    coverage, digest, count = Counter(), hashlib.sha256(), 0
    for case in cases():
        retail, flags = run(original, helpers, constants, case)
        compiled, other_flags = run(candidate, helpers, constants, case)
        assert compiled == retail and flags == other_flags, ('paired arrival execution', case)
        digest.update(retail.encode())
        coverage.update(flags)
        count += 1
    controls = negative_controls(source, target, layout, candidate, original, helpers, constants)
    layout.verify()
    for name, (comparison, _, _) in support.items():
        assert comparison_input_hashes(blocks[name][0]) == comparison['inputs_sha256'], ('Arrival helper inputs changed', name)
    assert comparison_input_hashes(source) == result['inputs_sha256'], 'Arrival candidate inputs changed'
    for data_source, comparison in data_comparisons.items():
        assert data_input_hashes(data_source) == comparison['inputs_sha256'], ('Arrival data inputs changed', data_source)
    assert hashlib.sha256(Path(__file__).read_bytes()).hexdigest() == checker_hash, 'Arrival checker changed during execution'
    report = {'source': source, 'instruction_match': result['matches'],
              'matching_source_claim': False, 'retail_size': len(original),
              'candidate_size': len(candidate), 'different_words': len(result['different_words']),
              'retail_frame': frame(original), 'candidate_frame': frame(candidate),
              'paired_cases': count, 'coverage': dict(coverage),
              'outcomes_sha256': digest.hexdigest(), 'helpers': list(SUPPORT),
              'support_comparisons': {name: value[0] for name, value in support.items()},
              'data_comparisons': data_comparisons,
              'negative_controls': controls, 'checker_sha256': checker_hash,
              'target_rom_sha256': hashlib.sha256(target).hexdigest(),
              'callees_using_abi_observers': ['diagnostic output', 'fatal renderer'],
              'synthetic_fatal_return': True, 'unicorn_version': version('unicorn'),
              'inputs_sha256': result['inputs_sha256']}
    path = ROOT / 'build/scene-arrival-audit/report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed scene arrivals:', count, 'paired cases;', len(controls),
          'rejected mutations;', len(result['different_words']), 'instruction words differ')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', default=DEFAULT_SOURCE)
    main(parser.parse_args().source)
