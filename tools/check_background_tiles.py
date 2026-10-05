"""Check tiled background setup, pool failure and all eighty strip submissions.

The tile renderer is an ABI stub with configurable vertex consumption. This
checks the caller's complete display list and dispatch; it does not execute
the framebuffer strip renderer or establish visual correctness.
"""

import hashlib
import itertools
import json
import struct
from importlib.metadata import version

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs

from check_actor_group_path import machine, word
from compare_startup import SymbolLayoutSnapshot, compare_block
from owned_sections import elf_sections_and_symbols
from rom import ROOT, validate


ENTRY, END, STACK = 0x80040560, 0x80040724, 0x80300000
DISPLAY, CURSOR, DEPTH, VERTEX = 0x80211010, 0x80138254, 0x800CD3B8, 0x80123AE4
FAMILY = 'background-tiles-execution'
WORDS = ((0xB7000000, 4), (0xFCFFFFFF, 0xFFFCF279),
         (0xB900031D, 0x00552078), (0xBA000C02, 0),
         (0xBA001001, 0), (0xBA001301, 0),
         (0xBB000001, 0x80008000), (0xBA000E02, 0))


def execute(code, mode, first, increment):
    uc, write, run = machine([(ENTRY, code)], [])
    command_guard = bytes((i * 19 + 7) & 255 for i in range(96))
    write(DISPLAY - 16, command_guard)
    write(CURSOR - 16, bytes([0xC7]) * 36)
    write(DEPTH - 16, bytes([0xD8]) * 36)
    write(VERTEX - 16, bytes([0xE9]) * 36)
    write(CURSOR, word(DISPLAY))
    write(VERTEX, word(12345))
    uc.reg_write(regs.UC_MIPS_REG_A0, mode & 0xFFFFFFFF)
    calls, tiles = [], []
    allowed_reads = [(STACK - 0x100, STACK + 32),
                     (CURSOR, CURSOR + 4), (VERTEX, VERTEX + 4)]
    allowed_writes = allowed_reads + [(DEPTH, DEPTH + 4), (DISPLAY, DISPLAY + 64)]

    def guard(uc, access, address, size, value, allowed):
        address |= 0x80000000
        assert any(a <= address and address + size <= b for a, b in allowed), (
            'Memory guard', hex(address), size, hex(uc.reg_read(regs.UC_MIPS_REG_PC)))

    uc.hook_add(UC_HOOK_MEM_READ, guard, user_data=allowed_reads)
    uc.hook_add(UC_HOOK_MEM_WRITE, guard, user_data=allowed_writes)

    def stub(uc, address, size, user):
        if address not in (0x80047048, 0x80047094, 0x80040724):
            return
        a0 = uc.reg_read(regs.UC_MIPS_REG_A0)
        a1 = uc.reg_read(regs.UC_MIPS_REG_A1)
        returned = uc.reg_read(regs.UC_MIPS_REG_RA)
        if address == 0x80040724:
            tiles.append((a0, a1))
            index = len(tiles) - 1
            consumed = increment if increment is not None else (index * 7 + 3) % 9
            current = struct.unpack('>I', uc.mem_read(VERTEX, 4))[0]
            write(VERTEX, word(current + consumed))
        else:
            calls.append((address, None if address == 0x80047048 else a0))
        for name in ('V0', 'V1', 'A0', 'A1', 'A2', 'A3',
                     'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9'):
            uc.reg_write(getattr(regs, 'UC_MIPS_REG_' + name), 0xD00D1234)
        if address == 0x80047048:
            uc.reg_write(regs.UC_MIPS_REG_V0, first & 0xFFFFFFFF)
        uc.reg_write(regs.UC_MIPS_REG_PC, returned)

    uc.hook_add(UC_HOOK_CODE, stub)
    run(ENTRY)
    submitted = [] if first == -1 else [(x, y) for x in (0, 160) for y in range(0, 240, 6)]
    consumed = 0 if first == -1 else sum(
        increment if increment is not None else (i * 7 + 3) % 9 for i in range(80))
    assert tiles == submitted, 'All tile coordinates and order'
    expected_calls = [(0x80047048, None)]
    if first != -1:
        expected_calls.append((0x80047094, consumed))
    assert calls == expected_calls, 'Allocation and commit ABI'
    expected_display = bytearray(command_guard)
    expected_display[16:80] = b''.join(word(a) + word(b) for a, b in WORDS)
    assert bytes(uc.mem_read(DISPLAY - 16, 96)) == bytes(expected_display), 'Complete display-list oracle'
    for address, fill, value in ((CURSOR, 0xC7, DISPLAY + 64),
                                 (DEPTH, 0xD8, 31000 - mode * 10000),
                                 (VERTEX, 0xE9, first + consumed)):
        expected_memory = bytes([fill]) * 16 + word(value) + bytes([fill]) * 16
        assert bytes(uc.mem_read(address - 16, 36)) == expected_memory, ('Global oracle', hex(address))
    return calls, tiles, bytes(expected_display).hex()


def run(source='src/game/model_framebuffer_draw.c'):
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    comparison = compare_block('background_tiles', source, ENTRY, 0x41160, 0x41324,
                               target, FAMILY, layout)
    assert comparison['matches']
    directory = ROOT / 'build' / FAMILY / 'background_tiles'
    sections, symbols = elf_sections_and_symbols(directory / 'background_tiles.raw.o')
    assert sections['.text']['size'] == 464
    assert sections['.text']['bytes'][452:] == bytes(12)
    assert symbols['func_80040560']['size'] == 452
    for name, section in sections.items():
        if section['flags'] & 2 and section['size']:
            assert name in ('.text', '.reginfo'), name
    original = target[0x41160:0x41324]
    compiled = (directory / 'background_tiles.bin').read_bytes()
    cases = list(itertools.product((0, 1, -1, 2, 65535, -0x80000000, 0x7FFFFFFF),
                                  (-1, 0, 1, 500, 9999), (0, 1, 4, None)))
    digest = hashlib.sha256()
    for case in cases:
        retail_result = execute(original, *case)
        recovered_result = execute(compiled, *case)
        assert retail_result == recovered_result, ('Retail execution', case)
        digest.update(json.dumps((case, recovered_result), separators=(',', ':')).encode())
    mutations = []
    # Change a fixed display-list word and the depth offset. Both must fail the oracle.
    for name, needle, replacement in (
        ('depth constant', bytes.fromhex('240f7918'), bytes.fromhex('240f7919')),
        ('geometry state', bytes.fromhex('3c0db700'), bytes.fromhex('3c0db701')),
    ):
        offsets = [i for i in range(0, len(original), 4) if original[i:i + 4] == needle]
        assert offsets, ('Missing mutation instruction', name)
        mutant = bytearray(original)
        mutant[offsets[0]:offsets[0] + 4] = replacement
        try:
            execute(bytes(mutant), 1, 0, 4)
        except AssertionError as error:
            mutations.append({'name': name, 'detected': True, 'reason': str(error)})
        else:
            raise AssertionError(('Undetected mutation', name))
    layout.verify()
    report = {'matches': True, 'execution_cases': len(cases), 'trace_sha256': digest.hexdigest(),
              'mutations': mutations, 'comparison': comparison, 'unicorn': version('unicorn'),
              'stub_scope': 'Vertex-pool allocation/commit and framebuffer strip submission.',
              'retail_rom_sha256': hashlib.sha256(target).hexdigest()}
    path = ROOT / 'build' / FAMILY / 'report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print(f'Passed {len(cases)} tile caller cases: {path}', flush=True)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', default='src/game/model_framebuffer_draw.c')
    run(parser.parse_args().source)
