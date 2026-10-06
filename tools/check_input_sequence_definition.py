"""Guard complete retail and matched input-sequence definition executions.

The diagnostic formatter is an ABI-clobbering, synthetically returning stub.
Its formatting and fatal reporter are outside this function's execution proof.
"""

import hashlib
import itertools
import json
import struct

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_boundary_boss import environment, signed, CLOBBER
from check_actor_group_path import word, SENTINEL
from compare_data import compare_unit
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate

ENTRY, END, STACK = 0x8001BE2C, 0x8001BF48, 0x80300000
CURSOR, BUTTONS, SEQUENCES = 0x8009E588, 0x8009E590, 0x8009EE08
COMMAND, FORMAT, DIAGNOSTIC = 0x80201010, 0x800903C8, 0x8001C0D0
SOURCE = 'src/game/input_sequences/define.c'
FIXED = {1: (24, 0x80073A48), 12: (4, 0x80073A80), 13: (3, 0x80073A78)}


def locate(data, address, size):
    for start, block in data.items():
        if start <= address and address + size <= start + len(block):
            return block, address - start
    raise AssertionError(('Outside fixture', hex(address), size))


def put(data, address, value):
    block, offset = locate(data, address, len(value))
    block[offset:offset + len(value)] = value


def get(data, address, size):
    block, offset = locate(data, address, size)
    return bytes(block[offset:offset + size])


def integer(data, address):
    return struct.unpack('>i', get(data, address, 4))[0]


def initial(case):
    index, cursor, length, alias, callback = case
    command = COMMAND if alias == -1 else SEQUENCES + index * 28 + alias
    ranges = [(CURSOR - 16, BUTTONS + 800 + 16),
              (SEQUENCES - 16, SEQUENCES + 392 + 48)]
    if alias == -1:
        ranges.append((COMMAND - 16, COMMAND + 48))
    data = {start: bytearray((i * 37 + index * 19 + 7) & 255
                            for i in range(end - start)) for start, end in ranges}
    put(data, CURSOR, word(cursor))
    fields = (0x13572468, index, 0xF013579B, 0x76543210,
              0xA02468CE, 0xB147258D, 0xC0369CF0, length)
    put(data, command, b''.join(word(value) for value in fields))
    return data, command


def oracle(data, command, case):
    index, _, _, _, callback = case
    expected = {a: bytearray(b) for a, b in data.items()}
    fields = [integer(data, command + i * 4) for i in range(8)]
    assert fields[1] == index
    cursor, length = integer(data, CURSOR), fields[7]
    row = SEQUENCES + index * 28
    allowed = [(row + 4, row + 28), (CURSOR, CURSOR + 4)]
    # Capture every input word before any destination store, including aliases.
    for offset, value in ((4, fields[4]), (8, fields[2]), (12, fields[5]),
                          (16, fields[6]), (20, length), (24, BUTTONS + cursor * 2)):
        put(expected, row + offset, word(value))
    trace = []
    if signed(cursor + length) >= 400:
        trace.append(([FORMAT, cursor & 0xFFFFFFFF, length & 0xFFFFFFFF, 400],
                      get(expected, row, 28).hex(), get(expected, CURSOR, 4).hex()))
        if callback:
            cursor, length = -37, 0x7FFFFFFF
            put(expected, CURSOR, word(cursor))
            put(expected, row + 20, word(length))
    put(expected, CURSOR, word(cursor + length))
    if index in FIXED:
        length, pointer = FIXED[index]
        put(expected, row + 20, word(length))
        put(expected, row + 24, word(pointer))
    return expected, allowed, trace


def execute(code, case, message):
    data, command = initial(case)
    expected, allowed, expected_trace = oracle(data, command, case)
    uc, write, run, read, finish_call = environment([(ENTRY, code)], [])
    for a, b in data.items():
        write(a, bytes(b))
    write(FORMAT, message)
    stack_start = STACK - 80
    stack = bytes((i * 43 + 11) & 255 for i in range(112))
    write(stack_start, stack)
    uc.reg_write(regs.UC_MIPS_REG_A0, command)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xABCD1234)
    allowed.append((STACK - 64, STACK + 16))
    reads = [(command, command + 32), (CURSOR, CURSOR + 4),
             (SEQUENCES + case[0] * 28, SEQUENCES + (case[0] + 1) * 28),
             (STACK - 64, STACK + 16)]
    touched, trace = set(), []

    def guard_write(uc, access, address, size, value, user):
        address |= 0x80000000
        assert any(a <= address and address + size <= b for a, b in allowed), (
            'Write guard', hex(address), size, case)
        if stack_start <= address < STACK + 16:
            touched.update(range(address, address + size))

    def guard_read(uc, access, address, size, value, user):
        address |= 0x80000000
        assert any(a <= address and address + size <= b for a, b in reads), (
            'Read guard', hex(address), size, case)

    def guard_code(uc, address, size, user):
        assert (address in (SENTINEL, DIAGNOSTIC) or ENTRY <= address < END
                or CLOBBER <= address < CLOBBER + 92), ('Escaped code', hex(address), case)
        if address == DIAGNOSTIC:
            row = SEQUENCES + case[0] * 28
            arguments = [uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + n))
                         for n in ('A0', 'A1', 'A2', 'A3')]
            assert read(arguments[0], 32) == message, 'Source-defined diagnostic message'
            trace.append((arguments, read(row, 28).hex(), read(CURSOR, 4).hex()))
            if case[4]:
                write(CURSOR, word(-37))
                write(row + 20, word(0x7FFFFFFF))
            finish_call()

    uc.hook_add(UC_HOOK_MEM_WRITE, guard_write)
    uc.hook_add(UC_HOOK_MEM_READ, guard_read)
    uc.hook_add(UC_HOOK_CODE, guard_code)
    run(ENTRY)
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xABCD1234, 'GP preservation'
    assert trace == expected_trace, ('Diagnostic trace', case, trace, expected_trace)
    assert read(FORMAT, 32) == message, 'Diagnostic message changed'
    digest = hashlib.sha256()
    for a, b in expected.items():
        actual = read(a, len(b))
        assert actual == bytes(b), ('Independent memory oracle', hex(a), case)
        digest.update(actual)
    actual_stack = read(stack_start, len(stack))
    assert all(value == stack[i] for i, value in enumerate(actual_stack)
               if stack_start + i not in touched), 'Stack canaries'
    digest.update(json.dumps(trace).encode())
    return digest.hexdigest()


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    family = 'input-sequence-definition-execution'
    comparison = compare_block('definition', SOURCE, ENTRY, 0x1CA2C, 0x1CB48,
                               target, family, layout)
    assert comparison['matches'], 'Complete 284-byte instruction comparison'
    directory = ROOT / 'build' / family / 'definition'
    compiled = (directory / 'definition.bin').read_bytes()
    retail = target[0x1CA2C:0x1CB48]
    raw, symbols = elf_sections_and_symbols(directory / 'definition.raw.o')
    assert symbols['func_8001BE2C']['size'] == 284
    assert raw['.text']['size'] == 288 and raw['.text']['bytes'][284:] == bytes(4)
    assert all(name in ('.text', '.reginfo') or not (s['flags'] & 2 and s['size'])
               for name, s in raw.items()), 'Unexpected generated data'
    owned = {}
    for source in ('src/game/early_input_cursor_data.c', 'src/game/early_input_button_data.c',
                   'src/game/early_input_sequence_data.c', 'src/game/early_input_fixed_data.c',
                   'src/game/input_sequences/limit_message.c'):
        owned[source] = compare_unit(source, source_sections(source), target, layout)
    message = elf_sections_and_symbols(ROOT / 'build/data-comparison/src/game/input_sequences/limit_message/compiled.elf')[0]['.input_sequence_limit_message']['bytes']
    assert message == b'Too many buttons %d + %d >= %d\0\0'
    pairs = ((0, 0), (0, 24), (399, 0), (399, 1), (400, 0), (401, -1),
             (-1, 401), (-400, 800), (-0x80000000, -1), (0x7FFFFFFF, 1),
             (0x7FFFFFFF, -1), (-0x80000000, 0x7FFFFFFF), (100, 300), (400, -2))
    cases = [(index, cursor, length, alias, callback)
             for index, (cursor, length), alias, callback in
             itertools.product(range(14), pairs, (-1, 0, 4), (0, 1))]
    digest = hashlib.sha256()
    for number, case in enumerate(cases, 1):
        a, b = execute(retail, case, message), execute(compiled, case, message)
        assert a == b, ('Retail differential', case)
        digest.update(json.dumps([case, b]).encode())
        if number % 196 == 0:
            print('Input-sequence guarded cases', number, flush=True)
    mutations = []
    for old, new, case in (
            ('29810190', '29810191', (2, 100, 300, -1, 0)),
            ('8ca5e588', '00000000', (2, 100, 300, -1, 1)),
            ('ac2ee588', '00000000', (1, 0, 5, -1, 0)),
            ('24180018', '24180019', (1, 0, 5, -1, 0))):
        # Cursor loads occur twice; mutate only the post-diagnostic reload.
        offset = 0x90 if old == '8ca5e588' else compiled.index(bytes.fromhex(old))
        assert compiled[offset:offset + 4] == bytes.fromhex(old)
        mutated = compiled[:offset] + bytes.fromhex(new) + compiled[offset + 4:]
        try:
            execute(mutated, case, message)
        except (AssertionError, ValueError) as error:
            mutations.append(dict(address=hex(ENTRY + offset), original=old,
                                  replacement=new, detected=str(error)[:200]))
        else:
            raise AssertionError(('Undetected mutation', old))
    layout.verify()
    report = dict(matches=True, cases=len(cases), mutations=mutations,
                  trace_sha256=digest.hexdigest(), compiled_sha256=hashlib.sha256(compiled).hexdigest(),
                  retail_sha256=hashlib.sha256(retail).hexdigest(), raw_text_bytes=288,
                  live_instruction_bytes=284, comparison=comparison, owned_data=owned,
                  limits=['Valid indices 0 through 13; invalid indices and inaccessible pointers are excluded.',
                          'Diagnostic formatter is an ABI-clobbering stub that returns synthetically; its formatting and fatal reporter are not executed.',
                          'Callback cursor and length changes characterize reloads after that synthetic return.',
                          'Integer overflow cases characterize retail and pinned IDO instructions, not portable ISO C arithmetic.',
                          'Out-of-array button pointers are never dereferenced here; extreme cursor cases characterize word arithmetic, not portable C pointer formation.',
                          'Command words through offset 0x1C are exercised, including destination aliasing; full script-record extent is not inferred.',
                          'Whole fixture buffers, stack canaries, bounded reads/writes/code, GP, SP and saved integer registers are checked.'])
    (ROOT / 'build' / family / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k: report[k] for k in ('matches', 'cases', 'mutations', 'trace_sha256')}), flush=True)


if __name__ == '__main__':
    main()
