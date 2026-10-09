"""Execute the matching boss constructor and complete actor boundary clamp.

Integer trigonometry and absolute value execute freshly matched source.
Object, allocation, animation and diagnostic boundaries use ABI stubs.
"""

import hashlib
import itertools
import json
import struct
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import SENTINEL, machine, word
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


BOSS, BOUNDARY = 0x8001049C, 0x80018480
ACTOR, POSITION = 0x80201010, 0x80202010
RESOURCE = 0x80203010
SESSION, PLAYERS = 0x800AD138, 0x8009B190
CLOBBER = 0x80000100
SUPPORT = ('object_recovery_fixed_trig', 'short_sine', 'short_cosine',
           'fixed_geometry_setup')
CALLER_SAVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                     ('V0', 'V1', 'A0', 'A1', 'A2', 'A3',
                      'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9'))


def signed(value):
    value &= 0xFFFFFFFF
    return value - 0x100000000 if value & 0x80000000 else value


def divide(first, second):
    assert second != 0 and (first, second) != (-0x80000000, -1)
    result = abs(first) // abs(second)
    return -result if (first < 0) != (second < 0) else result


def absolute(value):
    return signed(-value) if value < 0 else value


def sign(value):
    return -1 if value < 0 else int(value > 0)


def environment(code, support):
    clobber = word(0x3C013F80)
    clobber += b''.join(word(0x44810000 | (i << 11)) for i in range(20))
    clobber += word(0x03E00008) + word(0)
    uc, write, execute = machine(code + [(CLOBBER, clobber)], support)
    uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS,
                 uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | (1 << 29))

    def read(address, size):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, size))

    def finish_call(result=None):
        for index, register in enumerate(CALLER_SAVED):
            uc.reg_write(register, 0xB4560000 + index * 257)
        if result is not None:
            uc.reg_write(regs.UC_MIPS_REG_V0, result)
        uc.reg_write(regs.UC_MIPS_REG_PC, CLOBBER)

    return uc, write, execute, read, finish_call


def run_boundary(code, support, case):
    margin, x, y, diagonal = case
    uc, write, execute, read, finish_call = environment(code, support)
    actor = bytearray((i * 37 + 19) & 255 for i in range(156))
    actor[22:24] = struct.pack('>h', margin)
    actor[28:30] = struct.pack('>h', -17)
    actor[0x70:0x7C] = word(x) + word(y) + word(0x12345678)
    expected = bytearray(actor)
    global_data = b'\xA9' * 16 + word(diagonal) + b'\xB9' * 16
    write(ACTOR - 16, bytes(actor))
    write(0x800BA774, global_data)
    calls, trace = [], []
    changed = 0

    def update(axis, value):
        nonlocal x, y, changed
        if axis == 0:
            x = value
        else:
            y = value
        expected[0x70:0x78] = word(x) + word(y)
        changed = 1
        calls.append([[-17 & 0xFFFFFFFF, ACTOR + 0x60], bytes(expected).hex()])

    for axis in (1, 0):
        value = y if axis else x
        if value <= margin - 30000:
            update(axis, margin - 30000)
        value = y if axis else x
        if value >= 30000 - margin:
            update(axis, 30000 - margin)
    if diagonal:
        limit = 42000 - margin
        if signed(absolute(x) + absolute(y)) > limit:
            ratio = absolute(divide(signed(y << 12), x))
            x = signed(sign(x) * divide(signed(limit << 12), signed(ratio + 4096)))
            y = signed(sign(y) * signed(limit - absolute(x)))
            update(0, x)

    def submit(uc, address, size, user):
        args = [uc.reg_read(register) for register in
                (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1)]
        event = [args, read(ACTOR - 16, 156).hex()]
        assert len(trace) < len(calls) and event == calls[len(trace)], (case, event, calls)
        trace.append(event)
        finish_call()

    uc.hook_add(UC_HOOK_CODE, submit, begin=0x800290B0, end=0x800290B0)
    uc.reg_write(regs.UC_MIPS_REG_A0, ACTOR)
    # Constrain the actual boundary instructions and every guest data access.
    support_code = [(start, end) for name, source, start, end in MATCHING_BLOCKS
                    if name in SUPPORT]
    table_ranges = [(address, address + len(data)) for address, data in support
                    if not any(start <= address < end for start, end in support_code)]
    code_ranges = support_code + [
        (BOUNDARY, BOUNDARY + len(next(data for address, data in code if address == BOUNDARY))),
        (CLOBBER, CLOBBER + 92), (SENTINEL, SENTINEL + 4),
        (0x800290B0, 0x800290B4),
    ]
    stack = (0x802FFF00, 0x80300010)
    canaries = [(stack[0] - 16, b'\xD7' * 16), (stack[1], b'\xE9' * 16)]
    for address, data in canaries:
        write(address, data)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA578ABCD)

    def inside(address, size, ranges):
        address = (address & 0x1FFFFFFF) | 0x80000000
        return any(start <= address and address + size <= end for start, end in ranges)

    def instruction(uc, address, size, user):
        assert not address & 3 and inside(address, 4, code_ranges), (
            'Boundary instruction bounds', case, hex(address))

    def load(uc, access, address, size, value, user):
        assert inside(address, size, [(ACTOR, ACTOR + 124),
                      (0x800BA784, 0x800BA788), stack] + table_ranges), (
            'Boundary read bounds', case, hex(address), size)

    def store(uc, access, address, size, value, user):
        assert inside(address, size, [(ACTOR + 0x60, ACTOR + 0x68), stack]), (
            'Boundary write bounds', case, hex(address), size)

    handles = [uc.hook_add(UC_HOOK_CODE, instruction),
               uc.hook_add(UC_HOOK_MEM_READ, load),
               uc.hook_add(UC_HOOK_MEM_WRITE, store)]
    try:
        execute(BOUNDARY)
    finally:
        for handle in handles:
            uc.hook_del(handle)
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xA578ABCD
    for address, data in canaries:
        assert read(address, len(data)) == data, ('Boundary stack canary', case, hex(address))
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == changed
    assert read(ACTOR - 16, 156) == bytes(expected)
    assert read(0x800BA774, len(global_data)) == global_data
    assert trace == calls
    return dict(actor=bytes(expected).hex(), calls=trace, result=changed)


def run_boss(code, support, case):
    phase, player, animation, maximum, allocation, profile = case
    uc, write, execute, read, finish_call = environment(code, support)
    images = {}

    def region(address, size, salt):
        images[address] = bytearray((i * 37 + salt * 17 + profile * 13) & 255
                                    for i in range(size))

    for address, size, salt in ((SESSION - 16, 328 + 32, 1),
                               (PLAYERS - 16, 3508 * 2 + 32, 2),
                               (ACTOR - 16, 156, 3), (POSITION - 16, 44, 4),
                               (RESOURCE - 16, 124, 5), (0x80097344, 40, 6)):
        region(address, size, salt)

    def put(state, address, data):
        for start, image in state.items():
            if start <= address and address + len(data) <= start + len(image):
                image[address - start:address - start + len(data)] = data
                return
        raise AssertionError(('Write outside guarded regions', hex(address)))

    timestamp = (0, 0x12345678, 0x80000000, 0xFFFFFFFF)[profile]
    movement = (-25601, -1, 0, 25601)[profile]
    scale = (-30001, -1, 0, 30001)[profile]
    value24 = (-1, 0, 25600, 0x7FFFFFFF)[profile]
    for address, value in ((SESSION + 0x30, player), (SESSION + 0x9C, animation),
                           (SESSION + 0xA0, maximum), (ACTOR + 0x24, RESOURCE),
                           (ACTOR + 0x2C, movement), (RESOURCE + 0x0C, scale),
                           (PLAYERS + player * 3508 + 0x24, value24)):
        put(images, address, word(value))
    put(images, ACTOR + 0x0C, struct.pack('>h', -17))
    write(0x8009EFA0, word(timestamp))
    # This constructor selector has one verified retail animation pointer.
    write(0x8007356C, word(0x80073170))
    for address, image in images.items():
        write(address, bytes(image))
    expected = {address: bytearray(image) for address, image in images.items()}
    put(expected, 0x80097354, word(timestamp))
    put(expected, 0x80097358, word(timestamp))
    put(expected, SESSION + 0x84, word(0x8009EA18))
    put(expected, SESSION + 0xB4, word(0x80073170))
    calls, trace = [], []
    fatal = phase >= 0 and allocation == 'failure'
    if phase >= 0:
        if phase == 0:
            calls.append([0x8000F7D8, []])
            animation, maximum = 4, 5
            value24 = 25600
            put(expected, SESSION + 0x9C, word(animation))
            put(expected, SESSION + 0xA0, word(maximum))
            put(expected, PLAYERS + player * 3508 + 0x24, word(value24))
        put(expected, POSITION, word(0) + word(-20000) + word(0))
        calls.append([0x800283D4, [8, 0x8009EA18 + min(animation, 4) * 96 + 4, POSITION]])
        put(expected, SESSION + 0x80, word(0 if fatal else ACTOR))
        if fatal:
            calls.append([0x8001C0D0, [0x8008FB8C]])
        else:
            put(expected, ACTOR + 8, struct.pack('>h', 1024))
            # At angle 1024, func_8003CC88 is zero and func_8003CC58 is 4095.
            put(expected, ACTOR + 0x6C, word(0))
            put(expected, ACTOR + 0x70, word(divide(signed(4095 * movement), 4096)))
            product = signed(scale * 2028)
            numerator = struct.unpack('>f', struct.pack('>f', float(product)))[0]
            scaled = struct.pack('>f', numerator / 40960.0)
            calls.extend([[0x80039514, [-17 & 0xFFFFFFFF, 1024]],
                          [0x800399E4, [-17 & 0xFFFFFFFF, int.from_bytes(scaled, 'big')]],
                          [0x80027AB8, [ACTOR, 8 if phase == 0 else 0, 1]],
                          [0x8000EE48 if animation == maximum else 0x8000EDE0, [ACTOR]]])
            put(expected, ACTOR + 0x68, word(0))
            put(expected, ACTOR + 0x10, (value24 & 0xFFFF).to_bytes(2, 'big'))
            put(expected, SESSION + 0x90, word(1))
    arities = {0x8000F7D8: 0, 0x800283D4: 3, 0x8001C0D0: 1,
               0x80039514: 2, 0x800399E4: 2, 0x80027AB8: 3,
               0x8000EE48: 1, 0x8000EDE0: 1}

    def stub(uc, address, size, user):
        args = [uc.reg_read(register) for register in
                (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2)][:arities[address]]
        event = [address, args]
        assert len(trace) < len(calls) and event == calls[len(trace)], (case, event, calls)
        if address == 0x800283D4:
            assert read(POSITION, 12) == word(0) + word(-20000) + word(0)
        if address in (0x8000EE48, 0x8000EDE0):
            for start, image in expected.items():
                assert read(start, len(image)) == bytes(image), (case, hex(start),
                    [(offset, actual, wanted) for offset, (actual, wanted) in
                     enumerate(zip(read(start, len(image)), image)) if actual != wanted])
        trace.append(event)
        if address == 0x8001C0D0:
            uc.emu_stop()
        else:
            finish_call((0 if fatal else ACTOR) if address == 0x800283D4 else None)

    for address in arities:
        uc.hook_add(UC_HOOK_CODE, stub, begin=address, end=address)
    uc.reg_write(regs.UC_MIPS_REG_A0, 0)
    uc.reg_write(regs.UC_MIPS_REG_A1, POSITION if phase >= 0 else 0x81234000)
    uc.reg_write(regs.UC_MIPS_REG_A2, phase & 0xFFFFFFFF)
    if fatal:
        uc.emu_start(BOSS, 0, count=20000)
        assert uc.reg_read(regs.UC_MIPS_REG_PC) == 0x8001C0D0
    else:
        execute(BOSS)
        assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
        assert uc.reg_read(regs.UC_MIPS_REG_V0) == (0 if phase < 0 else ACTOR)
    assert trace == calls
    for start, image in expected.items():
        assert read(start, len(image)) == bytes(image), (case, hex(start))
    assert read(0x8009EFA0, 4) == word(timestamp)
    assert read(0x8007356C, 4) == word(0x80073170)
    return dict(images={hex(start): bytes(image).hex() for start, image in expected.items()},
                calls=trace, stopped_at_fatal=fatal)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, retail, support, comparisons, tables = [], [], [], {}, {}
    for name in ('early_boss_create', 'actor_boundary_clamp') + SUPPORT:
        _, source, start, end = next(record for record in MATCHING_BLOCKS if record[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target,
                               family='actor-boundary-boss-execution', layout=layout)
        directory = ROOT / 'build/actor-boundary-boss-execution' / name
        data = (directory / (name + '.bin')).read_bytes()
        comparisons[name] = report
        assert report['matches'], name
        if name == 'actor_boundary_clamp':
            assert report['actual_size'] == report['expected_size'] == 600
        if name in ('early_boss_create', 'actor_boundary_clamp'):
            compiled.append((start, data))
            retail.append((start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
        else:
            support.append((start, data))
        sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
        for record in source_sections(source):
            if record['rom'] is not None:
                bytes_ = sections[record['section']]['bytes']
                support.append((record['vram'], bytes_))
                tables[record['section']] = hashlib.sha256(bytes_).hexdigest()
    storage_source = 'src/game/actor_groups/boss_timestamps.c'
    storage = compare_unit(storage_source, source_sections(storage_source), target, layout)
    assert storage['matches']
    counts = dict(boundary=0, boss=0, fatal_boundaries=0, negative_phases=0)
    digest = hashlib.sha256()

    def check(kind, case):
        run = run_boundary if kind == 'boundary' else run_boss
        expected = run(retail, support, case)
        actual = run(compiled, support, case)
        assert actual == expected, (kind, case)
        digest.update(json.dumps([kind, case, actual], sort_keys=True).encode())
        counts[kind] += 1
        if kind == 'boss':
            counts['fatal_boundaries'] += int(actual['stopped_at_fatal'])
            counts['negative_phases'] += int(case[0] < 0)
        if (counts['boundary'] + counts['boss']) % 500 == 0:
            print('Compared actor boundary/boss cases:', counts, flush=True)

    coordinates = (-0x80000000, -65000, -30000, -1, 0, 1, 30000, 65000, 0x7FFFFFFF)
    for case in itertools.product((-32768, -1, 0, 1, 30000, 32767), coordinates, coordinates, (0, 1)):
        check('boundary', case)
    for case in itertools.product((-1, 0, 1, 2), (0, 1), (0, 3, 4, 8),
                                  (4, 5, 8), ('success', 'failure'), range(4)):
        check('boss', case)
    result = dict(matches=True, counts=counts, trace_sha256=digest.hexdigest(),
                  comparisons=comparisons, storage_comparison=storage, table_sha256=tables,
                  target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  machine_helper_sha256=hashlib.sha256((ROOT / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['Four complete matching arithmetic units and their tables execute compiled code.',
                          'Object submission, allocation, reset, animation and diagnostic effects use integer and FPU ABI-clobbering stubs.',
                          'Allocation failures stop at the fatal diagnostic boundary; recovery after a returning fatal diagnostic is not asserted.',
                          'Only selector index zero and its one verified animation pointer are exercised; other resource sets and caller index bounds remain unresolved.',
                          'Signed overflow and negative shifts characterize pinned IDO and MIPS behavior, not portable ISO C.',
                          'The selected boundary inputs do not reach a zero divisor after rectangular clamping; division exception delivery is not exercised.',
                          'The complete 600-byte boundary function matches; boundary instruction, read and write bounds, stack canaries and GP preservation are checked.',
                          'Boss constructor checks compare complete state and surrounding canaries; its machine does not apply the boundary access hooks.',
                          'This checker does not establish complete gameplay behavior.'])
    output = ROOT / 'build/actor-boundary-boss-execution/report.json'
    output.write_text(json.dumps(result, indent=2) + '\n')
    print('Passed actor boundary/boss execution:', counts, output, flush=True)


if __name__ == '__main__':
    main()
