"""Execute weighted separation with real math and position submission helpers."""

import hashlib
import itertools
import json
import math
import struct
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UC_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_boundary_boss import CLOBBER, environment, signed, divide
from check_actor_group_path import SENTINEL, word
from check_actor_collision_followup import State
from check_boss_trigger import (FPU_BITS, FPU_OUT, READ_FPU, SEED_FPU,
                               fpu_code, pattern, fingerprint, single,
                               fixed_sine, fixed_cosine)
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


SEPARATE, SQRT, ANGLE = 0x80018E1C, 0x8003CCE8, 0x8003CD4C
COSINE, SINE, POSITION, OBJECT = 0x8003CC88, 0x8003CC58, 0x800290B0, 0x80039614
FIRST, SECOND, INPUT_FIRST, INPUT_SECOND = 0x80201010, 0x80202010, 0x80203010, 0x80204010
ARITIES = {SQRT: 1, ANGLE: 2, COSINE: 1, SINE: 1, POSITION: 2, OBJECT: 2}
SUPPORT = ('object_recovery_fixed_trig', 'object_recovery_integer_sqrt',
           'object_recovery_angle_scale', 'object_recovery_direction_angle',
           'object_recovery_angle_table', 'fixed_geometry_setup',
           'short_sine', 'short_cosine', 'actor_position_submit')


def direction(y, x):
    """Quantize direction using independently generated tangent thresholds."""
    if y == 0:
        return 2048 if x < 0 else 0
    if x == 0:
        return 3072 if y < 0 else 1024
    a, b = abs(y), abs(x)
    ratio = divide(signed(min(a, b) * 32767), max(a, b))
    thresholds = [round(math.tan(i * math.pi / 256) * 32767) for i in range(65)]
    if ratio < thresholds[1]:
        bucket = 0
    elif ratio > thresholds[63]:
        bucket = 64
    else:
        # Shared interval endpoints use the retail search tree's first interval.
        priority = [i for step in (32, 16, 8, 4, 2, 1) for i in range(step, 64, step * 2)]
        bucket = next(i for i in priority if thresholds[i] <= ratio <= thresholds[i + 1])
    angle = bucket if a < b else 128 - bucket
    return ((angle, 512 - angle, 256 - angle, 256 + angle)[int(y < 0) | (int(x < 0) << 1)]) << 3


def run(code, data, case):
    fpu = fpu_code()
    uc, write, execute, read, finish_call = environment(code + fpu, data)
    ranges = ((FIRST, 124), (SECOND, 124), (INPUT_FIRST, 16), (INPUT_SECOND, 16), (FPU_OUT, 48))
    state = State({address - 16: pattern(size + 32, case['id'] + i * 19)
                   for i, (address, size) in enumerate(ranges)})
    other = FIRST if case['actor_alias'] else SECOND
    for actor, margin, object_index in ((FIRST, case['margins'][0], -17),
                                        (SECOND, case['margins'][1], 32767)):
        state.put(actor + 6, margin, 2)
        state.put(actor + 12, object_index, 2)
        state.put(actor + 20, case['flags'])
        for axis, value in enumerate((1111, -2222, 0x12345678)):
            state.put(actor + 96 + axis * 4, value)
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

    def event(address, args, vector=None):
        events.append([address, [v & 0xFFFFFFFF for v in args], vector, fingerprint(state.images)])

    def submission_mutation(image):
        if case['mutation']:
            image.put(other + 12, -32768, 2)
            image.put(other + 96, 0x7FFFFFFF)
            image.put(other + 100, -0x80000000)
            image.put(other + 104, 777)

    def delta(axis):
        return signed(state.get(first_input + axis * 4) - state.get(second_input + axis * 4))

    w1, w2 = case['weights']
    total = signed(w1 + w2)
    if total == 0:
        total, w1, w2 = 2, signed(w1 + 1), signed(w2 + 1)
    radius = state.get(FIRST + 6, 2) + state.get(other + 6, 2)
    square = signed(delta(0) ** 2 + delta(1) ** 2)
    event(SQRT, [square])
    distance = 0 if square < 0 else min(32768, math.isqrt(square))
    trap = None
    if distance < radius:
        for actor in (FIRST, other):
            state.put(actor + 20, state.get(actor + 20, unsigned=True) | 0x10000)
        y, x = delta(1), delta(0)
        event(ANGLE, [y, x])
        angle = direction(y, x)
        overlap, denominator = radius - distance + 400, signed(total << 12)
        for actor, source, weight, operation in ((FIRST, first_input, w1, 1), (other, second_input, w2, -1)):
            for axis, helper, value in ((0, COSINE, fixed_cosine(angle)), (1, SINE, fixed_sine(angle))):
                event(helper, [angle])
                product = signed(signed(value * overlap) * weight)
                if denominator == 0:
                    trap = 0x80018F5C
                    break
                displacement = divide(product, denominator)
                state.put(actor + 96 + axis * 4, state.get(source + axis * 4) + operation * displacement)
            if trap is not None:
                break
        if trap is None:
            for ordinal, actor in enumerate((FIRST, other)):
                object_index = state.get(actor + 12, 2)
                event(POSITION, [object_index, actor + 96])
                values = [state.get(actor + 96 + axis * 4) for axis in (0, 2, 1)]
                vector = b''.join(struct.pack('>f', single(single(single(float(v)) * 1400.0) / 60000.0)) for v in values).hex()
                event(OBJECT, [object_index], vector)
                if ordinal == 0:
                    submission_mutation(state)

    for start, image in initial.images.items():
        write(start, bytes(image))
    uc.emu_start(SEED_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    stack_start, stack_end = 0x802FFC00, 0x80300020
    stack = bytes(pattern(stack_end - stack_start, case['id'] + 71))
    write(stack_start, stack)
    write(0x80300010, word(first_input) + word(second_input))
    observed = []
    allowed_reads = ranges + tuple((address, len(image)) for address, image in data)

    def access(uc, access, address, size, value, user):
        address |= 0x80000000
        allowed = ranges if access == UC_MEM_WRITE else allowed_reads
        assert (0x80300000 - 256 <= address and address + size <= stack_end) or any(
            start <= address and address + size <= start + length for start, length in allowed
        ), (case, 'Memory bounds', hex(address), size)

    object_calls = [0]

    def observe(uc, address, size, user):
        if address == trap:
            uc.emu_stop()
            return
        if address in ARITIES:
            args = [uc.reg_read(r) for r in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1)[:ARITIES[address]]]
            vector = None
            if address == OBJECT:
                assert 0x80300000 - 256 <= args[1] <= 0x80300000 - 12
                vector = read(args[1], 12).hex()
                args = args[:1]
            actual = State({start: read(start, len(image)) for start, image in initial.images.items()})
            record = [address, args, vector, fingerprint(actual.images)]
            assert len(observed) < len(events) and record == events[len(observed)], (case, record, events[len(observed):len(observed)+1])
            observed.append(record)
            if address == OBJECT:
                if object_calls[0] == 0:
                    submission_mutation(actual)
                object_calls[0] += 1
                for start, image in actual.images.items():
                    write(start, bytes(image))
                finish_call(0xDEADBEEF)
        else:
            assert address == SENTINEL or CLOBBER <= address < CLOBBER + 92 or any(
                start <= address and address + size <= start + len(image) for start, image in code + fpu
            ), (case, 'Instruction bounds', hex(address))

    uc.hook_add(UC_HOOK_MEM_READ | UC_HOOK_MEM_WRITE, access)
    uc.hook_add(UC_HOOK_CODE, observe)
    for r, value in zip((regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3), (FIRST, other, *case['weights'])):
        uc.reg_write(r, value & 0xFFFFFFFF)
    if trap is None:
        execute(SEPARATE)
        assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
        uc.emu_start(READ_FPU, 0, count=1000)
        assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
        for i, bits in enumerate(FPU_BITS):
            state.put(FPU_OUT + i * 4, bits)
    else:
        uc.emu_start(SEPARATE, 0, count=20000)
        assert uc.reg_read(regs.UC_MIPS_REG_PC) == trap
        assert read(trap, 4) == word(0x0007000D)
    assert observed == events, case
    for start, image in state.images.items():
        assert read(start, len(image)) == bytes(image), (case, 'Final state', hex(start))
    assert read(stack_start, 0x80300000 - 256 - stack_start) == stack[:0x80300000 - 256 - stack_start]
    assert read(0x80300000, 16) == stack[-32:-16]
    assert read(0x80300010, 8) == word(first_input) + word(second_input)
    assert read(0x80300018, 8) == stack[-8:]
    for address, image in data:
        assert read(address, len(image)) == image
    return dict(events=observed, trap=trap, final_sha256=fingerprint(state.images))


def cases():
    vectors = ((0, 0), (1, 0), (0, -1), (300, 400), (-400, 300), (-300, -400),
               (400, -300), (999, 1), (1000, 0), (1001, 0), (20000, 17000),
               (32768, 32767), (50000, 50000), (65000, 65000))
    for vector, margins, weights in itertools.product(vectors, ((500, 500), (0, 0), (-32768, 32767), (32767, 32767)),
                                                       ((0, 0), (0, 1), (1, 0), (10, 10), (100, 1), (-1, 1), (-7, 3), (0x7FFFFFFF, 1))):
        yield dict(group='arithmetic', first=(*vector, 12345), margins=margins, weights=weights)
    for alias, actor_alias, weights, mutation in itertools.product(range(6), (False, True), ((0, 0), (1, 0), (0, 1), (10, 10)), (False, True)):
        yield dict(group='alias', position_alias=alias, actor_alias=actor_alias, weights=weights, mutation=mutation)
    for weights, alias in itertools.product(((1048576, 0), (-1048576, 0), (0x7FFFFFFF, 1), (0x40000000, 0x40000000)), range(4)):
        yield dict(group='division_guard', weights=weights, position_alias=alias)
    for weights in ((0, 0), (100, 1), (-7, 3)):
        yield dict(group='coordinate_wrap', first=(0x7FFFFFFF, 17, 0x7FFFFFFF), second=(-0x80000000, 19, -0x80000000), weights=weights)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, retail, data, comparisons, tables = [], [], [], {}, {}
    for name in ('actor_collision_separation',) + SUPPORT:
        _, source, start, end = next(r for r in MATCHING_BLOCKS if r[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00, end - 0x80000000 + 0xC00,
                               target, family='actor-separation-execution', layout=layout)
        assert report['matches'], name
        comparisons[name] = report
        directory = ROOT / 'build/actor-separation-execution' / name
        compiled.append((start, (directory / (name + '.bin')).read_bytes()))
        retail.append((start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
        records = source_sections(source)
        if records:
            sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
            for record in records:
                assert record['rom'] is not None
                image = sections[record['section']]['bytes']
                assert image == target[record['rom']:record['rom'] + record['size']]
                data.append((record['vram'], image))
                if name == 'short_sine':
                    assert image == struct.pack('>1024h', *(math.floor(32767 * math.sin(i * math.pi / 2046)) for i in range(1024)))
            tables[source] = dict(matches=True, bytes=sum(record['size'] for record in records),
                                  comparison=name, sha256=[hashlib.sha256(sections[r['section']]['bytes']).hexdigest() for r in records])
    source = 'src/game/actor_groups/direction_table.c'
    tables[source] = compare_unit(source, source_sections(source), target, layout)
    assert tables[source]['matches']
    sections, _ = elf_sections_and_symbols(ROOT / 'build/data-comparison' / Path(source).with_suffix('') / 'compiled.elf')
    data.append((0x8007C338, sections['.actor_direction_table']['bytes']))
    assert struct.unpack('>65i', data[-1][1]) == tuple(round(math.tan(i * math.pi / 256) * 32767) for i in range(65))
    counts, traps, contacts, digest = {}, 0, 0, hashlib.sha256()
    for i, parameters in enumerate(cases()):
        case = dict(id=i, first=(300, 400, 12345), second=(0, 0, -67890), margins=(500, 500), weights=(10, 10),
                    flags=(0, 0x10000, 0xFFFFFFFF)[i % 3], actor_alias=False, position_alias=0, mutation=False)
        case.update(parameters)
        expected, actual = run(retail, data, case), run(compiled, data, case)
        assert actual == expected, case
        counts[case['group']] = counts.get(case['group'], 0) + 1
        traps += actual['trap'] is not None
        contacts += len(actual['events']) > 1
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
        if (i + 1) % 250 == 0:
            print('Separation execution cases:', i + 1, flush=True)
    assert traps > 0 and 0 < contacts < sum(counts.values())
    layout.verify()
    report = dict(matches=True, cases=sum(counts.values()), counts=counts, division_traps=traps, contacts=contacts,
                  trace_sha256=digest.hexdigest(), comparisons=comparisons, table_comparisons=tables,
                  source_code_bytes=sum(len(image) for _, image in compiled), initialized_bytes=sum(len(image) for _, image in data),
                  target_rom_sha256=hashlib.sha256(target).hexdigest(), checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  helpers_sha256={name: hashlib.sha256((ROOT / 'tools' / name).read_bytes()).hexdigest() for name in
                                  ('check_actor_boundary_boss.py', 'check_actor_group_path.py', 'check_actor_collision_followup.py', 'check_boss_trigger.py')},
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['Ten complete code ranges and three initialized data units are freshly compiled and independently matched.',
                          'Square root, integer direction, sine/cosine and position conversion execute real recovered source.',
                          'Object transform submission uses an integer/FPU ABI stub and can mutate the second actor before its submission.',
                          'Independent arithmetic, ordered memory and float-byte oracles cover selected weights, margins, thresholds and aliases.',
                          'Memory and instruction bounds, guarded stack, caller homes, saved integer registers and F20 through F31 are checked on normal returns.',
                          'Selected shifted-zero denominators stop before the first retail break-7 instruction; later breaks and complete gameplay are outside this matrix.',
                          'Signed overflow characterizes pinned IDO/MIPS execution, not portable ISO C.'])
    output = ROOT / 'build/actor-separation-execution/report.json'
    output.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed actor separation:', report['cases'], counts, 'division traps', traps, output, flush=True)


if __name__ == '__main__':
    main()
