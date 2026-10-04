"""Execute the Pak directory menu with matching format/string helpers.

Device queries, file opening and menu submission are recorded ABI boundaries.
This models those responses; it does not emulate a Controller Pak or a menu.
"""

import hashlib
import itertools
import json
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs

from check_actor_group_path import machine, word, SENTINEL
from check_error_formatters import CALLER_SAVED, DIGITS, oracle
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import SymbolLayoutSnapshot, compare_block
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


ENTRY, END, STACK = 0x800267BC, 0x80026A10, 0x80300000
COUNT, TITLE, LABELS, POINTERS, ACTIVE = (
    0x80077A94, 0x800BAEA0, 0x800BAF08, 0x800BB0E8, 0x800761F4)
DATA = ('src/game/save_menus/pak_directory_storage.c',
        'src/game/save_menus/pak_directory_strings.c')
SUPPORT = ('destination_format', 'game_memory', 'game_number_format',
           'fixed_geometry_setup', 'geometry_debug_bridge')
BOUNDARIES = (0x8004FC98, 0x8004F990, 0x8004FB48, 0x8004C3AC, 0x800263E0)
FORMATS = (b'                    %3d', b'%d pages needed\\%d pages free',
           b'\\delete game ?\\%d pages free',
           b'delete game ?\\%d pages needed\\%d pages free')


def cases():
    for status, free, seed in itertools.product((-2, -1, 0, 2, 7, 1), (-1, 0, 999), (3, 197)):
        if status != 1 or free == -1:
            yield status, free, 0xFFFF, 18, 99, 1, seed
    for mask, length, pages, opened, seed in itertools.product(
            (0, 1, 0x8000, 0x8001, 0x5555, 0xAAAA, 0x7FFF, 0xFFFF),
            (0, 1, 17, 18, 24, 29, 30, 31, 32, 33),
            (0, 9, 9999, 10000, 0x7FFFFFFF, 0x80000001),
            (0, 5), (3, 197)):
        free = (0, 1, 999, 65535, 0x7FFFFFFF, -2)[(length + seed) % 6]
        yield 1, free, mask, length, pages, opened, seed


def scenario(case):
    status, free, mask, length, pages, opened, seed = case
    initial = bytes((index * 37 + seed) & 255 for index in range(648))
    expected = bytearray(initial)
    trace = [[0x8004FC98, [1]]]
    names = [bytes(65 + (slot + index) % 26 for index in range(length)) for slot in range(16)]
    count, active, returned = -1, 0x713579BD, 0
    if status == 1:
        trace.append([0x8004F990, []])
        if free != -1:
            count = 0
            for slot in range(16):
                trace.append([0x8004FB48, [slot, STACK - 0x24, STACK - 0x20]])
                if mask & (1 << slot):
                    expected[584 + count * 4:588 + count * 4] = word(LABELS + slot * 30)
                    formatted = oracle(FORMATS[0], (pages,), widths=True) + b'\0'
                    start = 104 + slot * 30
                    expected[start:start + len(formatted)] = formatted
                    copied = names[slot][:32]
                    expected[start:start + len(copied)] = copied
                    count += 1
            if count == 0:
                title = oracle(FORMATS[1], (16, free), widths=True)
            else:
                trace.append([0x8004C3AC, [0x80093870, 0x80093878]])
                title = oracle(FORMATS[2], (free,), widths=True) if opened else oracle(FORMATS[3], (16, free), widths=True)
            expected[:len(title) + 1] = title + b'\0'
            active = returned = 1
            trace.append([0x800263E0, [TITLE, POINTERS, count, 0xFFFFFFFF, 0, 0,
                                      0x800266BC, 0x8002674C, 210]])
    elif status in (-1, -2):
        returned = status
    return initial, bytes(expected), count, active, returned, trace, names


def run(code, support, case):
    initial, expected, count, active, returned, expected_trace, names = scenario(case)
    status, free, mask, length, pages, opened, seed = case
    uc, write, _ = machine(code, support)
    write(TITLE - 16, b'\xC7' * 16 + initial + b'\xD8' * 16)
    write(COUNT - 16, b'\xA9' * 16 + word(0x12345678) + b'\xB9' * 16)
    write(ACTIVE - 16, b'\xAB' * 16 + word(0x713579BD) + b'\xBC' * 16)
    write(STACK - 0x1010, b'\xA7' * 16 + b'\xA5' * 0x1040)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA1234000)
    trace = []

    def read(address, size):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, size))

    def guard(uc, access, address, size, value, user):
        address = (address & 0x1FFFFFFF) | 0x80000000
        if TITLE <= address and address + size <= TITLE + 648:
            return
        if any(base <= address and address + size <= base + 4 for base in (COUNT, ACTIVE)):
            return
        assert STACK - 0x1000 <= address and address + size <= STACK + max(0, length - 31), (case, hex(address), size)
        # No instruction or nested helper may use the measured gap below freePages.
        assert address + size <= STACK - 0x98 + 0x58 or address >= STACK - 0x98 + 0x70

    uc.hook_add(UC_HOOK_MEM_WRITE, guard)

    def boundary(uc, address, size, user):
        args = [uc.reg_read(r) for r in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                        regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)]
        result = 0
        if address == 0x8004FC98:
            event, result = [address, args[:1]], status
        elif address == 0x8004F990:
            event, result = [address, []], free
        elif address == 0x8004FB48:
            slot = args[0]
            assert 0 <= slot < 16 and args[1:3] == [STACK - 0x24, STACK - 0x20]
            event = [address, args[:3]]
            if mask & (1 << slot):
                write(args[1], word(pages))
                write(args[2], names[slot] + b'\0')
                # Nonzero negative responses exercise the caller's truth test.
                result = -1 if seed == 197 else 1
        elif address == 0x8004C3AC:
            event, result = [address, args[:2]], opened
        else:
            sp = uc.reg_read(regs.UC_MIPS_REG_SP)
            stacked = [int.from_bytes(read(sp + 16 + index * 4, 4), 'big') for index in range(5)]
            event = [address, args + stacked]
        trace.append(event)
        resume = uc.reg_read(regs.UC_MIPS_REG_RA)
        for index, register in enumerate(CALLER_SAVED):
            uc.reg_write(register, 0xB2340000 + index * 257)
        uc.reg_write(regs.UC_MIPS_REG_V0, result & 0xFFFFFFFF)
        uc.reg_write(regs.UC_MIPS_REG_PC, resume)

    for address in BOUNDARIES:
        uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)
    uc.emu_start(ENTRY, 0, count=250000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, 'Instruction limit or failed return'
    assert uc.reg_read(regs.UC_MIPS_REG_SP) == STACK
    for index, name in enumerate(('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP')):
        assert uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + name)) == 0xA2340000 + index * 256
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xA1234000
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == returned & 0xFFFFFFFF
    assert trace == expected_trace, (case, trace, expected_trace)
    assert read(TITLE - 16, 680) == b'\xC7' * 16 + expected + b'\xD8' * 16, case
    assert read(COUNT - 16, 36) == b'\xA9' * 16 + word(count) + b'\xB9' * 16
    assert read(ACTIVE - 16, 36) == b'\xAB' * 16 + word(active) + b'\xBC' * 16
    assert read(STACK - 0x40, 24) == b'\xA5' * 24
    assert read(STACK - 0x1010, 16) == b'\xA7' * 16
    # Artificial 32/33-byte names write their NUL into the incoming argument area.
    incoming = max(0, length - 31) if status == 1 and free != -1 and mask else 0
    assert read(STACK + incoming, 0x30 - incoming) == b'\xA5' * (0x30 - incoming)
    for address, data in support:
        assert read(address, len(data)) == data, ('Read-only supporting input changed', hex(address))
    return dict(storage_sha256=hashlib.sha256(expected).hexdigest(), count=count,
                active=active, returned=returned, trace=trace)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, retail, support, comparisons, data_comparisons = [], [], [], {}, {}
    for name in ('pak_menu_directory',) + SUPPORT:
        _, source, start, end = next(record for record in MATCHING_BLOCKS if record[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target,
                               family='pak-menu-execution', layout=layout)
        assert report['matches'], 'Complete matching source required: ' + name
        comparisons[name] = report
        directory = ROOT / 'build/pak-menu-execution' / name
        code = (directory / (name + '.bin')).read_bytes()
        if name == 'pak_menu_directory':
            compiled.append((start, code))
            retail.append((start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
        else:
            support.append((start, code))
            sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
            for record in source_sections(source):
                if record['rom'] is not None:
                    support.append((record['vram'], sections[record['section']]['bytes']))
    for source in DATA:
        records = source_sections(source)
        report = compare_unit(source, records, target, layout)
        assert report['matches']
        data_comparisons[source] = report
        sections, _ = elf_sections_and_symbols(ROOT / 'build/data-comparison' /
                                              Path(source).with_suffix('') / 'compiled.elf')
        for record in records:
            if record['rom'] is not None and record['vram'] != COUNT:
                support.append((record['vram'], sections[record['section']]['bytes']))
    assert target[0x7C71C:0x7C72C] == DIGITS
    support.append((0x8007BB1C, DIGITS))
    digest, count = hashlib.sha256(), 0
    for case in cases():
        expected = run(retail, support, case)
        actual = run(compiled, support, case)
        assert actual == expected
        digest.update(json.dumps([case, actual]).encode())
        count += 1
        if count % 100 == 0:
            print('Compared', count, 'Pak menu cases.', flush=True)
    report = dict(matches=True, cases=count, trace_sha256=digest.hexdigest(),
                  comparisons=comparisons, data_comparisons=data_comparisons,
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['All 596 instruction bytes and both initialized data ranges completely match.',
                          'Fresh matching string, number and destination formatter helpers execute.',
                          'Directory, free-page and entry queries, file opening and menu submission use ABI-clobbering stubs; no device or full-menu execution is claimed.',
                          'The independent oracle preserves wide page formats, 30-byte label strides, 32-byte copies, non-terminated labels and overlap with adjacent labels/pointers.',
                          'Synthetic 32/33-byte names also reproduce their NUL writes into the caller argument area; these exceed the caller local buffer and are not device-name behavior claims.',
                          'INT_MIN decimal conversion, arbitrary pointers and unbounded helper output are omitted.',
                          'All global storage bytes, guards, stack bounds, the unused 24-byte frame gap, integer callee-saved registers, GP and SP are checked.',
                          'The standard hexadecimal alphabet is checked against retail but is not credited as source-owned data.',
                          'The title storage span is measured; its original declaration and the purpose of unused bytes remain unknown.'])
    output = ROOT / 'build/pak-menu-execution/report.json'
    output.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed bounded Pak menu execution:', count, output, flush=True)


if __name__ == '__main__':
    main()
