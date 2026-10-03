"""Execute complete actor movement with real trigonometry and guarded byte oracles."""

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
from check_boss_trigger import (fixed_sine, fixed_cosine, fpu_code, FPU_OUT,
                               FPU_BITS, SEED_FPU, READ_FPU, pattern, fingerprint)
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


ENTRY, ACTOR = 0x80010A3C, 0x80201010
SESSION, RECORDS, ALTERNATE, DELTA = 0x800AD138, 0x80210010, 0x80220010, 0x8009EF94
COSINE, SINE, OBJECT = 0x8003CC88, 0x8003CC58, 0x80039514
SUPPORT = ('object_recovery_fixed_trig', 'short_sine', 'short_cosine', 'fixed_geometry_setup')
MODES = (-1, 0, 1, 2, 3, 4, 5, 6, 255)
ANGLES = (-32768, -4097, -4096, -4095, -2048, -1024, -1, 0, 1,
          1024, 2048, 4095, 4096, 32767)
RATES = (0, 1, -1, 50, -50, 0x40000001, -0x80000000, 0x7FFFFFFF)


def run_case(code, support, case):
    uc, write, execute, read, finish_call = environment(code + fpu_code(), support)
    images = {}
    for index, (address, size) in enumerate(((ACTOR, 124), (SESSION, 328),
            (RECORDS, 1020), (ALTERNATE, 1020), (DELTA, 4), (FPU_OUT, 48))):
        images[address - 16] = pattern(size + 32, index * 17 + 19)

    def put(state, address, data):
        for start, image in state.items():
            if start <= address and address + len(data) <= start + len(image):
                image[address - start:address - start + len(data)] = data
                return
        raise AssertionError(('Outside guarded regions', hex(address)))

    def get(state, address, size=4):
        for start, image in state.items():
            if start <= address and address + size <= start + len(image):
                return int.from_bytes(image[address - start:address - start + size], 'big', signed=True)
        raise AssertionError(hex(address))

    def put_short(state, address, value):
        put(state, address, (value & 65535).to_bytes(2, 'big'))

    def rate(state, mode=None):
        index = get(state, SESSION + 0xAC) if mode is None else mode
        assert 0 <= index < 6
        address = (get(state, SESSION + 0xB4) & 0xFFFFFFFF) + get(state, SESSION + 0x9C) * 204 + 40 + index * 12
        return get(state, address)

    def mutate(state, address, ordinal):
        mutation = case['mutation']
        if address in (COSINE, SINE) and ordinal == 1:
            if mutation == 1:
                put(state, SESSION + 0x9C, word((get(state, SESSION + 0x9C) + 1) % 5))
            elif mutation == 2:
                put(state, SESSION + 0xB4, word(ALTERNATE))
            elif mutation == 3:
                put(state, SESSION + 0xAC, word((get(state, SESSION + 0xAC) + 1) % 6))
            elif mutation == 4:
                mode = get(state, SESSION + 0xAC)
                if 0 <= mode < 6:
                    pointer = (get(state, SESSION + 0xB4) & 0xFFFFFFFF) + get(state, SESSION + 0x9C) * 204 + 40 + mode * 12
                    put(state, pointer, word(signed(-get(state, pointer) - 1)))
            elif mutation == 5:
                put_short(state, ACTOR + 8, -32768 if case['angle'] >= 0 else 32767)
            elif mutation == 7:
                put(state, SESSION + 0xB0, word(0 if get(state, SESSION + 0xB0) == 4 else 4))
        if address == OBJECT and ordinal == 1 and mutation == 6:
            put(state, SESSION + 0xB0, word(4))
            put(state, SESSION + 0x9C, word((get(state, SESSION + 0x9C) + 1) % 5))
        if address in (COSINE, SINE) and mutation == 8:
            put(state, SESSION + 0x9C, word((get(state, SESSION + 0x9C) + 1) % 5))
            put(state, SESSION + 0xB4, word(ALTERNATE if (get(state, SESSION + 0xB4) & 0xFFFFFFFF) == RECORDS else RECORDS))

    for offset, value in ((0x9C, case['phase']), (0xAC, case['mode']),
                          (0xB0, case['callback']), (0xB4, RECORDS)):
        put(images, SESSION + offset, word(value))
    put_short(images, ACTOR + 8, case['angle'])
    put_short(images, ACTOR + 12, -17 if case['id'] & 1 else 32767)
    put(images, ACTOR + 0x2C, word(777))
    put(images, ACTOR + 0x6C, word(-12345) + word(23456))
    put(images, DELTA, word(case['delta']))
    for table in (RECORDS, ALTERNATE):
        for phase in range(5):
            for mode in range(6):
                value = case['rate'] if phase == case['phase'] and table == RECORDS else (
                    (phase + 1) * 100 + mode * 7) * (-1 if table == ALTERNATE else 1)
                put(images, table + phase * 204 + 40 + mode * 12, word(value))
    for address, image in images.items():
        write(address, bytes(image))
    stack_above = bytes(pattern(32, 151))
    write(0x80300000, stack_above)
    uc.emu_start(SEED_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    expected = {address: bytearray(image) for address, image in images.items()}
    events = []
    oracle_ordinals = {COSINE: 0, SINE: 0, OBJECT: 0}
    oracle_trig = 0

    def emit(address, args):
        nonlocal oracle_trig
        oracle_ordinals[address] += 1
        result = None
        if address in (COSINE, SINE):
            oracle_trig += 1
            result = (fixed_cosine if address == COSINE else fixed_sine)(args[0])
        events.append(dict(address=address, args=[value & 0xFFFFFFFF for value in args],
                           images_sha256=fingerprint(expected), result=result))
        mutate(expected, address, oracle_trig if address != OBJECT else oracle_ordinals[OBJECT])
        return result

    def angle():
        return get(expected, ACTOR + 8, 2)

    def velocity(sideways=False, base=False):
        argument = angle() - 1024 if sideways else angle()
        if sideways:
            argument -= divide(argument, 4096) * 4096
        value = emit(COSINE, [argument])
        put(expected, ACTOR + 0x6C, word(divide(signed(value * rate(expected, 0 if base else None)), 4096)))
        argument = angle() - 1024 if sideways else angle()
        if sideways:
            argument -= divide(argument, 4096) * 4096
        value = emit(SINE, [argument])
        put(expected, ACTOR + 0x70, word(divide(signed(value * rate(expected, 0 if base else None)), 4096)))

    mode = case['mode']
    if mode == 4:
        put(expected, ACTOR + 0x2C, word(rate(expected)))
        if rate(expected) != 0:
            velocity(sideways=True)
    elif mode in (0, 1):
        put(expected, ACTOR + 0x2C, word(rate(expected)))
        velocity()
        emit(OBJECT, [get(expected, ACTOR + 12, 2), angle()])
    elif mode in (2, 3):
        turn = signed(rate(expected) * get(expected, DELTA))
        put(expected, ACTOR + 0x2C, word(0))
        put_short(expected, ACTOR + 8, signed(angle() + turn))
        value = angle()
        put_short(expected, ACTOR + 8, value - divide(value, 4096) * 4096)
        emit(COSINE, [angle()])
        put(expected, ACTOR + 0x6C, word(0))
        emit(SINE, [angle()])
        put(expected, ACTOR + 0x70, word(0))
        emit(OBJECT, [get(expected, ACTOR + 12, 2), angle()])
    elif mode != 5:
        put(expected, ACTOR + 0x2C, word(0))
        emit(COSINE, [angle()])
        put(expected, ACTOR + 0x6C, word(0))
        emit(SINE, [angle()])
        put(expected, ACTOR + 0x70, word(0))
        emit(OBJECT, [get(expected, ACTOR + 12, 2), angle()])
    if get(expected, SESSION + 0xB0) == 4:
        put(expected, ACTOR + 0x2C, word(rate(expected, 0)))
        velocity(base=True)
        emit(OBJECT, [get(expected, ACTOR + 12, 2), angle()])

    trace, pending = [], None
    actual_trig, objects = 0, 0

    def current_images():
        return {address: bytearray(read(address, len(image))) for address, image in images.items()}

    def apply_mutation(address, ordinal):
        state = current_images()
        mutate(state, address, ordinal)
        for start, image in state.items():
            write(start, bytes(image))

    def observe(uc, address, size, user):
        nonlocal pending, actual_trig, objects
        if pending is not None and address == pending['return']:
            result = signed(uc.reg_read(regs.UC_MIPS_REG_V0))
            assert result == pending['result'], (case, pending, result)
            apply_mutation(pending['address'], pending['ordinal'])
            pending = None
            finish_call(result & 0xFFFFFFFF)
            return
        if address not in (COSINE, SINE, OBJECT):
            return
        args = [uc.reg_read(regs.UC_MIPS_REG_A0)]
        result = None
        if address == OBJECT:
            args.append(uc.reg_read(regs.UC_MIPS_REG_A1))
        else:
            result = (fixed_cosine if address == COSINE else fixed_sine)(signed(args[0]))
        trace.append(dict(address=address, args=args, images_sha256=fingerprint(current_images()), result=result))
        if address == OBJECT:
            objects += 1
            apply_mutation(address, objects)
            finish_call()
        else:
            actual_trig += 1
            assert pending is None
            pending = dict(address=address, return_=uc.reg_read(regs.UC_MIPS_REG_RA),
                           result=result, ordinal=actual_trig)
            pending['return'] = pending.pop('return_')

    uc.hook_add(UC_HOOK_CODE, observe)
    uc.reg_write(regs.UC_MIPS_REG_A0, ACTOR)
    unused = 0x13570000 | (case['id'] & 65535)
    uc.reg_write(regs.UC_MIPS_REG_A1, unused)
    execute(ENTRY)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL and pending is None
    assert trace == events, (case, trace, events)
    assert read(0x80300000, 32) == stack_above[:4] + word(unused) + stack_above[8:]
    uc.emu_start(READ_FPU, 0, count=1000)
    put(expected, FPU_OUT, b''.join(word(value) for value in FPU_BITS))
    for address, image in expected.items():
        assert read(address, len(image)) == bytes(image), (case, 'final', hex(address))
    return dict(events=trace, final_images_sha256=fingerprint(expected),
                trigonometric_calls=actual_trig, object_calls=objects)


def cases():
    for mode, angle, rate, callback in itertools.product(MODES, ANGLES, RATES, (-1, 0, 4, 5)):
        yield dict(kind='arithmetic', mode=mode, angle=angle, rate=rate, callback=callback)
    for mode, mutation, callback, rate in itertools.product(MODES, range(1, 9), (-1, 0, 4, 5), (0, -50)):
        yield dict(kind='mutation', mode=mode, mutation=mutation, callback=callback, rate=rate)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, retail, support, comparisons, tables = [], [], [], {}, {}
    for name in ('early_actor_movement',) + SUPPORT:
        _, source, start, end = next(record for record in MATCHING_BLOCKS if record[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target, family='actor-movement-execution', layout=layout)
        assert report['matches'], name
        comparisons[name] = report
        directory = ROOT / 'build/actor-movement-execution' / name
        data = (directory / (name + '.bin')).read_bytes()
        if name == 'early_actor_movement':
            compiled.append((start, data))
            retail.append((start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
        else:
            support.append((start, data))
        sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
        for record in source_sections(source):
            if record['rom'] is not None:
                data = sections[record['section']]['bytes']
                tables[record['section']] = hashlib.sha256(data).hexdigest()
                if name == 'early_actor_movement':
                    compiled.append((record['vram'], data))
                    retail.append((record['vram'], target[record['rom']:record['rom'] + record['size']]))
                else:
                    support.append((record['vram'], data))
                if record['section'] == '.short_sine_data':
                    expected = [math.floor(32767 * math.sin(index * math.pi / 2046)) for index in range(1024)]
                    assert struct.unpack('>1024h', data) == tuple(expected)
    counts = dict(cases=0, arithmetic=0, mutation=0, trigonometric_calls=0, object_calls=0)
    digest = hashlib.sha256()
    for index, parameters in enumerate(cases()):
        case = dict(id=index, kind='arithmetic', mode=0, angle=(-1, 0, 1024, 32767)[index % 4],
                    rate=50, callback=-1, phase=index % 5, delta=(-2, 0, 1, 2, 0x7FFFFFFF)[index % 5], mutation=0)
        case.update(parameters)
        expected = run_case(retail, support, case)
        actual = run_case(compiled, support, case)
        assert actual == expected, case
        counts['cases'] += 1
        counts[case['kind']] += 1
        counts['trigonometric_calls'] += actual['trigonometric_calls']
        counts['object_calls'] += actual['object_calls']
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
        if counts['cases'] % 500 == 0:
            print('Compared movement cases:', counts, flush=True)
    assert (counts['cases'], counts['arithmetic'], counts['mutation']) == (4608, 4032, 576)
    report = dict(matches=True, counts=counts, trace_sha256=digest.hexdigest(), comparisons=comparisons,
        tables_sha256=tables, target_rom_sha256=hashlib.sha256(target).hexdigest(),
        checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        helpers_sha256={name: hashlib.sha256((ROOT / 'tools' / name).read_bytes()).hexdigest() for name in
            ('check_actor_group_path.py', 'check_actor_boundary_boss.py', 'check_boss_trigger.py')},
        emulator=dict(package='unicorn', version=version('unicorn')),
        limits=['Five complete code units and their initialized tables are freshly compiled and compared.',
                'Trigonometry executes real matching code; mathematical waveform, wrapped products, signed remainder and guarded state provide independent oracles.',
                'Object-angle effects use integer and FPU ABI stubs; real trigonometric results also pass through ABI clobbers before the handler resumes.',
                'Synthetic mutations exercise fresh phase, movement, record pointer, rate, actor angle and callback reads without asserting real callees mutate them.',
                'Caller home slot at entry SP + 4 receives the unused second argument; other 28 seeded bytes remain unchanged.',
                'Integer saved registers, stack and F20 through F31 are checked on every normal return.',
                'Signed overflow, narrowing and shifts describe pinned IDO/MIPS behavior rather than portable ISO C.',
                'Synthetic record bounds do not establish enclosing retail table extents, callers or complete gameplay/rendering.'])
    output = ROOT / 'build/actor-movement-execution/report.json'
    output.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed movement execution:', counts, output, flush=True)


if __name__ == '__main__':
    main()
