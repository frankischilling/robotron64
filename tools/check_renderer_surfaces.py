"""Compare the excluded surface group with retail MIPS CPU execution.

All exercised callees and initialized support data are freshly compiled and
matched before execution. Texture-file cache misses and fatal diagnostics are
rejected. This covers CPU geometry and commands, without executing the RSP/RDP.
"""

import hashlib
import itertools
import json
import struct
from importlib.metadata import version
from pathlib import Path

import unicorn
from unicorn import Uc, UC_ARCH_MIPS, UC_MODE_MIPS32, UC_MODE_BIG_ENDIAN, UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn.mips_const import UC_MIPS_REG_A0, UC_MIPS_REG_A1, UC_MIPS_REG_A2, UC_MIPS_REG_A3, UC_MIPS_REG_V0, UC_MIPS_REG_SP, UC_MIPS_REG_RA
from compare_runtime import MATCHING_BLOCKS, CANDIDATE_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


SUPPORT = ('frame_transform', 'fixed_math', 'short_sine', 'short_cosine', 'graphics_pool',
           'debug_noop', 'graphics_modes', 'graphics_mode_dispatch', 'renderer_texture_file_cache',
           'renderer_texture_load', 'renderer_alpha_quad', 'renderer_camera_square', 'object_runtime_service')
SURFACES = ('renderer_surface_ring', 'renderer_surface_quad', 'renderer_surface_tiles')


def signed(value):
    value &= 0xFFFFFFFF
    return value - 0x100000000 if value & 0x80000000 else value


def run(code, entry, support, case, inputs=None, gate=1, selector=0):
    base, frame_start, position, matrix, mode, texture_loaded, button = case
    uc = Uc(UC_ARCH_MIPS, UC_MODE_MIPS32 | UC_MODE_BIG_ENDIAN)
    uc.mem_map(0, 0x400000)
    uc.mem_map(0x80000000, 0x400000)

    def write(address, payload):
        address &= 0x1FFFFFFF
        uc.mem_write(address, payload)
        uc.mem_write(address | 0x80000000, payload)

    def read(address, length):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, length))

    def word(address, value):
        write(address, struct.pack('>I', value & 0xFFFFFFFF))

    def load(address):
        return struct.unpack('>I', read(address, 4))[0]

    def vector(address):
        return [signed(v) for v in struct.unpack('>3I', read(address, 12))]

    def store_vector(address, values):
        write(address, struct.pack('>3I', *(v & 0xFFFFFFFF for v in values)))

    def mirror(uc, access, address, size, value, user):
        other = address ^ 0x80000000
        if other < 0x400000 or 0x80000000 <= other < 0x80400000:
            uc.mem_write(other, (value & ((1 << (size * 8)) - 1)).to_bytes(size, 'big'))

    uc.hook_add(UC_HOOK_MEM_WRITE, mirror)
    for address, payload in support + code:
        write(address, payload)
    vertex_start = 0x800CDBD0
    command_start = 0x80200000
    write(vertex_start, b'\xA5' * (22000 * 16))
    write(vertex_start + base * 16 - 16, b'\xA7' * 16)
    write(vertex_start + (base + 128) * 16, b'\xB8' * 16)
    word(0x80138254, command_start)
    word(0x80126B84, base)
    word(0x80123B20, frame_start)
    word(0x80123AE4, base)
    word(0x80123B14, 5)
    word(0x80123B18, 9)
    word(0x8007D5D8, mode)
    word(0x800C85B8, 1)
    word(0x80123AE8, 37)
    word(0x80123B00, 0x800CD3C0 if texture_loaded else 0)
    word(0x8007CD8C, 2)
    word(0x800CDBC0, 2)
    word(0x8007CD90, 4)
    word(0x800C8DFC, 123)
    word(0x80075950, gate)
    word(0x800BA784, selector)
    word(0x8013DBF8, button)
    write(0x800CD3C0, b'\x69' * 2048)
    store_vector(0x800C8BD8 + 0x1C, position)
    for i, row in enumerate(matrix):
        store_vector(0x800CD250 + i * 12, row)
    input_addresses = (0x80210000, 0x8021000C, 0x80210018, 0x80210024)
    if inputs is not None:
        vectors, aliases = inputs
        for address, value in zip(input_addresses, vectors):
            store_vector(address, value)
        input_addresses = tuple(input_addresses[index] for index in aliases)
    original_inputs = read(0x80210000, 48)
    initial_guards = [read(vertex_start + base * 16 - 16, 16).hex(),
                      read(vertex_start + (base + 128) * 16, 16).hex()]
    trace = []
    stopped = [False]
    watched = {0x80000080, 0x80042BDC, 0x80043070, 0x80045214, 0x8004D4B4,
               0x8004DBB0, 0x8004DBE4, 0x80047048, 0x80047094, 0x80048DC0,
               0x8004729C, 0x80042830, 0x800463E8, 0x80046AD0, 0x8004EE9C, 0x800496E0}

    def callback(uc, address, size, user):
        address |= 0x80000000
        if address not in watched:
            return
        if address == 0x80000080:
            stopped[0] = True
            uc.emu_stop()
            return
        if address in (0x8004EE9C, 0x800496E0):
            raise ValueError('Surface execution reached an unsupported file load or fatal diagnostic')
        args = [uc.reg_read(reg) & 0xFFFFFFFF for reg in (UC_MIPS_REG_A0, UC_MIPS_REG_A1, UC_MIPS_REG_A2, UC_MIPS_REG_A3)]
        if address in (0x80042BDC, 0x80045214):
            trace.append([hex(address), [vector(value) for value in args],
                          hashlib.sha256(read(vertex_start + base * 16, 128 * 16)).hexdigest()])
        elif address == 0x8004D4B4:
            trace.append(['transform', vector(args[2]), [vector(args[1] + i * 12) for i in range(3)]])
        elif address in (0x8004DBB0, 0x8004DBE4, 0x80043070):
            trace.append([hex(address), signed(args[0]), signed(args[1])])
        elif address == 0x80047048:
            trace.append(['allocate', load(0x80126B84), load(0x80123B20)])
        elif address == 0x80047094:
            trace.append(['commit', signed(args[0])])
        elif address == 0x80048DC0:
            trace.append(['allocation-warning'])
        else:
            trace.append([hex(address), signed(args[0]) if address != 0x80046AD0 else None])

    uc.hook_add(UC_HOOK_CODE, callback)
    uc.reg_write(UC_MIPS_REG_SP, 0x803F0000)
    uc.reg_write(UC_MIPS_REG_RA, 0x80000080)
    if inputs is None:
        uc.reg_write(UC_MIPS_REG_A0, 0x12345678)
    else:
        for register, address in zip((UC_MIPS_REG_A0, UC_MIPS_REG_A1, UC_MIPS_REG_A2, UC_MIPS_REG_A3), input_addresses):
            uc.reg_write(register, address)
    uc.emu_start(entry, 0, count=200000)
    if not stopped[0]:
        raise ValueError('Surface execution did not return within the instruction limit')
    end = load(0x80138254)
    if not command_start <= end <= command_start + 0x10000:
        raise ValueError('Invalid surface display-list cursor')
    assert read(0x80210000, 48) == original_inputs
    assert [read(vertex_start + base * 16 - 16, 16).hex(),
            read(vertex_start + (base + 128) * 16, 16).hex()] == initial_guards
    state_addresses = (0x80123AE4, 0x80126B84, 0x80123B14, 0x80123B18,
                       0x8007D5D8, 0x800C85B8, 0x80123AE8, 0x80123B00, 0x8007CD8C, 0x8007CD90)
    return dict(trace=trace, commands=read(command_start, end - command_start).hex(),
                vertices=read(vertex_start + base * 16, 128 * 16).hex(),
                guards=[read(vertex_start + base * 16 - 16, 16).hex(), read(vertex_start + (base + 128) * 16, 16).hex()],
                state=[load(address) for address in state_addresses],
                result=uc.reg_read(UC_MIPS_REG_V0) if entry == 0x8003B254 else None)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    retail = []
    candidate = []
    comparisons = {}
    support = []
    support_comparisons = {}
    initialized_support = []
    for name in SURFACES + SUPPORT:
        records = CANDIDATE_BLOCKS if name in SURFACES else MATCHING_BLOCKS
        _, source, start, end = next(block for block in records if block[0] == name)
        block = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                              end - 0x80000000 + 0xC00, target, family='surface-execution', layout=layout)
        directory = ROOT / 'build/surface-execution' / name
        binary = (directory / (name + '.bin')).read_bytes()
        if name in SURFACES:
            candidate.append((start, binary))
            retail.append((start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
            comparisons[name] = block
        else:
            if not block['matches'] or block['different_words']:
                raise ValueError('Surface support does not match: ' + name)
            support.append((start, binary))
            sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
            for owned in source_sections(source):
                if owned['rom'] is not None:
                    data = sections[owned['section']]['bytes']
                    support.append((owned['vram'], data))
                    initialized_support.append(dict(source=source, section=owned['section'], vram=owned['vram'],
                                                    size=len(data), sha256=hashlib.sha256(data).hexdigest()))
            support_comparisons[name] = block
    positions = ((0, 0, 0), (401, -305, 71), (-1, 1, -3), (200000, -200001, 90000))
    matrices = (((32767, 0, 0), (0, 32767, 0), (0, 0, 32767)),
                ((32767, 200, -100), (400, 32767, 50), (-60, 75, 32767)),
                ((-32768, 0, 0), (0, 0, 32767), (0, -32768, 0)))
    allocations = ((0, 0), (7, 0), (9800, 0), (9801, 0), (21872, 21872))
    counts = dict(ring=0, tiles=0, quad=0, service=0)
    digest = hashlib.sha256()

    def check(kind, entry, case, inputs=None, gate=1, selector=0):
        expected = run(retail, entry, support, case, inputs, gate, selector)
        actual = run(candidate, entry, support, case, inputs, gate, selector)
        if actual != expected:
            different = [key for key in expected if expected[key] != actual[key]]
            raise ValueError('Surface behavior differs for ' + repr((kind, case, inputs, gate, selector)) + ': ' + ', '.join(different))
        base, frame_start = case[:2]
        active = inputs is not None or (gate and base - frame_start <= 9800)
        quads = 1 if inputs is not None else ((32 if kind == 'ring' or (kind == 'service' and selector) else 25) if active else 0)
        if not gate and kind == 'service':
            quads = 0
        assert expected['state'][0] == (base + quads * 4 if active else (base if not gate else 0xFFFFFFFF))
        assert expected['state'][1] == base + (quads * 4 if inputs is None else 0)
        assert expected['state'][2:4] == [5 + quads, 9 + quads]
        # At base zero the leading guard also contains the current texture ID.
        assert expected['guards'] == [('00000002' + 'a7' * 12) if base == 0 else 'a7' * 16, 'b8' * 16]
        assert sum(event[0] == '0x80045214' for event in expected['trace']) == quads
        assert sum(event[0] == 'transform' for event in expected['trace']) == quads * 4
        uses_texture = inputs is None and (kind != 'service' or gate)
        tiled = kind == 'tiles' or (kind == 'service' and not selector)
        changed_mode = uses_texture and tiled and case[4] != 1
        packets = 3 if inputs is not None else ((8 + 5 * changed_mode + 8 * (not case[5]) +
                                                (quads * 3 + 7 if quads else 0)) if uses_texture else 0)
        assert len(bytes.fromhex(expected['commands'])) == packets * 8
        assert expected['state'][4] == (1 if uses_texture and tiled else case[4])
        assert expected['state'][5:7] == ([0, 160] if changed_mode else [1, 37])
        assert expected['state'][8:10] == [2, 4 + int(bool(uses_texture and case[6] & 0x2000))]
        vertex_bytes = bytes.fromhex(expected['vertices'])
        texture_extent = 3968 if tiled and inputs is None else 1984
        corners = ((0, 0), (texture_extent, 0), (texture_extent, texture_extent), (0, texture_extent))
        for index in range(quads * 4):
            vertex = vertex_bytes[index * 16:(index + 1) * 16]
            assert struct.unpack('>2h', vertex[8:12]) == corners[index & 3]
            assert vertex[6:8] == b'\xA5\xA5' and vertex[12:16] == b'\xA5\xA5\xA5\xA0'
        assert vertex_bytes[quads * 64:] == b'\xA5' * (128 * 16 - quads * 64)
        if kind == 'service':
            assert expected['result'] == int(bool(gate))
        digest.update(json.dumps([kind, case, inputs, gate, selector, expected], sort_keys=True, separators=(',', ':')).encode())
        counts[kind] += 1
        if sum(counts.values()) % 100 == 0:
            print('Compared', sum(counts.values()), 'surface execution cases.', flush=True)

    for kind, entry in (('ring', 0x800428C0), ('tiles', 0x80042E2C)):
        for allocation, position, matrix, mode, loaded, button in itertools.product(allocations, positions, matrices, (1, 16), (False, True), (0, 0x2000)):
            check(kind, entry, (*allocation, position, matrix, mode, loaded, button))
    vectors = (((1000, 0, 2000), (3000, -4000, 5000), (-6000, 7000, -8000), (9000, -10000, 11000)),
               ((1, -1, 3), (-3, 5, -5), (32767, -32768, 65537), (-65537, 131071, -131072)))
    for allocation, position, matrix, inputs, aliases in itertools.product(allocations[:3], positions, matrices, vectors, ((0, 1, 2, 3), (0, 0, 0, 0), (3, 2, 1, 0))):
        check('quad', 0x80042BDC, (*allocation, position, matrix, 1, True, 0), (inputs, aliases))
    for allocation, position, mode, loaded, gate, selector in itertools.product(allocations, positions[:2], (1, 16), (False, True), (0, 1), (0, 1)):
        check('service', 0x8003B254, (*allocation, position, matrices[0], mode, loaded, 0x2000), gate=gate, selector=selector)
    report = dict(matches=True, cases=sum(counts.values()), counts=counts,
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(), trace_sha256=digest.hexdigest(),
                  target_rom_sha256=hashlib.sha256(target).hexdigest(), comparisons=comparisons,
                  support_comparisons=support_comparisons, initialized_support=initialized_support,
                  compiled_code_sha256={name: hashlib.sha256(data).hexdigest() for name, (_, data) in zip(SURFACES, candidate)},
                  target_code_sha256={name: hashlib.sha256(data).hexdigest() for name, (_, data) in zip(SURFACES, retail)},
                  emulator=dict(package='unicorn', installed_version=version('unicorn'), binding_version=unicorn.__version__),
                  limits=['Thirteen complete matching support units and their owned initialized data execute compiled instructions.',
                          'No callee stubs are used; texture-file cache misses and fatal diagnostics are rejected.',
                          'The checker compares complete vertex buffers, command bytes, call order, per-quad snapshots, counters, input preservation, and guards.',
                          'Only selected controller bits, texture cache hits, graphics modes 1/16, matrices, allocations, and quad-input aliases are covered.',
                          'The renderer candidates remain instruction mismatches, and no RSP/RDP execution or GPU behavior is verified.'])
    path = ROOT / 'build/surface-execution/report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed', report['cases'], 'surface execution cases:', counts, flush=True)


if __name__ == '__main__':
    main()
