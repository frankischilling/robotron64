"""Check both complete seek procedures with a real decoder and an array oracle.

Backend and sequence handlers are recorded ABI stubs. The variable-length
decoder and command lengths are independently compiled and matched to retail.
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
from check_audio_instance_allocate import CALLER_SAVED
from compare_startup import compare_block, SymbolLayoutSnapshot
from compare_data import compare_unit, comparison_directory
from owned_sections import source_sections, elf_sections_and_symbols
from rom import ROOT, validate

VOICE, STREAM, BRANCH, END, OUT = 0x80201010, 0x80202010, 0x80203010, 0x80204010, 0x80205010
OPS, STACK, DECODER = 0x80206010, 0x80300000, 0x80059580
LENGTHS = (0, 0, 0, 0, 0, 0, 0, 3, 2, 3, 2, 2, 2, 2, 2, 2, 2, 3, 2,
           4, 5, 5, 2, 2, 3, 3, 3, 3, 1, 1, 3, 3, 3, 1, 1, 1)
SPECS = (("audio_seek_forward", 0x80056EF0, 0x80057124),
         ("audio_seek_restart", 0x80057124, 0x80057358))


def encode(value):
    result = [value & 127]
    value >>= 7
    while value:
        result.insert(0, (value & 127) | 128)
        value >>= 7
    return bytes(result)


def fixture(case):
    entry, codes, initial, wait, position, base, fraction, flags, backend, mutation = case
    voice = bytearray((i * 37 + 91) & 255 for i in range(80))
    voice[0], voice[16] = flags, backend
    voice[8:12] = word(initial)
    voice[32:36], voice[40:44] = word(fraction), word(base)
    prefix = encode(initial)
    stream = bytearray(prefix)
    for code in codes:
        stream += bytes((code,)) + bytes((code ^ 0x5A,)) * max(0, LENGTHS[code] - 1 if code < 36 else 0)
        stream += encode(wait)
    stream += b'\x22'
    branch = bytes((7, 0x31, 0x32)) + encode(wait) + b'\x22'
    voice[48:56] = word(STREAM) + word(STREAM + len(prefix))
    images = {VOICE: voice, STREAM: stream, BRANCH: bytearray(branch), END: bytearray(b'\x22'),
              OUT: bytearray(word(0x86753099)),
              0x80192750: bytearray(b'\x93' * 8),
              0x8008D800: bytearray(word(OPS) * 2),
              0x8008DBFC: bytearray(word(OPS)),
              OPS: bytearray(word(0) * 7 + b''.join(word(0x80000100 + i * 16) for i in range(7, 19))),
              0x8008D96C: bytearray(b''.join(word(0x80001000 + i * 16) for i in range(19, 36)))}
    return images


def model(case, images):
    entry, codes, initial, wait, position, base, fraction, flags, backend, mutation = case
    state = {a: bytearray(b) for a, b in images.items()}
    voice = state[VOICE]
    trace = []

    def get(offset):
        return int.from_bytes(voice[offset:offset + 4], 'big')

    def put(offset, value):
        voice[offset:offset + 4] = word(value)

    def byte(address):
        for first, data in state.items():
            if first <= address < first + len(data):
                return data[address - first]
        raise ValueError(hex(address))

    def decode(address):
        trace.append([DECODER, address, STACK - 12])
        first = byte(address)
        value = first & 127
        address += 1
        if first & 128:
            while True:
                last = byte(address)
                value = ((value << 7) + (last & 127)) & 0xFFFFFFFF
                address += 1
                if not last & 128:
                    state[0x80192750][4] = last
                    break
        state[0x80192750][:4] = word(value)
        put(52, address)
        return value

    def dispatch(family, code):
        actual = code if 7 <= code < 36 else 29
        address = (0x80000100 if family == 'backend' else 0x80001000) + actual * 16
        trace.append([address, VOICE, code])
        if not 7 <= code < 36 or code == 29:
            put(52, END)
        elif mutation and code == 21:
            put(52, BRANCH)
            voice[0] |= 2
        elif mutation and code == 7:
            put(52, BRANCH)
            put(32, 0xDEADBEEF)
            put(40, 0x87654321)

    if entry == 0x80057124:
        time = 0
        cursor = get(48)
        put(52, cursor)
        delay = decode(cursor)
    else:
        time = (base + (fraction >> 16)) & 0xFFFFFFFF
        cursor = get(52)
        delay = initial
    for _ in range(100):
        time = (time + delay) & 0xFFFFFFFF
        if time >= position:
            put(8, time - position)
            put(32, 0)
            put(40, position)
            break
        code = byte(get(52))
        if code == 34:
            put(8, 0)
            put(32, 0)
            put(40, time)
            break
        if code in (17, 18):
            put(52, get(52) + LENGTHS[code])
            cursor = get(52)
            delay = decode(cursor)
        elif 7 <= code < 19:
            dispatch('backend', code)
            put(52, get(52) + LENGTHS[code])
            cursor = get(52)
            delay = decode(cursor)
        elif 19 <= code < 36:
            dispatch('sequence', code)
            if voice[0] & 2:
                if entry == 0x80056EF0:
                    cursor = get(52)
                voice[0] &= 253
            else:
                put(52, get(52) + LENGTHS[code])
                cursor = get(52)
                delay = decode(cursor)
        else:
            dispatch('sequence', code)
            if entry == 0x80056EF0:
                cursor = get(52)
    else:
        raise AssertionError('Oracle exceeded scan bound')
    state[OUT][:] = word(cursor)
    return state, trace, get(40)


def run(code, decoder, lengths, case):
    images = fixture(case)
    expected, events, returned = model(case, images)
    uc, write, execute = machine([(case[0], code), (DECODER, decoder)], [(0x8008D8D0, lengths)])
    guard = bytes(range(16))
    write(0x8008D8D0 - 16, guard + lengths + guard)
    for address, data in images.items():
        write(address - 16, guard + data + guard)
    write(STACK + 16, b'\xC9' * 32)
    write(STACK - 112, b'\xD6' * 16)
    trace = []

    def read(address, length):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, length))

    def boundary(uc, address, size, user):
        if address == DECODER:
            trace.append([address, uc.reg_read(regs.UC_MIPS_REG_A0), uc.reg_read(regs.UC_MIPS_REG_A1)])
            return
        if 0x80000170 <= address <= 0x80000220 or 0x80001130 <= address <= 0x80001230:
            code = read(int.from_bytes(read(VOICE + 52, 4), 'big'), 1)[0]
            trace.append([address, uc.reg_read(regs.UC_MIPS_REG_A0), code])
            assert trace[-1] == events[len(trace) - 1], (case, trace, events)
            if code < 7 or code >= 36 or code == 29:
                write(VOICE + 52, word(END))
            elif case[-1] and code == 21:
                write(VOICE + 52, word(BRANCH))
                write(VOICE, bytes((read(VOICE, 1)[0] | 2,)))
            elif case[-1] and code == 7:
                write(VOICE + 52, word(BRANCH))
                write(VOICE + 32, word(0xDEADBEEF))
                write(VOICE + 40, word(0x87654321))
            for i, register in enumerate(CALLER_SAVED):
                uc.reg_write(register, 0xD1350000 + i * 256)
            uc.reg_write(regs.UC_MIPS_REG_PC, uc.reg_read(regs.UC_MIPS_REG_RA))

    uc.hook_add(UC_HOOK_CODE, boundary)
    uc.reg_write(regs.UC_MIPS_REG_A0, VOICE)
    uc.reg_write(regs.UC_MIPS_REG_A1, case[4])
    uc.reg_write(regs.UC_MIPS_REG_A2, OUT)
    execute(case[0])
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == returned, case
    assert trace == events, (case, trace, events)
    digest = hashlib.sha256()
    for address, data in expected.items():
        observed = read(address - 16, len(data) + 32)
        assert observed == guard + data + guard, (case, hex(address), observed.hex(), data.hex())
        digest.update(word(address) + observed)
    assert read(STACK + 16, 32) == b'\xC9' * 32
    assert read(STACK - 112, 16) == b'\xD6' * 16
    assert read(0x8008D8D0 - 16, len(lengths) + 32) == guard + lengths + guard
    return dict(trace=trace, returned=returned, state_sha256=digest.hexdigest())


def cases():
    codes = tuple(range(7, 29)) + (30, 31, 32, 33, 35, 0, 6, 36, 255)
    for entry, code, initial, wait, position in itertools.product(
            (0x80056EF0, 0x80057124), codes, (0, 128), (0, 127, 16384), (0, 1, 128, 20000)):
        yield (entry, (code,), initial, wait, position, 0, 0, 0xA5, 0, False)
    for entry, position, base, fraction, flags, backend, mutation in itertools.product(
            (0x80056EF0, 0x80057124), (1, 500, 0xFFFFFFFF),
            (0, 0xFFFFFFF0), (0, 0xFFFFFFFF), (0, 2, 255), (0, 255), (False, True)):
        yield (entry, (17, 18, 19, 21, 7, 35), 127, 128, position, base, fraction, flags, backend, mutation)
    for entry, initial, wait, position in itertools.product(
            (0x80056EF0, 0x80057124), (1, 0xFFFFFFFF),
            (0xFFFFFFF0, 0xFFFFFFFF), (1, 128, 0xFFFFFFFE, 0xFFFFFFFF)):
        yield (entry, (17,), initial, wait, position, 0, 0, 0x7D, 1, False)


def main():
    rom = (ROOT/'baseroms/us/baserom.z64').read_bytes()
    validate(rom)
    layout = SymbolLayoutSnapshot()
    family = 'audio-seeking-execution'
    comparisons = {}
    for name, first, last in (*SPECS, ('audio_stream_variable_read', DECODER, 0x800595D4)):
        source = 'src/game/audio/' + name.removeprefix('audio_') + '.c' if name != 'audio_stream_variable_read' else 'src/game/audio_stream_variable_read.c'
        result = compare_block(name, source, first, first-0x80000000+0xC00, last-0x80000000+0xC00,
                               rom, family=family, layout=layout)
        assert result['matches'], result['different_words']
        comparisons[name] = result
    source = 'src/game/audio_command_lengths.c'
    data_comparison = compare_unit(source, source_sections(source), rom, layout)
    sections, _ = elf_sections_and_symbols(comparison_directory(source)/'compiled.elf')
    lengths = sections['.audio_command_lengths']['bytes']
    assert lengths == bytes(LENGTHS)
    output = ROOT/'build'/family
    decoder = (output/'audio_stream_variable_read/audio_stream_variable_read.bin').read_bytes()
    compiled = {first: (output/name/(name+'.bin')).read_bytes() for name, first, last in SPECS}
    retail = {first: rom[first-0x80000000+0xC00:last-0x80000000+0xC00] for _, first, last in SPECS}
    digest = hashlib.sha256()
    count = 0
    for case in cases():
        a = run(retail[case[0]], rom[0x5A180:0x5A1D4], bytes(LENGTHS), case)
        b = run(compiled[case[0]], decoder, lengths, case)
        assert a == b, case
        digest.update(json.dumps([case, a], sort_keys=True).encode())
        count += 1
        if count % 500 == 0:
            print('Compared', count, 'audio seek cases', flush=True)
    result = dict(matches=True, cases=count, trace_sha256=digest.hexdigest(), comparisons=comparisons,
                  data_comparison=data_comparison, emulator=version('unicorn'),
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  helper_sha256={name: hashlib.sha256((ROOT/'tools'/name).read_bytes()).hexdigest()
                                 for name in ('check_actor_group_path.py', 'check_audio_instance_allocate.py')},
                  target_rom_sha256=hashlib.sha256(rom).hexdigest(),
                  limits=['Backend and sequence handlers are documented, caller-saved-register-poisoning ABI stubs.',
                          'The complete real variable-length decoder and command lengths execute in both images.',
                          'Every guarded input, voice field, output cursor and decoder state is checked against an independent model.',
                          'SDK synthesis, audio hardware and arbitrary malformed unterminated streams are outside this oracle.'])
    (output/'report.json').write_text(json.dumps(result, indent=2)+'\n')
    print('Passed', count, 'audio seek cases', digest.hexdigest())


if __name__ == '__main__':
    main()
