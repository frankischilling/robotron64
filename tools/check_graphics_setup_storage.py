"""Compare complete setup storage and execute matching renderer consumers."""

import argparse
import hashlib
from importlib.metadata import version
import itertools
import json
from pathlib import Path
import struct

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UC_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import SENTINEL, machine, word
from compare_data import compare_unit, comparison_directory
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


SOURCES = tuple('src/game/renderer_setup/' + name + '.c' for name in
                ('defaults', 'tile_packets', 'cache_state', 'arena_state'))
SUPPORT = ('graphics_modes', 'renderer_tile_origin_mode', 'graphics_lights',
           'palette_tint', 'graphics_frame_reset')
CURSOR, OUTPUT, TILE, LIGHTS, STACK = 0x80138254, 0x80210010, 0x80220010, 0x80123B28, 0x80300000
STATE = 0x80123AE8


def signed(value):
    value &= 0xFFFFFFFF
    return value - 0x100000000 if value & 0x80000000 else value


def run(code, data, kind, values):
    uc, write, execute = machine(code, data)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA57B315D)
    panels = {}
    expected = {}

    def panel(address, size):
        blob = bytearray((i * 37 + 19) & 255 for i in range(size + 32))
        # A neighboring initialized object can occupy a guard. Preserve its
        # real compiled bytes instead of seeding over the setup-list terminator.
        for start, payload in data:
            first = max(address - 16, start)
            end = min(address + size + 16, start + len(payload))
            if first < end:
                blob[first - address + 16:end - address + 16] = payload[first - start:end - start]
        panels[address] = blob
        expected[address] = bytearray(blob)
        write(address - 16, bytes(blob))

    def put(address, value):
        for start, blob in panels.items():
            if start <= address and address + 4 <= start + len(blob) - 32:
                offset = 16 + address - start
                blob[offset:offset + 4] = word(value)
                expected[start][offset:offset + 4] = word(value)
                write(address, word(value))
                return
        raise AssertionError(('Fixture address', hex(address)))

    def want(address, value):
        for start, blob in expected.items():
            if start <= address and address + 4 <= start + len(blob) - 32:
                offset = 16 + address - start
                blob[offset:offset + 4] = word(value)
                return
        raise AssertionError(('Expected address', hex(address)))

    panel(0x8013823C, 28)
    panel(OUTPUT, 40)
    panel(TILE, 0x188)
    # One fixture covers adjacent globals and lights, with every gap retained
    # in the independent final-memory oracle rather than overlapping guards.
    panel(STATE, 0x80126B88 - STATE)
    for address in (0x800BEF60, 0x8007D6A8):
        panel(address, 4)
    panel(0x800BF2C0, 8)
    write(STACK - 0x100, b'\xD7' * 0x120)
    put(CURSOR, OUTPUT)
    put(0x8013823C, TILE)
    for index, address in enumerate((0x80123B00, 0x80123B04, 0x80123B08, 0x80123B0C,
                                    0x80123B10, 0x80123B14, 0x80123B18, 0x80123B1C,
                                    0x80123B20, 0x800BF2C0, 0x800BF2C4, 0x800BEF60,
                                    0x80126B28, 0x80123AE8, 0x8007D6A8, 0x80126B74,
                                    0x80126B78, 0x80126B7C, 0x80126B80, 0x80126B84)):
        put(address, 17 + index * 31)
    default_before = bytes(uc.mem_read(0x8007D5D8 & 0x1FFFFFFF, 200))
    expected_defaults = bytearray(default_before)
    light_before = None
    allowed = [(CURSOR, CURSOR + 4), (OUTPUT, OUTPUT + 40),
               (0x8013823C, 0x80138240), (TILE + 0x180, TILE + 0x188),
               (0x80123B00, 0x80123B24), (0x80126B74, 0x80126B88),
               (0x80126B30, 0x80126B50), (0x800BF2C0, 0x800BF2C8),
               (0x800BEF60, 0x800BEF64), (0x80126B28, 0x80126B2C),
               (0x80123AE8, 0x80123AEC), (0x8007D6A8, 0x8007D6AC)]
    writable = list(allowed) + [(0x8007D5D8, 0x8007D5E8)]
    allowed += [(0x8007D5D8, 0x8007D6A0), (0x8007BF34, 0x8007C334)]
    entry = {'default': 0x80046608, 'tile': 0x80046C2C,
             'light': 0x80046EA8, 'tint': 0x800465B0, 'reset': 0x8004717C}[kind]
    for register in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3):
        uc.reg_write(register, 0)
    if kind in ('default', 'tile'):
        packets = [(0x06000000, 0x8007D5E8), (0xBA000E02, 0)]
        if kind == 'tile':
            x, y = values
            put(TILE + 0x180, x)
            put(TILE + 0x184, y)
            packets = [(0x06000000, 0x8007C970),
                       (0xF2000000 | ((x & 0xFFF) << 12) | (y & 0xFFF),
                        (((x + 0x7C) & 0xFFF) << 12) | ((y + 0x7C) & 0xFFF)),
                       (0xB7000000, 0x20204), (0xBA000E02, 0)]
        for i, pair in enumerate(packets):
            want(OUTPUT + i * 8, pair[0])
            want(OUTPUT + i * 8 + 4, pair[1])
        want(CURSOR, OUTPUT + len(packets) * 8)
    elif kind in ('light', 'tint'):
        index, red, green, blue = values
        write(LIGHTS, b'\xA5' * (256 * 16))
        offset = 16 + LIGHTS - STATE
        panels[STATE][offset:offset + 256 * 16] = b'\xA5' * (256 * 16)
        expected[STATE][offset:offset + 256 * 16] = b'\xA5' * (256 * 16)
        light_before = bytes(uc.mem_read((LIGHTS - 16) & 0x1FFFFFFF, 256 * 16 + 32))
        light_expected = bytearray(light_before)
        allowed.append((LIGHTS, LIGHTS + 256 * 16))
        writable.append((LIGHTS, LIGHTS + 256 * 16))
        direction = (70, 50, -70)
        indices = (index,)
        if kind == 'tint':
            direction = (red, green, blue)
            indices = range(256)
            for offset, value in zip((4, 8, 12), direction):
                expected_defaults[offset:offset + 4] = word(value)
            args = direction
        else:
            args = (index, red, green, blue)
        for register, value in zip((regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                    regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3), args):
            uc.reg_write(register, value & 0xFFFFFFFF)
        for i in indices:
            if kind == 'tint':
                packed = int.from_bytes(uc.mem_read((0x8007BF34 + i * 4) & 0x1FFFFFFF, 4), 'big')
                colors = ((packed >> 24) & 255, (packed >> 16) & 255, (packed >> 8) & 255)
            else:
                colors = (red, green, blue)
            start = 16 + i * 16
            for offset, value in enumerate(colors):
                value = min(signed(value * 380) >> 8, 255) & 255
                light_expected[start + offset] = value
                light_expected[start + offset + 4] = value
            for offset, value in enumerate(direction):
                light_expected[start + 8 + offset] = value & 255
        offset = 16 + LIGHTS - STATE
        expected[STATE][offset:offset + 256 * 16] = light_expected[16:-16]
    else:
        alternate, = values
        uc.reg_write(regs.UC_MIPS_REG_A0, alternate & 0xFFFFFFFF)
        counters = (17 + 14 * 31, 17 + 7 * 31, 17 + 10 * 31, 17 + 4 * 31,
                    17 + 5 * 31, 17 + 6 * 31, (17 + 19 * 31) - (17 + 8 * 31), 17 + 18 * 31)
        for i, value in enumerate(counters):
            want(0x80126B30 + i * 4, value)
        start = 2000 if alternate else 12000
        for address in (0x8007D6A8, 0x80123B10, 0x80123B14, 0x80123B18,
                        0x800BF2C4, 0x80123B1C, 0x80126B28, 0x80123B08,
                        0x80123B00, 0x80123B04, 0x800BF2C0, 0x800BEF60):
            want(address, 0)
        want(0x80126B84, start)
        want(0x80123B20, start)
        want(0x80123AE8, 255)
        want(0x80123B0C, 255)
        expected_defaults[:4] = word(-1)
    stack = (STACK - 0x100, STACK + 16)
    ranges = [(a, a + len(b)) for a, b in code]

    def inside(address, size, bounds):
        address = (address & 0x1FFFFFFF) | 0x80000000
        return any(a <= address and address + size <= b for a, b in bounds)

    def instruction(uc, address, size, user):
        assert address == SENTINEL or inside(address, size, ranges), ('Instruction bound', hex(address))

    def access(uc, access, address, size, value, user):
        assert inside(address, size, (writable if access == UC_MEM_WRITE else allowed) + [stack]), ('Memory bound', kind, hex(address), size)

    uc.hook_add(UC_HOOK_CODE, instruction)
    uc.hook_add(UC_HOOK_MEM_READ | UC_HOOK_MEM_WRITE, access)
    execute(entry)
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xA57B315D
    assert bytes(uc.mem_read((STACK - 0x100) & 0x1FFFFFFF, 16)) == b'\xD7' * 16
    assert bytes(uc.mem_read((STACK + 16) & 0x1FFFFFFF, 16)) == b'\xD7' * 16
    for address, blob in expected.items():
        assert bytes(uc.mem_read((address - 16) & 0x1FFFFFFF, len(blob))) == bytes(blob), ('Panel oracle', kind, hex(address), values)
    assert bytes(uc.mem_read(0x7D5D8, 200)) == bytes(expected_defaults), ('Mutable defaults oracle', kind)
    if light_before is not None:
        assert bytes(uc.mem_read((LIGHTS - 16) & 0x1FFFFFFF, len(light_expected))) == bytes(light_expected), ('Light oracle', kind, values)
    return hashlib.sha256(b''.join(bytes(x) for x in expected.values()) + bytes(expected_defaults)).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.parse_args()
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    data_reports, data = {}, []
    for source in SOURCES:
        records = source_sections(source)
        report = compare_unit(source, records, target, layout)
        assert report['matches']
        data_reports[source] = report
        sections, _ = elf_sections_and_symbols(comparison_directory(source) / 'compiled.elf')
        for item in records:
            if item['rom'] is not None:
                data.append((item['vram'], sections[item['section']]['bytes']))
    palette_source = 'src/game/palette_effects/color_tables.c'
    palette_records = source_sections(palette_source)
    palette_report = compare_unit(palette_source, palette_records, target, layout)
    assert palette_report['matches']
    palette_sections, _ = elf_sections_and_symbols(comparison_directory(palette_source) / 'compiled.elf')
    for item in palette_records:
        data.append((item['vram'], palette_sections[item['section']]['bytes']))
    code, retail, comparisons = [], [], {}
    for name in SUPPORT:
        _, source, first, end = next(x for x in MATCHING_BLOCKS if x[0] == name)
        report = compare_block(name, source, first, first - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target, 'graphics-setup-execution', layout)
        assert report['matches']
        comparisons[name] = report
        blob = (ROOT / 'build/graphics-setup-execution' / name / (name + '.bin')).read_bytes()
        code.append((first, blob))
        retail.append((first, target[first - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
    counts = dict(default=0, tile=0, light=0, tint=0, reset=0)
    digest = hashlib.sha256()
    cases = [('default', ())]
    coordinates = (-0x80000000, -4097, -1, 0, 1, 4095, 4096, 0x7FFFFFFF)
    cases += [('tile', x) for x in itertools.product(coordinates, repeat=2)]
    channels = (-0x80000000, -300, -1, 0, 1, 171, 255, 256, 0x7FFFFFFF)
    cases += [('light', (index, *rgb)) for index, rgb in itertools.product((0, 7, 255), itertools.product(channels, repeat=3))]
    cases += [('tint', (0, d, 50, -70)) for d in (-256, -129, -128, -1, 0, 70, 255, 511)]
    cases += [('reset', (x,)) for x in (0, 1, -1, 0x7FFFFFFF, -0x80000000)]
    for kind, values in cases:
        expected = run(retail, data, kind, values)
        actual = run(code, data, kind, values)
        assert actual == expected
        counts[kind] += 1
        digest.update(json.dumps([kind, values, actual]).encode())
    result = dict(matches=True, cases=counts, paired_cases=sum(counts.values()),
                  data_comparisons=data_reports, consumer_comparisons=comparisons,
                  palette_comparison=palette_report,
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  target_rom_sha256=hashlib.sha256(target).hexdigest(), trace_sha256=digest.hexdigest(),
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['Five complete matching consumer units are loaded; their default, tile, light, tint and reset entry points execute without callee stubs.',
                          'The tint loop reads the independently matched, compiled palette table.',
                          'Light fixtures cover the 256 indices demanded by the tint loop; no full light-array extent is owned.',
                          'Packet submission, tile packing, direction narrowing, frame snapshots and guarded storage are checked.',
                          'RSP/RDP execution, texture contents, allocation paths and gameplay are not established.'])
    out = ROOT / 'build/graphics-setup-execution/report.json'
    out.write_text(json.dumps(result, indent=2) + '\n')
    print('Passed graphics setup storage:', counts, 'paired cases:', result['paired_cases'], flush=True)


if __name__ == '__main__':
    main()
