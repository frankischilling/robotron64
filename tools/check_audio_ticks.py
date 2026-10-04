"""Check timing and sequence ticks against retail MIPS and independent byte models.

Command and backend callbacks are recorded ABI boundaries. The complete real
decoder executes in both images; this checker does not synthesize audio.
"""

import hashlib
import itertools
import json
import subprocess
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word
from check_audio_instance_allocate import CALLER_SAVED
from check_audio_seeking import encode, LENGTHS
from compare_startup import compare_block, SymbolLayoutSnapshot, external_assignments
from compare_data import compare_unit, comparison_directory
from owned_sections import source_sections, elf_sections_and_symbols
from rom import ROOT, validate

TIMING, SEQUENCE, DECODER = 0x80058A58, 0x8005A9AC, 0x80059580
VOICES, CONTEXT, OPS, OPS_ALT = 0x80201010, 0x80203010, 0x80205010, 0x80206010
STREAMS, BRANCHES, STACK = 0x80210010, 0x80220010, 0x80300000
CLOCK, STATIC, DECODE_STATE, TABLES = 0x8008D868, 0x80192800, 0x80192750, 0x8008D96C
GUARD = bytes(range(16))
SPECS = (('audio_timing_tick', 'src/game/audio/timing_tick.c', TIMING, 0x80058ADC),
         ('audio_sequence_tick', 'src/game/audio/sequence_tick.c', SEQUENCE, 0x8005AD50),
         ('audio_stream_variable_read', 'src/game/audio_stream_variable_read.c', DECODER, 0x800595D4))


def get(data, offset=0):
    return int.from_bytes(data[offset:offset + 4], 'big')


def put(data, offset, value):
    data[offset:offset + 4] = word(value)


def clock_model(case):
    tick, time, fraction, gate, mutation = case
    fraction = (fraction + 0x85555) & 0xFFFFFFFF
    state = bytearray(word(tick + 1) + word(time + (fraction >> 16)) + word(gate) + word(fraction & 65535))
    trace = []
    if gate:
        trace.append([0x80059438, state.hex()])
        if mutation:
            state[:] = word(0xFFFFFFFF) + word(0xFFFFFFF0) + word(0) + word(0xDEADBEEF)
        trace.append([SEQUENCE, state.hex()])
        if mutation:
            put(state, 4, get(state, 4) + 0x31)
    return state, trace


def poison(uc):
    for i, register in enumerate(CALLER_SAVED):
        uc.reg_write(register, 0xD1350000 + i * 256)
    uc.reg_write(regs.UC_MIPS_REG_PC, uc.reg_read(regs.UC_MIPS_REG_RA))


def run_clock(code, case):
    initial = b''.join(word(case[i]) for i in (0, 1, 3, 2))
    expected, events = clock_model(case)
    uc, write, execute = machine([(TIMING, code)], [])
    write(CLOCK - 16, GUARD + initial + GUARD)
    write(STACK - 48, b'\xD6' * 16)
    write(STACK + 16, b'\xC9' * 32)
    trace = []

    def read(address, length):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, length))

    def boundary(uc, address, size, user):
        if address not in (0x80059438, SEQUENCE):
            return
        trace.append([address, read(CLOCK, 16).hex()])
        assert trace[-1] == events[len(trace) - 1], (case, trace, events)
        assert uc.reg_read(regs.UC_MIPS_REG_SP) == STACK - 24
        if case[-1]:
            if address == 0x80059438:
                write(CLOCK, word(0xFFFFFFFF) + word(0xFFFFFFF0) + word(0) + word(0xDEADBEEF))
            else:
                write(CLOCK + 4, word(get(read(CLOCK + 4, 4)) + 0x31))
        poison(uc)

    uc.hook_add(UC_HOOK_CODE, boundary)
    execute(TIMING)
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == 0
    assert trace == events, (case, trace, events)
    assert read(CLOCK - 16, 48) == GUARD + expected + GUARD, case
    assert read(STACK - 48, 16) == b'\xD6' * 16
    assert read(STACK + 16, 32) == b'\xC9' * 32
    return [trace, expected.hex()]


def handler_address(family, code=0, backend=0):
    if family == 'sequence':
        return 0x80001000 + code * 16
    base = 0x80000300 if backend else 0x80000100
    return base + {'backend': code, 'stop': 5, 'frame': 2}[family] * 16


def sequence_fixture(case):
    count, budget, pattern, codes, wait, elapsed, fraction, rate, position, flags, backend, mutation, entry = case
    voices = bytearray((i * 37 + 91) & 255 for i in range(max(count, 1) * 80))
    images = {VOICES: voices, CONTEXT: bytearray((i * 13 + 53) & 255 for i in range(36)),
              STATIC: bytearray(b'\x93' * 16), DECODE_STATE: bytearray(b'\x95' * 8),
              CLOCK: bytearray(word(0xFFFFFFFF) + word(0xFFFFFFF0) + word(1) + word(0xFFF0)),
              0x8008D800: bytearray(word(OPS) + word(OPS_ALT)),
              0x8008DBFC: bytearray(word(OPS_ALT)), TABLES: bytearray(88)}
    images[CONTEXT][5] = budget
    for b, address in ((0, OPS), (1, OPS_ALT)):
        images[address] = bytearray(b''.join(word(handler_address('backend', i, b)) for i in range(19)))
    images[TABLES][:68] = b''.join(word(handler_address('sequence', i)) for i in range(19, 36))
    images[TABLES][72] = count
    put(images[TABLES], 76, VOICES)
    put(images[TABLES], 84, CONTEXT)
    for i in range(max(count, 1)):
        offset = i * 80
        active = pattern == 'all' or pattern == 'alternating' and i % 2 == 0 or pattern == 'last' and i == count - 1
        voices[offset], voices[offset + 16] = (flags & 127) | (128 if active else 0), backend
        for field, value in ((8, wait), (28, rate), (32, fraction), (36, elapsed),
                             (40, position), (44, 0xFFFFFFFE), (48, STREAMS + i * 256), (52, STREAMS + i * 256)):
            put(voices, offset + field, value)
        stream = bytearray()
        for code in codes:
            stream += bytes((code,)) + bytes((code ^ 0x5A,)) * max(0, LENGTHS[code] - 1 if code < 36 else 0)
            stream += encode(wait)
        stream += b'\x1D'
        images[STREAMS + i * 256] = stream
        images[BRANCHES + i * 256] = bytearray(bytes((7, 0x31, 0x32)) + encode(wait) + b'\x1D')
    return images


def apply_handler(state, case, family, code, address, changed):
    voices = state[VOICES]
    offset = address - VOICES
    if family == 'sequence' and (code == 29 or code < 7 or code >= 36):
        voices[offset] &= 127
        return changed
    if family not in ('backend', 'sequence') or changed or case[-2] == 'none':
        return changed
    mutation = case[-2]
    if mutation == 'pause':
        voices[offset] |= 16
    elif mutation == 'retire':
        voices[offset] &= 127
        voices[offset] |= 2
    elif mutation == 'redirect':
        put(voices, offset + 52, BRANCHES + (offset // 80) * 256)
        put(voices, offset + 8, 17)
        voices[offset] |= 2
    elif mutation == 'opcode':
        put(state[STATIC], 12, 35)
    elif mutation == 'cursor':
        put(state[STATIC], 0, VOICES + (80 if case[0] > 1 else 0))
    elif mutation == 'backend':
        voices[offset + 16] = 1
    else:
        raise ValueError(mutation)
    return True


def sequence_model(case, images):
    state = {address: bytearray(data) for address, data in images.items()}
    voices, scratch = state[VOICES], state[STATIC]
    trace, changed = [], False

    def byte(address):
        for first, data in state.items():
            if first <= address < first + len(data):
                return data[address - first]
        raise ValueError(hex(address))

    def dispatch(family, code, voice):
        nonlocal changed
        b = voices[voice - VOICES + 16] != 0
        opcode = code if 7 <= code < 36 else 29
        address = handler_address(family, opcode, b)
        trace.append([address, voice, scratch.hex(), voices.hex()])
        changed = apply_handler(state, case, family, code, voice, changed)

    def decode(voice):
        offset = voice - VOICES
        address = get(voices, offset + 52)
        trace.append([DECODER, address, voice + 8, scratch.hex(), voices.hex()])
        first = byte(address)
        value = first & 127
        address += 1
        if first & 128:
            while True:
                last = byte(address)
                value = ((value << 7) + (last & 127)) & 0xFFFFFFFF
                address += 1
                if not last & 128:
                    state[DECODE_STATE][4] = last
                    break
        put(state[DECODE_STATE], 0, value)
        put(voices, offset + 8, value)
        put(voices, offset + 52, address)

    if case[-1] == TIMING:
        clock, _ = clock_model((0xFFFFFFFF, 0xFFFFFFF0, 0xFFF0, 1, False))
        state[CLOCK] = clock
        trace.append([0x80059438, clock.hex()])
    scratch[4] = case[1]
    if case[1]:
        put(scratch, 8, case[0])
        cursor = VOICES
        put(scratch, 0, cursor)
        for _ in range(300):
            previous = get(scratch, 8)
            put(scratch, 8, previous - 1)
            if not previous:
                put(scratch, 0, cursor)
                break
            offset = cursor - VOICES
            if voices[offset] & 128:
                put(scratch, 0, cursor)
                if not voices[offset] & 16:
                    fraction = (get(voices, offset + 32) + get(voices, offset + 28)) & 0xFFFFFFFF
                    put(voices, offset + 40, get(voices, offset + 40) + (fraction >> 16))
                    put(voices, offset + 36, get(voices, offset + 36) + (fraction >> 16))
                    put(voices, offset + 32, fraction & 65535)
                    if voices[offset] & 8 and get(voices, offset + 40) >= get(voices, offset + 44):
                        dispatch('stop', 0, cursor)
                    else:
                        for _ in range(100):
                            offset = cursor - VOICES
                            if (get(voices, offset + 36) < get(voices, offset + 8) or
                                    not voices[offset] & 128 or voices[offset] & 16):
                                break
                            put(voices, offset + 36, get(voices, offset + 36) - get(voices, offset + 8))
                            code = byte(get(voices, offset + 52))
                            put(scratch, 12, code)
                            family = 'backend' if 7 <= code < 19 else 'sequence'
                            dispatch(family, code, cursor)
                            cursor = get(scratch)
                            offset = cursor - VOICES
                            if family == 'backend' or 19 <= code < 36 and voices[offset] & 128 and not voices[offset] & 2:
                                opcode = get(scratch, 12)
                                put(voices, offset + 52, get(voices, offset + 52) + LENGTHS[opcode])
                                decode(cursor)
                            elif 19 <= code < 36:
                                voices[offset] &= 253
                            put(scratch, 0, cursor)
                        else:
                            raise AssertionError('Command oracle exceeded its bound')
                scratch[4] = (scratch[4] - 1) & 255
                cursor = get(scratch)
                if not scratch[4]:
                    break
            cursor += 80
        else:
            raise AssertionError('Voice oracle exceeded its bound')
    dispatch('frame', 0, VOICES)
    return state, trace


def run_sequence(code, decoder, lengths, case):
    images = sequence_fixture(case)
    try:
        expected, events = sequence_model(case, images)
    except (IndexError, ValueError) as error:
        raise AssertionError(case) from error
    uc, write, execute = machine(code + [(DECODER, decoder)], [(0x8008D8D0, lengths)])
    for address, data in images.items():
        write(address - 16, GUARD + data + GUARD)
    write(0x8008D8D0 - 16, GUARD + lengths + GUARD)
    write(STACK - 96, b'\xD6' * 16)
    write(STACK + 16, b'\xC9' * 32)
    trace, changed = [], False
    handlers = {handler_address('sequence', i): 'sequence' for i in range(19, 36)}
    handlers.update({handler_address('backend', i, b): 'backend' for i in range(7, 19) for b in (0, 1)})
    handlers.update({handler_address(family, 0, b): family for family in ('frame', 'stop') for b in (0, 1)})

    def read(address, length):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, length))

    def boundary(uc, address, size, user):
        nonlocal changed
        if address == 0x80059438:
            trace.append([address, read(CLOCK, 16).hex()])
            poison(uc)
        elif address == DECODER:
            trace.append([address, uc.reg_read(regs.UC_MIPS_REG_A0), uc.reg_read(regs.UC_MIPS_REG_A1),
                          read(STATIC, 16).hex(), read(VOICES, len(images[VOICES])).hex()])
        elif address in handlers:
            voice = uc.reg_read(regs.UC_MIPS_REG_A0)
            scratch, voices = bytearray(read(STATIC, 16)), bytearray(read(VOICES, len(images[VOICES])))
            trace.append([address, voice, scratch.hex(), voices.hex()])
            family = handlers[address]
            changed = apply_handler({STATIC: scratch, VOICES: voices}, case, family,
                                    get(scratch, 12), voice, changed)
            write(STATIC, bytes(scratch))
            write(VOICES, bytes(voices))
            poison(uc)
        else:
            return
        assert trace[-1] == events[len(trace) - 1], (case, trace[-1], events[len(trace) - 1])

    uc.hook_add(UC_HOOK_CODE, boundary)
    execute(case[-1])
    assert trace == events, (case, trace, events)
    if case[-1] == TIMING:
        assert uc.reg_read(regs.UC_MIPS_REG_V0) == 0
    digest = hashlib.sha256()
    for address, data in expected.items():
        observed = read(address - 16, len(data) + 32)
        assert observed == GUARD + data + GUARD, (case, hex(address), observed.hex(), data.hex())
        digest.update(word(address) + observed)
    assert read(0x8008D8D0 - 16, len(lengths) + 32) == GUARD + lengths + GUARD
    assert read(STACK - 96, 16) == b'\xD6' * 16
    assert read(STACK + 16, 32) == b'\xC9' * 32
    return [trace, digest.hexdigest()]


def sequence_cases():
    for code, wait, elapsed, flags, backend in itertools.product(
            (*range(7, 36), 0, 6, 36, 255), (0, 128, 16384), (0, 127, 20000), (0, 2, 16), (0, 255)):
        yield (1, 1, 'all', (code,), wait, elapsed, 0, 0, 0, flags, backend, 'none', SEQUENCE)
    for count, budget, pattern, entry in itertools.product(
            (0, 1, 4, 8), (0, 1, 4, 255), ('none', 'all', 'alternating', 'last'), (SEQUENCE, TIMING)):
        yield (count, budget, pattern, (7, 19, 35), 128, 500, 0xFFF0, 0x85555, 0, 0, 0, 'none', entry)
    for mutation, code, backend, entry in itertools.product(
            ('pause', 'retire', 'redirect', 'opcode', 'cursor', 'backend'), (7, 18, 19, 21, 35), (0, 1), (SEQUENCE, TIMING)):
        yield (4, 3 if mutation == 'cursor' else 4, 'all', (code, 7, 35), 128, 500, 0xFFF0, 0x85555, 0, 0, backend, mutation, entry)
    for fraction, rate, elapsed, position, flags in itertools.product(
            (0x7FFFFFFF, 0xFFFFFFFF), (0x10001, 0xFFFFFFFF), (0, 0xFFFFFFFF),
            (0xFFFFFFF0, 0xFFFFFFFE, 0xFFFFFFFF), (0, 8)):
        yield (1, 1, 'all', (7, 35), 0xFFFFFFFF, elapsed, fraction, rate, position, flags, 1, 'none', SEQUENCE)


def check_context(directory, rom, layout):
    raw = directory / 'audio_sequence_tick/audio_sequence_tick.raw.o.ido'
    sections, symbols = elf_sections_and_symbols(raw)
    assert symbols['func_80059580']['value'] == 0 and symbols['func_80059580']['size'] == 84
    assert symbols['func_8005A9AC']['value'] == 84 and symbols['func_8005A9AC']['size'] == 920
    # Link the untouched compiler object with its decoder at the retail address.
    # Only the complete decoder is compared here; the sequence has its own
    # separately relocated and completely compared 932-byte output.
    undefined = {line.split()[-1] for line in subprocess.check_output(['mips-linux-gnu-nm', '-u', str(raw)], text=True).splitlines()}
    script, elf = directory / 'context.ld', directory / 'context.elf'
    script.write_text(external_assignments(undefined, layout.addresses) +
                      'SECTIONS { .text 0x80059580 : SUBALIGN(4) { *(.text) } .bss 0x80192800 (NOLOAD) : { *(.bss) } }\n')
    subprocess.run(['mips-linux-gnu-ld', '-T', str(script), '-e', 'func_80059580', '-o', str(elf), str(raw)], check=True)
    linked, _ = elf_sections_and_symbols(elf)
    decoder = linked['.text']['bytes'][:84]
    assert decoder == rom[0x5A180:0x5A1D4]
    return dict(matches=True, decoder_bytes=84, raw_sequence_bytes=920, owned_sequence_bytes=932,
                decoder_sha256=hashlib.sha256(decoder).hexdigest(), raw_object_sha256=hashlib.sha256(raw.read_bytes()).hexdigest())


def main():
    rom = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(rom)
    family = 'audio-ticks-execution'
    directory = ROOT / 'build' / family
    layout = SymbolLayoutSnapshot()
    comparisons, compiled, retail = {}, {}, {}
    for name, source, first, last in SPECS:
        result = compare_block(name, source, first, first - 0x80000000 + 0xC00,
                               last - 0x80000000 + 0xC00, rom, family=family, layout=layout)
        assert result['matches'], result['different_words']
        comparisons[name] = result
        compiled[first] = (directory / name / (name + '.bin')).read_bytes()
        retail[first] = rom[first - 0x80000000 + 0xC00:last - 0x80000000 + 0xC00]
    data_comparisons = {}
    for source in ('src/game/audio_command_lengths.c', 'src/game/audio_timing_data.c'):
        data_comparisons[source] = compare_unit(source, source_sections(source), rom, layout)
    sections, _ = elf_sections_and_symbols(comparison_directory('src/game/audio_command_lengths.c') / 'compiled.elf')
    lengths = sections['.audio_command_lengths']['bytes']
    assert lengths == bytes(LENGTHS)
    context_comparison = check_context(directory, rom, layout)
    digest, clock_count, sequence_count = hashlib.sha256(), 0, 0
    for case in itertools.product((0, 1, 0xFFFFFFFF), (0, 0xFFFFFFF0, 0xFFFFFFFF),
                                  (0, 65535, 0x7FFFFFFF, 0xFFFFFFFF), (0, 1, 0x80000000), (False, True)):
        a, b = run_clock(retail[TIMING], case), run_clock(compiled[TIMING], case)
        assert a == b
        digest.update(json.dumps([case, a], sort_keys=True).encode())
        clock_count += 1
    for case in sequence_cases():
        a = run_sequence([(TIMING, retail[TIMING]), (SEQUENCE, retail[SEQUENCE])], retail[DECODER], bytes(LENGTHS), case)
        b = run_sequence([(TIMING, compiled[TIMING]), (SEQUENCE, compiled[SEQUENCE])], compiled[DECODER], lengths, case)
        assert a == b, case
        digest.update(json.dumps([case, a], sort_keys=True).encode())
        sequence_count += 1
        if sequence_count % 500 == 0:
            print('Compared', sequence_count, 'sequence tick cases', flush=True)
    result = dict(matches=True, timing_cases=clock_count, sequence_cases=sequence_count,
                  cases=clock_count + sequence_count, trace_sha256=digest.hexdigest(),
                  comparisons=comparisons, data_comparisons=data_comparisons, context_comparison=context_comparison,
                  emulator=version('unicorn'), checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  helper_sha256={name: hashlib.sha256((ROOT / 'tools' / name).read_bytes()).hexdigest()
                                 for name in ('check_actor_group_path.py', 'check_audio_instance_allocate.py', 'check_audio_seeking.py')},
                  target_rom_sha256=hashlib.sha256(rom).hexdigest(),
                  limits=['Backend and sequence handlers and the command service are recorded ABI stubs that poison caller-saved registers.',
                          'Real decoder instructions and independently compiled command lengths execute in both images.',
                          'Guarded clock, voice, context, streams, dispatch tables, decoder state and all 16 static BSS bytes are checked against independent byte models.',
                          'Some cases execute timing and sequence ticks together; synthesis, hardware audio and arbitrary malformed unterminated streams are outside this oracle.'])
    (directory / 'report.json').write_text(json.dumps(result, indent=2) + '\n')
    print('Passed', result['cases'], 'audio tick cases', digest.hexdigest())


if __name__ == '__main__':
    main()
