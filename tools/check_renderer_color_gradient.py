"""Check both gradient renderers' complete code, ABI, vertices, and commands."""
import hashlib
import itertools
import json
import struct
from pathlib import Path
from importlib.metadata import version

from elftools.elf.elffile import ELFFile
from unicorn import Uc, UC_ARCH_MIPS, UC_MODE_MIPS32, UC_MODE_BIG_ENDIAN
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn.mips_const import *

from compare_startup import compare_block, SymbolLayoutSnapshot
from compare_runtime import MATCHING_BLOCKS
from compare_data import compare_unit
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate

GRADIENTS = {
    'gradient': dict(entry=0x80040F5C, size=548, rom=0x41B5C, vertices=4,
                     source='src/game/renderer_surfaces/color_gradient.c'),
    'border_gradient': dict(entry=0x80041180, size=836, rom=0x41D80, vertices=12,
                            source='src/game/renderer_surfaces/border_gradient.c'),
}
FAMILY = 'renderer-color-gradient-execution'
CALLS = (0x8004729C, 0x80047048, 0x80047094)
FP_INIT, FP_RETURN = 0x80001800, 0x80002000


def audit_object(path, spec):
    size = spec['size']
    with path.open('rb') as stream:
        elf = ELFFile(stream)
        text = elf.get_section_by_name('.text')
        assert text['sh_size'] == size + 12
        assert text.data()[size:] == bytes(12)
        for section in elf.iter_sections():
            if section['sh_type'] == 'SHT_MIPS_REGINFO':
                assert section.name == '.reginfo' and section['sh_size'] == 24
                continue
            if section['sh_flags'] & 2 and section['sh_size']:
                assert section.name == '.text', section.name
        symbols = elf.get_section_by_name('.symtab')
        functions = [s for s in symbols.iter_symbols()
                     if s['st_info']['type'] == 'STT_FUNC'
                     and isinstance(s['st_shndx'], int)]
        assert len(functions) == 1
        assert functions[0].name == f'func_{spec["entry"]:08X}'
        assert functions[0]['st_value'] == 0
        assert functions[0]['st_size'] == size
        relocations = []
        expected = {'func_8004729C', 'func_80047048', 'func_80047094',
                    'D_80138254', 'D_80123AE4', 'D_800CDBD0',
                    'D_8007CCA8', 'D_8007CCAC'}
        for section in elf.iter_sections():
            if section['sh_type'] != 'SHT_REL':
                continue
            table = elf.get_section(section['sh_link'])
            assert elf.get_section(section['sh_info']).name == '.text'
            for relocation in section.iter_relocations():
                symbol = table.get_symbol(relocation['r_info_sym']).name
                assert symbol in expected, symbol
                assert relocation['r_info_type'] in (4, 5, 6)
                assert relocation['r_offset'] < size
                relocations.append((relocation['r_offset'],
                                    relocation['r_info_type'], symbol))
        assert {r[2] for r in relocations} == expected
        return {'function_bytes': size, 'zero_text_tail': 12,
                'initialized_data_bytes': 0, 'relocations': relocations}


def execute(code, width, height, colors, mode, base, support=None, previous=2,
            kind='gradient'):
    spec = GRADIENTS[kind]
    entry, count = spec['entry'], spec['vertices']
    border = kind == 'border_gradient'
    uc = Uc(UC_ARCH_MIPS, UC_MODE_MIPS32 | UC_MODE_BIG_ENDIAN)
    uc.mem_map(0, 0x400000)
    uc.mem_map(0x80000000, 0x400000)

    def write(address, data):
        address &= 0x1FFFFFFF
        uc.mem_write(address, data)
        uc.mem_write(address | 0x80000000, data)

    def read(address, size):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, size))

    def word(address, value):
        write(address, struct.pack('>I', value & 0xFFFFFFFF))

    def load(address):
        return int.from_bytes(read(address, 4), 'big')

    def mirror(uc, access, address, size, value, user):
        physical = address & 0x1FFFFFFF
        ranges = [(sp - 64, sp + 32), (0x80200000, 0x80200080)]
        if base != -1:
            ranges.append((vertex, vertex + count * 16))
        ranges += [(address, address + 4) for address in
                   (0x80138254, 0x80123AE4, 0x8007D5D8,
                    0x80123AE8, 0x800C85B8, 0x80126B84)]
        if 0x3100 <= physical and physical + size <= 0x3130:
            pc = uc.reg_read(UC_MIPS_REG_PC) | 0x80000000
            assert FP_RETURN <= pc < FP_RETURN + 48, hex(pc)
        else:
            assert any((start & 0x1FFFFFFF) <= physical and
                       physical + size <= (end & 0x1FFFFFFF)
                       for start, end in ranges), (hex(address), size)
        other = address ^ 0x80000000
        if other < 0x400000 or 0x80000000 <= other < 0x80400000:
            uc.mem_write(other, (value & ((1 << (size * 8)) - 1)).to_bytes(size, 'big'))

    uc.hook_add(UC_HOOK_MEM_WRITE, mirror)
    if support is not None:
        for address, data in support:
            write(address, data)
    write(entry, code)
    # Unicorn's MIPS API cannot directly access these FPRs. Load and observe
    # their bits with MIPS instructions, outside the compared procedure.
    fp_seed = b''.join(struct.pack('>I', 0x3F000000 + i * 0x10000)
                       for i in range(32))
    initializer = b''.join(struct.pack('>I', 0xC4003000 | i << 16 | i * 4)
                           for i in range(32))
    initializer += struct.pack('>II', 0x08000000 | ((entry >> 2) & 0x3FFFFFF), 0)
    observer = b''.join(struct.pack('>I', 0xE4003100 | i << 16 | (i - 20) * 4)
                        for i in range(20, 32))
    observer += struct.pack('>II', 0x08000020, 0)
    write(FP_INIT, initializer)
    write(FP_RETURN, observer)
    write(0x3000, fp_seed)
    write(0x3100, bytes([0x89]) * 48)
    word(0x8007CCA8, width)
    word(0x8007CCAC, height)
    word(0x80138254, 0x80200000)
    word(0x80123AE4, 1234)
    allocation = 9801 if base == -1 else base
    frame_start = 0 if allocation <= 9801 else allocation
    word(0x80126B84, allocation)
    word(0x80123B20, frame_start)
    word(0x8007D5D8, previous)
    word(0x80123AE8, 37)
    word(0x800C85B8, 1)
    vertex = 0x800CDBD0 + max(base, 0) * 16
    vertex_span = 32 + count * 16
    write(vertex - 16, bytes([0xA5]) * vertex_span)
    write(0x801FFFF0, bytes([0xA5]) * 144)
    sp = 0x803F0000
    write(sp - 128, bytes([0xA5]) * 192)
    args = colors if border else (*colors, mode)
    for i, value in enumerate(args[4:]):
        word(sp + 16 + i * 4, value)
    stack_low = read(sp - 128, 64)
    stack_high = read(sp + 32, 32)
    trace = []
    finished = [False]
    caller_saved = [UC_MIPS_REG_V0, UC_MIPS_REG_V1,
                    UC_MIPS_REG_A0, UC_MIPS_REG_A1, UC_MIPS_REG_A2, UC_MIPS_REG_A3,
                    UC_MIPS_REG_T0, UC_MIPS_REG_T1, UC_MIPS_REG_T2, UC_MIPS_REG_T3,
                    UC_MIPS_REG_T4, UC_MIPS_REG_T5, UC_MIPS_REG_T6, UC_MIPS_REG_T7,
                    UC_MIPS_REG_T8, UC_MIPS_REG_T9]

    def hook(uc, address, size, user):
        address |= 0x80000000
        if address == 0x80000080:
            finished[0] = True
            uc.emu_stop()
        elif address in CALLS or (support is not None and address in (0x80046800, 0x80048DC0)):
            argument = uc.reg_read(UC_MIPS_REG_A0) & 0xFFFFFFFF
            trace.append((address, [] if address in (CALLS[1], 0x80046800) else [argument]))
            if support is not None:
                return
            result = base if address == CALLS[1] else 0x10203040
            destination = uc.reg_read(UC_MIPS_REG_RA)
            for i, register in enumerate(caller_saved):
                uc.reg_write(register, 0xCA000000 + i * 0x101)
            uc.reg_write(UC_MIPS_REG_V0, result & 0xFFFFFFFF)
            uc.reg_write(UC_MIPS_REG_PC, destination)

    uc.hook_add(UC_HOOK_CODE, hook)
    preserved = [UC_MIPS_REG_S0, UC_MIPS_REG_S1, UC_MIPS_REG_S2, UC_MIPS_REG_S3,
                 UC_MIPS_REG_S4, UC_MIPS_REG_S5, UC_MIPS_REG_S6, UC_MIPS_REG_S7,
                 UC_MIPS_REG_FP, UC_MIPS_REG_GP]
    sentinels = [0x13570000 + i * 0x101 for i in range(len(preserved))]
    for register, value in zip(preserved, sentinels):
        uc.reg_write(register, value)
    uc.reg_write(UC_MIPS_REG_SP, sp)
    uc.reg_write(UC_MIPS_REG_RA, FP_RETURN)
    for register, value in zip((UC_MIPS_REG_A0, UC_MIPS_REG_A1,
                                UC_MIPS_REG_A2, UC_MIPS_REG_A3), args):
        uc.reg_write(register, value & 0xFFFFFFFF)
    uc.emu_start(FP_INIT, 0, count=2000)
    assert finished[0]
    assert uc.reg_read(UC_MIPS_REG_SP) == sp
    assert [uc.reg_read(r) for r in preserved] == sentinels
    assert read(0x3100, 48) == fp_seed[80:128]
    assert read(0x3000, len(fp_seed)) == fp_seed
    assert read(sp - 128, 64) == stack_low and read(sp + 32, 32) == stack_high
    expected_trace = [(CALLS[0], [2])]
    prefix = []
    if support is not None and previous != 2:
        if previous == 18:
            prefix.append((0xB9000002, 0))
        prefix += [(0xE7000000, 0), (0xB6000000, 0x00060000),
                   (0xB7000000, 0x205), (0xFCFFFFFF, 0xFFFE793C),
                   (0xB900031D, 0x00552078)]
        expected_trace.append((0x80046800, []))
    expected_trace.append((CALLS[1], []))
    if support is not None and base == -1:
        expected_trace.append((0x80048DC0, [0x80095280]))
    if border:
        commands = [(0xBA000602, 0), (0xB7000000, 4),
                    (0xFCFFFFFF, 0xFFFE793C), (0xB900031D, 0x00552078)]
    else:
        commands = [(0xB7000000, 4), (0xFCFFFFFF, 0xFFFE793C),
                    (0xB900031D, 0x0050007B if mode else 0x005049D8)]
    expected_vertices = bytearray([0xA5] * vertex_span)
    if base != -1:
        expected_trace.append((CALLS[2], [count]))
        if border:
            commands += [(0x040030BF, vertex), (0xB1020406, 0x00020600),
                         (0xB10A0C0E, 0x000A0E08), (0xB1121416, 0x00121610)]
            coordinates = [(-width, height), (width, height),
                           (width, 2000), (-width, 2000),
                           (-width, -2000), (width, -2000),
                           (width, -height), (-width, -height),
                           (-width, -2000), (width, -2000),
                           (width, 2000), (-width, 2000)]
            first_color = (0, 1, 6, 7)
        else:
            commands += [(0x0400103F, vertex), (0xB1020406, 0x00020600)]
            coordinates = [(-width, -height), (-width, height),
                           (width, height), (width, -height)]
            first_color = (1, 2)
        for i, (x, y) in enumerate(coordinates):
            offset = 16 + i * 16
            expected_vertices[offset:offset + 6] = struct.pack(
                '>3H', x & 0xFFFF, y & 0xFFFF, 32000)
            channels = colors[:3] if i in first_color else colors[3:]
            expected_vertices[offset + 12:offset + 16] = bytes(
                [v & 255 for v in channels] + [255])
    commands = prefix + commands
    expected_commands = b''.join(struct.pack('>II', *c) for c in commands)
    assert trace == expected_trace
    assert read(vertex - 16, vertex_span) == expected_vertices
    assert read(0x801FFFF0, 144) == (bytes([0xA5]) * 16 + expected_commands
                                     + bytes([0xA5]) * (128 - len(expected_commands)))
    assert load(0x80138254) == 0x80200000 + len(expected_commands)
    assert load(0x80123AE4) == base & 0xFFFFFFFF
    assert load(0x8007CCA8) == width & 0xFFFFFFFF
    assert load(0x8007CCAC) == height & 0xFFFFFFFF
    changed = support is not None and previous != 2
    state = [load(a) for a in (0x8007D5D8, 0x80123AE8, 0x800C85B8, 0x80126B84)]
    assert state == [2 if changed else previous & 0xFFFFFFFF,
                     255 if changed else 37, 0 if changed else 1,
                     allocation + (count if support is not None and base != -1 else 0)]
    assert load(0x80123B20) == frame_start
    if support is not None:
        for address, data in support:
            assert read(address, len(data)) == data
    return {'state': state, 'trace': trace, 'vertices': bytes(expected_vertices).hex(),
            'commands': expected_commands.hex()}


def main():
    retail = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(retail)
    dimensions = [(16000, 11000), (-0x80000000, 0x7FFFFFFF), (32000, 24000), (0, 0), (1, -1), (-32768, 32767),
                  (32768, 65535), (-65536, 65536)]
    palettes = [(0, 0, 0, 255, 255, 255), (255, 0, 127, 1, 128, 254),
                (-1, 256, 257, -256, 511, -257),
                (0x12345678, -0x12345678, 17, 31, 63, 127),
                (11, 22, 33, 44, 55, 66)]
    digest = hashlib.sha256()
    layout = SymbolLayoutSnapshot()
    support = []
    support_comparisons = {}
    initialized_support = []
    for name in ('graphics_pool', 'graphics_modes', 'graphics_mode_dispatch', 'debug_noop'):
        record = next(item for item in MATCHING_BLOCKS if item[0] == name)
        _, source, start, end = record
        rom = start - 0x80000000 + 0xC00
        proof = compare_block(name, source, start, rom, rom + end - start,
                              retail, family=FAMILY, layout=layout)
        assert proof['matches'] and not proof['different_words']
        directory_support = ROOT / 'build' / FAMILY / name
        binary = (directory_support / (name + '.bin')).read_bytes()
        support.append((start, binary))
        sections, _ = elf_sections_and_symbols(directory_support / (name + '.elf'))
        for owned in source_sections(source):
            if owned['rom'] is not None:
                data = sections[owned['section']]['bytes']
                assert data == retail[owned['rom']:owned['rom'] + owned['size']]
                support.append((owned['vram'], data))
                initialized_support.append(dict(source=source, section=owned['section'],
                                                vram=owned['vram'], size=len(data),
                                                sha256=hashlib.sha256(data).hexdigest()))
        support_comparisons[name] = proof
    extent_source = 'src/game/renderer_surfaces/gradient_extents.c'
    extent_comparison = compare_unit(extent_source, source_sections(extent_source), retail, layout)
    functions = {}
    stub_cases, real_cases = 0, 0
    for kind, spec in GRADIENTS.items():
        comparison = compare_block(kind, spec['source'], spec['entry'], spec['rom'],
                                   spec['rom'] + spec['size'], retail,
                                   family=FAMILY, layout=layout)
        assert comparison['matches'] and not comparison['different_words']
        directory = ROOT / 'build' / FAMILY / kind
        audit = audit_object(directory / (kind + '.raw.o'), spec)
        compiled = (directory / (kind + '.bin')).read_bytes()
        original = retail[spec['rom']:spec['rom'] + spec['size']]
        modes = (0, 1, -1, 7) if kind == 'gradient' else (None,)
        allocations = (-1, 0, 1, 17, 9800, 22000 - spec['vertices'])
        cases = list(itertools.product(dimensions, palettes, modes, allocations))
        for extent, colors, mode, base in cases:
            expected = execute(original, *extent, colors, mode, base, kind=kind)
            actual = execute(compiled, *extent, colors, mode, base, kind=kind)
            assert actual == expected
            digest.update(json.dumps([kind, actual], sort_keys=True).encode())
            stub_cases += 1
        for previous in (2, 1, 18):
            for extent, colors, mode, base in cases:
                expected = execute(original, *extent, colors, mode, base,
                                   support, previous, kind)
                actual = execute(compiled, *extent, colors, mode, base,
                                 support, previous, kind)
                assert actual == expected
                digest.update(json.dumps([kind, previous, actual], sort_keys=True).encode())
                real_cases += 1
            print('Compared', kind, 'with real support code and previous mode', previous, flush=True)
        functions[kind] = {'comparison': comparison, 'object': audit,
                           'callback_stub_cases': len(cases),
                           'real_support_cases': 3 * len(cases)}
    layout.verify()
    report = {'matches': True, 'cases': stub_cases + real_cases,
              'callback_stub_cases': stub_cases, 'real_support_cases': real_cases,
              'functions': functions, 'support_comparisons': support_comparisons,
              'initialized_support': initialized_support,
              'extent_comparison': extent_comparison,
              'source_code_bytes': sum(s['size'] for s in GRADIENTS.values())
                                   + sum(p['actual_size'] for p in support_comparisons.values()),
              'initialized_support_bytes': sum(r['size'] for r in initialized_support),
              'target_rom_sha256': hashlib.sha256(retail).hexdigest(),
              'emulator': {'package': 'unicorn', 'version': version('unicorn')},
              'trace_sha256': digest.hexdigest(),
              'checker_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'helpers_sha256': {name: hashlib.sha256((ROOT / 'tools' / name).read_bytes()).hexdigest()
                                 for name in ('compare_startup.py', 'compare_runtime.py', 'compare_data.py',
                                              'owned_sections.py', 'manifest.py', 'compiler.py',
                                              'provenance.py', 'trim_padding.py', 'toolchain.py', 'rom.py')},
              'limits': ['The callback-clobbering cases use ABI stubs; the other cases execute four complete source-owned support units and their initialized data.',
                         'Checks direct vertices, display-list commands, callback arguments, guards and preserved registers.',
                         'Does not execute RSP/RDP rendering or exercise pool commits beyond 22000 vertices.']}
    out = ROOT / 'build' / FAMILY / 'report.json'
    out.write_text(json.dumps(report, indent=2) + '\n')
    print(f'{report["cases"]} gradient CPU cases passed; report: {out}')


if __name__ == '__main__':
    main()
