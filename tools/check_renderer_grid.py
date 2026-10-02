"""Compare the excluded grid renderer against retail MIPS execution.

Install requirements-analysis.txt and the pinned compiler first. Matrix,
transform, absolute-value, and vertex-pool callees execute freshly compiled
matching code. Mode, texture, and final-state calls use deterministic stubs;
this checks CPU buffers and call order, not RSP/RDP execution.
"""

import hashlib
import itertools
import json
import struct
from importlib.metadata import version
from pathlib import Path

import unicorn
from unicorn import Uc, UC_ARCH_MIPS, UC_MODE_MIPS32, UC_MODE_BIG_ENDIAN, UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn.mips_const import (
    UC_MIPS_REG_A0, UC_MIPS_REG_A1, UC_MIPS_REG_A2, UC_MIPS_REG_A3,
    UC_MIPS_REG_V0, UC_MIPS_REG_V1, UC_MIPS_REG_T0, UC_MIPS_REG_T1,
    UC_MIPS_REG_T2, UC_MIPS_REG_T3, UC_MIPS_REG_T4, UC_MIPS_REG_T5,
    UC_MIPS_REG_T6, UC_MIPS_REG_T7, UC_MIPS_REG_T8, UC_MIPS_REG_T9,
    UC_MIPS_REG_HI, UC_MIPS_REG_LO, UC_MIPS_REG_SP, UC_MIPS_REG_RA,
)
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from rom import ROOT, validate


def signed(value):
    value &= 0xFFFFFFFF
    return value - 0x100000000 if value & 0x80000000 else value


def run(binary, support, case):
    base, frame_start, position, matrix, buffer, matrix_index, texture_changes_view = case
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
        return [signed(x) for x in struct.unpack('>3I', read(address, 12))]

    def store_vector(address, values):
        write(address, struct.pack('>3I', *(v & 0xFFFFFFFF for v in values)))

    def mirror(uc, access, address, size, value, user):
        other = address ^ 0x80000000
        if other < 0x400000 or 0x80000000 <= other < 0x80400000:
            uc.mem_write(other, (value & ((1 << (size * 8)) - 1)).to_bytes(size, 'big'))

    uc.hook_add(UC_HOOK_MEM_WRITE, mirror)
    write(0x800431C0, binary)
    for address, data in support:
        write(address, data)
    command_start = 0x80200000
    vertex_start = 0x800CDBD0
    write(vertex_start, b'\xA5' * (22000 * 16))
    write(vertex_start + base * 16 - 16, b'\xA7' * 16)
    write(vertex_start + (base + 49) * 16, b'\xB8' * 16)
    word(0x80138254, command_start)
    word(0x80126B84, base)
    word(0x80123B20, frame_start)
    word(0x80123AE4, 17)
    word(0x8007D6A8, matrix_index)
    word(0x8007D910, buffer)
    word(0x800C8DFC, 123)
    store_vector(0x800C8BD8 + 0x1C, position)
    for i, row in enumerate(matrix):
        store_vector(0x800CD250 + i * 12, row)
    matrix_address = 0x80126B90 + matrix_index * 128 + buffer * 64
    write(matrix_address, b'\x5A' * 64)
    trace = []
    stopped = [False]
    stub_addresses = (0x8004729C, 0x80042830, 0x80046AD0)
    for address in stub_addresses:
        write(address, bytes.fromhex('03e0000800000000'))
    caller_saved = (UC_MIPS_REG_V0, UC_MIPS_REG_V1, UC_MIPS_REG_A0, UC_MIPS_REG_A1,
                    UC_MIPS_REG_A2, UC_MIPS_REG_A3, UC_MIPS_REG_T0, UC_MIPS_REG_T1,
                    UC_MIPS_REG_T2, UC_MIPS_REG_T3, UC_MIPS_REG_T4, UC_MIPS_REG_T5,
                    UC_MIPS_REG_T6, UC_MIPS_REG_T7, UC_MIPS_REG_T8, UC_MIPS_REG_T9,
                    UC_MIPS_REG_HI, UC_MIPS_REG_LO)

    def callback(uc, address, size, user):
        address |= 0x80000000
        if address == 0x80000080:
            stopped[0] = True
            uc.emu_stop()
            return
        args = [uc.reg_read(r) & 0xFFFFFFFF for r in (UC_MIPS_REG_A0, UC_MIPS_REG_A1, UC_MIPS_REG_A2)]
        if address == 0x8004D4B4:
            trace.append(['transform', vector(args[2]), [vector(args[1] + i * 12) for i in range(3)]])
        elif address == 0x80047D88:
            trace.append(['matrix', vector(args[0] + 40)])
        elif address == 0x80047048:
            trace.append(['allocate', load(0x80126B84), load(0x80123B20)])
        elif address == 0x80047094:
            trace.append(['commit', signed(args[0])])
        elif address == 0x80048DC0:
            trace.append(['allocation-warning'])
        elif address == 0x8004CEF0:
            # Observe each completed vertex before the next absolute-value call.
            trace.append(['absolute', signed(args[0]), hashlib.sha256(read(vertex_start + base * 16, 49 * 16)).hexdigest()])
        elif address in stub_addresses:
            trace.append([hex(address), signed(args[0]) if address != 0x80046AD0 else None])
            if address == 0x80042830 and texture_changes_view:
                store_vector(0x800C8BD8 + 0x1C, [position[0] + 19, position[1] - 27, position[2] + 31])
            for i, register in enumerate(caller_saved):
                uc.reg_write(register, 0x13570000 + i * 0x101)

    uc.hook_add(UC_HOOK_CODE, callback)
    uc.reg_write(UC_MIPS_REG_SP, 0x803FF000)
    uc.reg_write(UC_MIPS_REG_RA, 0x80000080)
    uc.reg_write(UC_MIPS_REG_A0, 77)
    uc.emu_start(0x800431C0, 0x80400000, count=100000)
    if not stopped[0]:
        raise ValueError('Grid execution did not return within the instruction limit')
    end = load(0x80138254)
    if end < command_start or end > command_start + 0x10000:
        raise ValueError('Invalid grid display-list cursor')
    commands = read(command_start, end - command_start)
    vertices = read(vertex_start + base * 16, 49 * 16)
    return dict(trace=trace, commands=commands.hex(), vertices=vertices.hex(),
                guards=[read(vertex_start + base * 16 - 16, 16).hex(),
                        read(vertex_start + (base + 49) * 16, 16).hex()],
                matrix=read(matrix_address, 64).hex(), vertex_base=load(0x80123AE4),
                next_vertex=load(0x80126B84), next_matrix=load(0x8007D6A8))


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    comparison = compare_block('renderer_grid', 'src/game/renderer_setup/grid.c', 0x800431C0,
                               0x43DC0, 0x44530, target, family='grid-execution', layout=layout)
    candidate = (ROOT / 'build/grid-execution/renderer_grid/renderer_grid.bin').read_bytes()
    retail = target[0x43DC0:0x44530]
    support = []
    comparisons = []
    for name in ('frame_transform', 'renderer_matrix_submit', 'fixed_geometry_setup', 'graphics_pool', 'debug_noop'):
        _, source, start, end = next(block for block in MATCHING_BLOCKS if block[0] == name)
        block = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                              end - 0x80000000 + 0xC00, target, family='grid-execution', layout=layout)
        if not block['matches'] or block['different_words']:
            raise ValueError('Grid support code does not match: ' + name)
        comparisons.append(block)
        support.append((start, (ROOT / 'build/grid-execution' / name / (name + '.bin')).read_bytes()))
    positions = ((0, 0, 0), (401, -305, 71), (-1, 1, -3), (200000, -200001, 90000))
    matrices = (((32767, 0, 0), (0, 32767, 0), (0, 0, 32767)),
                ((32767, 200, -100), (400, 32767, 50), (-60, 75, 32767)),
                ((-32768, 0, 0), (0, 0, 32767), (0, -32768, 0)))
    allocations = ((0, 0), (7, 0), (9800, 0), (9801, 0), (21951, 21951))
    digest = hashlib.sha256()
    count = 0
    for case in itertools.product(allocations, positions, matrices, (0, 1), (0, 2), (False, True)):
        allocation, position, matrix, buffer, matrix_index, changes_view = case
        case = (*allocation, position, matrix, buffer, matrix_index, changes_view)
        expected = run(retail, support, case)
        actual = run(candidate, support, case)
        succeeds = allocation[0] - allocation[1] <= 9800
        assert expected['next_matrix'] == matrix_index + 1
        assert expected['next_vertex'] == allocation[0] + (49 if succeeds else 0)
        assert expected['vertex_base'] == (allocation[0] if succeeds else 0xFFFFFFFF)
        assert sum(event[0] == 'absolute' for event in expected['trace']) == (49 if succeeds else 0)
        assert len(bytes.fromhex(expected['commands'])) == (181 if succeeds else 9) * 8
        assert expected['guards'] == ['a7' * 16, 'b8' * 16]
        if succeeds:
            words = list(struct.iter_unpack('>II', bytes.fromhex(expected['commands'])))
            loads = [address for command, address in words if command in (0x0400081F, 0x0404081F)]
            assert len(loads) == 84
            indices = [(address - 0x800CDBD0) // 16 - allocation[0] for address in loads]
            assert min(indices) == 0 and max(indices) + 1 == 48
        if actual != expected:
            differences = [key for key in expected if expected[key] != actual[key]]
            raise ValueError('Grid behavior differs for ' + repr(case) + ': ' + ', '.join(differences))
        digest.update(json.dumps([case, expected], sort_keys=True, separators=(',', ':')).encode())
        count += 1
        if count % 100 == 0:
            print('Compared', count, 'grid execution cases.', flush=True)
    report = dict(matches=True, cases=count, checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  trace_sha256=digest.hexdigest(), target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  target_code_sha256=hashlib.sha256(retail).hexdigest(), compiled_code_sha256=hashlib.sha256(candidate).hexdigest(),
                  comparison=comparison, support_comparisons=comparisons,
                  emulator=dict(package='unicorn', installed_version=version('unicorn'), binding_version=unicorn.__version__),
                  limits=['Mode, texture-cache, and final-state calls use deterministic stubs.',
                          'Matrix, transform, absolute-value, vertex-pool, and diagnostic no-op code execute compiled matching instructions.',
                          'The checker compares call order, per-vertex snapshots, complete vertex/matrix buffers, command bytes, and counters.',
                          'No RSP/RDP command execution or GPU behavior is verified.'])
    path = ROOT / 'build/grid-execution/report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed', count, 'grid execution cases; report:', path.relative_to(ROOT), flush=True)


if __name__ == '__main__':
    main()
