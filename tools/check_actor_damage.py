"""Execute actor damage with real balance/value helpers and guarded state oracles."""

import hashlib
import itertools
import json
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_boundary_boss import CLOBBER, environment
from check_actor_group_path import SENTINEL, word
from check_actor_collision_followup import State
from check_boss_trigger import (FPU_BITS, FPU_OUT, READ_FPU, SEED_FPU,
                               fpu_code, pattern, fingerprint)
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from rom import ROOT, validate


DAMAGE, BALANCE, VALUE = 0x80035244, 0x80015130, 0x80035190
FIRST, SECOND, CHILD = 0x80201010, 0x80202010, 0x80203010
RESOURCE, OWNER, CHILD_OWNER = 0x80204010, 0x80205010, 0x80207010
DISABLED, LIMIT, CLOCK = 0x8007D8FC, 0x800B6FD0, 0x8009EFA0
ANIMATE, COLOR, RETIRE, CALLBACK = 0x80027AB8, 0x80039C1C, 0x800354C8, 0x80000200
INSTALLED_CALLBACK = 0x80029210
ARG_COUNTS = {ANIMATE: 3, COLOR: 4, RETIRE: 2, CALLBACK: 1}


def run(code, case):
    fpu = fpu_code()
    uc, write, execute, read, finish_call = environment(code + fpu, [])
    ranges = ((FIRST, 124), (SECOND, 124), (CHILD, 124), (RESOURCE, 88),
              (OWNER, 16), (CHILD_OWNER, 16), (DISABLED, 4), (LIMIT, 4), (CLOCK, 4),
              (FPU_OUT, 48))
    guarded_ranges = sorted((address - 16, address + size + 16) for address, size in ranges)
    assert all(left[1] <= right[0] for left, right in zip(guarded_ranges, guarded_ranges[1:]))
    state = State({address - 16: pattern(size + 32, case['id'] + ordinal * 19)
                   for ordinal, (address, size) in enumerate(ranges)})
    other = FIRST if case['alias'] else SECOND
    child = (0, CHILD, FIRST)[case['child']]
    for actor, health in ((FIRST, case['health']), (SECOND, case['other_health']), (CHILD, 777)):
        state.put(actor + 16, health, 2)
        state.put(actor + 20, case['flags'])
        state.put(actor + 28, case['category'], 1)
        state.put(actor + 36, 0 if case['null_resource'] else RESOURCE)
        state.put(actor + 60, CHILD_OWNER if actor == CHILD else OWNER)
        state.put(actor + 68, CALLBACK)
        state.put(actor + 12, -17, 2)
    state.put(OWNER + 12, child)
    state.put(CHILD_OWNER + 12, 0xF1E2D3C4)
    state.put(RESOURCE + 2, case['kind'], 1)
    state.put(FIRST + 84, case['countdown'])
    state.put(DISABLED, case['disabled'])
    state.put(LIMIT, case['limit'])
    state.put(CLOCK, case['clock'])
    initial = State(state.images)
    uc.emu_start(SEED_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    events = []

    def mutate(image, address):
        mutation = case['mutation']
        if address == ANIMATE:
            if mutation == 1:
                image.put(FIRST + 16, 0, 2)
            elif mutation == 2:
                image.put(FIRST + 84, case['limit'])
            elif mutation == 3:
                image.put(child + 20, image.get(child + 20, unsigned=True) | 0x40)
            elif mutation == 4:
                image.put(child + 20, image.get(child + 20, unsigned=True) & ~0x40)
        if address == CALLBACK:
            if mutation == 5:
                image.put(FIRST + 16, -32768, 2)
                image.put(CLOCK, 0xFFFFFFFF)
            elif mutation == 6:
                image.put(FIRST + 84, -2147483648)
                image.put(LIMIT, -2147483647)
        if address == COLOR and mutation == 7:
            image.put(FIRST + 12, 31, 2)
            image.put(FIRST + 16, 257, 2)
        if address == RETIRE:
            image.put(FIRST + 33, 2, 1)
            image.put(FIRST + 16, 0, 2)

    def event(address, args):
        events.append([address, [value & 0xFFFFFFFF for value in args], fingerprint(state.images)])
        mutate(state, address)

    result = 0
    if not case['disabled']:
        if state.get(other + 28, 1, True) != 0 or not 5 <= state.get(RESOURCE + 2, 1, True) < 9:
            # Real balance helper clamps, then updates each short in order. This
            # also models the distinct outcome when both arguments alias.
            for actor in (other, FIRST):
                if state.get(actor + 16, 2) < 0:
                    state.put(actor + 16, 0, 2)
            saved = state.get(other + 16, 2)
            state.put(other + 16, saved - state.get(FIRST + 16, 2), 2)
            state.put(FIRST + 16, state.get(FIRST + 16, 2) - saved, 2)
        else:
            state.put(FIRST + 16, state.get(FIRST + 16, 2) - state.get(other + 16, 2), 2)
        value = state.get(FIRST + 16, 2)
        if child:
            if value < 257:
                state.put(child + 33, 2, 1)
                owner = state.get(child + 60, unsigned=True)
                state.put(owner + 12, 0)
            else:
                event(ANIMATE, [child, 6, 1])
                flags = state.get(child + 20, unsigned=True)
                if flags & 0x40:
                    state.put(child + 20, flags & ~0x40)
                    event(state.get(child + 68, unsigned=True), [child])
                state.put(child + 20, state.get(child + 20, unsigned=True) | 0x40)
                state.put(child + 68, INSTALLED_CALLBACK)
                state.put(child + 14, 999, 2)
        if state.get(FIRST + 16, 2) <= 0 or state.get(FIRST + 84) >= state.get(LIMIT):
            event(COLOR, [state.get(FIRST + 12, 2), 200, 200, 200])
            event(RETIRE, [FIRST, other])
            result = 1
        else:
            state.put(FIRST + 20, state.get(FIRST + 20, unsigned=True) | 0x4000)
            state.put(FIRST + 72, state.get(CLOCK, unsigned=True))

    for start, data in initial.images.items():
        write(start, bytes(data))
    stack_start, stack_end = 0x802FFC00, 0x80300010
    stack = bytes(pattern(stack_end - stack_start, case['id'] + 71))
    write(stack_start, stack)
    observed = []

    def access(uc, access, address, size, value, user):
        normalized = address | 0x80000000
        assert (0x80300000 - 96 <= normalized and normalized + size <= stack_end) or any(
            start <= normalized and normalized + size <= start + length for start, length in ranges
        ), (case, 'Memory outside payload/stack bounds', hex(normalized), size)

    def observe(uc, address, size, user):
        if address in ARG_COUNTS:
            args = [uc.reg_read(register) for register in
                    (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2,
                     regs.UC_MIPS_REG_A3)[:ARG_COUNTS[address]]]
            actual = State({start: read(start, len(data)) for start, data in initial.images.items()})
            record = [address, args, fingerprint(actual.images)]
            assert len(observed) < len(events) and record == events[len(observed)], (case, record, events)
            observed.append(record)
            mutate(actual, address)
            for start, data in actual.images.items():
                write(start, bytes(data))
            finish_call(0xDEADBEEF)
        else:
            assert address == SENTINEL or CLOBBER <= address < CLOBBER + 92 or any(
                start <= address and address + size <= start + len(data) for start, data in code + fpu
            ), (case, 'Unexpected executed code', hex(address))

    uc.hook_add(UC_HOOK_MEM_READ | UC_HOOK_MEM_WRITE, access)
    uc.hook_add(UC_HOOK_CODE, observe)
    uc.reg_write(regs.UC_MIPS_REG_A0, FIRST)
    uc.reg_write(regs.UC_MIPS_REG_A1, 0 if case['null_other'] else other)
    execute(DAMAGE)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, (case, 'Damage did not return')
    assert observed == events and uc.reg_read(regs.UC_MIPS_REG_V0) == result, case
    uc.emu_start(READ_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    for index, bits in enumerate(FPU_BITS):
        state.put(FPU_OUT + index * 4, bits)
    for start, data in state.images.items():
        assert read(start, len(data)) == bytes(data), (case, 'Final state', hex(start))
    # Damage owns a 40-byte frame; its value helper may use another 32 bytes.
    assert read(stack_start, 0x80300000 - 96 - stack_start) == stack[:0x80300000 - 96 - stack_start]
    expected_home = bytearray(stack[-16:])
    if not case['disabled']:
        expected_home[4:8] = word(other)
    assert read(0x80300000, 16) == bytes(expected_home), (case, 'Caller argument home slots')
    return dict(events=observed, final_sha256=fingerprint(state.images), result=result)


def cases():
    for health, other_health, category, kind in itertools.product(
            (-32768, -257, -1, 0, 1, 255, 256, 257, 1024, 32767),
            (-32768, -1, 0, 1, 256, 32767), (0, 1), (4, 5, 8, 9)):
        yield dict(group='arithmetic', health=health, other_health=other_health, category=category, kind=kind)
    for countdown, limit in itertools.product(
            (-2147483648, -1, 0, 1, 2147483647), (-2147483648, -1, 0, 1, 2147483647)):
        yield dict(group='threshold', health=257, countdown=countdown, limit=limit)
    for health, category, kind in itertools.product((-32768, -1, 0, 1, 256, 257, 1024, 32767), (0, 1), (4, 5, 8, 9)):
        yield dict(group='alias', health=health, alias=True, category=category, kind=kind)
    for health, child, flags, mutation in itertools.product((257, 32767), (1, 2), (0, 0x40), range(8)):
        yield dict(group='mutation', health=health, child=child, flags=flags, mutation=mutation)
    for disabled, health in itertools.product((-2147483648, -1, 1), (-32768, 0, 256, 257, 32767)):
        yield dict(group='disabled', disabled=disabled, health=health, null_other=True, null_resource=True)
    for health in (-32768, -1, 0, 1, 256, 257, 1024, 32767):
        yield dict(group='resource_short_circuit', health=health, category=1, null_resource=True)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, retail, comparisons = [], [], {}
    records = [('actor_damage', 'src/game/collisions/damage.c', DAMAGE, 0x80035360)]
    records.extend(next(record for record in MATCHING_BLOCKS if record[0] == name)
                   for name in ('early_actor_pair_balance', 'actor_value_transition'))
    for name, source, start, end in records:
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target,
                               family='actor-damage-execution', layout=layout)
        assert report['matches'], name
        comparisons[name] = report
        directory = ROOT / 'build/actor-damage-execution' / name
        compiled.append((start, (directory / (name + '.bin')).read_bytes()))
        retail.append((start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
    counts, digest, services = {}, hashlib.sha256(), {}
    for index, parameters in enumerate(cases()):
        case = dict(id=index, health=257, other_health=0, category=0, kind=5,
                    flags=(0, 0x40, 0x4000, 0xFFFFFFFF)[index % 4], child=index % 3,
                    alias=False, countdown=-1, limit=1000, disabled=0, mutation=0,
                    clock=(0, 0x7FFFFFFF, 0x80000000, 0xFFFFFFFF)[index % 4],
                    null_other=False, null_resource=False)
        case.update(parameters)
        expected, actual = run(retail, case), run(compiled, case)
        assert actual == expected, case
        counts[case['group']] = counts.get(case['group'], 0) + 1
        for address, _, _ in actual['events']:
            services[hex(address)] = services.get(hex(address), 0) + 1
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
        if (index + 1) % 250 == 0:
            print('Damage execution cases:', index + 1, flush=True)
    assert all(services.get(hex(address), 0) for address in ARG_COUNTS), services
    layout.verify()
    report = dict(matches=True, cases=sum(counts.values()), counts=counts,
                  services=services, trace_sha256=digest.hexdigest(), comparisons=comparisons,
                  source_code_bytes=sum(end-start for _,_,start,end in records),
                  target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  helpers_sha256={name: hashlib.sha256((ROOT / 'tools' / name).read_bytes()).hexdigest()
                                  for name in ('check_actor_boundary_boss.py', 'check_actor_group_path.py',
                                               'check_actor_collision_followup.py', 'check_boss_trigger.py')},
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['Three complete code ranges are freshly compiled and independently compared.',
                          'The balance and value transition helpers execute real matched source.',
                          'Animation, prior callback, object color and retirement use recorded integer/FPU ABI stubs.',
                          'Short wrapping, aliasing, thresholds, early disable and short-circuit pointer reads use independent state oracles.',
                          'Calls check state before service mutation; mutations model reload behavior, not actual service effects.',
                          'Memory payload bounds, instruction ranges, guarded stack, saved integer registers and stack restoration are checked.',
                          'Real MIPS mtc1/swc1 instructions check preservation of F20 through F31 while service stubs poison F0 through F19.',
                          'Required actor and owner pointers are valid synthetic inputs; actual allocation and gameplay remain outside this matrix.',
                          'Signed overflow characterizes pinned IDO/MIPS execution, not portable ISO C.'])
    output = ROOT / 'build/actor-damage-execution/report.json'
    output.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed actor damage:', report['cases'], counts, output, flush=True)


if __name__ == '__main__':
    main()
