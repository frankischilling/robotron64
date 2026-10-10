"""Compare complete mutable alphabets and path diagnostics, then execute consumers."""
import hashlib
import itertools
import json
import math
from pathlib import Path

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL
from compare_runtime import MATCHING_BLOCKS
from compare_startup import SymbolLayoutSnapshot, compare_block
from compiler import compile_source
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


CONSUMERS = ('actor_setup_strings', 'actor_dynamic_point_append',
             'actor_dynamic_pair_append', 'actor_dynamic_parameter_append')
HELPERS = ('text', 'game_memory', 'early_coordinate_rescale',
           'object_recovery_integer_sqrt', 'error_warning_format')
EXPECTED = ((0x80074AA4, b'abcdefghijklmnopqrstuvwxyz0123456789SDE\0'),
            (0x80074ACC, b'bcdfghjklmnpqrstvwxyz0123456789SDE\0'),
            (0x8008F9A8, b'Too many path segments\n\0'),
            (0x8008F9C0, b'WARNING:\tzero lenght found in path, possible crash\n\0'),
            (0x8008F9F4, b'Too many path segments\n\0'),
            (0x8008FA0C, b'Num wave instances exceeded\n\0'))
POOL, COMMAND = 0x80212000, 0x80211000
STACK = (0x802FF000, 0x80300020)


def prepare():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    retail, compiled, comparisons, originals, arrays = [], [], {}, [], []
    for name in CONSUMERS + HELPERS:
        _, source, start, end = next(x for x in MATCHING_BLOCKS if x[0] == name)
        report = compare_block(name, source, start, start - 0x7FFFF400,
                               end - 0x7FFFF400, target, family='actor-path-literals', layout=layout)
        assert report['matches'], name
        comparisons[name] = report
        directory = ROOT / 'build/actor-path-literals' / name
        sections, symbols = elf_sections_and_symbols(directory / (name + '.elf'))
        raw_sections, raw_symbols = elf_sections_and_symbols(directory / (name + '.raw.o'))
        code = (directory / (name + '.bin')).read_bytes()
        retail.append((start, target[start - 0x7FFFF400:end - 0x7FFFF400]))
        compiled.append((start, code))
        for record in source_sections(source):
            if record['rom'] is None:
                continue
            data = sections[record['section']]['bytes']
            original = target[record['rom']:record['rom'] + record['size']]
            assert data == original and len(data) == record['size']
            if name in CONSUMERS:
                assert record['input_section'] == '.data'
                assert not any(raw_sections['.data']['bytes'][record['size']:])
                originals.append((record['vram'], original))
                arrays.append((record['vram'], data))
                for symbol, offset in record['symbols'].items():
                    address = record['vram'] + offset
                    expected = dict(EXPECTED)[address]
                    assert data[offset:offset + len(expected)] == expected
                    assert symbols[symbol]['value'] == address
                    assert raw_symbols[symbol]['value'] == offset
                    # IDO leaves data STT_OBJECT sizes zero; do not infer extent from it.
                    assert raw_symbols[symbol]['size'] in (0, len(expected))
            else:
                compiled.append((record['vram'], data))
                retail.append((record['vram'], original))
    # The warning formatter's prefix is already owned in this data-only unit.
    from compare_data import compare_unit, comparison_directory
    source = 'src/game/diagnostics/messages.c'
    records = source_sections(source)
    report = compare_unit(source, records, target, layout)
    assert report['matches']
    sections, _ = elf_sections_and_symbols(comparison_directory(source) / 'compiled.elf')
    for record in records:
        data = sections[record['section']]['bytes']
        compiled.append((record['vram'], data))
        retail.append((record['vram'], target[record['rom']:record['rom'] + record['size']]))
    layout.verify()
    assert sum(len(x[1]) for x in arrays) == 204
    probe = ROOT / 'build/actor-path-literals/extent-probe.c'
    sources = [next(x[1] for x in MATCHING_BLOCKS if x[0] == name) for name in CONSUMERS]
    probe.write_text(''.join('#include "' + str(ROOT / source) + '"\n' for source in sources) +
                     'unsigned int probe_sizes[] = {' +
                     ','.join('sizeof(D_%08X)' % address for address, text in EXPECTED) + '};\n')
    obj = probe.with_suffix('.o')
    compile_source(probe, obj)
    sections, symbols = elf_sections_and_symbols(obj)
    start = symbols['probe_sizes']['value']
    actual = sections['.data']['bytes'][start:start + 24]
    assert actual == b''.join(word(len(text)) for address, text in EXPECTED), 'compiler array extents'
    return originals, arrays, retail, compiled, comparisons


def normalized(address):
    return (address & 0x1FFFFFFF) | 0x80000000


def inside(address, size, ranges):
    address = normalized(address)
    return any(start <= address and address + size <= end for start, end in ranges)


def run(code, arrays, case):
    kind, count, value, group_index = case
    uc, write, _ = machine(code, [])
    for address, data in arrays:
        write(address - 8, b'\xE7' * (len(data) + 16))
    for address, data in arrays:
        write(address, data)
    initial_pool = bytearray(b'\x5A' * 9096)
    initial_pool[0:16] = word(0) + word(0) + word(group_index) + word(count)
    group = 16 + 124 * 10 + group_index * 604
    initial_pool[group:group + 4] = word(count)
    x, y = value, 200 - value
    adjusted_x, adjusted_y = (x - 100) * 320, (y - 100) * 320
    if 0 < count <= 50:
        previous = group + 4 + (count - 1) * 8
        initial_pool[previous:previous + 8] = word(adjusted_x - 5) + word(adjusted_y - 12)
    write(POOL - 16, b'\xA9' * 16 + bytes(initial_pool) + b'\xB9' * 16)
    write(0x800AE4F4, word(POOL))
    values = [value + i * 101 for i in range(9)]
    command = word(0) + (word(x) + word(y) if kind == 'point' else
                        word(value) if kind == 'pair' else b''.join(word(x) for x in values))
    write(COMMAND - 16, b'\xD7' * 16 + command + b'\xE9' * 16)
    globals_image = b'\xA5' * 36
    write(0x800AD2C8, globals_image)
    write(0x800B8F74, b'\x39\x71')
    write(STACK[0], b'\xAC' * (STACK[1] - STACK[0]))
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA7654321)
    uc.reg_write(regs.UC_MIPS_REG_A0, value & 0xFFFFFFFF if kind == 'name' else COMMAND)
    entry = {'name': 0x8001DE60, 'point': 0x8000D090,
             'pair': 0x8000D1FC, 'parameter': 0x8000D2D4}[kind]
    known_code = {start: end for _, _, start, end in MATCHING_BLOCKS}
    code_ranges = [(address, address + len(data)) for address, data in code if address in known_code]
    data_ranges = [(address, address + len(data)) for address, data in code if address not in known_code]
    data_ranges += [(address, address + len(data)) for address, data in arrays]
    state_ranges = [(POOL, POOL + 9096), (COMMAND, COMMAND + len(command)),
                    (0x800AE4F4, 0x800AE4F8), (0x800AD2C8, 0x800AD2EC),
                    (0x800B8F74, 0x800B8F76)]
    readable = data_ranges + state_ranges + [STACK]
    writable = state_ranges + [(address, address + len(data)) for address, data in arrays] + [STACK]
    trace, stopped = [], []
    saved = {getattr(regs, 'UC_MIPS_REG_' + name): uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + name))
             for name in ('S0','S1','S2','S3','S4','S5','S6','S7','FP','GP')}

    def read(address, size):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, size))

    def string(address, ranges):
        extent = next(end - address for start, end in ranges if start <= address < end)
        data = read(address, extent)
        assert 0 in data, ('unterminated bounded diagnostic', hex(address))
        return data.split(b'\0', 1)[0]

    def boundary(uc, address, size, user):
        if address == SENTINEL:
            stopped.append('return'); uc.emu_stop(); return
        if address == 0x8001C0D0:
            pointer = uc.reg_read(regs.UC_MIPS_REG_A0)
            expected_address = 0x8008F9A8 if kind == 'point' else 0x8008F9F4
            assert count == 50 and kind in ('point','pair') and pointer == expected_address
            assert string(pointer, data_ranges) == b'Too many path segments\n'
            trace.append(('fatal', pointer)); stopped.append('fatal'); uc.emu_stop(); return
        if address == 0x8003CC38:
            pointer = uc.reg_read(regs.UC_MIPS_REG_A0)
            message = string(pointer, readable)
            expected_message = b'WARNING: ' if not trace else b'Num wave instances exceeded\n'
            assert kind == 'parameter' and count == 49 and message == expected_message
            trace.append(('output', message.hex()))
            return_address = uc.reg_read(regs.UC_MIPS_REG_RA)
            for index, name in enumerate(('V0','V1','A0','A1','A2','A3','T0','T1','T2','T3','T4','T5','T6','T7','T8','T9')):
                uc.reg_write(getattr(regs, 'UC_MIPS_REG_' + name), 0xB2340000 + index * 257)
            uc.reg_write(regs.UC_MIPS_REG_PC, return_address)
            return
        assert inside(address, size, code_ranges), ('instruction outside compared code', hex(address))

    def guard_read(uc, access, address, size, value, user):
        assert inside(address, size, readable), ('read outside fixture', hex(address), size)

    def guard_write(uc, access, address, size, value, user):
        assert inside(address, size, writable), ('write outside fixture', hex(address), size)

    uc.hook_add(UC_HOOK_CODE, boundary)
    uc.hook_add(UC_HOOK_MEM_READ, guard_read)
    uc.hook_add(UC_HOOK_MEM_WRITE, guard_write)
    uc.emu_start(entry, 0, count=20000)
    if not stopped and uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL:
        stopped.append('return')
    assert len(stopped) == 1, ('consumer did not terminate within the bound', case,
                              hex(uc.reg_read(regs.UC_MIPS_REG_PC)))
    expected_pool = bytearray(initial_pool)
    if stopped[0] == 'return':
        assert uc.reg_read(regs.UC_MIPS_REG_SP) == 0x80300000
        assert all(uc.reg_read(register) == value for register, value in saved.items()), 'integer O32 preservation'
        if kind == 'point':
            offset = group + 4 + count * 8
            expected_pool[offset:offset + 8] = word(adjusted_x) + word(adjusted_y)
            if count:
                offset = group + 404 + (count - 1) * 4
                expected_pool[offset:offset + 4] = word(math.isqrt(5 * 5 + 12 * 12))
            expected_pool[group:group + 4] = word(count + 1)
        elif kind == 'pair':
            offset = group + 4 + count * 8
            expected_pool[offset:offset + 8] = word(-1) + word(value * 10)
            expected_pool[group:group + 4] = word(count + 1)
        elif kind == 'parameter':
            assert count <= 49
            offset = 7296 + count * 36
            order = (0,1,5,4,6,2,3,7,8)
            expected_pool[offset:offset + 36] = b''.join(word(values[i]) for i in order)
            expected_pool[12:16] = word(count + 1)
            assert len(trace) == (2 if count == 49 else 0)
    assert read(POOL - 16, 9128) == b'\xA9' * 16 + bytes(expected_pool) + b'\xB9' * 16
    assert read(COMMAND - 16, len(command) + 32) == b'\xD7' * 16 + command + b'\xE9' * 16
    expected_globals = bytearray(globals_image)
    if kind == 'name':
        expected_globals[:8] = word(-1) * 2
        expected_globals[34] = (0xA5 & 0x0F) | ((value & 7) << 4)
    assert read(0x800AD2C8, 36) == bytes(expected_globals)
    assert read(0x800B8F74, 2) == (b'\0\x0A' if kind == 'name' else b'\x39\x71')
    literals = []
    for address, original in EXPECTED:
        expected = original
        if kind == 'name' and address in (0x80074AA4, 0x80074ACC):
            expected = bytes(x + 122 if 48 <= x <= 57 else x for x in original)
            expected = expected[:-4] + b'\x3B\x26\x95\0'
        assert read(address, len(expected)) == expected, ('literal oracle', hex(address))
        literals.append(read(address, len(expected)).hex())
    return dict(trace=trace,stopped=stopped[0],pool_sha256=hashlib.sha256(bytes(expected_pool)).hexdigest(),literals=literals)


def cases():
    for value in (-1,0,1,7,8,0x7FFFFFFF):
        yield ('name',0,value,0)
    for kind, count, value, group in itertools.product(('point','pair'),(0,1,48,49,50),(-10,0,100,210),(0,9)):
        yield (kind,count,value,group)
    for count,value in itertools.product((0,1,48,49),(-100,0,65535,0x7FFFFF00)):
        yield ('parameter',count,value,0)


def main():
    original, arrays, retail, compiled, comparisons = prepare()
    results = []
    for case in cases():
        expected = run(retail, original, case)
        actual = run(compiled, arrays, case)
        assert actual == expected
        results.append(dict(case=case,result=actual))
    controls = []
    for (address, text), mutation in itertools.product(EXPECTED, ('character','terminator')):
        # Shared arrays require changing a member's actual offset.
        changed = []
        for base,data in arrays:
            mutable = bytearray(data)
            if base <= address < base + len(data):
                offset = address-base if mutation == 'character' else address-base+len(text)-1
                mutable[offset] = mutable[offset] ^ 1 if mutation == 'character' else 65
            changed.append((base,bytes(mutable)))
        case = ('name',0,0,0) if address < 0x80080000 else (
            ('point',50,0,0) if address in (0x8008F9A8,0x8008F9C0) else
            ('pair',50,0,0) if address == 0x8008F9F4 else ('parameter',49,0,0))
        try:
            run(compiled, changed, case)
        except (AssertionError, StopIteration) as error:
            controls.append(dict(address=hex(address),mutation=mutation,detected=True,reason=str(error)))
        else:
            raise AssertionError(('literal mutation passed',hex(address),mutation))
    receipt = dict(pairs=len(results),initialized_bytes=204,consumer_functions=4,
        comparisons=comparisons,results=results,controls=controls,
        limits=['Bounded valid commands and group/parameter capacities; arbitrary aliases and gameplay are unverified.',
                'Fatal capacity paths stop before the formatter and unsafe continuation.',
                'Warning output is an argument-checked returning service boundary; integer caller-saved registers are clobbered.',
                'The unusual point-warning address comparison is preserved and unreachable in these pool fixtures.',
                'Literal equality detects the unreachable warning mutation; execution does not claim to reach that branch.',
                'Only terminated array bytes receive ownership; following zeros remain fallback.'])
    out=ROOT/'build/actor-path-literals/receipt.json'
    out.write_text(json.dumps(receipt,indent=2)+'\n')
    print(f'{len(results)} paired cases;204 initialized bytes;{len(controls)} literal mutations detected')


if __name__ == '__main__':main()
