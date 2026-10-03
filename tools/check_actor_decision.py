"""Execute the complete actor decision C against retail and guarded byte oracles."""

import hashlib
import itertools
import json
import math
import struct
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE, UcError
from unicorn import mips_const as regs
from check_actor_group_path import SENTINEL, word
from check_actor_boundary_boss import environment, signed, divide
from check_boss_trigger import fpu_code, FPU_OUT, FPU_BITS, SEED_FPU, READ_FPU, pattern, fingerprint
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


ENTRY, SOURCE = 0x8000FBC0, 0x80201010
SESSION, PLAYERS = 0x800AD138, 0x8009B190
PLAYER_ACTORS = (0x80202010, 0x80203010)
RECORDS, RESOURCES, STATIC = 0x80220010, 0x80224010, 0x80073164
GLOBAL = 0x80097340
SUPPORT = ('object_recovery_integer_sqrt', 'object_recovery_angle_scale',
           'object_recovery_direction_angle', 'object_recovery_angle_table',
           'fixed_geometry_setup', 'runtime_random')
RANDOM, ANIMATE, CREATE, SPAWN, CAMERA = 0x800631F0, 0x8000ECE4, 0x8000F564, 0x8001AF44, 0x80039EB8
CALLBACKS = {0: ENTRY, 1: 0x8000F318, 4: 0x8000F4E0}
RANDOM_VALUES = (0, 7, 792, 800, -1, -800)
ANGLES = (-32768, -2048, -1536, -1380, -1379, -669, -668, -553, -552,
          -1, 0, 1, 552, 553, 668, 669, 1379, 1380, 1535, 1536, 2047, 32767)


def remainder(value, divisor):
    return value - divide(value, divisor) * divisor


def run_case(code, support, case):
    uc, write, execute, read, finish_call = environment(code + fpu_code(), support)
    images = {}

    def region(address, size, seed):
        images[address - 16] = pattern(size + 32, seed)

    for index, (address, size) in enumerate(((SOURCE, 124), (SESSION, 328),
            (PLAYERS, 7016), (PLAYER_ACTORS[0], 124), (PLAYER_ACTORS[1], 124),
            (RECORDS, 1020), (RESOURCES, 988), (STATIC, 1020), (GLOBAL, 28), (FPU_OUT, 48))):
        region(address, size, index * 17 + 19)

    def put(state, address, data):
        for start, image in state.items():
            if start <= address and address + len(data) <= start + len(image):
                image[address - start:address - start + len(data)] = data
                return
        raise AssertionError(('Outside guarded regions', hex(address)))

    def get(state, address):
        for start, image in state.items():
            if start <= address and address + 4 <= start + len(image):
                return signed(int.from_bytes(image[address - start:address - start + 4], 'big'))
        raise AssertionError(hex(address))

    player, phase = case['player'], case['phase']
    distance = case['distance']
    vectors = ((distance, 0), (0, distance), (-distance, 0), (0, -distance), (distance, distance))
    dx, dy = vectors[case['vector']]
    heading = round(math.atan2(dy, dx) * 4096 / (2 * math.pi)) & 4095 if (dx, dy) != (0, 0) else 0
    source_angle = signed(((heading - case['angle']) + 32768) % 65536 - 32768)
    put(images, SOURCE + 8, struct.pack('>h', source_angle))
    put(images, SOURCE + 0x60, word(-5000) + word(3000) + word(777))
    for index, address in enumerate(PLAYER_ACTORS):
        put(images, address + 0x60, word(-5000 + dx) + word(3000 + dy) + word(999))
        put(images, PLAYERS + index * 3508 + 8, word(address))
        put(images, PLAYERS + index * 3508 + 0x24, word(case['value']))
    for offset, value in ((0x30, player), (0x84, RESOURCES), (0x9C, phase), (0xB4, RECORDS)):
        put(images, SESSION + offset, word(value))
    for index in range(6):
        put(images, RESOURCES + 0x3C4 + index * 4, word(case['cutoff'] if index == phase else case['denominator']))
    put(images, GLOBAL + 8, word(case['wave']))
    put(images, GLOBAL + 12, word(case['wave']))
    write(0x800C8B7C, word(case['spawn_count']))

    def slot(address, animation, value, kind, extra):
        put(images, address, word(animation) + word(value) + bytes((kind, extra, 0xA3, 0xB7)))

    for record in range(5):
        address = RECORDS + record * 204
        put(images, address + 24, word(301 + record))
        for index in range(6):
            animation = -1 if case['movement'] == index or case['movement'] == 6 else 400 + record * 10 + index
            slot(address + 36 + index * 12, animation, 0, 0, 51 + index)
        for index in range(5):
            profile = case['profile']
            animation, weight, kind = 600 + index, (1, 10, 40, 100, 0)[index], index % 5
            if profile == 0:
                animation = -1
            elif profile in (1, 2, 3):
                weight |= (0x10000000, 0x20000000, 0x40000000)[profile - 1]
            elif profile == 4:
                kind = 1
            elif profile == 5:
                kind = 2
            elif profile == 6:
                kind = 4
            elif profile == 7:
                animation = 0xDEADBEEF if index < 4 else 701
                weight, kind = 100, (4, 2, 1, 255, 0)[index]
            elif profile == 8:
                weight = 0x80000000 | weight
                kind = 255
            slot(address + 108 + index * 12, animation, weight, kind, 61 + index)
        for index in range(3):
            animation = -1 if case['reset'] == 0 else 800 + index
            enabled = 1 if case['reset'] == 2 or (case['reset'] == 3 and index == 0) else 0
            threshold = case['reset_threshold'] + index
            slot(address + 168 + index * 12, animation, threshold, enabled, 71 + index)
    for address, image in images.items():
        write(address, bytes(image))
    stack_above = bytes(pattern(32, 151))
    write(0x80300000, stack_above)
    uc.emu_start(SEED_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL

    expected = {address: bytearray(image) for address, image in images.items()}
    events, random_index = [], 0
    trap = None

    def emit(address, args):
        nonlocal random_index
        result = None
        if address == RANDOM:
            result = case['random'] if random_index == 0 else (case['reroll'] if random_index < 5 else 792)
            random_index += 1
        events.append(dict(address=address, args=[value & 0xFFFFFFFF for value in args],
                           images_sha256=fingerprint(expected), result=result))
        if address == ANIMATE and case['mutation'] == 1:
            put(expected, SESSION + 0xA8, word(-1))
            put(expected, SESSION + 0x9C, word((get(expected, SESSION + 0x9C) + 1) % 5))
        if address == CAMERA and case['mutation'] == 2:
            put(expected, GLOBAL + 12, word(1))
        if address == SPAWN and case['mutation'] == 2:
            put(expected, GLOBAL + 12, word(0))
        return result

    for offset in (0xA8, 0xB0, 0xAC):
        put(expected, SESSION + offset, word(-1))
    squared = signed(divide(signed(dx * dx), 10000) + divide(signed(dy * dy), 10000))
    magnitude = 32768 if squared >= 0x40000000 else math.isqrt(max(0, squared))
    measured = magnitude * 100
    put(expected, SESSION + 0x98, word(measured))
    progress = divide(signed(case['value']), 256)
    if progress <= case['cutoff']:
        put(expected, GLOBAL + 16, word(phase))
        put(expected, SESSION + 0xA8, word(0))
        initial = get(expected, RECORDS + phase * 204 + 24)
        extra = expected[STATIC - 16][16 + phase * 204 + 45]
        emit(ANIMATE, [SOURCE, initial, 0x8000EE48 if phase != 0 else 0x80029154, 999, extra])
        emit(CREATE, [10 if phase != 0 else 30])
    random = remainder(signed(emit(RANDOM, [])) >> 3, 100)
    current_phase = get(expected, SESSION + 0x9C)
    for index in range(5):
        if get(expected, SESSION + 0xA8) != -1:
            break
        address = RECORDS + current_phase * 204 + 108 + index * 12
        animation, weight = get(expected, address), get(expected, address + 4) & 0xFFFFFFFF
        kind = expected[RECORDS - 16][16 + current_phase * 204 + 108 + index * 12 + 8]
        extra = expected[RECORDS - 16][16 + current_phase * 204 + 108 + index * 12 + 9]
        if animation == -1:
            break
        available = kind != 1 or (get(expected, GLOBAL + 12) == 0 and get(expected, GLOBAL + 8) == 0)
        band = weight >> 28
        permitted = {1: measured > 25000, 2: 9000 < measured < 25000, 4: measured < 9000}.get(band, True)
        if available and permitted:
            random = signed(random - (weight & 0x0FFFFFFF))
        if random < 0:
            put(expected, SESSION + 0xB0, word(kind))
            callback, timer = CALLBACKS.get(kind, ENTRY), 1 if kind in (1, 4) else 999
            if kind == 4:
                emit(CAMERA, [20, 2])
            if kind == 2 and case['spawn_count'] + 1 < 50:
                emit(SPAWN, [33, SOURCE + 0x60, 0])
            if animation != signed(0xDEADBEEF):
                emit(ANIMATE, [SOURCE, animation, callback, timer, extra])
                put(expected, SESSION + 0xA8, word(2))
                break
            random = remainder(signed(emit(RANDOM, [])) >> 3, 100)
    current_phase = get(expected, SESSION + 0x9C)
    if get(expected, SESSION + 0xA8) == -1:
        for index in range(3):
            address = RECORDS + current_phase * 204 + 168 + index * 12
            animation, threshold = get(expected, address), get(expected, address + 4)
            enabled = expected[RECORDS - 16][16 + current_phase * 204 + 168 + index * 12 + 8]
            extra = expected[RECORDS - 16][16 + current_phase * 204 + 168 + index * 12 + 9]
            if animation == -1:
                break
            if enabled == 0:
                numerator = signed(signed(progress - get(expected, RESOURCES + 0x3C4 + current_phase * 4)) * 100)
                denominator = get(expected, RESOURCES + 0x3C8 + current_phase * 4)
                if denominator == 0 or (numerator, denominator) == (-0x80000000, -1):
                    trap = 7 if denominator == 0 else 6
                    break
                if divide(numerator, denominator) <= threshold:
                    put(expected, address + 8, bytes((1,)))
                    emit(ANIMATE, [SOURCE, animation, ENTRY, 999, extra])
                    put(expected, SESSION + 0xA8, word(3))
                    break
    if get(expected, SESSION + 0xA8) == -1 and trap is None:
        delta = ((heading + 256) & 0xE00) - source_angle
        delta = (delta + 2048) % 4096 - 2048
        absolute = abs(delta)
        movement = -1
        if 553 <= absolute < 1536:
            rare = False
            if measured > 9000 and 668 < absolute < 1380:
                rare = remainder(signed(emit(RANDOM, [])) >> 3, 256) > 128
            movement = (5 if delta > 0 else 4) if rare else (3 if delta > 0 else 2)
        elif absolute >= 1536:
            animation = get(expected, RECORDS + current_phase * 204 + 48)
            movement = 1 if animation != -1 else (3 if delta > 0 else 2)
        elif get(expected, RECORDS + current_phase * 204 + 36) != -1:
            movement = 0
        if movement != -1:
            put(expected, SESSION + 0xAC, word(movement))
            put(expected, SESSION + 0xA8, word(1))
            address = RECORDS + current_phase * 204 + 36 + movement * 12
            animation = get(expected, address)
            extra = expected[RECORDS - 16][16 + current_phase * 204 + 36 + movement * 12 + 9]
            emit(ANIMATE, [SOURCE, animation, ENTRY, 999, extra])

    trace = []
    arities = {RANDOM: 0, ANIMATE: 5, CREATE: 1, SPAWN: 3, CAMERA: 2}

    def stub(uc, address, size, user):
        arity = arities[address]
        args = [uc.reg_read(register) for register in
                (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)[:min(4, arity)]]
        if arity == 5:
            args.append(int.from_bytes(read(uc.reg_read(regs.UC_MIPS_REG_SP) + 16, 4), 'big'))
        assert len(trace) < len(events), (case, hex(address), 'unexpected call')
        event = events[len(trace)]
        actual = dict(address=address, args=args, images_sha256=fingerprint(
            {start: read(start, len(image)) for start, image in images.items()}), result=event['result'])
        assert actual == event, (case, actual, event)
        trace.append(actual)
        if address == ANIMATE and case['mutation'] == 1:
            write(SESSION + 0xA8, word(-1))
            write(SESSION + 0x9C, word((int.from_bytes(read(SESSION + 0x9C, 4), 'big') + 1) % 5))
        if address == CAMERA and case['mutation'] == 2:
            write(GLOBAL + 12, word(1))
        if address == SPAWN and case['mutation'] == 2:
            write(GLOBAL + 12, word(0))
        finish_call(event['result'])

    for address in arities:
        uc.hook_add(UC_HOOK_CODE, stub, begin=address, end=address)
    observed_breaks = []

    def observe_break(uc, address, size, user):
        observed_breaks.append([address, int.from_bytes(read(address, 4), 'big')])

    for address, data in code:
        if address == ENTRY:
            for offset in range(0, len(data), 4):
                if data[offset:offset + 4] in (word(0x0006000D), word(0x0007000D)):
                    uc.hook_add(UC_HOOK_CODE, observe_break, begin=address + offset, end=address + offset)
    uc.reg_write(regs.UC_MIPS_REG_A0, SOURCE)
    if trap is None:
        execute(ENTRY)
        assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    else:
        try:
            uc.emu_start(ENTRY, 0, count=20000)
        except UcError:
            # Unicorn clears PC on this exception; observe the actual break
            # instruction before it executes rather than reading the cleared PC.
            assert len(observed_breaks) == 1 and observed_breaks[0][1] == (trap << 16) | 13, (case, observed_breaks, trap)
        else:
            raise AssertionError((case, 'Expected division trap'))
    assert trace == events, case
    assert bool(observed_breaks) == (trap is not None)
    assert read(0x80300000, 32) == word(SOURCE) + stack_above[4:]
    uc.emu_start(READ_FPU, 0, count=1000)
    put(expected, FPU_OUT, b''.join(word(value) for value in FPU_BITS))
    for address, image in expected.items():
        assert read(address, len(image)) == bytes(image), (case, 'final', hex(address))
    assert read(0x800C8B7C, 4) == word(case['spawn_count'])
    return dict(events=trace, final_images_sha256=fingerprint(expected), trap=trap,
                state=get(expected, SESSION + 0xA8), movement=get(expected, SESSION + 0xAC), observed_breaks=observed_breaks)


def cases():
    for profile, distance, random, wave, player in itertools.product(range(9),
            (0, 8900, 9000, 9100, 24900, 25000, 25100), RANDOM_VALUES, (0, 1), range(2)):
        yield dict(kind='weighted', profile=profile, distance=distance, random=random, wave=wave, player=player)
    for phase, player, value, mutation in itertools.product(range(5), range(2),
            (-25601, -256, -1, 0, 1, 25599, 25600, 25601), range(3)):
        yield dict(kind='phase', phase=phase, player=player, value=value, mutation=mutation, profile=0)
    for progress, denominator, reset, threshold, player in itertools.product((101, 102, 103, 200),
            (-3, -1, 1, 2, 100), (1, 2, 3), (-1, 0, 99, 100), range(2)):
        yield dict(kind='reset', value=progress * 256, denominator=denominator,
                   reset=reset, reset_threshold=threshold, player=player, profile=0)
    for angle, random, player, movement in itertools.product(ANGLES, RANDOM_VALUES, range(2), (0, 1, 6)):
        yield dict(kind='angles', angle=angle, random=random, player=player, movement=movement, profile=0)
    for player, trap in itertools.product(range(2), (6, 7)):
        yield dict(kind='traps', player=player, reset=1, profile=0,
                   value=256, cutoff=-536870911 if trap == 6 else 0, denominator=-1 if trap == 6 else 0)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, retail, support, comparisons, tables = [], [], [], {}, {}
    for name in ('early_actor_decision',) + SUPPORT:
        _, source, start, end = next(record for record in MATCHING_BLOCKS if record[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target, family='actor-decision-execution', layout=layout)
        assert report['matches'], name
        comparisons[name] = report
        directory = ROOT / 'build/actor-decision-execution' / name
        data = (directory / (name + '.bin')).read_bytes()
        if name == 'early_actor_decision':
            compiled.append((start, data))
            retail.append((start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
        else:
            support.append((start, data))
        sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
        for record in source_sections(source):
            if record['rom'] is not None:
                data = sections[record['section']]['bytes']
                support.append((record['vram'], data))
                tables[record['section']] = hashlib.sha256(data).hexdigest()
    source = 'src/game/actor_groups/direction_table.c'
    records = source_sections(source)
    data_comparison = compare_unit(source, records, target, layout)
    assert data_comparison['matches']
    sections, _ = elf_sections_and_symbols(ROOT / 'build/data-comparison' / Path(source).with_suffix('') / 'compiled.elf')
    for record in records:
        data = sections[record['section']]['bytes']
        support.append((record['vram'], data))
        tables[record['section']] = hashlib.sha256(data).hexdigest()
    counts = dict(cases=0, weighted=0, phase=0, reset=0, angles=0, traps=0,
                  random_calls=0, animation_calls=0, creates=0, spawns=0, cameras=0)
    digest = hashlib.sha256()
    for index, parameters in enumerate(cases()):
        case = dict(id=index, kind='weighted', player=0, phase=index % 5, distance=9100,
                    vector=index % 4, angle=700, random=0, reroll=(0, 7, 792, -1)[index % 4],
                    profile=0, reset=0, reset_threshold=99, movement=7, cutoff=100,
                    denominator=100, value=101 * 256, wave=0, mutation=index % 3,
                    spawn_count=(0, 48, 49, 50)[index % 4])
        case.update(parameters)
        expected = run_case(retail, support, case)
        actual = run_case(compiled, support, case)
        assert actual == expected, case
        counts['cases'] += 1
        counts[case['kind']] += 1
        for address, key in ((RANDOM, 'random_calls'), (ANIMATE, 'animation_calls'),
                             (CREATE, 'creates'), (SPAWN, 'spawns'), (CAMERA, 'cameras')):
            counts[key] += sum(event['address'] == address for event in actual['events'])
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
        if counts['cases'] % 500 == 0:
            print('Compared actor decision cases:', counts, flush=True)
    assert (counts['cases'], counts['weighted'], counts['phase'], counts['reset'], counts['angles'], counts['traps']) == (3028, 1512, 240, 480, 792, 4)
    report = dict(matches=True, counts=counts, trace_sha256=digest.hexdigest(), comparisons=comparisons,
        data_comparison=data_comparison, tables_sha256=tables, target_rom_sha256=hashlib.sha256(target).hexdigest(),
        checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        helpers_sha256={name: hashlib.sha256((ROOT / 'tools' / name).read_bytes()).hexdigest() for name in
                       ('check_actor_group_path.py', 'check_actor_boundary_boss.py', 'check_boss_trigger.py')},
        emulator=dict(package='unicorn', version=version('unicorn')),
        limits=['Seven complete code units and the direction table are freshly compiled and compared.',
                'Six support units execute real arithmetic and random-wrapper code; the SDK random leaf, animation, creation, spawn and camera effects use integer and FPU ABI stubs.',
                'Guarded synthetic records and thresholds do not establish the enclosing retail table extents or all caller indices.',
                'Direction inputs are zero or cardinals; arbitrary direction quantization is outside this matrix.',
                'Normal returns restore integer saved registers, stack and F20 through F31; intentional division traps stop before restoration.',
                'Signed overflow, division and shifts characterize pinned IDO/MIPS rather than portable ISO C.',
                'This checker does not establish gameplay, real allocation, camera effects or animation/callback behavior.'])
    output = ROOT / 'build/actor-decision-execution/report.json'
    output.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed actor decision execution:', counts, output, flush=True)


if __name__ == '__main__':
    main()
