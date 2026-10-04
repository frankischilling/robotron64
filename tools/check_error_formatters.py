"""Compare excluded error formatter candidates with bounded retail executions.

Memory/string/number helpers execute freshly matched C. Output and the fatal
reporter use recorded ABI stubs; the reporter returns synthetically.
"""

import hashlib
import json
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs

from check_actor_group_path import machine, word
from compare_data import compare_unit
from compare_runtime import CANDIDATE_BLOCKS, MATCHING_BLOCKS
from compare_startup import SymbolLayoutSnapshot, compare_block
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


FORMAT, STRINGS, STACK = 0x80201010, 0x80210010, 0x80300000
OUTPUT, REPORT = 0x8003CC38, 0x800496E0
SUPPORT = ('game_memory', 'game_number_format', 'fixed_geometry_setup')
CANDIDATES = ('error_fatal_format', 'error_warning_format')
DIGITS = b'0123456789ABCDEF'
CALLER_SAVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                     ('V0', 'V1', 'A0', 'A1', 'A2', 'A3',
                      'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9'))


def oracle(format_string, values):
    """Model the supported conversions, including skipped unknown specifiers."""
    output = bytearray()
    index = argument = 0
    while index < len(format_string):
        character = format_string[index]
        index += 1
        if character != ord('%'):
            output.append(character)
            continue
        assert index < len(format_string), 'Cases omit dangling percent specifiers'
        specifier = format_string[index]
        index += 1
        if specifier not in b'Ccdsx':
            continue
        value = values[argument]
        argument += 1
        if specifier in b'Cc':
            output.append(value & 255)
        elif specifier == ord('s'):
            output.extend(value)
        elif specifier == ord('d'):
            signed = value & 0xFFFFFFFF
            signed -= 0x100000000 if signed & 0x80000000 else 0
            assert signed != -0x80000000, 'INT_MIN decimal is outside this oracle'
            output.extend(str(signed).encode('ascii'))
        else:
            output.extend(format(value & 0xFFFFFFFF, 'X').encode('ascii'))
    assert len(output) < 500
    return bytes(output)


def cases():
    yield b'', ()
    yield b'plain text', ()
    yield b'A' * 499, ()
    yield bytes(value for value in range(1, 256) if value != ord('%')), ()
    yield b'%s', (b'',)
    yield b'%s', (b'B' * 499,)
    yield b'%s/%d/%x/%C/%c', (b'name', -123, 0xFEDCBA98, 65, 122)
    yield b'%C%c%d%x%s', (65, 66, -7, 0x10, b'end')
    yield b'%q%d%z%s', (-17, b'next')
    yield b'%%/%d', (42,)
    for specifier in b'Cc':
        for value in range(256):
            yield b'%' + bytes([specifier]), (0x12345600 | value,)
    for value in (0, 1, -1, 9, 10, 99, 100, -999, 32767, -32768,
                  0x7FFFFFFF, -0x7FFFFFFF, 0x80000000, 0xFFFFFFFF):
        yield b'%x', (value,)
        if value & 0xFFFFFFFF != 0x80000000:
            yield b'%d', (value,)
    for specifier in range(32, 127):
        if specifier not in b'Ccdsx':
            yield b'%' + bytes([specifier]) + b'%C/%d', (81, -37)
    for value in (1, 65, 127, 128, 255):
        yield b'[%s]', (bytes([value]) * 200,)


def run(code, support, entry, size, case):
    format_string, values = case
    expected = oracle(format_string, values)
    uc, write, execute = machine(code, support)
    write(STACK - 0x2010, b'\xA7' * 16)
    write(STACK - 0x2000, b'\xA5' * 0x2080)
    guarded_format = b'\xA9' * 16 + format_string + b'\0' + b'\xB9' * 16
    write(FORMAT - 16, guarded_format)
    inputs, arguments = [], []
    for index, value in enumerate(values):
        if isinstance(value, bytes):
            address = STRINGS + index * 0x400
            guarded = b'\xAA' * 16 + value + b'\0' + b'\xBB' * 16
            write(address - 16, guarded)
            inputs.append((address - 16, guarded))
            arguments.append(address)
        else:
            arguments.append(value & 0xFFFFFFFF)
    arguments += [0xDEADBEEF] * max(0, 3 - len(arguments))
    registers = (regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)
    for register, argument in zip(registers, arguments):
        uc.reg_write(register, argument)
    stack_arguments = b''.join(word(value) for value in arguments[3:])
    write(STACK + 16, stack_arguments)
    uc.reg_write(regs.UC_MIPS_REG_A0, FORMAT)
    trace, buffer = [], []

    def read(address, size):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, size))

    def string(address):
        data = read(address, 500)
        end = data.find(b'\0')
        assert end >= 0, 'Output did not terminate within the message bound'
        return data[:end]

    # The fully compared instruction at +0x40 establishes the output cursor.
    own_code = next(data for address, data in code if address == entry)
    assert own_code[0x40:0x42] == bytes.fromhex('27b0')

    def capture_buffer(uc, address, size, user):
        buffer.append(uc.reg_read(regs.UC_MIPS_REG_S0))

    uc.hook_add(UC_HOOK_CODE, capture_buffer, begin=entry + 0x44, end=entry + 0x44)

    def guard_write(uc, access, address, size, value, user):
        physical = address & 0x1FFFFFFF
        assert STACK - 0x2000 <= (physical | 0x80000000)
        assert (physical | 0x80000000) + size <= STACK + 16
        pc = uc.reg_read(regs.UC_MIPS_REG_PC)
        if entry <= pc < entry + size_of_function and size == 1:
            assert buffer and buffer[0] <= (physical | 0x80000000) < buffer[0] + 500

    size_of_function = size
    uc.hook_add(UC_HOOK_MEM_WRITE, guard_write)

    def boundary(uc, address, size, user):
        args = [uc.reg_read(register) for register in
                (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                 regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)]
        if address == OUTPUT:
            if not trace:
                assert args[0] == (0x80090420 if entry == 0x8001C0D0 else 0x80090454)
            else:
                assert args[0] == buffer[0]
            trace.append(['output', string(args[0]).hex()])
        else:
            assert args[0] == 0x80090430 and args[1] == buffer[0]
            assert args[2:] == [0x80090448, 77]
            trace.append(['report', string(args[0]).hex(), string(args[1]).hex(),
                          string(args[2]).hex(), args[3]])
        for index, register in enumerate(CALLER_SAVED):
            uc.reg_write(register, 0xB2340000 + index * 257)
        uc.reg_write(regs.UC_MIPS_REG_PC, uc.reg_read(regs.UC_MIPS_REG_RA))

    for address in (OUTPUT, REPORT):
        uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)
    execute(entry)
    visible = expected.split(b'\0', 1)[0].hex()
    prefix = b'FATAL ERROR: ' if entry == 0x8001C0D0 else b'WARNING: '
    expected_trace = [['output', prefix.hex()], ['output', visible]]
    if entry == 0x8001C0D0:
        expected_trace.append(['report', b'FATAL ERROR: %s %s %d\n'.hex(), visible,
                               b'errors.c'.hex(), 77])
    assert trace == expected_trace, (case, trace, expected_trace)
    assert read(buffer[0], len(expected) + 1) == expected + b'\0'
    assert read(FORMAT - 16, len(guarded_format)) == guarded_format
    for address, data in inputs:
        assert read(address, len(data)) == data
    assert read(STACK + 16, len(stack_arguments)) == stack_arguments
    assert read(STACK - 0x2010, 16) == b'\xA7' * 16
    assert read(STACK + 0x40, 16) == b'\xA5' * 16
    return trace


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    comparisons, compiled, retail, support = {}, {}, {}, []
    records = MATCHING_BLOCKS + CANDIDATE_BLOCKS
    for name in CANDIDATES + SUPPORT:
        _, source, start, end = next(record for record in records if record[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target,
                               family='error-formatter-execution', layout=layout)
        comparisons[name] = report
        directory = ROOT / 'build/error-formatter-execution' / name
        code = (directory / (name + '.bin')).read_bytes()
        if name in CANDIDATES:
            compiled[name] = [(start, code)]
            retail[name] = [(start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00])]
        else:
            assert report['matches'], 'Supporting source must completely match: ' + name
            support.append((start, code))
            sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
            for owned in source_sections(source):
                if owned['rom'] is not None:
                    support.append((owned['vram'], sections[owned['section']]['bytes']))
    messages = 'src/game/diagnostics/messages.c'
    data_report = compare_unit(messages, source_sections(messages), target, layout)
    assert data_report['matches']
    sections, _ = elf_sections_and_symbols(ROOT / 'build/data-comparison' /
        Path(messages).with_suffix('') / 'compiled.elf')
    support.append((0x80090420, sections['.error_messages']['bytes']))
    assert target[0x7C71C:0x7C72C] == DIGITS
    support.append((0x8007BB1C, DIGITS))
    digest, count = hashlib.sha256(), 0
    for name in CANDIDATES:
        _, _, start, end = next(record for record in records if record[0] == name)
        for case in cases():
            expected = run(retail[name], support, start, end - start, case)
            actual = run(compiled[name], support, start, end - start, case)
            assert actual == expected
            digest.update(json.dumps([name, expected]).encode())
            count += 1
            if count % 250 == 0:
                print('Compared', count, 'formatter cases.', flush=True)
    report = dict(matches=True, cases=count, trace_sha256=digest.hexdigest(),
                  comparisons=comparisons, data_comparison=data_report,
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  limits=['Both formatter candidates remain instruction nonmatching.',
                          'Output and the fatal reporter use ABI-clobbering stubs; the fatal reporter returns synthetically.',
                          'Only valid strings and output shorter than 500 bytes are exercised; overflowing buffers and dangling percent specifiers are omitted.',
                          'INT_MIN decimal conversion is omitted; hexadecimal covers all listed 32-bit boundaries.',
                          'The standard hexadecimal alphabet is checked against retail but is not credited as source-owned data.',
                          'Stack bounds, output byte writes, preserved registers, input buffers and stacked arguments are checked.'])
    output = ROOT / 'build/error-formatter-execution/report.json'
    output.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed bounded formatter execution:', count, output, flush=True)


if __name__ == '__main__':
    main()
