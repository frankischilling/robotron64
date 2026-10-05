"""Execute the complete collision-kind handler with guarded state and ABI checks."""

import hashlib
import itertools
import json
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UC_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_boundary_boss import CLOBBER, environment, signed
from check_actor_collision_followup import State
from check_actor_group_path import SENTINEL, word
from check_boss_trigger import (FPU_BITS, FPU_OUT, READ_FPU, SEED_FPU,
                               fpu_code, pattern, fingerprint)
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


ENTRY, CONTACT, ABSOLUTE = 0x80016950, 0x80015614, 0x8004CEF0
SEPARATE, RETIRE, TURN = 0x80018CC8, 0x8001B4F8, 0x8001A410
FIRST, SECOND = 0x80201010, 0x80202010
RESOURCE, OTHER_RESOURCE, ALT_RESOURCE = 0x80203010, 0x80204010, 0x80207010
INPUT_FIRST, INPUT_SECOND = 0x80205010, 0x80206010
TICK, THRESHOLD, TABLE = 0x8009EF94, 0x800B8F60, 0x8008FF1C
ARITIES = {CONTACT: 4, ABSOLUTE: 1, SEPARATE: 4, RETIRE: 2, TURN: 2}
FAMILY = 'actor-collision-kind-response-execution'


def magnitude(value):
    return signed(-value) if value < 0 else value


def run(code, data, case):
    fpu = fpu_code()
    uc, write, execute, read, finish_call = environment(code + fpu, data)
    ranges = ((FIRST, 124), (SECOND, 124), (RESOURCE, 88), (OTHER_RESOURCE, 88),
              (ALT_RESOURCE, 88), (INPUT_FIRST, 16), (INPUT_SECOND, 16),
              (TICK, 4), (THRESHOLD, 4), (FPU_OUT, 48))
    state = State({address - 16: pattern(size + 32, case['id'] + ordinal * 19)
                   for ordinal, (address, size) in enumerate(ranges)})
    other = FIRST if case['actor_alias'] else SECOND
    for actor, resource, kind in ((FIRST, RESOURCE, case['first_kind']),
                                  (other, OTHER_RESOURCE, case['second_kind'])):
        state.put(actor + 36, resource)
        state.put(resource + 2, kind, 1)
        state.put(actor + 20, case['flags'])
        state.put(actor + 8, case['angle'], 2)
        for axis, value in enumerate(case['actor_position'] if actor == FIRST else case['other_position']):
            state.put(actor + 96 + axis * 4, value)
    state.put(ALT_RESOURCE + 2, 12, 1)
    state.put(TICK, case['tick'])
    state.put(THRESHOLD, case['threshold'])
    first_input, second_input = (
        (INPUT_FIRST, INPUT_SECOND), (FIRST + 96, other + 96),
        (other + 96, FIRST + 96), (INPUT_FIRST, INPUT_FIRST),
        (FIRST + 92, FIRST + 100), (INPUT_FIRST, INPUT_FIRST + 4)
    )[case['position_alias']]
    for address, values in ((first_input, case['first']), (second_input, case['second'])):
        for axis, value in enumerate(values):
            state.put(address + axis * 4, value)
    initial = State(state.images)
    events = []

    def mutate(image, address):
        if case['mutation'] == 1 and address == RETIRE:
            image.put(other + 36, ALT_RESOURCE)
        elif case['mutation'] == 2 and address == RETIRE:
            image.put(image.get(other + 36, unsigned=True) + 2, 7, 1)
        elif case['mutation'] == 3 and address == SEPARATE:
            image.put(FIRST + 20, 0xA0000400)
        elif case['mutation'] == 4 and address == CONTACT:
            image.put(FIRST + 36, ALT_RESOURCE)
            image.put(ALT_RESOURCE + 2, 27, 1)
        elif case['mutation'] == 5 and address == CONTACT:
            image.put(image.get(FIRST + 36, unsigned=True) + 2, 0, 1)
            image.put(image.get(other + 36, unsigned=True) + 2, 255, 1)
        elif case['mutation'] == 6 and address == TURN:
            image.put(FIRST + 96, 0x7FFFFFFF)
            image.put(other + 100, -0x80000000)

    def event(address, arguments):
        events.append([address, [value & 0xFFFFFFFF for value in arguments], fingerprint(state.images)])
        if address != CONTACT or not case['real_contact']:
            mutate(state, address)

    event(CONTACT, [other, FIRST, second_input, first_input])
    if case['real_contact']:
        axis = int(state.get(other + 8, 2) != 0)
        delta = signed(state.get(FIRST + 96 + axis * 4) - state.get(other + 96 + axis * 4))
        event(ABSOLUTE, [delta])
        contact = magnitude(delta) < 500
    else:
        contact = case['contact'] != 0
    if contact:
        first_kind = state.kind(FIRST)
        second_kind = state.kind(other)
        if first_kind == 27:
            event(SEPARATE, [FIRST, other, first_input, second_input])
        elif first_kind == 1:
            # Both observed threshold outcomes return zero. The instruction
            # comparison separately requires the complete calculation.
            pass
        elif second_kind in (8, 9):
            event(SEPARATE, [FIRST, other, first_input, second_input])
            state.put(FIRST + 20, state.get(FIRST + 20, unsigned=True) | 2)
        elif second_kind in (10, 13):
            for axis in (0, 1):
                difference = (state.get(first_input + axis * 4) - state.get(second_input + axis * 4)) & 0xFFFFFFFF
                if difference == 0:
                    difference = 1
                numerator = (state.get(TICK) * 1000) & 0xFFFFFFFF
                state.put(FIRST + 96 + axis * 4, state.get(FIRST + 96 + axis * 4) + numerator // difference)
        elif first_kind in (0, 2, 3, 4):
            event(RETIRE, [FIRST, 0])
            if state.kind(other) != 12:
                event(TURN, [other, FIRST])
        elif first_kind in (5, 6, 7, 8, 25, 26, 28):
            event(TURN, [other, FIRST])
        elif first_kind not in (9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 29, 30):
            event(SEPARATE, [FIRST, other, first_input, second_input])

    for address, image in initial.images.items():
        write(address, bytes(image))
    uc.emu_start(SEED_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA3456700)
    stack_start, stack_end = 0x802FFC00, 0x80300020
    stack = bytes(pattern(stack_end - stack_start, case['id'] + 71))
    write(stack_start, stack)
    observed = []
    allowed_reads = ranges + tuple((address, len(image)) for address, image in data)
    stack_floor = 0x80300000 - (48 if case['real_contact'] else 24)

    def access(uc, access, address, size, value, user):
        address |= 0x80000000
        allowed = ranges if access == UC_MEM_WRITE else allowed_reads
        assert (stack_floor <= address and address + size <= 0x80300010) or any(
            start <= address and address + size <= start + length for start, length in allowed
        ), (case, 'Memory bounds', hex(address), size)

    def observe(uc, address, size, user):
        if address in ARITIES:
            arguments = [uc.reg_read(r) for r in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                                  regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)[:ARITIES[address]]]
            actual = State({start: read(start, len(image)) for start, image in initial.images.items()})
            record = [address, arguments, fingerprint(actual.images)]
            assert len(observed) < len(events) and record == events[len(observed)], (case, record, events[len(observed):len(observed) + 1])
            observed.append(record)
            if address not in (CONTACT, ABSOLUTE) or not case['real_contact']:
                mutate(actual, address)
                for start, image in actual.images.items():
                    write(start, bytes(image))
                finish_call(case['contact'] if address == CONTACT else 0xDEADBEEF)
        else:
            assert address == SENTINEL or CLOBBER <= address < CLOBBER + 92 or any(
                start <= address and address + size <= start + len(image) for start, image in code + fpu
            ), (case, 'Instruction bounds', hex(address))

    uc.hook_add(UC_HOOK_MEM_READ | UC_HOOK_MEM_WRITE, access)
    uc.hook_add(UC_HOOK_CODE, observe)
    for register, value in zip((regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3),
                               (FIRST, other, first_input, second_input)):
        uc.reg_write(register, value)
    execute(ENTRY)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == 0
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xA3456700
    uc.emu_start(READ_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    for index, bits in enumerate(FPU_BITS):
        state.put(FPU_OUT + index * 4, bits)
    assert observed == events, case
    for address, image in state.images.items():
        assert read(address, len(image)) == bytes(image), (case, 'Final state', hex(address))
    assert read(stack_start, stack_floor - stack_start) == stack[:stack_floor - stack_start]
    assert read(0x80300000, 16) == b''.join(word(value) for value in (FIRST, other, first_input, second_input))
    assert read(0x80300010, 16) == stack[-16:]
    for address, image in code + data:
        assert read(address, len(image)) == image
    return dict(events=observed, final_sha256=fingerprint(state.images))


def cases():
    for first_kind, second_kind, contact in itertools.product(range(36), tuple(range(36)) + (36, 127, 255), (0, 1)):
        yield dict(group='dispatch', first_kind=first_kind, second_kind=second_kind, contact=contact)
    for first_kind, second_kind in itertools.product((36, 127, 255), (0, 8, 9, 10, 12, 13, 27, 255)):
        yield dict(group='unknown_kind', first_kind=first_kind, second_kind=second_kind)
    for first_kind, second_kind, mutation in itertools.product((0, 4, 5, 8, 13, 27, 35), (0, 8, 10, 12, 13), range(1, 7)):
        yield dict(group='callback_mutation', first_kind=first_kind, second_kind=second_kind, mutation=mutation)
    vectors = ((0, 0), (1, -1), (-1, 1), (0x7FFFFFFF, -0x80000000), (-0x80000000, 0x7FFFFFFF))
    for tick, vector, alias, actor_alias in itertools.product((0, 1, -1, 2147483, 0x7FFFFFFF, -0x80000000), vectors, range(6), (False, True)):
        yield dict(group='unsigned_division', second_kind=10, tick=tick,
                   first=(*vector, 17), second=(0, 0, -19), position_alias=alias, actor_alias=actor_alias)
    for height, threshold in itertools.product((0, 1, -1, 499, -500, 0x7FFFFFFF, -0x80000000), (0, 1, -1, 999, -999, 0x7FFFFFFF, -0x80000000)):
        yield dict(group='threshold', first_kind=1, actor_position=(0, 0, height), threshold=threshold)
    for first_kind, second_kind, axis, delta in itertools.product((0, 1, 5, 13, 27, 35), (0, 8, 10, 12, 13), (0, 17), (0, 499, 500, -499, -500, 0x7FFFFFFF, -0x80000000)):
        yield dict(group='real_contact', first_kind=first_kind, second_kind=second_kind, angle=axis,
                   actor_position=(delta, delta, 17), other_position=(0, 0, -19), real_contact=True)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, retail, data, comparisons = [], [], [], {}
    names = ('actor_collision_kind_response', 'early_actor_state')
    absolute = next(r[0] for r in MATCHING_BLOCKS if r[2] <= ABSOLUTE < r[3])
    for name in names + (absolute,):
        _, source, start, end = next(r for r in MATCHING_BLOCKS if r[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target, family=FAMILY, layout=layout)
        assert report['matches'], name
        comparisons[name] = report
        directory = ROOT / 'build' / FAMILY / name
        compiled.append((start, (directory / (name + '.bin')).read_bytes()))
        retail.append((start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
        sections, symbols = elf_sections_and_symbols(directory / (name + '.elf'))
        if name == names[0]:
            assert symbols['func_80016950']['size'] == 716
            assert sections['.text']['size'] == 716
            assert all(sections.get(section, {}).get('size', 0) == 0 for section in ('.data', '.bss'))
        for record in source_sections(source):
            assert record['rom'] is not None
            image = sections[record['section']]['bytes']
            assert image == target[record['rom']:record['rom'] + record['size']]
            data.append((record['vram'], image))
    table = next(image for address, image in data if address == TABLE)
    assert len(table) == 144 and all(ENTRY <= int.from_bytes(table[i:i + 4], 'big') < ENTRY + 716 for i in range(0, 144, 4))
    digest, counts = hashlib.sha256(), {}
    for index, parameters in enumerate(cases()):
        case = dict(id=index, first_kind=0, second_kind=0, contact=1, mutation=0,
                    actor_alias=False, position_alias=0, first=(101, -203, 17), second=(0, 0, -19),
                    actor_position=(17, -31, 12345), other_position=(-11, 19, -777),
                    flags=(0, 2, 0xFFFFFFFF)[index % 3], angle=0, tick=16,
                    threshold=1000, real_contact=False)
        case.update(parameters)
        expected, actual = run(retail, data, case), run(compiled, data, case)
        assert actual == expected, case
        counts[case['group']] = counts.get(case['group'], 0) + 1
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
        if (index + 1) % 500 == 0:
            print('Collision-kind execution cases:', index + 1, flush=True)
    layout.verify()
    report = dict(matches=True, cases=sum(counts.values()), counts=counts,
                  trace_sha256=digest.hexdigest(), comparisons=comparisons,
                  source_code_bytes=sum(len(image) for _, image in compiled),
                  initialized_bytes=sum(len(image) for _, image in data),
                  table_sha256=hashlib.sha256(table).hexdigest(),
                  target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  helpers_sha256={name: hashlib.sha256((ROOT / 'tools' / name).read_bytes()).hexdigest() for name in
                                  ('check_actor_boundary_boss.py', 'check_actor_collision_followup.py',
                                   'check_actor_group_path.py', 'check_boss_trigger.py')},
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['Three complete source units and their owned initialized data are freshly matched.',
                          'Selected cases execute the real contact predicate and integer absolute-value helper.',
                          'Separation, retirement and animation boundaries use caller-clobbering stubs with selected state mutations.',
                          'Checks independent dispatch and sequential unsigned arithmetic oracles, aliases, guards and preserved ABI state.',
                          'Wrapped arithmetic characterizes pinned IDO/MIPS execution; complete gameplay is outside this checker.'])
    output = ROOT / 'build' / FAMILY / 'report.json'
    output.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed collision-kind response:', report['cases'], counts, output, flush=True)


if __name__ == '__main__':
    main()
