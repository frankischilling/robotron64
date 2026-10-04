"""Execute complete voice release and pitch commands against retail and byte models.

Capture, timed release and pitch scaling execute real freshly matched code.
SDK priority, volume and pitch setters are recorded, adversarial ABI boundaries.
"""

import hashlib
import itertools
import json
import struct
import subprocess
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UC_MEM_READ
from unicorn import mips_const as regs

from check_actor_group_path import machine, word, SENTINEL
from check_audio_instance_allocate import CALLER_SAVED
from check_audio_playback import f32
from compare_startup import compare_block, SymbolLayoutSnapshot, external_assignments
from compare_data import compare_unit, comparison_directory
from owned_sections import source_sections, elf_sections_and_symbols, linker_placements
from rom import ROOT, validate

RELEASE, PITCH, CAPTURE, TIMED_RELEASE, SCALE = (
    0x8005B854, 0x8005BA24, 0x8005AEA8, 0x8005C4F8, 0x8005B000)
PRIORITY, VOLUME, SET_PITCH = 0x80066970, 0x80066710, 0x80066680
VOICES, INSTANCES, HARDWARE, REGIONS, WAVES, CAPTURE_BUFFER, SDK, SYNTH, STREAM, TIME = (
    0x80201010, 0x80202010, 0x80203010, 0x80204010, 0x80205010,
    0x80206010, 0x80207010, 0x80208010, 0x80209010, 0x8020A010)
GLOBALS, LEVELS, RELEASE_STATE, PITCH_STATE, STACK = (
    0x80192814, 0x8008DA28, 0x80192AD0, 0x80192AE4, 0x80300000)
FP_STUB, FP_INIT, FP_RETURN = 0x80001000, 0x80001800, 0x80002000
GUARD = bytes(range(16))
SPECS = (
    ('audio_backend_voice_release_all', 'src/game/audio/backend/voice_release_all.c', RELEASE, 420),
    ('audio_backend_pitch_command', 'src/game/audio/backend/pitch_command.c', PITCH, 676),
    ('audio_voice_capture_append', 'src/game/audio_voice_capture_append.c', CAPTURE, 316),
    ('audio_backend_release', 'src/game/audio_backend_release.c', TIMED_RELEASE, 396),
    ('audio_pitch_scale', 'src/game/audio_pitch_scale.c', SCALE, 100),
)


def get(data, offset=0):
    return int.from_bytes(data[offset:offset + 4], 'big')


def put(data, offset, value):
    data[offset:offset + 4] = word(value)


def signed(value, bits=32):
    value &= (1 << bits) - 1
    return value - (1 << bits) if value & (1 << (bits - 1)) else value


def pitch_bits(cents, multiplier):
    factor = f32(1.00057781 if cents >= 0 else 0.99942255)
    result = f32(1.0)
    cents = abs(cents)
    while cents:
        if cents & 1:
            result = f32(result * factor)
        factor = f32(factor * factor)
        cents >>= 1
    return struct.unpack('>I', struct.pack('>f', f32(result * multiplier)))[0]


def snapshot(images):
    digest = hashlib.sha256()
    for address, blob in sorted(images.items()):
        digest.update(word(address) + bytes(blob))
    return digest.hexdigest()


def fixture(kind, case):
    state = RELEASE_STATE if kind == 'release' else PITCH_STATE
    images = {
        VOICES: bytearray(b'\xA3' * 320), INSTANCES: bytearray(b'\xB5' * 96),
        HARDWARE: bytearray(b'\xC7' * 120), REGIONS: bytearray(b'\xD9' * 120),
        WAVES: bytearray(b'\xE3' * 144), CAPTURE_BUFFER: bytearray(b'\xF5' * 520),
        SDK: bytearray(b'\x83' * 224), SYNTH: bytearray(b'\x95' * 80),
        STREAM: bytearray(bytes([12, case['bend'] & 255, (case['bend'] >> 8) & 255]) + b'\x37' * 13),
        TIME: bytearray(word(case['clock'])), state: bytearray(b'\x97' * (16 if kind == 'release' else 24)),
        GLOBALS: bytearray(word(INSTANCES) + word(VOICES) + word(HARDWARE) +
                           word(case['budget']) + word(0x13579BDF) + word(TIME)),
        LEVELS: bytearray(word(case['release_time']) + word(CAPTURE_BUFFER if case['capture'] else 0) +
                         struct.pack('>f', case['multiplier'])),
        0x80190200: bytearray(word(SDK)), 0x8008F160: bytearray(word(SYNTH)),
    }
    voice = images[VOICES]
    voice[1:4] = bytes([case['owner'], case['instance'], case['category']])
    voice[6:8] = struct.pack('>h', case['old_bend'])
    voice[17] = case['count']
    put(voice, 52, STREAM)
    put(images[CAPTURE_BUFFER], 0, case['captured'])
    put(images[CAPTURE_BUFFER], 4, case['mask'])
    for i in range(4):
        images[INSTANCES][i * 24 + 2:i * 24 + 4] = struct.pack('>h', (-32768, -1, 17, 32767)[i])
    for i in range(6):
        off, region, wave = i * 20, i * 20, i * 24
        active = case['pattern'] in (3, 4) or (case['pattern'] == 1 and i == 4) or (
            case['pattern'] == 2 and i % 2 == 0)
        flags = (0x80 if active else 0) | 0x20 | (0x40 if case['pattern'] == 4 and i == 1 else 0) | 0x09
        images[HARDWARE][off:off + 8] = bytes([
            flags, 0x27, i, case['owner'] if i != 2 or case['pattern'] != 2 else 99,
            70 + i, case['key'], 19 + i, 1 if case['pattern'] == 4 and i == 2 else 0])
        put(images[HARDWARE], off + 8, REGIONS + region)
        put(images[HARDWARE], off + 12, WAVES + wave)
        put(images[HARDWARE], off + 16, 0x24680000 + i)
        images[REGIONS][region + 4:region + 6] = bytes([case['root'], case['detune'] & 255])
        images[REGIONS][region + 8:region + 10] = bytes([case['down'] & 255, case['up'] & 255])
        put(images[WAVES], wave + 20, case['tuning'])
    return images


def mutate(images, kind, case, hardware_offset):
    mode = case['mutation']
    state = images[RELEASE_STATE if kind == 'release' else PITCH_STATE]
    if mode == 1:
        if kind == 'release':
            put(images[TIME], 0, get(images[TIME]) + 37)
            put(images[LEVELS], 0, -7)
        else:
            images[VOICES][6:8] = struct.pack('>h', -127)
    elif mode == 2:
        put(state, 8, HARDWARE + 40)
    elif mode == 3:
        if kind == 'release':
            put(images[LEVELS], 4, 0)
        else:
            put(state, 0, 0)
    elif mode == 4:
        if kind == 'release':
            images[HARDWARE][hardware_offset + 2] = 7
        else:
            images[LEVELS][8:12] = struct.pack('>f', 0.5)


def model(kind, case):
    images = fixture(kind, case)
    state = images[RELEASE_STATE if kind == 'release' else PITCH_STATE]
    voice, hardware = images[VOICES], images[HARDWARE]
    trace, mutated = [], False

    def emit(address, args, off):
        nonlocal mutated
        trace.append([address, [value & 0xFFFFFFFF for value in args], snapshot(images)])
        if not mutated:
            mutate(images, kind, case, off)
            mutated = True

    if kind == 'pitch':
        state[12:14] = struct.pack('>h', case['bend'])
        if case['bend'] == case['old_bend']:
            return images, trace
        voice[6:8] = struct.pack('>h', case['bend'])
    put(state, 0, case['count'])
    if not case['count']:
        return images, trace
    put(state, 4, case['budget'])
    put(state, 8, HARDWARE)
    for _ in range(8):
        budget = get(state, 4)
        put(state, 4, budget - 1)
        if not budget:
            return images, trace
        off = get(state, 8) - HARDWARE
        assert 0 <= off < 120 and off % 20 == 0, (kind, case, off)
        if hardware[off] & 0x80 and hardware[off + 3] == voice[1]:
            if kind == 'release':
                if get(images[LEVELS], 4) and not hardware[off] & 0x40 and not hardware[off + 7]:
                    instance = voice[2] * 24
                    put(state, 12, INSTANCES + instance)
                    capture = images[CAPTURE_BUFFER]
                    mask = get(capture, 4)
                    eligible = (voice[3] == 1 and mask & 1) or (voice[3] == 0 and mask & 2)
                    count = get(capture)
                    if eligible and count < 32:
                        at = 8 + count * 16
                        capture[at:at + 2] = images[INSTANCES][instance + 2:instance + 4]
                        capture[at + 2:at + 4] = struct.pack('>h', hardware[off + 3])
                        capture[at + 4:at + 6] = hardware[off + 5:off + 7]
                        capture[at + 8:at + 16] = hardware[off + 8:off + 16]
                        put(capture, 0, count + 1)
                release_time = get(images[LEVELS])
                emit(PRIORITY, [SYNTH, SDK + hardware[off + 2] * 28, 0], off)
                emit(VOLUME, [SYNTH, SDK + hardware[off + 2] * 28, 0, release_time * 1000], off)
                hardware[off] = (hardware[off] | 0x40) & ~0x20
                put(hardware, off + 16, get(images[TIME]) + release_time)
            else:
                bend = int.from_bytes(voice[6:8], 'big', signed=True)
                region = get(hardware, off + 8) - REGIONS
                wave = get(hardware, off + 12) - WAVES
                factors = images[REGIONS]
                factor = signed(factors[region + (9 if bend > 0 else 8)], 8)
                cents = int((factor * bend) * 0.0122) if bend else 0
                put(state, 20, cents)
                tuning = signed(get(images[WAVES], wave + 20))
                cents = signed(tuning + cents + (hardware[off + 5] - factors[region + 4]) * 100 -
                               signed(factors[region + 5], 8))
                multiplier = struct.unpack('>f', images[LEVELS][8:12])[0]
                pitch = pitch_bits(cents, multiplier)
                put(state, 16, pitch)
                emit(SET_PITCH, [SYNTH, SDK + hardware[off + 2] * 28, pitch], off)
            put(state, 0, get(state) - 1)
            if not get(state):
                return images, trace
        put(state, 8, get(state, 8) + 20)
    raise AssertionError(('Model exceeded its bounded fixture', kind, case))


def execute(kind, code, support, case):
    entry = RELEASE if kind == 'release' else PITCH
    images, (expected, events) = fixture(kind, case), model(kind, case)
    seed = b''.join(word(0x3F000000 + i * 0x10000) for i in range(32))
    initializer = b''.join(word(0xC4003000 | i << 16 | i * 4) for i in range(32))
    initializer += word(0x3C190080 if case['fp_condition'] else 0x0000C825) + word(0x44D9F800)
    initializer += word(0x08000000 | ((entry >> 2) & 0x3FFFFFF)) + word(0)
    clobber = b''.join(word(0xC4003080 | i << 16) for i in range(20)) + word(0x03E00008) + word(0)
    observe = b''.join(word(0xE4003100 | i << 16 | (i - 20) * 4) for i in range(20, 32))
    observe += word(0x4459F800) + word(0xAC193140)
    observe += word(0x08000000 | ((SENTINEL >> 2) & 0x3FFFFFF)) + word(0)
    uc, write, run = machine([(entry, code), (FP_INIT, initializer),
                              (FP_STUB, clobber), (FP_RETURN, observe)], support)
    write(0x3000, seed + word(0x42E00000))
    write(0x3100, b'\x89' * 68)
    for address, blob in images.items():
        write(address - 16, GUARD + bytes(blob) + GUARD)
    write(STACK - 272, b'\x47' * 16)
    write(STACK + 16, b'\x93' * 32)

    def read(address, size):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, size))

    allowed = [(a & 0x1FFFFFFF, (a & 0x1FFFFFFF) + len(b)) for a, b in images.items()]
    allowed += [(a & 0x1FFFFFFF, (a & 0x1FFFFFFF) + len(b)) for a, b in support]
    allowed += [(0x3000, 0x3084), (0x3100, 0x3144),
                ((STACK - 256) & 0x1FFFFFFF, (STACK + 16) & 0x1FFFFFFF)]
    writable = [(a & 0x1FFFFFFF, (a & 0x1FFFFFFF) + len(b)) for a, b in images.items()]
    writable += allowed[-2:]

    def access(uc, kind, address, size, value, user):
        address &= 0x1FFFFFFF
        ranges = allowed if kind == UC_MEM_READ else writable
        assert any(low <= address and address + size <= high for low, high in ranges), (
            'Out-of-fixture memory access', hex(address), size, case)

    uc.hook_add(UC_HOOK_MEM_READ | UC_HOOK_MEM_WRITE, access)
    trace, mutated = [], False

    def boundary(uc, address, size, user):
        nonlocal mutated
        registers = (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                     regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)
        args = [uc.reg_read(r) for r in registers[:4 if address == VOLUME else 3]]
        observed = {a: read(a, len(b)) for a, b in images.items()}
        event = [address, args, snapshot(observed)]
        assert len(trace) < len(events) and event == events[len(trace)], (kind, case, event, events)
        trace.append(event)
        if not mutated:
            current = {a: bytearray(b) for a, b in observed.items()}
            # The timed helper holds its original status pointer even if the
            # outer cursor changes at the boundary.
            cursor = get(current[RELEASE_STATE if kind == 'release' else PITCH_STATE], 8) - HARDWARE
            mutate(current, kind, case, cursor)
            for a, b in current.items():
                write(a, bytes(b))
            mutated = True
        for i, r in enumerate(CALLER_SAVED):
            uc.reg_write(r, 0xB1230000 + i * 257)
        uc.reg_write(regs.UC_MIPS_REG_PC, FP_STUB)

    for address in ((PRIORITY, VOLUME) if kind == 'release' else (SET_PITCH,)):
        uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)
    uc.reg_write(regs.UC_MIPS_REG_A0, VOICES)
    uc.reg_write(regs.UC_MIPS_REG_RA, FP_RETURN)
    try:
        run(FP_INIT)
    except Exception as error:
        raise RuntimeError((kind, case, hex(uc.reg_read(regs.UC_MIPS_REG_PC)), trace)) from error
    assert trace == events, (kind, case, trace, events)
    assert read(0x3100, 48) == seed[80:128], ('Floating callee-saved registers', kind, case)
    fcsr = get(read(0x3140, 4))
    assert fcsr & 0x00800003 == (0x00800000 if case['fp_condition'] else 0), (kind, case, fcsr)
    digest = hashlib.sha256()
    for address, blob in expected.items():
        observed = read(address - 16, len(blob) + 32)
        assert observed == GUARD + bytes(blob) + GUARD, (kind, case, hex(address), observed.hex(), blob.hex())
        digest.update(word(address) + observed)
    assert read(STACK - 272, 16) == b'\x47' * 16
    assert read(STACK + 16, 32) == b'\x93' * 32
    return dict(trace=trace, state_sha256=digest.hexdigest(), fcsr=fcsr)


def cases(kind):
    base = dict(owner=17, instance=2, category=0, count=3, budget=5, pattern=4,
                bend=127, old_bend=0, down=2, up=3, key=60, root=60, detune=-7,
                tuning=123, clock=0xFFFFFFF0, release_time=19, capture=1,
                captured=0, mask=3, multiplier=1.0, mutation=0, fp_condition=0)
    yield base
    for count, budget, pattern in itertools.product((0, 1, 2, 3, 255), (0, 1, 3, 5), range(5)):
        yield dict(base, count=count, budget=budget, pattern=pattern)
    if kind == 'release':
        for enabled, category, mask, count in itertools.product((0, 1), (0, 1, 2, 255), (0, 1, 2, 3, 255), (0, 31, 32, 33)):
            yield dict(base, capture=enabled, category=category, mask=mask, captured=count, pattern=3)
        for clock, duration in itertools.product((0, 1, 0xFFFFFFFF, 0x7FFFFFFF),
                                                (0, 1, -1, 2147483647, -2147483648)):
            yield dict(base, clock=clock, release_time=duration)
        for instance in range(4):
            yield dict(base, instance=instance, pattern=3)
    else:
        for bend, old, count in itertools.product((0, 1, -1, 8192, -8192, 32767, -32768),
                                                (0, 1, -1, 32767, -32768), (0, 1, 3)):
            yield dict(base, bend=bend, old_bend=old, count=count)
        for bend, up, down in itertools.product((0, 1, -1, 127, -127, 32767, -32768),
                                               (-128, -8, 0, 8, 127), (-128, -8, 0, 8, 127)):
            yield dict(base, bend=bend, old_bend=17, up=up, down=down)
        for key, root, detune, tuning in itertools.product((0, 60, 255), (0, 60, 255),
                                                         (-128, 0, 127), (-1200, 0, 1200)):
            yield dict(base, key=key, root=root, detune=detune, tuning=tuning)
        for multiplier in (0.0, 0.5, 2.0):
            yield dict(base, multiplier=multiplier)
    for mode, condition in itertools.product(range(5), (0, 1)):
        yield dict(base, mutation=mode, fp_condition=condition, pattern=3, budget=3)
    yield dict(base, budget=-1, count=1, pattern=3)


def verify_context(directory, source, function, size, context, context_size, target, layout):
    raw = directory / (directory.name + '.raw.o.ido')
    sections, symbols = elf_sections_and_symbols(raw)
    assert symbols[context]['value'] == 0 and symbols[context]['size'] == context_size
    assert symbols[function]['value'] == context_size and symbols[function]['size'] == size
    retained, _ = elf_sections_and_symbols(directory / (directory.name + '.raw.o'))
    assert retained['.text']['bytes'] == sections['.text']['bytes'][context_size:context_size + size]
    undefined = {line.split()[-1] for line in subprocess.check_output(
        ['mips-linux-gnu-nm', '-u', str(raw)], text=True).splitlines()}
    address = int(context.split('_')[1], 16)
    script = directory / 'context.ld'
    script.write_text(external_assignments(undefined, layout.addresses) +
                      f'SECTIONS {{ .text 0x{address:X} : SUBALIGN(4) {{ *(.text) }} ' +
                      linker_placements(source_sections(source)) + ' }\n')
    elf = directory / 'context.elf'
    subprocess.run(['mips-linux-gnu-ld', '-T', str(script), '-e', context, '-o', str(elf), str(raw)], check=True)
    rebuilt, _ = elf_sections_and_symbols(elf)
    data = rebuilt['.text']['bytes'][:context_size]
    rom = address - 0x80000000 + 0xC00
    assert data == target[rom:rom + context_size], context
    return dict(function=context, bytes=context_size, matches_retail=True,
                bytes_sha256=hashlib.sha256(data).hexdigest(),
                untouched_object_sha256=hashlib.sha256(raw.read_bytes()).hexdigest())


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    family = 'audio-voice-command-execution'
    output = ROOT / 'build' / family
    comparisons, compiled, original = {}, {}, {}
    for name, source, address, size in SPECS:
        rom = address - 0x80000000 + 0xC00
        comparisons[name] = compare_block(name, source, address, rom, rom + size, target,
                                         family=family, layout=layout)
        assert comparisons[name]['matches'], comparisons[name]
        compiled[address] = (output / name / (name + '.bin')).read_bytes()
        original[address] = target[rom:rom + size]
    factors = 'src/game/audio/pitch_factors.c'
    data_comparison = compare_unit(factors, source_sections(factors), target, layout)
    sections, _ = elf_sections_and_symbols(comparison_directory(factors) / 'compiled.elf')
    rebuilt_data = [(0x80095CC4, sections['.audio_pitch_scale_rodata']['bytes'])]
    sections, _ = elf_sections_and_symbols(output / SPECS[1][0] / (SPECS[1][0] + '.elf'))
    rebuilt_data += [(0x80095CE0, sections['.audio_backend_pitch_command_rodata']['bytes'])]
    original_data = [(0x80095CC4, target[0x968C4:0x968CC]), (0x80095CE0, target[0x968E0:0x968F0])]
    assert rebuilt_data == original_data
    contexts = {}
    for spec, context, size in ((SPECS[0], 'func_8005AEA8', 316), (SPECS[1], 'func_8005B000', 100)):
        name, source, function, length = spec
        contexts[name] = verify_context(output / name, source, f'func_{function:08X}',
                                        length, context, size, target, layout)
    digest, counts = hashlib.sha256(), {}
    for kind, entry in (('release', RELEASE), ('pitch', PITCH)):
        count = 0
        for case in cases(kind):
            retail = execute(kind, original[entry], [(a, b) for a, b in original.items() if a != entry] + original_data, case)
            rebuilt = execute(kind, compiled[entry], [(a, b) for a, b in compiled.items() if a != entry] + rebuilt_data, case)
            assert retail == rebuilt, (kind, case, retail, rebuilt)
            digest.update(json.dumps([kind, case, rebuilt], sort_keys=True).encode())
            count += 1
        counts[kind] = count
        print('Passed', kind, count, 'cases', flush=True)
    layout.verify()
    report = dict(matches=True, cases=counts, trace_sha256=digest.hexdigest(),
                  comparisons=comparisons, factor_comparison=data_comparison, contexts=contexts,
                  emulator=version('unicorn'), checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  execution_inputs_sha256={name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
                      for name in ('tools/check_audio_voice_commands.py', 'tools/check_actor_group_path.py',
                                   'tools/check_audio_instance_allocate.py', 'tools/check_audio_playback.py')},
                  target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  limits=['SDK setters are recorded stubs; synthesis and hardware execution are outside scope.',
                          'Capture, timed release and pitch scale execute complete freshly matched source.',
                          'Finite pitch fixtures use round-to-nearest arithmetic and preserve FCSR rounding and condition bits.',
                          'SDK stubs poison caller-saved integer and floating registers and mutate live state.',
                          'Independent byte models check every SDK snapshot, final buffers, private padding and guards.',
                          'Memory accesses are bounded; integer and floating callee-saved registers and stack are checked.',
                          'Malformed pointers, negative capture indices and unbounded invalid pool scans are outside scope.'])
    (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Audio voice command report:', output / 'report.json')


if __name__ == '__main__':
    main()
