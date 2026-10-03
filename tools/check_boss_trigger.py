"""Compare boss trigger and reset execution with retail and guarded byte oracles."""

import hashlib
import itertools
import json
import math
import struct
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE
from unicorn import mips_const as regs
from check_actor_group_path import SENTINEL, word
from check_actor_boundary_boss import environment, signed, divide
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


TRIGGER, RESET = 0x8000F814, 0x8000F7D8
SOURCE, CENTER = 0x80201010, 0x80202010
PLAYER_ACTORS = (0x80203010, 0x80204010)
RESOURCE, FPU_OUT, CHILDREN = 0x80205010, 0x80206010, 0x80210010
SESSION, PLAYERS = 0x800AD138, 0x8009B190
CONTROL = 0x80073588
SEED_FPU, READ_FPU = 0x80000200, 0x80000300
SUPPORT = ('object_recovery_fixed_trig', 'short_sine', 'short_cosine',
           'object_recovery_angle_scale', 'object_recovery_direction_angle',
           'object_recovery_angle_table', 'fixed_geometry_setup')
VECTORS = ((0, 0), (1200, 0), (-1200, 0), (0, 1200), (0, -1200),
           (1200, 1200), (-1200, 1200), (-1200, -1200), (1200, -1200))
FPU_BITS = tuple(0x3F800000 + index * 0x10000 for index in range(12))
SCALES = (-32768, -1, 2028, 32767)


def single(value):
    return struct.unpack('>f', struct.pack('>f', value))[0]


def fixed_sine(angle):
    phase = angle & 4095
    index = phase & 1023
    if phase & 1024:
        index = 1023 - index
    value = math.floor(32767 * math.sin(index * math.pi / 2046))
    return divide(-value if phase & 2048 else value, 8)


def fixed_cosine(angle):
    return fixed_sine(angle + 1024)


def pattern(size, seed):
    return bytearray((index * 37 + seed) & 255 for index in range(size))


def fingerprint(images):
    digest = hashlib.sha256()
    for address, image in sorted(images.items()):
        digest.update(word(address))
        digest.update(image)
    return digest.hexdigest()


def records_for(case, original):
    if case['kind'] != 'synthetic':
        return bytearray(original)
    profile = case['profile']
    records = [[-1] * 7 for _ in range(10)]
    if profile != 0:
        for index in range(3):
            records[index] = [0, 6, 4 + index, 3, 9, 19 + index, 7 + index]
            if profile in (1, 3):
                records[index][2] = -1
            if profile in (2, 3):
                records[index][5] = -1
        if profile == 4:
            records[0][0], records[1][0] = -2, 1
        if profile == 5:
            for record in records[:3]:
                record[1], record[4] = case['stage'], 0x00800009
    return bytearray(b''.join(struct.pack('>7i', *record) for record in records))


def fpu_code():
    seed = b''
    for index, bits in enumerate(FPU_BITS):
        seed += word(0x3C080000 | (bits >> 16)) + word(0x35080000 | (bits & 65535))
        seed += word(0x44880000 | ((index + 20) << 11))
    jump = word(0x08000000 | ((SENTINEL & 0x0FFFFFFF) >> 2)) + word(0)
    seed += jump
    reader = word(0x3C080000 | (FPU_OUT >> 16)) + word(0x35080000 | (FPU_OUT & 65535))
    reader += b''.join(word(0xE5000000 | ((index + 20) << 16) | (index * 4))
                       for index in range(12)) + jump
    return [(SEED_FPU, seed), (READ_FPU, reader)]


def run_case(code, support, case, original):
    uc, write, execute, read, finish_call = environment(code + fpu_code(), support)
    images = {}

    def region(address, size, seed):
        image = pattern(size + 32, seed)
        images[address - 16] = image
        return image

    source = region(SOURCE, 124, 19)
    source[24:26] = struct.pack('>h', case['angle'])
    source[28:30] = struct.pack('>h', -17)
    source[47] = case['animation']
    source[40:44] = word(case['frame'])
    source[112:124] = word(-5000) + word(3000) + word(0xA1B2C3D4)
    center = region(CENTER, 124, 23)
    center[112:124] = word(10000) + word(-20000) + word(777)
    for index, address in enumerate(PLAYER_ACTORS):
        image = region(address, 124, 31 + index)
        vector = VECTORS[case['direction']]
        if index:
            vector = tuple(-value for value in vector)
        image[112:124] = word(-5000 + vector[0]) + word(3000 + vector[1]) + word(991)
    players = region(PLAYERS, 2 * 3508, 41)
    for index, address in enumerate(PLAYER_ACTORS):
        players[16 + index * 3508 + 8:20 + index * 3508 + 8] = word(address)
    session = region(SESSION, 328, 43)
    session[64:68] = word(case['player'])
    session[144:148] = word(CENTER)
    session[172:176] = word(case['stage'])
    resource = region(RESOURCE, 88, 47)
    resource[28:32] = word(SCALES[case['scale']])
    for index in range(9):
        child = region(CHILDREN + index * 256, 124, 51 + index)
        child[28:30] = struct.pack('>h', 37 + index)
        child[52:56] = word(RESOURCE)
    fpu = region(FPU_OUT, 48, 61)
    control = region(CONTROL, 288, 67)
    control[16:20] = word(case['id'] % 3 - 1)
    control[24:304] = records_for(case, original)
    now = 0xFFFFFF00 if case['id'] & 1 else 10000
    if case['kind'] == 'reset':
        for index in range(9):
            control[24 + index * 28:28 + index * 28] = word(index + 1)
    control[20:24] = word(now - case['elapsed'])
    fade_elapsed = (None, 0, 1, 499, 500, 0xFFFFFFFF)[case['id'] % 6]
    fade_stamp = 0 if fade_elapsed is None else (now - fade_elapsed) & 0xFFFFFFFF
    fade = region(0x800739CC, 4, 71)
    fade[16:20] = word(fade_stamp)
    clock = region(0x8009EFA0, 4, 73)
    clock[16:20] = word(now)
    stack_above = pattern(32, 79)
    write(0x80300000, bytes(stack_above))
    third = word(0x13570000 | (case['id'] & 65535))
    write(0x802FFFF8, third)
    for address, image in images.items():
        write(address, bytes(image))
    uc.emu_start(SEED_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    if case['kind'] == 'reset':
        execute(RESET)
        assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
        for index in range(9):
            control[24 + index * 28:28 + index * 28] = word(0)
        control[20:24] = word(now)
        for address, image in images.items():
            assert read(address, len(image)) == bytes(image), (case, 'reset', hex(address))
        now = (now + case['elapsed']) & 0xFFFFFFFF
        clock[16:20] = word(now)
        write(0x8009EFA0, word(now))

    events = []
    counts = dict(allocations=0, created=0, arrivals=0, colors=0, clock_advances=0)

    def emit(address, args, position=None):
        nonlocal now
        events.append(dict(address=address, args=[value & 0xFFFFFFFF for value in args],
                           images_sha256=fingerprint(images), position=position))
        if ((case['mutation'] == 1 and address == 0x80039C1C) or
                (case['mutation'] == 2 and address == 0x8001FCE4)):
            now = (now + 1001) & 0xFFFFFFFF
            clock[16:20] = word(now)
            counts['clock_advances'] += 1

    if fade_stamp != 0 and ((now - fade_stamp) & 0xFFFFFFFF) < 500:
        color = (((500 - now + fade_stamp) * 200) & 0xFFFFFFFF) // 500
        emit(0x80039C1C, [-17, color, color, 0])
        counts['colors'] += 1
    for index in range(10):
        offset = 24 + index * 28
        used, threshold, actor_resource, animation, frame, extra, count = struct.unpack('>7i', control[offset:offset + 28])
        if used == -1:
            break
        eligible = (case['stage'] < threshold or
                    (case['stage'] == threshold and case['animation'] == animation and
                     signed(frame << 8) < signed(case['frame'])))
        if used != 0 or ((now - int.from_bytes(control[20:24], 'big')) & 0xFFFFFFFF) <= 1000 or not eligible:
            continue
        if actor_resource != -1:
            attempt = counts['allocations']
            position = word(signed(10000 + divide(fixed_cosine(case['angle']) * 8000, 4096)))
            position += word(signed(-20000 + divide(fixed_sine(case['angle']) * 8000, 4096))) + third
            emit(0x800283D4, [9, 0x800B1BE8 + actor_resource * 88, 0x802FFFF0], position.hex())
            counts['allocations'] += 1
            policy = case['allocation']
            success = policy == 0 or (policy == 2 and attempt % 2 != 0) or (policy == 3 and attempt != 0)
            if success:
                counts['created'] += 1
                child_address = CHILDREN + attempt * 256
                child = images[child_address - 16]
                control[20:24] = word(now)
                scale = single(single(float(signed(SCALES[case['scale']] * 20280))) / 40960.0)
                bits = struct.unpack('>I', struct.pack('>f', scale))[0]
                emit(0x800399E4, [37 + attempt, bits])
                emit(0x80039C1C, [37 + attempt, 255, 255, 0])
                counts['colors'] += 1
                control[offset:offset + 4] = word(1)
                vector = VECTORS[case['direction']]
                if case['player']:
                    vector = tuple(-value for value in vector)
                heading = round(math.atan2(vector[1], vector[0]) * 4096 / (2 * math.pi)) & 4095 if vector != (0, 0) else 0
                child[24:26] = struct.pack('>h', heading)
                child[60:64] = word(50)
                child[124:128] = word(divide(fixed_cosine(heading) * 50, 4096))
                child[128:132] = word(divide(fixed_sine(heading) * 50, 4096))
                emit(0x80039514, [37 + attempt, heading])
        if extra != -1:
            emit(0x8001FCE4, [1, 0, extra, 1, 1, count, -1, -1])
            counts['arrivals'] += 1

    trace = []
    actual_attempts = 0

    def stub(uc, address, size, user):
        nonlocal actual_attempts
        arity = {0x800283D4: 3, 0x800399E4: 2, 0x80039C1C: 4,
                 0x80039514: 2, 0x8001FCE4: 8}[address]
        args = [uc.reg_read(register) for register in
                (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)[:min(arity, 4)]]
        if arity > 4:
            sp = uc.reg_read(regs.UC_MIPS_REG_SP)
            args += [int.from_bytes(read(sp + index * 4, 4), 'big') for index in range(4, arity)]
        actual = dict(address=address, args=args,
                      images_sha256=fingerprint({start: read(start, len(image)) for start, image in images.items()}),
                      position=read(args[2], 12).hex() if address == 0x800283D4 else None)
        assert len(trace) < len(events) and actual == events[len(trace)], (case, actual, events[len(trace):len(trace) + 1])
        trace.append(actual)
        if ((case['mutation'] == 1 and address == 0x80039C1C) or
                (case['mutation'] == 2 and address == 0x8001FCE4)):
            current = int.from_bytes(read(0x8009EFA0, 4), 'big')
            write(0x8009EFA0, word(current + 1001))
        result = None
        if address == 0x800283D4:
            policy = case['allocation']
            success = policy == 0 or (policy == 2 and actual_attempts % 2 != 0) or (policy == 3 and actual_attempts != 0)
            result = CHILDREN + actual_attempts * 256 if success else 0
            actual_attempts += 1
        finish_call(result)

    for address in (0x800283D4, 0x800399E4, 0x80039C1C, 0x80039514, 0x8001FCE4):
        uc.hook_add(UC_HOOK_CODE, stub, begin=address, end=address)
    uc.reg_write(regs.UC_MIPS_REG_A0, SOURCE)
    execute(TRIGGER)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL and trace == events
    assert read(0x802FFFF8, 4) == third and read(0x80300000, 32) == bytes(stack_above)
    uc.emu_start(READ_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    fpu[16:64] = b''.join(word(value) for value in FPU_BITS)
    for address, image in images.items():
        assert read(address, len(image)) == bytes(image), (case, 'final', hex(address))
    return dict(counts=counts, events=trace, final_images_sha256=fingerprint(images),
                unspecified_position_word=third.hex())


def cases():
    for player, stage, animation, frame, elapsed, allocation in itertools.product(
            range(2), (-1, 0, 1, 2, 3, 4, 5), (0, 1, 3, 5), (2303, 2304, 2305),
            (0, 1000, 1001, 0xFFFFFFFF), range(2)):
        yield dict(kind='retail', player=player, stage=stage, animation=animation,
                   frame=frame, elapsed=elapsed, allocation=allocation)
    for direction, angle, scale, player, allocation in itertools.product(
            range(9), (0, 1024, 2048, 3072), range(4), range(2), range(2)):
        yield dict(kind='vectors', direction=direction, angle=angle, scale=scale,
                   player=player, allocation=allocation)
    for profile, elapsed, allocation, player, mutation in itertools.product(
            range(6), (0, 1000, 1001, 0xFFFFFFFF), range(4), range(2), range(3)):
        yield dict(kind='synthetic', profile=profile, elapsed=elapsed, allocation=allocation,
                   player=player, mutation=mutation, stage=3)
    for player, stage, elapsed, allocation in itertools.product(
            range(2), (-1, 1, 3, 5), (0, 1000, 1001), range(4)):
        yield dict(kind='reset', player=player, stage=stage, elapsed=elapsed,
                   allocation=allocation)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, retail, support, comparisons, data_comparisons, tables = [], [], [], {}, {}, {}
    for name in ('early_boss_trigger', 'actor_chain_reset') + SUPPORT:
        _, source, start, end = next(record for record in MATCHING_BLOCKS if record[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target,
                               family='boss-trigger-execution', layout=layout)
        assert report['matches'], name
        comparisons[name] = report
        directory = ROOT / 'build/boss-trigger-execution' / name
        data = (directory / (name + '.bin')).read_bytes()
        if name in ('early_boss_trigger', 'actor_chain_reset'):
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
                if record['section'] == '.short_sine_data':
                    expected = [math.floor(32767 * math.sin(index * math.pi / 2046)) for index in range(1024)]
                    assert struct.unpack('>1024h', data) == tuple(expected)
    original = None
    for source in ('src/game/actor_groups/trigger_records.c',
                   'src/game/actor_groups/trigger_state.c', 'src/game/actor_groups/direction_table.c'):
        records = source_sections(source)
        report = compare_unit(source, records, target, layout)
        assert report['matches'], source
        data_comparisons[source] = report
        directory = ROOT / 'build/data-comparison' / Path(source).with_suffix('')
        sections, _ = elf_sections_and_symbols(directory / 'compiled.elf')
        for record in records:
            data = sections[record['section']]['bytes']
            support.append((record['vram'], data))
            tables[record['section']] = hashlib.sha256(data).hexdigest()
            if record['section'] == '.early_boss_trigger_records':
                original = data
    assert original is not None and len(original) == 280
    counts = dict(cases=0, retail=0, vectors=0, synthetic=0, reset=0,
                  allocations=0, created=0, arrivals=0, colors=0, clock_advances=0)
    digest = hashlib.sha256()
    for index, parameters in enumerate(cases()):
        case = dict(id=index, stage=0, animation=3, frame=2305, elapsed=1001, allocation=0,
                    angle=(index // 4 % 4) * 1024, direction=index % 9, scale=index % 4,
                    player=0, profile=0, mutation=0)
        case.update(parameters)
        expected = run_case(retail, support, case, original)
        actual = run_case(compiled, support, case, original)
        assert actual == expected, case
        counts['cases'] += 1
        counts[case['kind']] += 1
        for key, value in actual['counts'].items():
            counts[key] += value
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
        if counts['cases'] % 500 == 0:
            print('Compared boss trigger cases:', counts, flush=True)
    assert (counts['cases'], counts['retail'], counts['vectors'], counts['synthetic'], counts['reset']) == (2592, 1344, 576, 576, 96)
    result = dict(matches=True, counts=counts, trace_sha256=digest.hexdigest(),
        comparisons=comparisons, data_comparisons=data_comparisons, tables_sha256=tables,
        target_rom_sha256=hashlib.sha256(target).hexdigest(),
        checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        helpers_sha256={name: hashlib.sha256((ROOT / 'tools' / name).read_bytes()).hexdigest()
                        for name in ('check_actor_boundary_boss.py', 'check_actor_group_path.py')},
        emulator=dict(package='unicorn', version=version('unicorn')),
        limits=['Nine complete matching code units and three data-only units are freshly compiled and compared.',
                'Seven arithmetic units execute compiled code; object effects, allocation and scene arrival scheduling use integer and FPU ABI-clobbering stubs.',
                'The undefined third position word is seeded and observed as stack state; no portable C value or valid allocation semantics are asserted for it.',
                'Real MIPS mtc1 and swc1 instructions check preservation of F20 through F31; integer saved registers and stack restoration are also checked.',
                'Input directions cover zero, cardinals and equal-magnitude diagonals; arbitrary direction quantization is outside this execution matrix.',
                'Signed overflow and shifts characterize pinned IDO and MIPS behavior, not portable ISO C.',
                'Required actor, resource and player pointers are valid synthetic inputs; null or invalid required pointers are not exercised.',
                'This checker does not establish complete gameplay, rendering, allocation or scene-arrival behavior.'])
    output = ROOT / 'build/boss-trigger-execution/report.json'
    output.write_text(json.dumps(result, indent=2) + '\n')
    print('Passed boss trigger execution:', counts, output, flush=True)


if __name__ == '__main__':
    main()
