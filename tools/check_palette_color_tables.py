"""Execute matching palette/light consumers with recovered initial color tables."""

import hashlib
import json
from importlib.metadata import version

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs

from check_actor_group_path import machine, word, SENTINEL
from compare_data import compare_unit, comparison_directory
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


TABLE, LIGHT_COLORS = 0x8007BB34, 0x8007BF34
RGB5551, LIGHTS, INPUT = 0x8007D6D0, 0x80123B28, 0x80201010
STACK = 0x80300000
GET, SET, RANGE = 0x8003C14C, 0x8003C0DC, 0x8003C020
LIGHT_FIRST, LIGHT_SECOND = 0x80046CF8, 0x80046DD0
DATA_SOURCES = ('src/game/palette_effects/color_tables.c',
                'src/game/formatting/digits.c',
                'src/game/renderer_diagnostics/fatal_message.c')


def packed_5551(rgb):
    red, green, blue = rgb
    return (red // 8) * 2048 + (green // 8) * 64 + (blue // 8) * 2 + 1


def run(code, data, initial_colors, case):
    entry, index, count, directions = case
    uc, write, execute = machine(code, data)
    saved = {getattr(regs, 'UC_MIPS_REG_' + name): 0xA2340000 + i * 256
             for i, name in enumerate(('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP'))}
    source = bytes(value for i in range(256) for value in
                   ((i * 17 + 13) & 255, (i * 29 + 71) & 255, (i * 43 + 193) & 255, 0x5C))
    initial = {TABLE - 16: b'\xA8' * 16 + initial_colors + b'\xB8' * 16,
               RGB5551 - 16: b'\xA9' * 16 + b'\xA5' * 512 + b'\xB9' * 16,
               LIGHTS - 16: b'\xAA' * 16 + b'\xA6' * 4096 + b'\xBA' * 16,
               INPUT - 16: b'\xAB' * 16 + source + b'\xBB' * 16,
               0x8007D5DC: b''.join(word(value) for value in directions),
               STACK - 80: b'\xAC' * 112}
    expected = {a: bytearray(b) for a, b in initial.items()}
    for address, payload in initial.items():
        write(address, payload)
    # The proposed data is supplied separately from the retail-derived oracle.
    for address, payload in data:
        write(address, payload)
    allowed = [(STACK - 64, STACK + 16)]

    def store(base, offset, value):
        expected[base][offset:offset + len(value)] = value
        allowed.append((base + offset, base + offset + len(value)))

    if entry == GET:
        rgb = initial_colors[index * 4:index * 4 + 3]
        for channel in range(3):
            store(INPUT - 16, 16 + channel, rgb[channel:channel + 1])
        arguments = (INPUT, index)
    elif entry in (SET, RANGE):
        count = 1 if entry == SET else count
        for row in range(max(0, count)):
            rgb = source[row * 4:row * 4 + 3]
            for channel in range(3):
                store(TABLE - 16, 16 + (index + row) * 4 + channel, rgb[channel:channel + 1])
            store(RGB5551 - 16, 16 + (index + row) * 2, packed_5551(rgb).to_bytes(2, 'big'))
        arguments = (INPUT, index, count)
    else:
        rgb = initial_colors[1024 + index * 4:1024 + index * 4 + 3]
        for channel, value in enumerate(rgb):
            scaled = min(255, (value * 380) // 256)
            for field in (channel, 4 + channel):
                store(LIGHTS - 16, 16 + index * 16 + field, bytes([scaled]))
            store(LIGHTS - 16, 16 + index * 16 + 8 + channel, bytes([directions[channel] & 255]))
        arguments = (0xA1234567, index) if entry == LIGHT_FIRST else (index,)
    for register, value in zip((regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                regs.UC_MIPS_REG_A2), arguments):
        uc.reg_write(register, value & 0xFFFFFFFF)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xABCD1234)
    touched = set()

    def guard_write(uc, access, address, size, value, user):
        address |= 0x80000000
        assert any(a <= address and address + size <= b for a, b in allowed), ('Write guard', case, hex(address), size)
        if STACK - 64 <= address < STACK + 16:
            touched.update(range(address, address + size))

    def guard_read(uc, access, address, size, value, user):
        address |= 0x80000000
        spans = [(a, a + len(b)) for a, b in initial.items()]
        spans += [(a, a + len(b)) for a, b in data]
        assert any(a <= address and address + size <= b for a, b in spans), ('Read guard', case, hex(address), size)

    def guard_code(uc, address, size, user):
        assert address == SENTINEL or any(a <= address and address + size <= a + len(b) for a, b in code), ('Code guard', hex(address))

    uc.hook_add(UC_HOOK_MEM_WRITE, guard_write)
    uc.hook_add(UC_HOOK_MEM_READ, guard_read)
    uc.hook_add(UC_HOOK_CODE, guard_code)
    execute(entry)
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xABCD1234
    assert all(uc.reg_read(register) == value for register, value in saved.items())
    digest = hashlib.sha256()
    for address, payload in expected.items():
        observed = bytes(uc.mem_read(address & 0x1FFFFFFF, len(payload)))
        if address == STACK - 80:
            assert all(value == payload[i] for i, value in enumerate(observed) if address + i not in touched), 'Stack guard'
        else:
            assert observed == payload, ('State oracle', case, hex(address))
            digest.update(observed)
    return digest.hexdigest()


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    reports, code, data = {}, [], []
    for name in ('palette', 'graphics_lights'):
        _, source, start, end = next(x for x in MATCHING_BLOCKS if x[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target, 'palette-color-table-execution', layout)
        assert report['matches'], name
        reports[name] = report
        path = ROOT / 'build/palette-color-table-execution' / name / (name + '.bin')
        code.append((start, path.read_bytes()))
    for source in DATA_SOURCES:
        owned = source_sections(source)
        report = compare_unit(source, owned, target, layout)
        assert report['matches'], source
        reports[source] = report
        sections, _ = elf_sections_and_symbols(comparison_directory(source) / 'compiled.elf')
        for record in owned:
            data.append((record['vram'], sections[record['section']]['bytes']))
    colors = target[0x7C734:0x7CF34]
    assert len(colors) == 2048 and colors[:1024] == colors[1024:]
    # Formatting constants are compared above but are not read by these calls.
    # Keep the adjacent digit bytes out of the palette's guard region.
    data = [(address, payload) for address, payload in data if address == TABLE]
    cases = [(entry, index, 1, (-128, 0, 127)) for entry in
             (GET, SET, LIGHT_FIRST, LIGHT_SECOND) for index in range(256)]
    for start, count in ((0, -1), (255, -1), (0, 0), (255, 0), (0, 1), (255, 1),
                         (0, 2), (254, 2), (0, 255), (1, 255), (0, 256)):
        cases.append((RANGE, start, count, (-1, 128, 256)))
    for directions in ((-1, 128, 256), (0x7FFFFFFF, -0x80000000, -257), (19, -29, 43)):
        for entry in (LIGHT_FIRST, LIGHT_SECOND):
            for index in (0, 7, 16, 31, 254, 255):
                cases.append((entry, index, 1, directions))
    retail = [(a, target[a - 0x80000000 + 0xC00:a - 0x80000000 + 0xC00 + len(b)]) for a, b in code]
    retail_data = [(a, target[a - 0x80000000 + 0xC00:a - 0x80000000 + 0xC00 + len(b)]) for a, b in data]
    digest = hashlib.sha256()
    for index, case in enumerate(cases):
        original = run(retail, retail_data, colors, case)
        recovered = run(code, data, colors, case)
        assert recovered == original
        digest.update(json.dumps([case, recovered]).encode())
        if (index + 1) % 250 == 0:
            print('Compared', index + 1, 'color-table cases.', flush=True)
    mutations = []
    for label, address, predicate, change, case in (
        ('RGB5551 opacity bit', 0x8003BFEC,
         lambda x: x >> 26 == 13 and x & 65535 == 1,
         lambda x: x & ~1, (SET, 1, 1, (-128, 0, 127))),
        ('getter destination blue byte', GET,
         lambda x: x >> 26 == 40 and x & 65535 == 2,
         lambda x: x + 1, (GET, 254, 1, (-128, 0, 127))),
        ('directional-light intensity shift', LIGHT_FIRST + 0x50,
         lambda x: x >> 26 == 0 and x & 63 == 3 and (x >> 6) & 31 == 8,
         lambda x: x + (1 << 6), (LIGHT_FIRST, 16, 1, (-128, 0, 127)))):
        unit, payload = next((a, b) for a, b in code if a <= address < a + len(b))
        last = GET if address == 0x8003BFEC else (0x8003C180 if address == GET else LIGHT_SECOND)
        candidates = [(i, int.from_bytes(payload[i:i + 4], 'big')) for i in range(address - unit, last - unit, 4)
                      if predicate(int.from_bytes(payload[i:i + 4], 'big'))]
        assert candidates, label
        offset, instruction = candidates[0]
        modified = payload[:offset] + word(change(instruction)) + payload[offset + 4:]
        altered = [(a, modified if a == unit else b) for a, b in code]
        try:
            run(altered, data, colors, case)
        except AssertionError:
            mutations.append(dict(name=label,detected=True,vram=hex(unit + offset)))
        else:
            raise AssertionError('Mutation escaped execution oracle: ' + label)
    report = dict(matches=True,cases=len(cases),trace_sha256=digest.hexdigest(),
                  comparisons=reports,detected_mutations=mutations,
                  checker_sha256=hashlib.sha256((ROOT / 'tools/check_palette_color_tables.py').read_bytes()).hexdigest(),
                  emulator=dict(package='unicorn',version=version('unicorn')),
                  limits=['All 256 indices and both separate initialized tables are exercised.',
                          'Palette RGB writes, packed RGB5551, getters, directional-light colors, reserved bytes, directions, bounds and integer ABI preservation are checked.',
                          'Matching palette and light instructions execute without supporting-call stubs.',
                          'The two formatting constants receive full data comparisons only; these calls do not read them.',
                          'Only bounded palette ranges and light indices are exercised; invalid pointers and renderer/gameplay integration remain outside this checker.',
                          'The fatal formatter remains excluded; its formatted-output and infinite-wait path are not executed by this checker.'])
    layout.verify()
    output=ROOT / 'build/palette-color-table-execution/report.json'
    output.write_text(json.dumps(report,indent=2)+'\n')
    print('Passed',len(cases),'color-table cases and',len(mutations),'detected mutations.',flush=True)


if __name__ == '__main__':
    main()
