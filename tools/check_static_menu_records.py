"""Guard matched menu cleanup with complete retail and source-built static records.

Text release and camera submission are ABI-clobbering boundary stubs. Page
activation, callback invocation and full-game behavior are outside this proof.
"""

import hashlib
import itertools
import json
from importlib.metadata import version

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UC_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_boundary_boss import environment, CLOBBER
from check_actor_group_path import word, SENTINEL
from compare_data import compare_unit, comparison_directory
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate

NAV, STACK = 0x800AEE98, 0x80300000
ACTOR, PREVIEW, CAPTURE = 0x80203000, 0x80204000, 0x80201000
DATA = tuple('src/game/save_menus/static_' + kind + '/' + leaf + '.c'
             for kind in ('confirmation', 'pause') for leaf in ('labels', 'page', 'text'))
SUPPORT = ('save_menu_nav_cleanup', 'save_menu_nav_preview_release', 'menu_transition_start')
PAGES = ((0x800772F0, 0x800772A0, 2), (0x8007751C, 0x80077454, 5))
RECORD_RANGES = ((0x800772A0, 132), (0x80077454, 252),
                 (0x8009347C, 16), (0x800934F0, 80))


def run(code, image, retail, case, pages=PAGES, record_ranges=RECORD_RANGES):
    page_index, transition, restore, release, preview, actor, mask = case
    page, labels, count = pages[page_index]
    uc, write, execute, read, finish_call = environment(code, [])
    fixtures = {}
    def seed(address, value):
        fixtures[address] = bytearray(value)
    for base, size in record_ranges:
        offset = base - 0x80000000 + 0xC00
        seed(base - 16, b'\xA5' * 16 + retail[offset:offset + size] + b'\xB6' * 16)
    seed(NAV - 16, b'\xC7' * 132)
    seed(ACTOR - 16, b'\xD8' * 112)
    seed(PREVIEW - 16, b'\xE9' * 112)
    seed(CAPTURE - 16, b'\xFA' * 44)
    seed(STACK - 0x300, b'\x8B' * 0x340)

    def put(address, value, destination=fixtures):
        for base, data in destination.items():
            if base <= address and address + len(value) <= base + len(data):
                data[address - base:address - base + len(value)] = value
                return
        raise AssertionError(('Write outside fixture', hex(address), len(value)))

    put(NAV + 4, word(page))
    put(NAV + 0x1C, word(PREVIEW if preview else 0))
    put(NAV + 0x20, word(ACTOR if actor else 0))
    put(NAV + 0x60, word(0x80208000))
    camera = (0x3F800000, 0xC0000000, 0x40800000)
    angles = (0x81234567, 0, 0x7FFFFFFF)
    for i, value in enumerate(camera):
        put(NAV + 0x2C + i * 4, word(value))
    for i, value in enumerate(angles):
        put(NAV + 0x38 + i * 4, word(value))
    slots = [(page + 4, 137 if mask & 1 else -1)]
    slots += [(labels + i * 40 + 16, 200 + i if mask & (1 << (i % 3)) else -1)
              for i in reversed(range(count))]
    for address, value in slots:
        put(address, word(value))
    expected = {a: bytearray(b) for a, b in fixtures.items()}
    expected_trace = []
    for address, value in slots:
        if value != -1:
            expected_trace.append(['text_release', address])
            put(address, word(-1), expected)
    if transition:
        put(NAV + 0x60, word(0), expected)
    if preview and release:
        put(PREVIEW + 0x21, b'\x02', expected)
        put(NAV + 0x1C, word(0), expected)
    if restore:
        expected_trace += [['camera_position', list(camera)], ['camera_angles', list(angles)]]
        put(CAPTURE, b''.join(word(x) for x in camera), expected)
    if actor:
        put(ACTOR + 0x21, b'\x02', expected)
    put(NAV + 4, word(0), expected)
    # Overlay independently compiled initialized storage; fixture expectations
    # continue to come from retail, including fields that cleanup never touches.
    actual = {a: bytearray(b) for a, b in fixtures.items()}
    for address, data in image:
        put(address, data, actual)
    for address, value in slots:
        put(address, word(value), actual)
    for base, data in actual.items():
        write(base, bytes(data))

    trace = []
    def stub(uc, address, size, user):
        if address == 0x80000ACC:
            argument = uc.reg_read(regs.UC_MIPS_REG_A0)
            trace.append(['text_release', argument])
            write(argument, word(-1))
        elif address == 0x80039F20:
            trace.append(['camera_position', [int.from_bytes(read(CAPTURE + i * 4, 4), 'big')
                                               for i in range(3)]])
        else:
            assert address == 0x80039FCC
            trace.append(['camera_angles', [uc.reg_read(r) for r in
                         (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2)]])
        finish_call()
    for address in (0x80000ACC, 0x80039F20, 0x80039FCC):
        uc.hook_add(UC_HOOK_CODE, stub, begin=address, end=address)

    code_ranges = [(a & 0x1FFFFFFF, (a & 0x1FFFFFFF) + len(b)) for a, b in code]
    code_ranges += [(CLOBBER & 0x1FFFFFFF, (CLOBBER & 0x1FFFFFFF) + 92)]
    stub_addresses = {0x80000ACC, 0x80039F20, 0x80039FCC, SENTINEL}
    reads = [(a & 0x1FFFFFFF, (a & 0x1FFFFFFF) + len(b)) for a, b in fixtures.items()] + code_ranges
    writes = [(STACK - 0x200, STACK + 16), (NAV + 4, NAV + 8),
              (NAV + 0x1C, NAV + 0x24), (NAV + 0x60, NAV + 0x64),
              (ACTOR + 0x21, ACTOR + 0x22), (PREVIEW + 0x21, PREVIEW + 0x22),
              (CAPTURE, CAPTURE + 12)]
    writes += [(a, a + 4) for a, _ in slots]
    writes = [(a & 0x1FFFFFFF, b & 0x1FFFFFFF) for a, b in writes]
    def memory_guard(uc, access, address, size, value, user):
        address &= 0x1FFFFFFF
        ranges = writes if access == UC_MEM_WRITE else reads
        assert any(a <= address and address + size <= b for a, b in ranges), (
            'Out-of-bounds memory access', access, hex(address), size)
    uc.hook_add(UC_HOOK_MEM_READ | UC_HOOK_MEM_WRITE, memory_guard)
    def execution_guard(uc, address, size, user):
        assert address in stub_addresses or any(a <= (address & 0x1FFFFFFF) < b
                                               for a, b in code_ranges), hex(address)
    uc.hook_add(UC_HOOK_CODE, execution_guard)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0x8007F123)
    uc.reg_write(regs.UC_MIPS_REG_A0, restore)
    uc.reg_write(regs.UC_MIPS_REG_A1, release)
    if transition:
        uc.reg_write(regs.UC_MIPS_REG_A2, 0)
    execute(0x800278AC if transition else 0x8002606C)
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0x8007F123
    assert trace == expected_trace, (case, trace, expected_trace)
    for base, data in expected.items():
        if base == STACK - 0x300:
            assert read(base, 0x100) == bytes(data[:0x100])
            assert read(STACK + 16, 48) == bytes(data[0x310:])
        else:
            assert read(base, len(data)) == bytes(data), (case, hex(base))
    return trace


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    comparisons, compiled, original = {}, [], []
    for name, source, first, last in MATCHING_BLOCKS:
        if name not in SUPPORT:
            continue
        offset = first - 0x80000000 + 0xC00
        result = compare_block(name, source, first, offset, offset + last - first,
                               target, 'static-menu-execution', layout)
        assert result['matches'], name
        comparisons[name] = result
        compiled.append((first, (ROOT / 'build/static-menu-execution' / name / (name + '.bin')).read_bytes()))
        original.append((first, target[offset:offset + last - first]))
    assert set(comparisons) == set(SUPPORT)
    # Capture actual O32 floating arguments before the Python boundary hook.
    shim = b''.join(word(x) for x in (0x3C018020, 0xE42C1000, 0xE42E1004, 0xAC261008, 0))
    compiled.append((0x80039F10, shim))
    original.append((0x80039F10, shim))
    data_comparisons, image, retail_image = {}, [], []
    for source in DATA:
        records = source_sections(source)
        data_comparisons[source] = compare_unit(source, records, target, layout)
        sections, _ = elf_sections_and_symbols(comparison_directory(source) / 'compiled.elf')
        for record in records:
            image.append((record['vram'], sections[record['section']]['bytes']))
            retail_image.append((record['vram'], target[record['rom']:record['rom'] + record['size']]))
    assert sum(len(b) for _, b in image) == 480
    cases = list(itertools.product(range(2), range(2), range(2), range(2), range(2), range(2), range(8)))
    digest = hashlib.sha256()
    for case in cases:
        first = run(original, retail_image, target, case)
        second = run(compiled, image, target, case)
        assert first == second
        digest.update(json.dumps([case, second], sort_keys=True).encode())
    mutations = []
    for name, address in (('page_child', 0x8007753C), ('label_callback', 0x800774D0),
                          ('page_timeout', 0x8007754C), ('label_text', 0x800774FC)):
        changed = []
        for base, data in image:
            value = bytearray(data)
            if base <= address < base + len(data):
                value[address - base:address - base + 4] = word(0)
                if name == 'page_timeout':
                    value[address - base:address - base + 4] = word(0x8002FC08)
            changed.append((base, bytes(value)))
        assert changed != image
        try:
            run(compiled, changed, target, (1, 1, 1, 1, 1, 1, 7))
        except (AssertionError, ValueError):
            mutations.append(name)
        else:
            raise AssertionError(('Mutation escaped', name))
    report = dict(matches=True, cases=len(cases), executions=len(cases) * 2,
                  initialized_bytes=480, source_instruction_bytes_added=0,
                  mutations_detected=mutations, trace_sha256=digest.hexdigest(),
                  data_comparisons=data_comparisons, support_comparisons=comparisons,
                  unicorn=version('unicorn'),
                  limits=['Only existing matching cleanup, preview release and immediate transition execute.',
                          'Text release and camera submission use ABI-clobbering stubs; camera O32 float arguments are captured by a MIPS shim.',
                          'The unprototyped callback entry stores addresses without invoking them.',
                          'Page activation, callback invocation, rendering and gameplay are unverified.',
                          'The dynamically constructed page timeout-word extent is not established.'])
    report['checker_sha256'] = hashlib.sha256((ROOT / 'tools/check_static_menu_records.py').read_bytes()).hexdigest()
    path = ROOT / 'build/static-menu-execution/report.json'
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(report, indent=2) + '\n')
    print('Matched static-menu cleanup:', len(cases), 'cases,', len(cases) * 2,
          'executions, 480 complete initialized bytes,', len(mutations), 'mutations detected')


if __name__ == '__main__':
    main()
