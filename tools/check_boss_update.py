"""Execute the boss update with real matching lighting and guarded call boundaries."""

import hashlib
import itertools
import json
import struct
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL
from check_error_formatters import CALLER_SAVED
from compare_startup import compare_block, SymbolLayoutSnapshot
from compare_runtime import MATCHING_BLOCKS
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


ENTRY, END, STACK = 0x800107A0, 0x80010A3C, 0x80300000
SESSION, PLAYERS = 0x800AD138, 0x8009B190
ACTORS, RESOURCES = (0x80201010, 0x80202010), (0x80203010, 0x80204010)
CLOCK, EFFECT, BURST_TIME, SINGLE_TIME = 0x8009EFA0, 0x80097354, 0x80097344, 0x80097340
BURSTS, SINGLES, VALUE, SPEED = 0x8009734C, 0x80097348, 0x80073588, 0x800736A8
LIGHT = 0x80123B28 + 186 * 16
BOUNDARIES = (0x80009F90, 0x8000F814, 0x8000F030)
INITIALIZERS = bytes.fromhex('00004e2000004e200000000000ff0000ff0000000000ff00')


class Images:
    def __init__(self, seed):
        regions = [(SESSION - 16, 360), (PLAYERS - 16, 7048),
                   (0x80097330, 64), (CLOCK - 16, 36), (VALUE - 16, 36),
                   (SPEED - 16, 32), (LIGHT - 16, 48),
                   (0x8007D5CC, 44), (0x800BA738, 36)]
        regions += [(a - 16, 156) for a in ACTORS]
        regions += [(a - 16, 120) for a in RESOURCES]
        self.images = {a: bytearray((i * 37 + seed) & 255 for i in range(n)) for a, n in regions}

    def locate(self, address, size):
        for start, data in self.images.items():
            if start <= address and address + size <= start + len(data):
                return data, address - start
        raise AssertionError(('Address outside guarded records', hex(address), size))

    def put(self, address, data):
        image, offset = self.locate(address, len(data))
        image[offset:offset + len(data)] = data

    def number(self, address, value):
        self.put(address, word(value))

    def get(self, address, size=4, signed=False):
        image, offset = self.locate(address, size)
        return int.from_bytes(image[offset:offset + size], 'big', signed=signed)

    def digest(self):
        return hashlib.sha256(b''.join(bytes(data) for data in self.images.values())).hexdigest()


def cases():
    # Ready, null actor and nonzero actor state each stop after lighting.
    for gate, light, seed in itertools.product((1, 2, 3, 4), (199, 200, 201), (3, 197)):
        yield gate, 0, 1, 0, 0, 0, 0, seed, light
    for animation, speed, player, health, timing, mutation in itertools.product(
            range(4), (-0x80000000, -32769, -1, 0, 32767, 0x7FFFFFFF),
            (0, 1), range(3), range(12), range(4)):
        yield 0, animation, speed, player, health, timing, mutation, 3 + 194 * player, 200 if timing & 1 else 199


def setup(case):
    gate, animation, speed, player, health, timing, mutation, seed, light = case
    state = Images(seed)
    clock = (0, 0xFFFFFFFF, 0x80000000)[timing % 3]
    # effect difference, disabled, bursts, burst difference, singles, single difference
    timers = [(100, 0, 0, 701, 1, 100), (101, 0, 0, 700, 1, 101),
              (0, 0, 1, 700, 1, 101), (101, 0, 1, 701, 1, 101),
              (0xFFFFFFFF, 0, -1, 0xFFFFFFFF, -1, 0xFFFFFFFF),
              (101, 1, 0, 701, 0, 101), (0, 0, 0, 701, -1, 0xFFFFFFFF),
              (100, 1, -0x80000000, 701, 1, 101),
              (101, 0, 0, 0, -0x80000000, 101),
              (0, 0, 1, 0, 1, 101), (101, 0, 0, 701, 1, 0),
              (0x80000000, 0, 1, 0x80000000, 1, 0x80000000)]
    effect_delta, disabled, bursts, burst_delta, singles, single_delta = timers[timing]
    actor_health, value = [(1, -1), (0, 0), (-32768, 1)][health]
    for address, number in [(SESSION + 0x90, 0 if gate == 1 else -1),
                            (SESSION + 0x80, 0 if gate == 2 else ACTORS[0]),
                            (SESSION + 0x30, player), (SESSION + 0x8C, disabled),
                            (SESSION + 0x9C, 2 if animation & 1 else 3),
                            (CLOCK, clock), (EFFECT, clock - effect_delta),
                            (BURST_TIME, clock - burst_delta), (SINGLE_TIME, clock - single_delta),
                            (BURSTS, bursts), (SINGLES, singles), (VALUE, value),
                            (SPEED, speed), (0x800BA748, light),
                            (0x8007D5DC, -128), (0x8007D5E0, 127), (0x8007D5E4, 255)]:
        state.number(address, number)
    for index, actor in enumerate(ACTORS):
        state.number(actor + 0x24, RESOURCES[index])
        state.put(actor + 0x10, struct.pack('>h', actor_health if index == 0 else -1))
        state.put(actor + 0x1F, bytes([5 if animation & 2 else 4]))
        state.put(actor + 0x21, bytes([1 if gate == 3 else 255 if gate == 4 else 0]))
    return state


def mutate(state, case, address, event_index):
    mutation = case[6]
    if mutation == 1 and address in (0x80009F90, 0x8000F814, 0x8000F030):
        current = state.get(SESSION + 0x80)
        state.number(SESSION + 0x80, ACTORS[1] if current == ACTORS[0] else ACTORS[0])
        state.number(SESSION + 0x30, state.get(SESSION + 0x30) ^ 1)
    elif mutation == 2:
        state.number(CLOCK, state.get(CLOCK) + 701)
        state.number(BURSTS, state.get(BURSTS) + 3)
        state.number(SINGLES, state.get(SINGLES) + 7)
    elif mutation == 3 and address == 0x8000F814:
        state.number(BURSTS, 1)
        state.number(BURST_TIME, state.get(CLOCK) - 701)
        state.number(SESSION + 0x80, ACTORS[1])
        state.number(SESSION + 0x30, state.get(SESSION + 0x30) ^ 1)
    elif mutation == 3 and address == 0x8000F030:
        state.put(state.get(SESSION + 0x80) + 0x10, struct.pack('>h', -1 if event_index & 1 else 1))
        state.number(VALUE, -1)


def oracle(case):
    state = setup(case)
    light_color = (0, 0, 200) if case[-1] == 200 else (250, 235, 35)
    for channel, value in enumerate(light_color):
        byte = min(255, value * 380 >> 8)
        state.put(LIGHT + channel, bytes([byte]))
        state.put(LIGHT + 4 + channel, bytes([byte]))
    state.put(LIGHT + 8, bytes([128, 127, 255]))
    events = []

    def event(address, args):
        events.append((address, [value & 0xFFFFFFFF for value in args], state.digest()))
        mutate(state, case, address, len(events) - 1)

    actor = state.get(SESSION + 0x80)
    if state.get(SESSION + 0x90) and actor and not state.get(actor + 0x21, 1):
        speed = state.get(SPEED)
        if state.get(actor + 0x1F, 1) == 5 and state.get(SESSION + 0x9C) == 2:
            speed *= 3
        state.put(state.get(actor + 0x24) + 0x50, (speed & 0xFFFF).to_bytes(2, 'big'))
        if not state.get(SESSION + 0x8C) and (state.get(CLOCK) - state.get(EFFECT)) & 0xFFFFFFFF > 100:
            state.number(EFFECT, state.get(CLOCK))
            event(0x80009F90, [state.get(SESSION + 0x80), 0])
        event(0x8000F814, [state.get(SESSION + 0x80)])
        if state.get(BURSTS):
            if (state.get(CLOCK) - state.get(BURST_TIME)) & 0xFFFFFFFF > 700:
                state.number(BURST_TIME, state.get(CLOCK))
                for index in range(10):
                    event(0x8000F030, [state.get(SESSION + 0x80), index, 4])
                state.number(BURSTS, state.get(BURSTS) - 1)
        elif state.get(SINGLES) and (state.get(CLOCK) - state.get(SINGLE_TIME)) & 0xFFFFFFFF > 100:
            state.number(SINGLE_TIME, state.get(CLOCK))
            event(0x8000F030, [state.get(SESSION + 0x80), 5, 9])
            state.number(SINGLES, state.get(SINGLES) - 1)
        actor = state.get(SESSION + 0x80)
        health = state.get(actor + 0x10, 2, True)
        state.number(PLAYERS + state.get(SESSION + 0x30) * 3508 + 0x24, health)
        if health <= 0 and state.get(VALUE, signed=True) <= 0:
            state.number(SESSION + 0x90, 0)
    return state, events


def run(code, support, case):
    state = setup(case)
    expected, events = oracle(case)
    uc, write, execute = machine(code, support)
    for start, image in state.images.items():
        write(start, bytes(image))
    write(STACK - 0x100, b'\xA5' * 0x120)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA1234000)
    trace = []

    def read(address, size):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, size))

    def boundary(uc, address, size, user):
        count = {0x80009F90: 2, 0x8000F814: 1, 0x8000F030: 3}[address]
        arguments = [uc.reg_read(getattr(regs, 'UC_MIPS_REG_A' + str(i))) for i in range(count)]
        for start, image in state.images.items():
            image[:] = read(start, len(image))
        actual = (address, arguments, state.digest())
        assert len(trace) < len(events) and actual == events[len(trace)], (case, actual, events)
        mutate(state, case, address, len(trace))
        trace.append(actual)
        for start, image in state.images.items():
            write(start, bytes(image))
        resume = uc.reg_read(regs.UC_MIPS_REG_RA)
        for index, register in enumerate(CALLER_SAVED):
            uc.reg_write(register, 0xB4560000 + index * 257)
        uc.reg_write(regs.UC_MIPS_REG_PC, resume)

    def guard(uc, access, address, size, value, user):
        address = address | 0x80000000
        frame = STACK - 0x50
        assert any(frame + first <= address and address + size <= frame + last
                   for first, last in ((0x18, 0x28), (0x30, 0x48))) or any(
            start <= address and address + size <= start + len(image)
            for start, image in state.images.items()), (case, hex(address), size)

    for address in BOUNDARIES:
        uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)
    uc.hook_add(UC_HOOK_MEM_WRITE, guard)
    execute(ENTRY)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xA1234000
    assert trace == events
    for start, image in expected.images.items():
        assert read(start, len(image)) == bytes(image), (case, hex(start))
    frame = STACK - 0x50
    assert read(frame + 0x30, 0x18) == INITIALIZERS[20:24] + INITIALIZERS[16:20] + INITIALIZERS[12:16] + INITIALIZERS[:12]
    assert read(frame + 0x48, 8) == b'\xA5' * 8
    assert read(frame, 0x18) == b'\xA5' * 0x18
    assert read(frame + 0x28, 8) == b'\xA5' * 8
    assert read(STACK - 0x100, 0xB0) == b'\xA5' * 0xB0
    assert read(STACK, 0x20) == b'\xA5' * 0x20
    for address, data in code + support:
        assert read(address, len(data)) == data
    return expected.digest(), trace


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    comparisons, support, caller = {}, [], None
    for name in ('boss_update', 'graphics_lights'):
        _, source, start, end = next(record for record in MATCHING_BLOCKS if record[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target,
                               family='boss-update-execution', layout=layout)
        assert report['matches'], report
        comparisons[name] = report
        directory = ROOT / 'build/boss-update-execution' / name
        data = (directory / (name + '.bin')).read_bytes()
        if name == 'boss_update':
            caller = (start, data)
        else:
            support.append((start, data))
        sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
        for record in source_sections(source):
            if record['rom'] is not None:
                support.append((record['vram'], sections[record['section']]['bytes']))
    assert next(data for address, data in support if address == 0x800736B8) == INITIALIZERS
    retail = [(ENTRY, target[0x113A0:0x1163C])]
    count, digest = 0, hashlib.sha256()
    for case in cases():
        expected = run(retail, support, case)
        actual = run([caller], support, case)
        assert actual == expected
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
        count += 1
        if count % 1000 == 0:
            print('Compared guarded boss update cases:', count, flush=True)
    result = dict(matches=True, cases=count, trace_sha256=digest.hexdigest(), comparisons=comparisons,
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  machine_helper_sha256=hashlib.sha256((ROOT / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
                  target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['Complete matching lighting code executes real C, including color scaling and direction writes.',
                          'Effect creation, trigger dispatch and queued spawn use ABI-clobbering integer-register boundary stubs.',
                          'Synthetic boundary mutations test shared actor, player, clock and counter reloads; they do not establish actual callee side effects.',
                          'Integer wrap and signed narrowing describe pinned IDO/MIPS behavior rather than portable ISO C.',
                          'Invalid required pointers, complete gameplay and floating-point register preservation are not established.',
                          'The unused eight-byte stack view preserves measured storage but does not recover its original declaration or purpose.'])
    output = ROOT / 'build/boss-update-execution/report.json'
    output.write_text(json.dumps(result, indent=2) + '\n')
    print('Passed guarded boss update execution:', count, output, flush=True)


if __name__ == '__main__':
    main()
