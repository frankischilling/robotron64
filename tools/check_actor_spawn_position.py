"""Check the complete spawn chooser with real absolute value and a guarded RNG stub."""

import hashlib
import itertools
import json
from importlib.metadata import version

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL
from check_error_formatters import CALLER_SAVED
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from rom import ROOT, validate


ENTRY, END, STACK = 0x80027ED4, 0x8002818C, 0x80300000
OUTPUT, HEAD, ACTORS = 0x80210010, 0x800AA708, tuple(0x80220010 + i * 0x100 for i in range(4))
RNG, ABSOLUTE = 0x8004CDE8, 0x8004CEF0
STREAMS = ((0,), (-8,), (0x7FFFFFFF,), (-0x80000000,),
           (0, 0, 1024, 2040), (0, 0, 1032, 1032),
           (2040, -2048, 2048, -8), (0, 0, 0, 0, 8000, -16000, 1032, 1024))


def signed(value):
    return ((value + 0x80000000) & 0xFFFFFFFF) - 0x80000000


def divide(value, divisor):
    return abs(value) // abs(divisor) * (-1 if (value < 0) != (divisor < 0) else 1)


def remainder(value, divisor):
    return value - divide(value, divisor) * divisor


class Images:
    def __init__(self, seed):
        self.regions = {OUTPUT - 16: bytearray((seed + i * 29) & 255 for i in range(44)),
                        HEAD - 16: bytearray((seed + i * 31) & 255 for i in range(44))}
        self.regions.update({a - 16: bytearray((seed + i * 37) & 255 for i in range(156)) for a in ACTORS})

    def put(self, address, data):
        for start, image in self.regions.items():
            if start <= address and address + len(data) <= start + len(image):
                image[address - start:address - start + len(data)] = data
                return
        raise AssertionError(('Write outside guarded storage', hex(address)))

    def number(self, address, value):
        self.put(address, word(value))

    def get(self, address, size=4, is_signed=False):
        for start, image in self.regions.items():
            if start <= address and address + size <= start + len(image):
                return int.from_bytes(image[address - start:address - start + size], 'big', signed=is_signed)
        raise AssertionError(('Read outside guarded storage', hex(address)))

    def digest(self):
        return hashlib.sha256(b''.join(self.regions.values())).hexdigest()


def generate(stream, cursor, constrained):
    values = []
    for unused in range(4 if constrained else 2):
        values.append(signed(stream[cursor % len(stream)]))
        cursor += 1
    point = [remainder(v >> 3, 3000) * 18 - 27000 for v in values[:2]] + [0]
    if constrained:
        axis = 0 if remainder(values[2] >> 3, 256) > 128 else 1
        point[axis] = 0 if remainder(values[3] >> 3, 256) > 128 else 60000
    return point, cursor


def setup(case):
    constrained, spacing, stream_index, layout, alias = case
    state = Images(19 + stream_index * 23 + layout)
    point, unused = generate(STREAMS[stream_index], 0, constrained)
    arrangements = [[], [(1, 200000, 200000)], [(1, 0, 0)],
                    [(1, 2999, 3000)], [(1, 3000, 0)], [(2, 0, 0)],
                    [(2, 9000, 0)], [(1, 0, 0), (2, 0, 0), (255, 0, 0), (2, 0, 0)],
                    [(1, -0x80000000, 0)], [(2, -0x80000000, -0x80000000)]]
    records = arrangements[layout]
    state.number(HEAD, ACTORS[0] if records else 0)
    for i, address in enumerate(ACTORS):
        kind, dx, dy = records[i] if i < len(records) else (253, 200000, -200000)
        state.put(address + 0x1C, bytes([kind]))
        state.number(address + 0x60, point[0] + dx)
        state.number(address + 0x64, point[1] + dy)
        state.number(address + 0x78, ACTORS[i + 1] if i + 1 < len(records) else 0)
    output = (OUTPUT, ACTORS[0] + 0x60, HEAD, 0)[alias]
    return state, output


def oracle(case):
    constrained, spacing, stream_index, unused, unused_alias = case
    state, output = setup(case)
    cursor = 0
    remaining = 100
    trace = []
    while True:
        point, next_cursor = generate(STREAMS[stream_index], cursor, constrained)
        for i in range(cursor, next_cursor):
            trace.append([signed(STREAMS[stream_index][i % len(STREAMS[stream_index])]) & 0xFFFFFFFF,
                          state.digest()])
        cursor = next_cursor
        accepted = True
        actor = state.get(HEAD) if spacing else 0
        minimum_x = minimum_y = 3000
        while actor:
            if state.get(actor + 0x1C, 1) == 2:
                factor = divide(signed(spacing * 30), 10)
                minimum_x = signed(minimum_x * factor)
                minimum_y = signed(minimum_y * factor)
            dx = signed(point[0] - state.get(actor + 0x60, is_signed=True))
            dy = signed(point[1] - state.get(actor + 0x64, is_signed=True))
            absolute_x = signed(-dx) if dx < 0 else dx
            absolute_y = signed(-dy) if dy < 0 else dy
            if absolute_x < minimum_x and absolute_y < minimum_y:
                remaining -= 1
                accepted = False
                if remaining == 0:
                    return state, 0, trace
            if state.get(actor + 0x1C, 1) == 2:
                minimum_x = minimum_y = 3000
            actor = state.get(actor + 0x78)
        if accepted:
            assert output != 0, 'Null outputs are tested only on failure'
            state.put(output, b''.join(word(v) for v in point))
            return state, 1, trace


def run_case(code, support, case):
    state, output = setup(case)
    expected, returned, trace = oracle(case)
    uc, write, unused_execute = machine(code, support)
    for address, data in state.regions.items():
        write(address, bytes(data))
    stack_start = STACK - 0x100
    stack_seed = bytes((i * 43 + 17) & 255 for i in range(0x160))
    write(stack_start, stack_seed)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xAC501234)
    saved = {getattr(regs, 'UC_MIPS_REG_' + n): uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + n))
             for n in ('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP')}
    calls = [0]
    touched = set()

    def rng_boundary(uc, address, size, user):
        assert calls[0] < len(trace), ('Unexpected RNG call', case, calls[0])
        value, digest = trace[calls[0]]
        actual = hashlib.sha256(b''.join(bytes(uc.mem_read(a & 0x1FFFFFFF, len(b)))
                                        for a, b in state.regions.items())).hexdigest()
        assert actual == digest, ('Unexpected pre-return memory change', case, calls[0])
        calls[0] += 1
        for i, register in enumerate(CALLER_SAVED):
            uc.reg_write(register, 0xBD450000 + i * 256)
        uc.reg_write(regs.UC_MIPS_REG_V0, value)
        uc.reg_write(regs.UC_MIPS_REG_PC, uc.reg_read(regs.UC_MIPS_REG_RA))

    def guard_write(uc, access, address, size, value, user):
        address |= 0x80000000
        allowed = [(STACK - 0x68 + 0x18, STACK - 0x68 + 0x40),
                   (STACK - 0x68 + 0x4C, STACK - 0x68 + 0x58), (STACK, STACK + 8)]
        if returned:
            allowed.append((output, output + 12))
        assert any(a <= address and address + size <= b for a, b in allowed), ('Unexpected write', case, hex(address), size)
        touched.update(range(address, address + size))

    uc.hook_add(UC_HOOK_CODE, rng_boundary, begin=RNG, end=RNG)
    uc.hook_add(UC_HOOK_MEM_WRITE, guard_write)
    uc.reg_write(regs.UC_MIPS_REG_A0, output)
    uc.reg_write(regs.UC_MIPS_REG_A1, case[0] & 0xFFFFFFFF)
    uc.reg_write(regs.UC_MIPS_REG_A2, case[1] & 0xFFFFFFFF)
    uc.emu_start(ENTRY, 0, count=200000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, ('Instruction limit', case)
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == returned and calls[0] == len(trace)
    assert uc.reg_read(regs.UC_MIPS_REG_SP) == STACK and uc.reg_read(regs.UC_MIPS_REG_GP) == 0xAC501234
    assert all(uc.reg_read(r) == value for r, value in saved.items())
    for address, data in expected.regions.items():
        assert bytes(uc.mem_read(address & 0x1FFFFFFF, len(data))) == bytes(data), ('Oracle memory mismatch', case, hex(address))
    stack = bytes(uc.mem_read(stack_start & 0x1FFFFFFF, len(stack_seed)))
    assert all(value == stack_seed[i] for i, value in enumerate(stack) if stack_start + i not in touched)
    return returned, len(trace), expected.digest()


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    support = []
    reports = {}
    for name in ('actor_spawn_position', 'fixed_geometry_setup'):
        unused, source, start, end = next(b for b in MATCHING_BLOCKS if b[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target,
                               family='spawn-position-execution', layout=layout)
        assert report['matches'], report
        reports[name] = report
        directory = ROOT / 'build/spawn-position-execution' / name
        binary = (directory / (name + '.bin')).read_bytes()
        assert len(binary) == end - start
        if name == 'actor_spawn_position':
            compiled = [(start, binary)]
            retail = [(start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00])]
        else:
            support.append((start, binary))
    cases = list(itertools.product((0, 1, -1), (-0x80000000, -3, -1, 0, 1, 2, 23, 0x7FFFFFFF),
                                   range(len(STREAMS)), range(10), range(3)))
    cases += [(0, spacing, stream, 2, 3) for spacing, stream in itertools.product((1, 2), (0, 1, 2, 3))]
    counts = dict(cases=len(cases), success=0, failure=0, null_output_failures=0)
    digest = hashlib.sha256()
    for i, case in enumerate(cases):
        original = run_case(retail, support, case)
        assert run_case(compiled, support, case) == original
        counts['success' if original[0] else 'failure'] += 1
        counts['null_output_failures'] += case[4] == 3
        digest.update(json.dumps([case, original], separators=(',', ':')).encode())
        if (i + 1) % 512 == 0:
            print('Spawn-position guarded cases:', i + 1, flush=True)
    proof = dict(matches=True, comparisons=reports, counts=counts, trace_sha256=digest.hexdigest(),
                 target_rom_sha256=hashlib.sha256(target).hexdigest(),
                 checker_sha256=hashlib.sha256((ROOT / 'tools/check_actor_spawn_position.py').read_bytes()).hexdigest(),
                 machine_helper_sha256=hashlib.sha256((ROOT / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
                 emulator='Unicorn ' + version('unicorn'),
                 limits=['RNG is a deterministic ABI stub; its actual generator and full-game spawning are outside this proof.',
                         'The complete matching absolute-value support unit executes real compiled code, including INT_MIN negation.',
                         'Input/output/actor guards, aliasing to actor position or head storage, unchanged failure output, complete stack write ranges and saved integer registers are checked.',
                         'Invalid successful output pointers, cycles, concurrent list mutation and floating-register preservation are not established.'])
    (ROOT / 'build/spawn-position-execution/report.json').write_text(json.dumps(proof, indent=2) + '\n')
    print('All spawn-position guarded cases passed:', counts, flush=True)


if __name__ == '__main__':
    main()
