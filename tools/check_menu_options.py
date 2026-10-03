"""Execute matching menu construction and callers against guarded record oracles."""

import hashlib
import itertools
import json
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE
from unicorn import mips_const as regs
from check_actor_group_path import SENTINEL, machine, word
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import source_sections
from rom import ROOT, validate


RECORDS, PAGE = 0x800AEF00, 0x800AF1A8
LABELS, STRINGS, TITLE = 0x80201010, 0x80202000, 0x80204010
NAMES = ('menu_options_define', 'menu_label_assign', 'save_menu_slot_prompt')
SUPPORT = ('game_memory',)
DATA = ('src/game/save_menus/option_records.c', 'src/game/save_menus/option_page.c')
CALLER_SAVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                     ('V0', 'V1', 'A0', 'A1', 'A2', 'A3',
                      'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9'))


def run(code, support, target, case):
    entry, count, profile, values, update = case
    uc, write, execute_machine = machine(code, support)
    def execute(address):
        execute_machine(address)
        assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, ('Function did not return', hex(address))
    label_base = LABELS if entry == 0x800263E0 else 0x800BB200
    mode, first, second, width, select, cancel = values
    title = TITLE
    if entry != 0x800263E0:
        count, mode, first, second, width = 8, 0xC5, 0, 0, 300
        select, cancel = 0x800309D0, 0x800308AC
        title = 0x8009401C if entry == 0x800308E8 else 0x80094028
    actual_count = min(count, 16)
    size = 680 + 48
    initial = bytes((0 if profile == 0 else (i * 37 + profile * 61) & 255)
                    for i in range(size))
    expected = bytearray(initial)
    write(RECORDS - 16, b'\xC7' * 16 + initial + b'\xD8' * 16)
    lengths, addresses = [], []
    strings = bytearray(b'\xE9' * (17 * 256))
    for i in range(17):
        length = (0, i, 17 - i, 7, i % 3, i * 8, 128, (i * 19) % 127)[profile]
        address = STRINGS + i * 256 + 16
        value = bytes(128 + (j % 127) for j in range(length)) + b'\0'
        strings[i * 256 + 16:i * 256 + 16 + len(value)] = value
        addresses.append(address)
        lengths.append(length)
    if profile == 4:
        addresses = [addresses[i % 3] for i in range(17)]
        lengths = [lengths[i % 3] for i in range(17)]
    write(STRINGS, bytes(strings))
    labels = b''.join(word(address) for address in addresses)
    write(label_base - 16, b'\xAB' * 16 + labels + b'\xBC' * 16)
    write(title - 16, b'\xCD' * 16 + b'menu title\0' + b'\xDE' * 16)
    footer_offset = 0x80093820 - 0x80000000 + 0xC00
    footer = target[footer_offset:target.index(b'\0', footer_offset) + 1]
    write(0x80093820, footer)
    footer_length = len(footer) - 1
    trace, measured_lengths = [], []

    def read(address, length):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, length))

    def stub(uc, address, instruction_size, user):
        args = [uc.reg_read(r) for r in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                        regs.UC_MIPS_REG_A2)]
        if address == 0x80026178:
            assert args[:2] == [PAGE, 1]
            assert read(RECORDS, size) == bytes(expected)
            event = [hex(address), args[:2]]
        elif address == 0x8001C0D0:
            assert count > 16 and args[:2] == [0x80093800, 16]
            event = [hex(address), args[:2]]
        elif address == 0x800278AC:
            assert args == [0, 1, 0]
            event = [hex(address), args]
        else:
            assert address == 0x80030798 and entry == 0x80030958
            event = [hex(address), []]
        trace.append(event)
        return_address = uc.reg_read(regs.UC_MIPS_REG_RA)
        for i, register in enumerate(CALLER_SAVED):
            uc.reg_write(register, 0xB1230000 + i * 257)
        uc.reg_write(regs.UC_MIPS_REG_PC, return_address)

    def strlen(uc, address, instruction_size, user):
        measured_lengths.append(uc.reg_read(regs.UC_MIPS_REG_A0))

    for address in (0x80026178, 0x8001C0D0, 0x800278AC, 0x80030798):
        uc.hook_add(UC_HOOK_CODE, stub, begin=address, end=address)
    uc.hook_add(UC_HOOK_CODE, strlen, begin=0x8003B4FC, end=0x8003B4FC)
    maximum, expected_lengths = 0, []
    for i in range(max(0, actual_count + 1)):
        last = i == actual_count
        address = 0x80093820 if last else addresses[i]
        record = [0x28900 if last else 0x100, cancel if last else select,
                  address, address, -1, PAGE + 20, 0 if last else RECORDS + (i + 1) * 40,
                  30 if actual_count == i + 1 else 20, 0, 68]
        expected[i * 40:(i + 1) * 40] = b''.join(word(value) for value in record)
        length = footer_length if last else lengths[i]
        expected_lengths.append(address)
        if length > maximum:
            maximum = length
            expected_lengths.append(address)
    page = [title, -1, 0, width, 90, None, 100, 200, RECORDS, 34, mode, first]
    for i, value in enumerate(page):
        if value is not None:
            expected[680 + i * 4:680 + (i + 1) * 4] = word(value)
    incoming = (title, label_base, count, mode, first, second, select, cancel, width)
    if entry == 0x800263E0:
        for register, value in zip((regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                    regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3), incoming):
            uc.reg_write(register, value & 0xFFFFFFFF)
        write(0x80300010, b''.join(word(value) for value in incoming[4:]))
    else:
        uc.reg_write(regs.UC_MIPS_REG_A0, second & 0xFFFFFFFF)
    execute(entry)
    assert measured_lengths == expected_lengths, (case, measured_lengths, expected_lengths)
    expected_trace = []
    if entry != 0x800263E0:
        expected_trace.append(['0x800278ac', [0, 1, 0]])
    if count > 16:
        expected_trace.append(['0x8001c0d0', [0x80093800, 16]])
    expected_trace.append(['0x80026178', [PAGE, 1]])
    if entry == 0x80030958:
        expected_trace.append(['0x80030798', []])
    assert trace == expected_trace
    if update:
        update_count = max(0, actual_count + 1)
        for i in range(update_count):
            replacement = addresses[16 - i]
            expected[i * 40 + 8:i * 40 + 16] = word(replacement) * 2
        write(label_base, b''.join(word(address) for address in reversed(addresses)))
        uc.reg_write(regs.UC_MIPS_REG_A0, label_base)
        uc.reg_write(regs.UC_MIPS_REG_A1, update_count)
        uc.reg_write(regs.UC_MIPS_REG_RA, 0x80000080)
        execute(0x80027940)
        write(label_base, labels)
    result = read(RECORDS - 16, size + 32)
    assert result == b'\xC7' * 16 + bytes(expected) + b'\xD8' * 16
    assert read(label_base - 16, len(labels) + 32) == b'\xAB' * 16 + labels + b'\xBC' * 16
    assert read(STRINGS, len(strings)) == bytes(strings)
    assert read(title - 16, 43) == b'\xCD' * 16 + b'menu title\0' + b'\xDE' * 16
    assert read(0x80093820, len(footer)) == footer
    return dict(storage_sha256=hashlib.sha256(result).hexdigest(), trace=trace,
                length_calls=measured_lengths, updated=update)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, retail, support, comparisons = [], [], [], {}
    for name in NAMES + SUPPORT:
        _, source, start, end = next(r for r in MATCHING_BLOCKS if r[0] == name)
        comparison = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                                   end - 0x80000000 + 0xC00, target,
                                   family='menu-options-execution', layout=layout)
        assert comparison['matches'], name
        comparisons[name] = comparison
        binary = (ROOT / 'build/menu-options-execution' / name / (name + '.bin')).read_bytes()
        if name in NAMES:
            compiled.append((start, binary))
            retail.append((start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
        else:
            support.append((start, binary))
    data = {source: compare_unit(source, source_sections(source), target, layout) for source in DATA}
    values = ((0, 0, 0, 0, 0, 0),
              (0xC5, -1, 17, 300, 0x800309D0, 0x800308AC),
              (-0x80000000, 0x7FFFFFFF, -0x80000000, -1, 0x800305F8, 0x800308AC),
              (-1, 2, -17, 0x7FFFFFFF, 0x800309D0, 0x800309D0))
    direct = ((0x800263E0, count, profile, args, update) for count, profile, args, update in
              itertools.product((-0x80000000, -17, -2, -1, 0, 1, 2, 7, 8, 15, 16, 17, 100, 0x7FFFFFFF),
                                range(8), values, (False, True)))
    callers = ((entry, 8, profile, args, update) for entry, profile, args, update in
               itertools.product((0x800308E8, 0x80030958), range(8), values, (False, True)))
    counts = dict(cases=0, direct=0, callers=0, excessive=0, negative=0, updated=0)
    digest = hashlib.sha256()
    for case in itertools.chain(direct, callers):
        expected, actual = run(retail, support, target, case), run(compiled, support, target, case)
        assert actual == expected, case
        counts['cases'] += 1
        counts['direct' if case[0] == 0x800263E0 else 'callers'] += 1
        counts['excessive'] += int(case[1] > 16)
        counts['negative'] += int(case[1] < 0)
        counts['updated'] += int(case[4])
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
    report = dict(matches=True, counts=counts, comparisons=comparisons, data_comparisons=data,
                  trace_sha256=digest.hexdigest(), target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  machine_helper_sha256=hashlib.sha256((ROOT / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['The complete constructor, label updater and two existing callers execute freshly matched code.',
                          'The complete matching game-memory unit supplies the real string-length routine.',
                          'Both BSS definitions are independently compiled and their sizes, symbols and placements verified.',
                          'Independent byte oracles check all seventeen records, the page, guards, labels, strings and call order.',
                          'Diagnostic, page activation, input reset and the secondary caller continuation use ABI stubs.',
                          'Stubs clobber caller-saved integer registers; saved registers and stack restoration are checked.',
                          'Callback invocation, diagnostic formatting, page activation, invalid pointers and full-game behavior are outside this proof.'])
    output = ROOT / 'build/menu-options-execution/report.json'
    output.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed menu option execution:', counts, output, flush=True)


if __name__ == '__main__':
    main()
