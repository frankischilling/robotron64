"""Execute the complete background dispatcher with guarded renderer ABI stubs.

The copy, matrix identity, absolute-value and sine callees execute freshly
matched C and retail instructions. Projection and renderer calls are recorded
stubs; this checks dispatch behavior, not rendered gameplay.
"""

import hashlib
import itertools
import json
import math
import struct
from importlib.metadata import version

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs

from check_actor_group_path import machine, word
from compare_runtime import MATCHING_BLOCKS
from compare_startup import SymbolLayoutSnapshot, compare_block
from owned_sections import elf_sections_and_symbols
from rom import ROOT, validate


ENTRY, END, STACK = 0x800400D0, 0x800404F4, 0x80300000
MATRIX, CLOCK, TABLE = 0x800CD250, 0x800CD2B4, 0x80094C80
FAMILY = 'background-dispatch-execution'
SUPPORT = ('game_memory', 'frame_helpers', 'fixed_geometry_setup',
           'fixed_math', 'short_sine')
COLOR_WORDS = (0x800ACE18, 0x800ACE24, 0x800ACE34,
               0x800ACE1C, 0x800ACE2C, 0x800ACE40)
GLOBALS = (0x8009E578, 0x8009EF94, 0x8007CCA0, 0x800AD280,
           0x8007CCB0, 0x8007BB18, CLOCK, 0x8007CCA8, 0x8007CCAC)
STUBS = {0x800493F4: 1, 0x8004729C: 1, 0x80049514: 0,
         0x80041B24: 6, 0x80040560: 1, 0x80040BA0: 2,
         0x80040F5C: 7, 0x80041180: 6, 0x8000B5AC: 0}
DRAW = {0x80041B24, 0x80040560, 0x80040BA0,
        0x80040F5C, 0x80041180, 0x8000B5AC}
OBSERVE = {0x8003B520: 3, 0x80048D9C: 0, 0x8004CEF0: 1,
           0x8004DB88: 1, **STUBS}


def signed(value):
    return (value + 0x80000000) % 0x100000000 - 0x80000000


def quotient(value, divisor):
    return abs(value) // divisor * (-1 if value < 0 else 1)


def sine(angle):
    phase = angle & 4095
    index = phase & 1023
    if phase & 1024:
        index = 1023 - index
    value = math.floor(32767 * math.sin(index * math.pi / 2046))
    return -value if phase & 2048 else value


def expected(case):
    mode, kind, clock, step, controller, save, colors = case
    time = signed(clock + step)
    args = [signed(0xA5A5A5A5)] * 3 + [0, 0, 0]
    angles = []
    if mode == 0:
        scaled = signed(time * 8)
        angles = [quotient(scaled, d) for d in (2, 5, 3)]
        blue, green, red = [((sine(a) * 30) >> 15) + 64 for a in angles]
        args = [red, green, blue, 0, 0, 255]
    elif mode == 1:
        angles = [quotient(time, 2), signed(time + 512), quotient(time, 3)]
        blue, green = [((sine(a) * 30) >> 15) + 64 for a in angles[:2]]
        red = ((sine(angles[2]) * 14) >> 15) + 32
        args = [red, green, blue, 0, 0, 0]
    elif mode == 2:
        args = list(colors)
    kind = signed(abs(kind))
    draw = {
        0: (0x80041B24, args), 1: (0x80040560, [0]),
        2: (0x80040BA0, [5, 5]), 3: (0x80040BA0, [10, 4]),
        4: (0x80040F5C, args + [0]), 5: (0x80041180, args),
        6: (0x80040560, [1]), 7: (0x8000B5AC, []),
        8: (0x80040F5C, args + [1]),
        9: (0x80041180, [255] * 6), 10: (0x80041180, [0] * 6),
    }.get(kind)
    return time, 11000 if controller and save == 9 else 14400, angles, draw


def execute(code, table, support, case):
    mode, kind, clock, step, controller, save, colors = case
    uc, write, run = machine([(ENTRY, code), (TABLE, table)], support)
    write(STACK - 0x100, bytes([0xA5]) * 0x140)
    initial = bytes((i * 37 + 19) & 255 for i in range(68))
    write(MATRIX - 16, initial)
    wave_state = bytes((i * 13 + 7) & 255 for i in range(292))
    write(CLOCK - 16, wave_state)
    values = (signed(0x80000000), step, controller, save, mode, kind,
              clock, 1234, -5678)
    for address, value in zip(GLOBALS, values):
        write(address, word(value))
    for address, value in zip(COLOR_WORDS, colors):
        write(address, word(value))
    calls = []
    allowed_reads = [(STACK - 0x100, STACK + 0x40), (MATRIX, MATRIX + 36),
                     (TABLE, TABLE + 44)]
    allowed_reads += [(a, a + 4) for a in GLOBALS + COLOR_WORDS]
    allowed_reads += [(a, a + len(b)) for a, b in support]
    allowed_writes = [(STACK - 0x100, STACK + 0x40), (MATRIX, MATRIX + 36)]
    allowed_writes += [(a, a + 4) for a in (CLOCK, 0x8007CCA8, 0x8007CCAC)]

    def guard(uc, access, address, size, value, ranges):
        address |= 0x80000000
        assert any(a <= address and address + size <= b for a, b in ranges), (
            'Memory guard', hex(address), size, hex(uc.reg_read(regs.UC_MIPS_REG_PC)))

    uc.hook_add(UC_HOOK_MEM_READ, guard, user_data=allowed_reads)
    uc.hook_add(UC_HOOK_MEM_WRITE, guard, user_data=allowed_writes)

    def observe(uc, address, size, user):
        if address not in OBSERVE:
            return
        count = OBSERVE[address]
        args = [signed(uc.reg_read(getattr(regs, 'UC_MIPS_REG_A' + str(i))))
                for i in range(min(count, 4))]
        sp = uc.reg_read(regs.UC_MIPS_REG_SP)
        args += [signed(struct.unpack('>I', uc.mem_read(sp + i * 4, 4))[0])
                 for i in range(4, count)]
        calls.append((address, args))
        if address in DRAW:
            identity = [32767 if i in (0, 4, 8) else 0 for i in range(9)]
            assert bytes(uc.mem_read(MATRIX, 36)) == b''.join(word(x) for x in identity)
            # A renderer may change view state. The dispatcher must restore it.
            write(MATRIX, bytes([0x3C]) * 36)
        if address in STUBS:
            returned = uc.reg_read(regs.UC_MIPS_REG_RA)
            for name in ('V0', 'V1', 'A0', 'A1', 'A2', 'A3',
                         'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9'):
                uc.reg_write(getattr(regs, 'UC_MIPS_REG_' + name), 0xD00D1234)
            uc.reg_write(regs.UC_MIPS_REG_PC, returned)

    uc.hook_add(UC_HOOK_CODE, observe)
    run(ENTRY)
    time, height, angles, draw = expected(case)
    assert bytes(uc.mem_read(MATRIX - 16, 68)) == initial, 'Matrix restoration and guards'
    result = bytearray(wave_state)
    result[16:20] = word(time)
    assert bytes(uc.mem_read(CLOCK - 16, len(result))) == bytes(result), 'Clock and wave guards'
    for address, value in zip(GLOBALS, values):
        value = {CLOCK: time, 0x8007CCA8: 19200, 0x8007CCAC: height}.get(address, value)
        assert bytes(uc.mem_read(address, 4)) == word(value), ('Global oracle', hex(address))
    for address, value in zip(COLOR_WORDS, colors):
        assert bytes(uc.mem_read(address, 4)) == word(value), 'Scene colors changed'
    assert [(a, v) for a, v in calls if a in DRAW] == ([] if draw is None else [draw]), 'Renderer ABI oracle'
    assert [v[0] for a, v in calls if a == 0x8004DB88] == angles, 'Sine phase oracle'
    assert [(a, v) for a, v in calls if a in STUBS and a not in DRAW] == [
        (0x800493F4, [400]), (0x8004729C, [2]), (0x80049514, [])], 'Projection order'
    copies = [v for a, v in calls if a == 0x8003B520]
    assert copies == [[signed(STACK - 144 + 68), signed(MATRIX), 36],
                      [signed(MATRIX), signed(STACK - 144 + 68), 36]], 'Complete matrix copy ABI'
    assert bytes(uc.mem_read(TABLE, 44)) == table, 'Dispatch table changed'
    return calls


def run():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    records = {r[0]: r for r in MATCHING_BLOCKS}
    comparisons, support = {}, []
    for name in ('renderer_background_dispatch',) + SUPPORT:
        _, source, start, end = records[name]
        result = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target, FAMILY, layout)
        assert result['matches'], name
        comparisons[name] = result
        directory = ROOT / 'build' / FAMILY / name
        sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
        segments = [(s['address'], s['bytes']) for section_name, s in sections.items()
                    if s['flags'] & 2 and s['bytes'] and s['type'] != 8
                    and section_name != '.reginfo']
        if name == 'renderer_background_dispatch':
            raw_sections, symbols = elf_sections_and_symbols(directory / (name + '.raw.o'))
            for section_name, s in raw_sections.items():
                if s['flags'] & 2 and s['size']:
                    assert section_name in ('.text', '.rodata', '.reginfo'), section_name
            assert raw_sections['.text']['size'] == 1072
            assert raw_sections['.text']['bytes'][1060:] == bytes(12)
            assert raw_sections['.rodata']['size'] == 48
            assert raw_sections['.rodata']['bytes'][44:] == bytes(4)
            assert symbols['func_800400D0']['size'] == 1060
            assert sections['.renderer_background_dispatch_table']['bytes'] == target[0x95880:0x958AC]
        if name != 'renderer_background_dispatch':
            support += segments
    table = target[0x95880:0x958AC]
    retail, compiled = target[0x40CD0:0x410F4], (ROOT / 'build' / FAMILY /
        'renderer_background_dispatch/renderer_background_dispatch.bin').read_bytes()
    clocks = (0, 1, 511, 512, 4095, -1, -512, -4096, 0x7FFFFFFF, -0x80000000)
    kinds = tuple(range(-11, 12)) + (-0x80000000, 0x7FFFFFFF)
    cases = list(itertools.product((0, 1, 2, 3, -1), kinds, clocks, (0, 1, -1),
                                  (0, 1), (8, 9)))
    digest = hashlib.sha256()
    for index, base in enumerate(cases):
        colors = tuple(signed(v) for v in (0, 255, 0x7FFFFFFF, 0x80000000, -1, 128))
        case = base + (colors,)
        original = execute(retail, table, support, case)
        recovered = execute(compiled, table, support, case)
        assert original == recovered, ('Retail execution', case)
        digest.update(json.dumps((case, original), separators=(',', ':')).encode())
        if index % 2000 == 0:
            print(f'Background cases: {index}/{len(cases)}', flush=True)
    mutations = []
    fixture = (0, 4, 512, 1, 1, 9, (12, 34, 56, 78, 90, 123))
    for name, address, replacement in (
        ('clock store', 0x8004013C, bytes(4)),
        ('short height', 0x8004016C, bytes.fromhex('240a2af9')),
        ('matrix restoration call', 0x800404DC, bytes(4)),
    ):
        mutant = bytearray(retail)
        offset = address - ENTRY
        assert bytes(mutant[offset:offset + 4]) != replacement
        mutant[offset:offset + 4] = replacement
        try:
            execute(bytes(mutant), table, support, fixture)
        except AssertionError as error:
            mutations.append({'name': name, 'detected': True, 'reason': str(error)})
        else:
            raise AssertionError(('Undetected mutation', name))
    layout.verify()
    report = {'matches': True, 'execution_cases': len(cases),
              'trace_sha256': digest.hexdigest(), 'mutations': mutations,
              'comparisons': comparisons, 'unicorn': version('unicorn'),
              'stub_scope': 'Projection/material selection and all renderer calls; no graphics execution.',
              'retail_rom_sha256': hashlib.sha256(target).hexdigest()}
    path = ROOT / 'build' / FAMILY / 'report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print(f'Passed {len(cases)} guarded cases and {len(mutations)} mutations: {path}', flush=True)


if __name__ == '__main__':
    run()
