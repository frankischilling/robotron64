"""Compare the excluded projectile trail and heap initializer under MIPS execution.

Install optional analysis dependencies and the pinned compiler, then run this
script from the repository. Supporting calls are deterministic stubs; this is
a behavior comparison for the listed cases, not an instruction match or GPU test.
"""

import hashlib
import itertools
import json
import struct

from importlib.metadata import version
from rom import ROOT, validate
from compare_startup import compare_block, SymbolLayoutSnapshot
import unicorn

from unicorn import (Uc, UC_ARCH_MIPS, UC_MODE_MIPS32, UC_MODE_BIG_ENDIAN,
                     UC_HOOK_CODE, UC_HOOK_MEM_WRITE)
from unicorn.mips_const import (
    UC_MIPS_REG_A0, UC_MIPS_REG_A1, UC_MIPS_REG_A2, UC_MIPS_REG_A3,
    UC_MIPS_REG_V0, UC_MIPS_REG_V1, UC_MIPS_REG_T0, UC_MIPS_REG_T1,
    UC_MIPS_REG_T2, UC_MIPS_REG_T3, UC_MIPS_REG_T4, UC_MIPS_REG_T5,
    UC_MIPS_REG_T6, UC_MIPS_REG_T7, UC_MIPS_REG_T8, UC_MIPS_REG_T9,
    UC_MIPS_REG_S0, UC_MIPS_REG_S1, UC_MIPS_REG_S2, UC_MIPS_REG_S3,
    UC_MIPS_REG_S4, UC_MIPS_REG_S5, UC_MIPS_REG_S6, UC_MIPS_REG_S7,
    UC_MIPS_REG_FP, UC_MIPS_REG_HI, UC_MIPS_REG_LO, UC_MIPS_REG_SP,
    UC_MIPS_REG_RA, UC_MIPS_REG_PC,
)

def signed(value):
    value &= 0xFFFFFFFF
    return value - 0x100000000 if value & 0x80000000 else value

def run(binary, case):
    timing, history_count, lifetime, slot, visible, occupied, allocation = case
    uc = Uc(UC_ARCH_MIPS, UC_MODE_MIPS32 | UC_MODE_BIG_ENDIAN)
    uc.mem_map(0, 0x400000)
    uc.mem_map(0x80000000, 0x400000)
    def write(address, payload):
        address &= 0x1FFFFFFF
        uc.mem_write(address, payload)
        uc.mem_write(address | 0x80000000, payload)
    def read(address, length):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, length))
    def word(address, value): write(address, struct.pack('>I', value & 0xFFFFFFFF))
    def load(address): return struct.unpack('>I', read(address, 4))[0]
    def vector(address): return [signed(x) for x in struct.unpack('>3I', read(address, 12))]
    def store_vector(address, values): write(address, struct.pack('>3I', *(v & 0xFFFFFFFF for v in values)))
    def mirror(uc, access, address, size, value, user):
        other = address ^ 0x80000000
        if other < 0x400000 or 0x80000000 <= other < 0x80400000:
            uc.mem_write(other, (value & ((1 << (size * 8)) - 1)).to_bytes(size, 'big'))
    uc.hook_add(UC_HOOK_MEM_WRITE, mirror)

    write(0x8004E364, binary)
    actor = 0x80200000
    history = 0x8013EC00 + slot * 16 * 12
    word(actor + 0x54, history)
    word(actor + 0x48, lifetime)
    word(actor + 0x4C, history_count)
    write(actor + 0x0C, struct.pack('>H', 17))
    word(0x8009EF94, timing)
    write(0x8008D494 + slot, bytes([occupied]))
    store_vector(0x800C8BD8 + 0x1C, [401, -305, 71])
    rows = [[32767, 200, -100], [400, 32767, 50], [-60, 75, 32767]]
    for i, row in enumerate(rows): store_vector(0x800CD250 + i * 12, row)
    for i in range(16): store_vector(history + i * 12, [i * 163 - 900, (i % 5) * 117 - 241, 43 * i + 5])
    word(0x80123AE4, 3)
    word(0x80123AE8, 19)
    trace = []
    stopped = [False]
    return_address = 0x80000080
    stubs = (0x80039E3C, 0x8004729C, 0x80047048, 0x8004DB34, 0x80047D88,
             0x8003C14C, 0x8004D4B4, 0x8000A200, 0x8000B06C, 0x80047094)
    stub_code = bytes.fromhex('03e0000800000000')
    for address in stubs: write(address, stub_code)
    def callback(uc, address, size, user):
        address = address | 0x80000000
        if address == return_address:
            stopped[0] = True
            uc.emu_stop()
            return
        args = [uc.reg_read(r) & 0xFFFFFFFF for r in (UC_MIPS_REG_A0, UC_MIPS_REG_A1, UC_MIPS_REG_A2, UC_MIPS_REG_A3)]
        result = 0
        if address == 0x80039E3C:
            trace.append(['visible', signed(args[0])])
            result = visible
        elif address == 0x8004729C:
            trace.append(['mode', signed(args[0])])
        elif address == 0x80047048:
            trace.append(['allocate'])
            result = allocation
        elif address == 0x8004DB34:
            for i in range(3): store_vector(args[0] + i * 12, [32767 if i == j else 0 for j in range(3)])
            trace.append(['identity'])
        elif address == 0x80047D88:
            trace.append(['matrix', vector(args[0] + 40), [vector(args[1] + i * 12) for i in range(3)]])
        elif address == 0x8003C14C:
            write(args[0], bytes([37, 79, 151, 201]))
            trace.append(['palette', signed(args[1])])
        elif address == 0x8004D4B4:
            values = vector(args[2])
            matrix = [vector(args[1] + i * 12) for i in range(3)]
            output = [signed(sum(signed(values[j] * row[j]) >> 15 for j in range(3))) for row in matrix]
            store_vector(args[0], output)
            trace.append(['transform', values, output])
        elif address == 0x8000A200:
            trace.append(['color', *[signed(x) for x in args[:3]]])
        elif address == 0x8000B06C:
            trace.append(['quad', *[vector(x) for x in args]])
            word(0x80123AE4, load(0x80123AE4) + 4)
        elif address == 0x80047094:
            trace.append(['release', signed(args[0])])
        else:
            raise AssertionError(hex(address))
        # Exercise the ABI: no callback preserves caller-saved integer registers.
        registers = (UC_MIPS_REG_V0, UC_MIPS_REG_V1, UC_MIPS_REG_A0, UC_MIPS_REG_A1,
                     UC_MIPS_REG_A2, UC_MIPS_REG_A3, UC_MIPS_REG_T0, UC_MIPS_REG_T1,
                     UC_MIPS_REG_T2, UC_MIPS_REG_T3, UC_MIPS_REG_T4, UC_MIPS_REG_T5,
                     UC_MIPS_REG_T6, UC_MIPS_REG_T7, UC_MIPS_REG_T8, UC_MIPS_REG_T9)
        for i, register in enumerate(registers): uc.reg_write(register, 0xA1500000 + i * 0x111)
        uc.reg_write(UC_MIPS_REG_V0, result & 0xFFFFFFFF)
        uc.reg_write(UC_MIPS_REG_HI, 0xABCDE123)
        uc.reg_write(UC_MIPS_REG_LO, 0x76543210)
    for address in (*stubs, return_address):
        uc.hook_add(UC_HOOK_CODE, callback, begin=address, end=address)
    saved_registers = (UC_MIPS_REG_S0, UC_MIPS_REG_S1, UC_MIPS_REG_S2,
                       UC_MIPS_REG_S3, UC_MIPS_REG_S4, UC_MIPS_REG_S5,
                       UC_MIPS_REG_S6, UC_MIPS_REG_S7, UC_MIPS_REG_FP)
    initial_saved = {register: 0x19840000 + i * 0x1100
                     for i, register in enumerate(saved_registers)}
    for register, value in initial_saved.items(): uc.reg_write(register, value)
    uc.reg_write(UC_MIPS_REG_A0, actor)
    uc.reg_write(UC_MIPS_REG_SP, 0x80300000)
    uc.reg_write(UC_MIPS_REG_RA, return_address)
    uc.emu_start(0x8004E364, 0x8004E7D4, count=20000)
    assert stopped[0], ('did not return', case, hex(uc.reg_read(UC_MIPS_REG_PC)))
    assert uc.reg_read(UC_MIPS_REG_SP) == 0x80300000
    assert all(uc.reg_read(register) == value for register, value in initial_saved.items())
    return dict(result=signed(uc.reg_read(UC_MIPS_REG_V0)), trace=trace,
                vertices=load(0x80123AE4), alpha=load(0x80123AE8),
                history_sha256=hashlib.sha256(read(history, 16 * 12)).hexdigest())

def run_heap(binary, start, end):
    uc = Uc(UC_ARCH_MIPS, UC_MODE_MIPS32 | UC_MODE_BIG_ENDIAN)
    uc.mem_map(0, 0x400000)
    uc.mem_map(0x80000000, 0x400000)
    def write(address, payload):
        uc.mem_write(address & 0x1FFFFFFF, payload)
        uc.mem_write(address | 0x80000000, payload)
    writes = []
    def mirror(uc, access, address, size, value, user):
        address &= 0x1FFFFFFF
        value &= (1 << (size * 8)) - 1
        writes.append([hex(address | 0x80000000), size, hex(value)])
        uc.mem_write(address, value.to_bytes(size, 'big'))
        uc.mem_write(address | 0x80000000, value.to_bytes(size, 'big'))
    uc.hook_add(UC_HOOK_MEM_WRITE, mirror)
    write(0x8004DE8C, binary)
    base = 0x80204000
    write(base, bytes([0x5A]) * 0x500)
    write(0x8013EBF0, bytes.fromhex('deadbeef'))
    stopped = [False]
    def stop(uc, address, size, user):
        stopped[0] = True
        uc.emu_stop()
    uc.hook_add(UC_HOOK_CODE, stop, begin=0x80000080, end=0x80000080)
    uc.reg_write(UC_MIPS_REG_A0, start)
    uc.reg_write(UC_MIPS_REG_A1, end)
    uc.reg_write(UC_MIPS_REG_SP, 0x80300000)
    uc.reg_write(UC_MIPS_REG_RA, 0x80000080)
    saved = (UC_MIPS_REG_S0, UC_MIPS_REG_S1, UC_MIPS_REG_S2, UC_MIPS_REG_S3,
             UC_MIPS_REG_S4, UC_MIPS_REG_S5, UC_MIPS_REG_S6, UC_MIPS_REG_S7, UC_MIPS_REG_FP)
    initial = {register: 0xA2340000 + i * 0x100 for i, register in enumerate(saved)}
    for register, value in initial.items(): uc.reg_write(register, value)
    uc.emu_start(0x8004DE8C, 0x8004DED8, count=500)
    assert stopped[0] and uc.reg_read(UC_MIPS_REG_SP) == 0x80300000
    assert all(uc.reg_read(register) == value for register, value in initial.items())
    return dict(writes=writes,
                first_block=bytes(uc.mem_read(0x13EBF0, 4)).hex(),
                arena_sha256=hashlib.sha256(uc.mem_read(base & 0x1FFFFFFF, 0x500)).hexdigest())


def main():
    target_rom = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target_rom)
    target = target_rom[0x4EF64:0x4F3D4]
    comparison = compare_block('actor_history_trail', 'src/game/actor_history/trail.c',
                               0x8004E364, 0x4EF64, 0x4F3D4, target_rom,
                               family='trail-execution', layout=SymbolLayoutSnapshot())
    candidate = (ROOT / 'build/trail-execution/actor_history_trail/actor_history_trail.bin').read_bytes()
    cases = itertools.product((0, 1, 2, 29, 81, 401, 0xFFFFFFFF), (-1, 0, 1, 2, 3, 15, 16, 17, 31, 128),
                              (20, 21, 180), (0, 5, 23), (0, 1), (0, 1), (-1, 16))
    aggregate = hashlib.sha256()
    count = 0
    statuses = {}
    for case in cases:
        expected = run(target, case)
        actual = run(candidate, case)
        assert actual == expected, dict(case=case, expected=expected, actual=actual)
        aggregate.update(json.dumps([case, actual], sort_keys=True).encode())
        statuses[str(actual['result'])] = statuses.get(str(actual['result']), 0) + 1
        count += 1
        if count % 500 == 0: print('Compared', count, 'trail execution cases.', flush=True)
    heap_comparison = compare_block('heap_initialize', 'src/game/heap/initialize.c',
                                    0x8004DE8C, 0x4EA8C, 0x4EAD8, target_rom,
                                    family='trail-execution', layout=SymbolLayoutSnapshot())
    heap_target = target_rom[0x4EA8C:0x4EAD8]
    heap_candidate = (ROOT / 'build/trail-execution/heap_initialize/heap_initialize.bin').read_bytes()
    heap_aggregate = hashlib.sha256()
    heap_count = 0
    for start_offset, end_offset, capacity in itertools.product(range(8), range(8), (16, 20, 64, 1024)):
        start = 0x80204000 + start_offset
        end = 0x80204000 + capacity + end_offset
        expected = run_heap(heap_target, start, end)
        actual = run_heap(heap_candidate, start, end)
        assert actual == expected, dict(start=start, end=end, expected=expected, actual=actual)
        heap_aggregate.update(json.dumps([start, end, actual], sort_keys=True).encode())
        heap_count += 1
    result = dict(matches=True, checker_sha256=hashlib.sha256((ROOT / 'tools/check_projectile_trail.py').read_bytes()).hexdigest(), cases=count, return_counts=statuses, trace_sha256=aggregate.hexdigest(),
                  target_rom_sha256=hashlib.sha256(target_rom).hexdigest(),
                  target_code_sha256=hashlib.sha256(target).hexdigest(),
                  compiled_code_sha256=hashlib.sha256(candidate).hexdigest(),
                  comparison=comparison,
                  heap=dict(matches=True, cases=heap_count, comparison=heap_comparison,
                            target_code_sha256=hashlib.sha256(heap_target).hexdigest(),
                            compiled_code_sha256=hashlib.sha256(heap_candidate).hexdigest(),
                            trace_sha256=heap_aggregate.hexdigest(),
                            scope='Complete ordered memory writes for the listed valid arena bounds; no callee stubs.'),
                  emulator=dict(name='Unicorn', package_version=version('unicorn'), binding_version=unicorn.__version__, mode='MIPS32 big endian'),
                  limits=['Supporting callees use deterministic stubs with integer ABI clobbers.',
                          'This validates the listed return values, calls, geometry, colors, and vertex accounting only.',
                          'It does not establish instruction matching, GPU execution, or full-game behavior.'])
    (ROOT / 'build/trail-execution/report.json').write_text(json.dumps(result, indent=2) + '\n')
    print('Passed', count, 'trail and', heap_count, 'heap execution cases; report: build/trail-execution/report.json', flush=True)


if __name__ == "__main__":
    main()
