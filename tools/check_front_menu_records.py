"""Execute matched display, cleanup and audio callbacks with complete front pages."""

import hashlib
import itertools
import json
from pathlib import Path
from importlib.metadata import version

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UC_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_boundary_boss import environment, CLOBBER, signed
from check_actor_group_path import word, SENTINEL
from check_static_menu_records import run as cleanup
from compare_data import compare_unit, comparison_directory
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, load_owned_sections, source_sections
from rom import ROOT, validate

NAV, STACK = 0x800AEE98, 0x80300000
PAGES = ((0x80076D70, 0x80076CD0, 4), (0x80076E44, 0x80076DA4, 4),
         (0x80076F18, 0x80076E78, 4))
RANGES = ((0x80076CD0, 636), (0x80093254, 196))
TITLES = (b'', b'', b'audio settings')
TEXT = ((b'main menu', b'view controller pak', b'load game', b'enter password'),
        (b'setup', b'load game', b'two player game', b'one player game'),
        (b'return', b'play music track', b'sound fx volume', b'music volume'))
SUPPORT = ('menu_display', 'game_memory', 'game_number_format', 'fixed_geometry_setup',
           'save_menu_nav_cleanup', 'save_menu_nav_preview_release', 'menu_transition_start',
           'save_menu_audio_index', 'save_menu_audio_apply', 'save_menu_audio_secondary')
DISPLAY_STUBS = (0x80000518, 0x800011AC, 0x8000177C, 0x80000E74,
                 0x80000B7C, 0x80001270, 0x8004CDE8)


def fixture(code, image, target, ranges, writable):
    uc, write, execute, read, finish_call = environment(code, [])
    state = {}
    for address, size in ranges:
        start = address - 0x80000000 + 0xC00
        data = target[start:start + size] if 0 <= start < len(target) else bytes(size)
        state[address - 16] = bytearray(b'\xA5' * 16 + data + b'\xB6' * 16)
    state[STACK - 0x300] = bytearray(b'\xC7' * 0x340)

    def put(storage, address, data):
        for base, value in storage.items():
            if base <= address and address + len(data) <= base + len(value):
                value[address - base:address - base + len(data)] = data
                return
        raise AssertionError(('Fixture write escaped extent', hex(address), len(data)))

    actual = {a: bytearray(b) for a, b in state.items()}
    for address, data in image:
        put(actual, address, data)
    code_ranges = [(a & 0x1FFFFFFF, (a & 0x1FFFFFFF) + len(b)) for a, b in code]
    code_ranges.append((CLOBBER & 0x1FFFFFFF, (CLOBBER & 0x1FFFFFFF) + 92))
    readable = [((a + 16) & 0x1FFFFFFF, (a + len(b) - 16) & 0x1FFFFFFF)
                for a, b in state.items() if a != STACK - 0x300] + code_ranges
    readable.append(((STACK - 0x200) & 0x1FFFFFFF, (STACK + 16) & 0x1FFFFFFF))
    writable = [(a & 0x1FFFFFFF, b & 0x1FFFFFFF) for a, b in writable]
    writable.append(((STACK - 0x200) & 0x1FFFFFFF, (STACK + 16) & 0x1FFFFFFF))

    def guard(uc, access, address, size, value, user):
        address &= 0x1FFFFFFF
        allowed = writable if access == UC_MEM_WRITE else readable
        assert any(a <= address and address + size <= b for a, b in allowed), (
            'Memory escaped fixture', hex(address), size)
    uc.hook_add(UC_HOOK_MEM_READ | UC_HOOK_MEM_WRITE, guard)

    def check(expected):
        for address, data in expected.items():
            if address == STACK - 0x300:
                assert read(address, 0x100) == bytes(data[:0x100])
                assert read(STACK + 16, 48) == bytes(data[0x310:])
            else:
                assert read(address, len(data)) == bytes(data), hex(address)
        assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0x8007F123

    def start(entry, stubs):
        def code_guard(uc, address, size, user):
            assert address in stubs + (SENTINEL,) or any(
                a <= (address & 0x1FFFFFFF) and (address & 0x1FFFFFFF) + size <= b
                for a, b in code_ranges), hex(address)
        uc.hook_add(UC_HOOK_CODE, code_guard)
        for address, data in actual.items():
            write(address, bytes(data))
        uc.reg_write(regs.UC_MIPS_REG_GP, 0x8007F123)
        execute(entry)
    return uc, read, write, finish_call, state, actual, put, start, check


def display(code, image, target, case):
    page_index, selected, alternate, properties, values = case
    page, labels, count = PAGES[page_index]
    slots = [(page + 4, page + 8)] + [(labels + i * 40 + 16, labels + i * 40 + 20)
                                     for i in range(count)]
    ranges = RANGES + ((NAV, 100), (0x800761F4, 4), (0x8009EF94, 4),
                      (0x800AD2F8, 32), (0x800938C8, 8), (0x8007BB1C, 20))
    uc, read, write, finish_call, expected, actual, put, start, check = fixture(
        code, image, target, ranges, slots)
    for storage in (expected, actual):
        put(storage, NAV + 4, word(page))
        put(storage, NAV + 0x44, word(123) + word(-234) + word(345))
        put(storage, NAV + 0x50, word(labels + selected * 40 if selected >= 0 else 0))
        put(storage, 0x800761F4, word(alternate))
        put(storage, 0x8009EF94, word(0))
        for address, value in zip((0x800AD2FC, 0x800AD314, 0x800AD310), values):
            put(storage, address, word(value))
    y = 405 if page_index == 2 else 420
    def draw(slot, row, title):
        return ['draw', [slot, 123, -40234, 345 + row * 130 - (45500 if title else 39000),
                         2278, 0, 0, 2500, 0, 0, 0, 1, 1, 20 if title else 32767,
                         180 if title else (1 if properties & 2 else 24)]]
    title = TITLES[page_index]
    oracle = [['convert', title.hex()], ['create', page + 4, title.hex(), 1500, 11, 0, 0],
              draw(100, y - (60 if alternate else 0), True)]
    put(expected, page + 4, word(100))
    for order, i in enumerate(reversed(range(count)), 101):
        text = TEXT[page_index][i]
        oracle += [['convert', text.hex()], ['create', labels + i * 40 + 16, text.hex(), 1000, 11, 1, 0]]
        put(expected, labels + i * 40 + 16, word(order))
        if page_index == 2 and i > 0:
            value = values[i - 1]
            suffix = b'never' if value == 105000 else bytes(
                (byte + 122) & 255 for byte in str(value + 1).encode())
            oracle.append(['suffix', order, len(text) + 1, suffix.hex()])
        oracle += [['properties', order, properties], draw(order, y, False)]
        y += 28
    trace = []
    handle = [99]
    def string(address):
        result = bytearray()
        for i in range(100):
            byte = read(address + i, 1)[0]
            if not byte:
                return result.hex()
            result.append(byte)
        raise AssertionError('Unterminated boundary string')
    def stub(uc, address, size, user):
        args = [uc.reg_read(r) for r in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                       regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)]
        sp = uc.reg_read(regs.UC_MIPS_REG_SP)
        if address == 0x80000518:
            trace.append(['convert', string(args[0])]); finish_call(args[0])
        elif address == 0x800011AC:
            trace.append(['create', args[0], string(args[1]), signed(args[2]), signed(args[3]),
                          int.from_bytes(read(sp + 16, 4), 'big'), int.from_bytes(read(sp + 20, 4), 'big')])
            handle[0] += 1; write(args[0], word(handle[0])); finish_call(handle[0])
        elif address == 0x8000177C:
            args += [int.from_bytes(read(sp + 16 + i * 4, 4), 'big') for i in range(11)]
            trace.append(['draw', [signed(x) for x in args]]); finish_call()
        elif address == 0x80000E74:
            trace.append(['properties', args[0], properties]); finish_call(properties)
        elif address == 0x80001270:
            trace.append(['suffix', args[0], args[1], string(args[2])]); finish_call(0)
        else:
            raise AssertionError(('Unexpected display boundary', hex(address)))
    for address in DISPLAY_STUBS:
        uc.hook_add(UC_HOOK_CODE, stub, begin=address, end=address)
    start(0x8002741C, DISPLAY_STUBS)
    assert trace == oracle, (case, trace, oracle)
    check(expected)
    return trace


def audio(code, image, target, case):
    index, selection, limit, stored = case
    label = 0x80076E78 + index * 40
    pointer = (0, 0x800AD2FC, 0x800AD314, 0x800AD310)[index]
    writes = [(0x800AD2FC, 0x800AD300), (pointer, pointer + 4)]
    if index == 1:
        writes.append((0x80076EC0, 0x80076EC4))
    ranges = RANGES + ((0x800AD2F8, 32), (0x800AF1E0, 4))
    uc, read, write, finish_call, expected, actual, put, start, check = fixture(
        code, image, target, ranges, writes)
    for storage in (expected, actual):
        put(storage, 0x800AF1E0, word(limit))
        put(storage, 0x800AD2FC, word(stored))
        put(storage, pointer, word(selection))
    if index == 1:
        # The record points at field04, so the first clamp also changes
        # *selection before the callback's subsequent comparison.
        result = min(limit, selection)
        put(expected, pointer, word(result))
        put(expected, 0x80076EC0, word(limit))
        oracle = [['sequence', signed(result + 1), 1, 1]]
    elif index == 2:
        oracle = [['sound', 3, 0, 1, 0], ['fx', selection]]
    else:
        oracle = [['music', selection]]
    trace = []
    stubs = (0x80051680, 0x8003614C, 0x80051888, 0x80051854)
    def stub(uc, address, size, user):
        args = [signed(uc.reg_read(r)) for r in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                               regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)]
        name, count = {0x80051680: ('sequence', 3), 0x8003614C: ('sound', 4),
                       0x80051888: ('fx', 1), 0x80051854: ('music', 1)}[address]
        trace.append([name] + args[:count]); finish_call()
    for address in stubs:
        uc.hook_add(UC_HOOK_CODE, stub, begin=address, end=address)
    # Read both words from the actual compiled record instead of substituting
    # the expected callback or selection pointer into the call.
    for address, data in actual.items():
        write(address, bytes(data))
    entry = int.from_bytes(read(label + 4, 4), 'big')
    argument = int.from_bytes(read(label + 20, 4), 'big')
    uc.reg_write(regs.UC_MIPS_REG_A0, argument)
    start(entry, stubs)
    assert trace == oracle, (case, trace, oracle)
    check(expected)
    return trace


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes(); validate(target)
    layout = SymbolLayoutSnapshot(); compiled = []; original = []; comparisons = {}
    for name, source, first, last in MATCHING_BLOCKS:
        if name not in SUPPORT:
            continue
        offset = first - 0x80000000 + 0xC00
        q = compare_block(name, source, first, offset, offset + last - first,
                          target, 'front-menu-execution', layout)
        assert q['matches'], name
        comparisons[name] = q
        compiled.append((first, (ROOT / 'build/front-menu-execution' / name / (name + '.bin')).read_bytes()))
        original.append((first, target[offset:offset + last - first]))
    assert set(comparisons) == set(SUPPORT)
    records = [x for x in load_owned_sections() if x['section'].startswith('.menu_front_')]
    image = []; data_comparisons = {}
    for item in records:
        source = item['source']; data_comparisons[source] = compare_unit(source, [item], target, layout)
        sections, _ = elf_sections_and_symbols(comparison_directory(source) / 'compiled.elf')
        image.append((item['vram'], sections[item['section']]['bytes']))
    assert sum(len(b) for _, b in image) == 832
    display_image = list(image)
    for source in ('src/game/formatting/digits.c', 'src/game/save_menus/display/never.c'):
        items = source_sections(source); data_comparisons[source] = compare_unit(source, items, target, layout)
        sections, _ = elf_sections_and_symbols(comparison_directory(source) / 'compiled.elf')
        display_image += [(item['vram'], sections[item['section']]['bytes']) for item in items]
    shim = b''.join(word(x) for x in (0x3C018020, 0xE42C1000, 0xE42E1004, 0xAC261008, 0))
    cleanup_compiled = compiled + [(0x80039F10, shim)]
    cleanup_original = original + [(0x80039F10, shim)]
    cleanup_cases = list(itertools.product(range(3), range(2), range(2), range(2), range(2), range(2), range(8)))
    display_cases = [(page, selected, alternate, properties, (value, value, value))
                     for page, selected, alternate, properties, value in itertools.product(
                         range(3), range(-1, 4), range(2), (0, 2, 18), (-1, 0, 9, 127, 105000, 2147483646))]
    audio_cases = list(itertools.product(range(1, 4), (-2147483648, -1, 0, 1, 127, 2147483647),
                                        (-1, 0, 1, 127, 2147483647), (0, 1, 17)))
    digest = hashlib.sha256()
    for case in cleanup_cases:
        a = cleanup(cleanup_compiled, image, target, case, PAGES, RANGES)
        b = cleanup(cleanup_original, [], target, case, PAGES, RANGES)
        assert a == b; digest.update(json.dumps(['cleanup', case, a]).encode())
    for case in display_cases:
        a = display(compiled, display_image, target, case)
        b = display(original, [], target, case)
        assert a == b; digest.update(json.dumps(['display', case, a]).encode())
    for case in audio_cases:
        a = audio(compiled, image, target, case)
        b = audio(original, [], target, case)
        assert a == b; digest.update(json.dumps(['audio', case, a]).encode())
    mutations = []
    for name, address, value, phase, case in (
            ('page_child', 0x80076D90, word(0), 'display', (0, -1, 0, 0, (9, 9, 9))),
            ('audio_selection', 0x80076EB4, word(0x800AD310), 'audio', (1, 9, 17, 1)),
            ('audio_callback', 0x80076ECC, word(0x80030F94), 'audio', (2, 9, 17, 1)),
            ('timeout_callback', 0x80076E74, word(0), 'cleanup', (1, 1, 1, 1, 1, 1, 7)),
            ('audio_title', 0x80093308, b'X', 'display', (2, -1, 0, 0, (9, 9, 9)))):
        altered = []
        for base, data in (display_image if phase == 'display' else image):
            if base <= address and address + len(value) <= base + len(data):
                data = bytearray(data); data[address - base:address - base + len(value)] = value; data = bytes(data)
            altered.append((base, data))
        try:
            if phase == 'cleanup': cleanup(cleanup_compiled, altered, target, case, PAGES, RANGES)
            else: {'display': display, 'audio': audio}[phase](compiled, altered, target, case)
        except (AssertionError, ValueError): mutations.append(name)
        else: raise AssertionError(('Mutation escaped', name))
    report = dict(matches=True, initialized_bytes_added=832, source_instruction_bytes_added=0,
                  bss_bytes_added=0, cleanup_cases=len(cleanup_cases), display_cases=len(display_cases),
                  audio_cases=len(audio_cases), cases=len(cleanup_cases) + len(display_cases) + len(audio_cases),
                  executions=2 * (len(cleanup_cases) + len(display_cases) + len(audio_cases)),
                  mutations_detected=mutations, trace_sha256=digest.hexdigest(),
                  support_comparisons=comparisons, data_comparisons=data_comparisons,
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  cleanup_checker_sha256=hashlib.sha256((ROOT / 'tools/check_static_menu_records.py').read_bytes()).hexdigest(),
                  unicorn_version=version('unicorn'),
                  limits=['Text services, rendering, RNG, audio hardware and camera submission use O32 boundary stubs.',
                          'Complete matching display, string/number helpers, cleanup and all three audio callbacks execute.',
                          'The timeout callback word is compared but its deferred control flow is not executed.',
                          'Activation, general menu control, other label callbacks and full-game rendering remain unverified.'])
    (ROOT / 'build/front-menu-execution/report.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Complete front menu records:', report['cases'], 'cases,', report['executions'],
          'executions and', len(mutations), 'mutations detected.', flush=True)


if __name__ == '__main__':
    main()
