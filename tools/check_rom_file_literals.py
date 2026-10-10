"""Compare complete ROM-file arrays and execute their bounded retail consumers."""
import hashlib
import itertools
import json
from pathlib import Path

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from compare_data import compare_unit, comparison_directory
from compare_runtime import MATCHING_BLOCKS
from compare_startup import SymbolLayoutSnapshot, compare_block
from compiler import compile_source
from owned_sections import elf_sections_and_symbols, load_owned_sections, source_sections
from resource_literal_execution import (literal_machine, verify_fpu, CALLER_SAVED,
                                       FP_INIT, FP_STUB, FP_RETURN, FP_SEED, FP_RESULT)
from check_actor_group_path import word, SENTINEL
from rom import ROOT, validate


EXPECTED = ((0x80095B40, b'EXIT at %s[%d]\n\0'),
            (0x80095B50, b'ERROR: %s not found in %d items of .RSC file %s %d\n\0'),
            (0x80095B84, b'romfile.c\0'), (0x80095B90, b'BOSS2\0'),
            (0x80095B98, b'BOSS1\0'), (0x80095BA0, b'LEVEL\0'), (0x80095BA8, b'.STR\0'))
BLOCKS = ('rom_file_error', 'rom_files', 'game_memory', 'game_string_case_compare',
          'game_string_compare', 'game_string_case_compare_n', 'game_character')
TABLE, INPUT, DESTINATION = 0x80212000, 0x80211000, 0x80213000
STACK = (0x802FE000, 0x80300080)


def prepare():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes(); validate(target)
    layout = SymbolLayoutSnapshot()
    records = [r for r in load_owned_sections() if r['evidence'] == 'docs/rom-file-literals.md']
    assert len(records) == 7 and sum(r['size'] for r in records) == 101
    comparisons, retail, compiled = {}, [], []
    for name in BLOCKS:
        _, source, start, end = next(r for r in MATCHING_BLOCKS if r[0] == name)
        report = compare_block(name, source, start, start - 0x7FFFF400, end - 0x7FFFF400,
                               target, family='rom-file-literals', layout=layout)
        assert report['matches'], name
        comparisons[name] = report
        directory = ROOT / 'build/rom-file-literals' / name
        compiled.append((start, (directory / (name + '.bin')).read_bytes()))
        retail.append((start, target[start - 0x7FFFF400:end - 0x7FFFF400]))
    arrays, originals, sources = [], [], []
    for record in records:
        source = record['source']; sources.append(source)
        block = next((r[0] for r in MATCHING_BLOCKS if r[1] == source), None)
        if block:
            directory = ROOT / 'build/rom-file-literals' / block
            elf, raw = directory / (block + '.elf'), directory / (block + '.raw.o')
        else:
            report = compare_unit(source, source_sections(source), target, layout)
            assert report['matches']; comparisons[source] = report
            directory = comparison_directory(source); elf, raw = directory / 'compiled.elf', directory / 'raw.o'
        sections, symbols = elf_sections_and_symbols(elf)
        raw_sections, raw_symbols = elf_sections_and_symbols(raw)
        data = sections[record['section']]['bytes']; address = record['vram']
        original = target[record['rom']:record['rom'] + record['size']]
        assert data == original == dict(EXPECTED)[address]
        assert not any(raw_sections['.data']['bytes'][record['size']:])
        symbol = 'D_%08X' % address
        assert symbols[symbol]['value'] == address and raw_symbols[symbol]['value'] == 0
        arrays.append((address, data)); originals.append((address, original))
    probe = ROOT / 'build/rom-file-literals/extent-probe.c'
    probe.write_text(''.join('#include "' + str(ROOT / source) + '"\n' for source in sources) +
                     'unsigned int probe_sizes[] = {' +
                     ','.join('sizeof(D_%08X)' % address for address, text in EXPECTED) + '};\n')
    obj = probe.with_suffix('.o'); compile_source(probe, obj)
    sections, symbols = elf_sections_and_symbols(obj)
    offset = symbols['probe_sizes']['value']
    assert sections['.data']['bytes'][offset:offset + 28] == b''.join(word(len(text)) for address, text in EXPECTED)
    layout.verify()
    return originals, arrays, retail, compiled, comparisons


def inside(address, size, ranges):
    address = (address & 0x1FFFFFFF) | 0x80000000
    return any(start <= address and address + size <= end for start, end in ranges)


def run(code, arrays, case):
    kind, name, index, size = case
    entry = {'lookup': 0x8004ED78, 'load': 0x8004EE9C, 'size': 0x8004EF6C,
             'failure': 0x8004ED14, 'copy': 0x8004EE30}[kind]
    uc, write, execute, loaded_code = literal_machine(code, entry)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA5728193)
    code_ranges = [(address, address + len(data)) for address, data in loaded_code]
    literal_ranges = [(address, address + len(data)) for address, data in arrays]
    for address, data in arrays: write(address, data)
    entries = bytearray(b'\xAC' * 96)
    names = [b'LEFT.BIN', b'MIDDLE.DAT', b'RIGHT.TEX']
    missing = index is None
    count = size if missing else 3
    if not missing: names[index] = name.upper()
    for i, text in enumerate(names):
        entries[i * 32:i * 32 + 24] = b'\x53' + text + b'\0' + b'\xD3' * (22 - len(text))
        entries[i * 32 + 24:i * 32 + 32] = word(0x31000000 + 0x100 * i) + word(size if i == index else 12 + i)
    guarded_table = b'\xA9' * 16 + bytes(entries) + b'\xB9' * 16
    write(TABLE - 16, guarded_table)
    globals_image = word(TABLE) + word(count)
    write(0x80141200, globals_image)
    input_image = b'\xA7' * 16 + name + b'\0' + b'\xB7' * 16
    write(INPUT - 16, input_image)
    destination_image = b'\x89' * 64
    write(DESTINATION - 16, b'\xC7' * 16 + destination_image + b'\xD7' * 16)
    source_bytes = bytes((i * 37 + 19) & 255 for i in range(64))
    if kind == 'copy':
        uc.reg_write(regs.UC_MIPS_REG_A0, DESTINATION)
        uc.reg_write(regs.UC_MIPS_REG_A1, 0x31000000)
        uc.reg_write(regs.UC_MIPS_REG_A2, size & 0xFFFFFFFF)
    else:
        uc.reg_write(regs.UC_MIPS_REG_A0, INPUT if kind != 'failure' else size & 0xFFFFFFFF)
        uc.reg_write(regs.UC_MIPS_REG_A1, DESTINATION)
    fp_ranges = [(FP_SEED - 16, FP_SEED + 148), (FP_RESULT - 16, FP_RESULT + 64)]
    state_ranges = [(TABLE, TABLE + 96), (INPUT, INPUT + len(name) + 1),
                    (DESTINATION, DESTINATION + 64), (0x80141200, 0x80141208)]
    readable = literal_ranges + state_ranges + fp_ranges + [STACK]
    writable = [(DESTINATION, DESTINATION + 64), (FP_RESULT, FP_RESULT + 48), STACK]
    saved = {getattr(regs, 'UC_MIPS_REG_' + name): uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + name))
             for name in ('S0','S1','S2','S3','S4','S5','S6','S7','FP','GP')}
    trace, stopped = [], []
    expected_destination = bytearray(destination_image)
    special = name[:5].upper() in (b'BOSS2', b'BOSS1', b'LEVEL') and name[name.find(b'.'):] == b'.STR'
    wanted_copies = max(0, (size + 3) // 4) if kind in ('copy','load') and not missing else 0

    def read(address, length): return bytes(uc.mem_read(address & 0x1FFFFFFF, length))

    def literal(address):
        data = next(data for start, data in arrays if start == address)
        actual = read(address, len(data)); assert 0 in actual, ('unterminated literal', hex(address))
        return actual.split(b'\0', 1)[0]

    def returning_service():
        for i, register in enumerate(CALLER_SAVED): uc.reg_write(register, 0xB7230000 + 257 * i)
        uc.reg_write(regs.UC_MIPS_REG_PC, FP_STUB)

    def boundary(uc, address, length, user):
        if address == SENTINEL: stopped.append('return'); uc.emu_stop(); return
        if address == 0x8004EBE4:
            assert kind in ('load','size') and not trace
            trace.append(('initialize',)); returning_service(); return
        if address == 0x80063560:
            assert kind in ('copy','load') and not missing
            offset = sum(event[0] == 'read' for event in trace) * 4
            device = 0x31000000 + (0 if kind == 'copy' else 0x100 * index) + offset
            pointer = DESTINATION + offset
            assert offset < wanted_copies * 4 and uc.reg_read(regs.UC_MIPS_REG_A0) == device
            assert uc.reg_read(regs.UC_MIPS_REG_A1) == pointer
            uc.mem_write(pointer & 0x1FFFFFFF, source_bytes[offset:offset + 4])
            expected_destination[offset:offset + 4] = source_bytes[offset:offset + 4]
            trace.append(('read', device, pointer)); returning_service(); return
        if address == 0x80021B38:
            assert kind == 'load' and special and not missing
            assert uc.reg_read(regs.UC_MIPS_REG_A0) == DESTINATION
            assert not any(event[0] == 'relocate' for event in trace)
            trace.append(('relocate', DESTINATION)); returning_service(); return
        if address == 0x800496E0:
            assert missing and kind in ('lookup','load','size')
            assert [uc.reg_read(r) for r in (regs.UC_MIPS_REG_A0,regs.UC_MIPS_REG_A1,regs.UC_MIPS_REG_A2,regs.UC_MIPS_REG_A3)] == [0x80095B50, INPUT, count, 0x80095B84]
            assert read(uc.reg_read(regs.UC_MIPS_REG_SP) + 16, 4) == word(0xCB)
            assert literal(0x80095B50) == dict(EXPECTED)[0x80095B50][:-1]
            assert literal(0x80095B84) == b'romfile.c'
            trace.append(('missing', count)); stopped.append('fatal'); uc.emu_stop(); return
        if address == 0x8003CF88:
            assert kind == 'failure' and uc.reg_read(regs.UC_MIPS_REG_A0) == 0x80095B40
            assert literal(0x80095B40) == b'EXIT at %s[%d]\n'
            trace.append(('failure',)); stopped.append('fatal'); uc.emu_stop(); return
        assert inside(address, length, code_ranges), ('instruction outside compared ranges', hex(address))

    def guard_read(uc, access, address, length, value, user):
        assert inside(address, length, readable), ('read outside fixture', hex(address), length)

    def guard_write(uc, access, address, length, value, user):
        assert inside(address, length, writable), ('write outside fixture', hex(address), length)

    uc.hook_add(UC_HOOK_CODE, boundary); uc.hook_add(UC_HOOK_MEM_READ, guard_read)
    uc.hook_add(UC_HOOK_MEM_WRITE, guard_write)
    uc.emu_start(FP_INIT, 0, count=50000)
    if not stopped and uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL: stopped.append('return')
    assert len(stopped) == 1, ('bounded termination', case)
    if stopped[0] == 'return':
        assert uc.reg_read(regs.UC_MIPS_REG_SP) == 0x80300000
        assert all(uc.reg_read(r) == value for r, value in saved.items()), 'integer O32 preservation'
        verify_fpu(uc)
        if kind in ('lookup','size','load'):
            assert uc.reg_read(regs.UC_MIPS_REG_V0) == (index if kind == 'lookup' else size)
        assert sum(event[0] == 'read' for event in trace) == wanted_copies
        assert sum(event[0] == 'relocate' for event in trace) == (kind == 'load' and special)
    assert read(TABLE - 16, len(guarded_table)) == guarded_table
    assert read(INPUT - 16, len(input_image)) == input_image
    assert read(0x80141200, 8) == globals_image
    assert read(DESTINATION - 16, 96) == b'\xC7' * 16 + bytes(expected_destination) + b'\xD7' * 16
    for address, data in EXPECTED: assert read(address, len(data)) == data, ('literal oracle', hex(address))
    return dict(trace=trace, stopped=stopped[0], destination_sha256=hashlib.sha256(expected_destination).hexdigest())


def cases():
    names = (b'BOSS2.STR', b'BOSS1.STR', b'LEVEL0.STR', b'boss2.STR', b'boss1.str', b'level1.STR',
             b'BOSS22.STR', b'LEVEL.STR', b'OTHER.STR', b'OTHER.DAT', b'LEVEL.FOO.STR', b'NODOT')
    for name, index in itertools.product(names, (0,1,2)):
        for kind in ('lookup','size'): yield kind, name, index, 17
        for size in (0,1,3,4,7,8,17): yield 'load', name, index, size
    for kind, count in itertools.product(('lookup','size','load'), (0,1,3)):
        yield kind, b'ABSENT.DAT', None, count
    for value in (0,-1,1,17,0x7FFFFFFF): yield 'failure', b'UNUSED', 0, value
    for size in (-3,0,1,3,4,5,17): yield 'copy', b'UNUSED', 0, size


def main():
    original, arrays, retail, compiled, comparisons = prepare()
    results = []
    for case in cases():
        expected = run(retail, original, case); actual = run(compiled, arrays, case)
        assert actual == expected
        results.append(dict(case=[x.decode() if isinstance(x,bytes) else x for x in case], result=actual))
    controls = []
    for (address, data), mutation in itertools.product(EXPECTED, ('character','terminator')):
        changed = [(base, bytes(byte ^ 1 if mutation == 'character' and i == 0 else
                                65 if mutation == 'terminator' and i == len(text)-1 else byte
                                for i,byte in enumerate(text))) if base == address else (base,text)
                   for base,text in arrays]
        case = ('failure',b'UNUSED',0,0) if address == 0x80095B40 else (
            ('lookup',b'ABSENT.DAT',None,3) if address in (0x80095B50,0x80095B84) else
            ('load', {0x80095B90:b'BOSS2.STR',0x80095B98:b'BOSS1.STR',0x80095BA0:b'LEVEL0.STR',0x80095BA8:b'LEVEL.STR'}[address],1,7))
        try: run(compiled, changed, case)
        except (AssertionError, StopIteration) as error:
            controls.append(dict(address=hex(address), mutation=mutation, detected=True, reason=str(error)))
        else: raise AssertionError(('literal mutation passed',hex(address),mutation))
    receipt = dict(pairs=len(results), initialized_bytes=101, comparisons=comparisons,
        results=results, controls=controls,
        limits=['Directory initialization, PI word reads and script relocation use checked integer/FPU-clobbering service boundaries.',
                'Failure and missing-file paths stop before unsafe continuation; division by zero and actual output formatting are unverified.',
                'Returning paths preserve integer O32 state and twelve distinct saved FPU words.',
                'Bounded fixtures do not establish arbitrary aliases, cartridge I/O or full gameplay.',
                'Only first-terminated bytes receive ownership; all gap and following zeros remain fallback.'])
    (ROOT/'build/rom-file-literals/receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print(f'{len(results)} paired ROM-file cases;101 initialized bytes;{len(controls)} mutations detected')


if __name__ == '__main__': main()
