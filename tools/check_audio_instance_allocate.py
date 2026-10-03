"""Check audio instance allocation against retail MIPS and an array model.

Sequence validation, interrupt gating and voice initialization are recorded ABI
boundaries. This checks the allocator's selection, counters and memory effects;
it does not simulate the audio device or claim to validate the boundary callees.
"""

import hashlib
import itertools
import json
import struct
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE
from unicorn import mips_const as regs

from check_actor_group_path import machine, word
from compare_startup import compare_block, SymbolLayoutSnapshot
from rom import ROOT, validate


NAME = 'audio_instance_allocate'
ENTRY, END = 0x8005396C, 0x80053C50
CONTEXT, INSTANCES, VOICES = 0x80201010, 0x80202010, 0x80210010
SLOT, TRACKS, PROPERTIES, INDICES = 0x80220010, 0x80221010, 0x80223010, 0x80240010
CONTEXT_POINTER, CONFIGURATION = 0x801902EC, 0x8008D844
STACK = 0x80300000
BOUNDARIES = {0x80052ACC: 1, 0x8005895C: 0, 0x8005899C: 0,
              0x8005362C: 3, 0x800538F8: 2}
CALLER_SAVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                     ('V0', 'V1', 'A0', 'A1', 'A2', 'A3',
                      'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9'))


def occupied(pattern, index, count):
    if pattern == 'none':
        return False
    if pattern == 'all':
        return True
    if pattern == 'last-free':
        return index != count - 1
    if pattern == 'alternating':
        return index % 2 == 0
    raise ValueError(pattern)


def scenario(case):
    instance_limit, voice_limit, instance_pattern, voice_pattern, requested, flags, seed, valid = case
    instance_count, voice_count = instance_limit & 255, voice_limit & 255
    images = {}

    def area(address, size, salt):
        data = bytearray((index * 37 + salt + seed) & 255 for index in range(size))
        images[address] = data
        return data

    context = area(CONTEXT, 36, 19)
    context[4:6] = bytes((seed, seed))
    context[24:32] = word(INSTANCES) + word(VOICES)
    instances = area(INSTANCES, max(instance_count, 1) * 24, 31)
    voices = area(VOICES, max(voice_count, 1) * 80, 43)
    vectors = area(INDICES, max(instance_count, 1) * 256, 59)
    slot = area(SLOT, 16, 71)
    slot[:2] = struct.pack('>h', requested)
    slot[12:16] = word(TRACKS)
    area(TRACKS, 256 * 12, 83)
    area(PROPERTIES, 20, 97)
    images[CONTEXT_POINTER] = bytearray(word(CONTEXT))
    images[CONFIGURATION] = bytearray(word(instance_limit) + word(voice_limit))
    for index in range(max(instance_count, 1)):
        offset = index * 24
        instances[offset] = (seed & 127) | (128 if occupied(instance_pattern, index, instance_count) else 0)
        instances[offset + 4:offset + 6] = bytes((seed, seed))
        instances[offset + 12:offset + 16] = word(INDICES + index * 256)
    for index in range(max(voice_count, 1)):
        offset = index * 80
        voices[offset] = (seed & 127) | (128 if occupied(voice_pattern, index, voice_count) else 0)
        voices[offset + 1] = index

    expected = {address: bytearray(data) for address, data in images.items()}
    calls = [[0x80052ACC, [0x12345]]]
    selected_instance = next((index for index in range(instance_count)
                              if not instances[index * 24] & 128), None)
    selected_voices = []
    returned = 0
    if valid:
        calls.append([0x8005895C, []])
        if selected_instance is not None:
            available = [index for index in range(voice_count) if not voices[index * 80] & 128]
            selected_voices = available[:requested] if requested > 0 else available
            instance_offset = selected_instance * 24
            for track, index in enumerate(selected_voices):
                voice = VOICES + index * 80
                calls.extend([[0x8005362C, [voice, TRACKS + track * 12, PROPERTIES]],
                              [0x800538F8, [voice, TRACKS + track * 12]]])
                expected[VOICES][index * 80 + 2] = selected_instance
                # The initializer ABI boundary sets the allocated flag. Other
                # byte bits remain observable to the allocator's flag updates.
                expected[VOICES][index * 80] |= 128
                if flags:
                    expected[VOICES][index * 80] |= 48
                else:
                    expected[VOICES][index * 80] &= ~48
            count = len(selected_voices)
            if count:
                instance = expected[INSTANCES]
                instance[instance_offset] = ((instance[instance_offset] | 128 | 64)
                                            if flags else (instance[instance_offset] | 128) & ~64)
                instance[instance_offset + 1] = 0 if flags else 1
                instance[instance_offset + 2:instance_offset + 4] = struct.pack('>H', 0x2345)
                instance[instance_offset + 4] = (seed + count) & 255
                instance[instance_offset + 5] = (seed + (0 if flags else count)) & 255
                instance[instance_offset + 6:instance_offset + 8] = bytes((128, 64))
                instance[instance_offset + 8:instance_offset + 12] = word(0x89ABCDEF)
                expected[CONTEXT][4] = (seed + 1) & 255
                expected[CONTEXT][5] = (seed + count) & 255
                start = selected_instance * 256
                expected[INDICES][start:start + count] = bytes(selected_voices)
                returned = selected_instance + 1
        calls.append([0x8005899C, []])
    return images, expected, calls, returned, selected_instance, selected_voices


def run_allocator(code, case):
    images, expected, expected_calls, expected_result, selected_instance, selected_voices = scenario(case)
    uc, write, execute = machine([(ENTRY, code)], [])

    def read(address, length):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, length))

    guard = bytes(range(0xD0, 0xE0))
    for address, data in images.items():
        write(address - 16, guard + bytes(data) + guard)
    stack_arguments = word(PROPERTIES) + b'\xC9' * 44
    write(STACK + 16, stack_arguments)
    write(STACK - 128, b'\xB7' * 16)
    trace = []

    def boundary(uc, address, size, user):
        arguments = [uc.reg_read(register) for register in
                     (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2)[:BOUNDARIES[address]]]
        event = [address, arguments]
        assert len(trace) < len(expected_calls) and event == expected_calls[len(trace)], (case, event, expected_calls)
        trace.append(event)
        if address == 0x8005362C:
            assert read(arguments[0] + 2, 1) == bytes((selected_instance,))
            write(arguments[0], bytes((read(arguments[0], 1)[0] | 128,)))
        for index, register in enumerate(CALLER_SAVED):
            uc.reg_write(register, 0xB1230000 + index * 257)
        uc.reg_write(regs.UC_MIPS_REG_V0, int(case[-1]) if address == 0x80052ACC else 0)
        uc.reg_write(regs.UC_MIPS_REG_PC, uc.reg_read(regs.UC_MIPS_REG_RA))

    for address in BOUNDARIES:
        uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)
    for register, value in zip((regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3),
                               (SLOT, 0x12345, 0x89ABCDEF, case[5] & 0xFFFFFFFF)):
        uc.reg_write(register, value)
    execute(ENTRY)
    assert trace == expected_calls
    returned = uc.reg_read(regs.UC_MIPS_REG_V0)
    assert returned == expected_result, (case, returned, expected_result)
    digest = hashlib.sha256()
    for address, data in expected.items():
        observed = read(address - 16, len(data) + 32)
        assert observed == guard + bytes(data) + guard, (case, hex(address))
        digest.update(word(address) + observed)
    assert read(STACK + 16, len(stack_arguments)) == stack_arguments
    assert read(STACK - 128, 16) == b'\xB7' * 16
    return dict(returned=returned, trace=trace, state_sha256=digest.hexdigest(),
                allocated=len(selected_voices) if case[-1] and selected_instance is not None else 0)


def cases():
    for instance_pattern, voice_pattern, requested, flags, seed in itertools.product(
            ('none', 'all', 'alternating', 'last-free'),
            ('none', 'all', 'alternating', 'last-free'),
            (1, 3, 8, 0, -1), (0, 1), (0, 255)):
        yield (4, 6, instance_pattern, voice_pattern, requested, flags, seed, True)
    for limits, valid, flags in itertools.product(
            ((0, 6), (4, 0), (256, 6), (4, 256), (0x104, 0x106),
             (255, 255), (1, 255), (255, 1)), (False, True), (0, -1)):
        yield (*limits, 'last-free', 'alternating', 255, flags, 254, valid)
    for requested in (-32768, 32767):
        yield (3, 5, 'alternating', 'none', requested, 0, 253, True)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    comparison = compare_block(NAME, 'src/game/' + NAME + '.c', ENTRY,
                               ENTRY - 0x80000000 + 0xC00, END - 0x80000000 + 0xC00,
                               target, family='audio-allocation-execution', layout=layout)
    assert comparison['matches'], comparison['different_words'][:8]
    output = ROOT / 'build/audio-allocation-execution'
    compiled = (output / NAME / (NAME + '.bin')).read_bytes()
    retail = target[ENTRY - 0x80000000 + 0xC00:END - 0x80000000 + 0xC00]
    counts = dict(cases=0, returned_zero=0, allocated_voices=0)
    digest = hashlib.sha256()
    for case in cases():
        expected = run_allocator(retail, case)
        actual = run_allocator(compiled, case)
        assert actual == expected, (case, expected, actual)
        counts['cases'] += 1
        counts['returned_zero'] += int(actual['returned'] == 0)
        counts['allocated_voices'] += actual['allocated']
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
        if counts['cases'] % 100 == 0:
            print('Compared', counts['cases'], 'audio allocator cases.', flush=True)
    result = dict(matches=True, counts=counts, comparison=comparison,
                  trace_sha256=digest.hexdigest(), emulator=dict(package='unicorn', version=version('unicorn')),
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  machine_helper_sha256=hashlib.sha256((ROOT / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
                  target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  limits=['Complete allocator bytes are independently matched before execution.',
                          'Validation, interrupt gating and voice setup/binding are checked ABI stubs.',
                          'The array model checks slot selection, partial allocation, flag preservation, counters and all guarded memory.',
                          'High configuration bits, zero/negative requested counts, byte-counter wrap and callee-saved registers are exercised.',
                          'Voice setup, interrupt hardware and whole-game playback are outside this checker.'])
    (output / 'report.json').write_text(json.dumps(result, indent=2) + '\n')
    print('Passed audio instance allocation:', counts, output / 'report.json', flush=True)


if __name__ == '__main__':
    main()
