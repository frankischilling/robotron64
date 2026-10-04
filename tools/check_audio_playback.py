"""Execute complete playback setup against retail code and numeric fixtures.

The pitch helper and its constants are freshly compiled and compared. SDK
allocation and voice start are recorded ABI boundaries, not device execution.
"""
import hashlib
import itertools
import json
import struct
from importlib.metadata import version
from pathlib import Path
from elftools.elf.elffile import ELFFile

from unicorn import UC_HOOK_CODE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL
from check_audio_instance_allocate import CALLER_SAVED
from compare_startup import compare_block, SymbolLayoutSnapshot
from rom import ROOT, validate

NAME = 'audio_backend_playback'
ENTRY = 0x8005B064
HARDWARE, VOICES, REGION, WAVE, SDK_VOICES, SYNTH = (
    0x80201010, 0x80202010, 0x80203010, 0x80204010, 0x80205010, 0x80206010)
STATE, CONFIGURATION = 0x80192A9C, 0x80192AAC
ALLOCATE, START = 0x80066448, 0x80066590
FP_STUB, FP_INIT, FP_RETURN = 0x80001000, 0x80001800, 0x80002000


def f32(value):
    return struct.unpack('>f', struct.pack('>f', value))[0]


def pitch_bits(cents):
    factor = f32(1.00057781 if cents >= 0 else 0.99942255)
    result = f32(1.0)
    cents = abs(cents)
    while cents:
        if cents & 1:
            result = f32(result * factor)
        factor = f32(factor * factor)
        cents >>= 1
    return struct.unpack('>I', struct.pack('>f', result))[0]


def fixture(case):
    images = {
        HARDWARE: bytearray(b'\xA3' * 20), VOICES: bytearray(b'\xB5' * 320),
        REGION: bytearray(b'\xC7' * 20), WAVE: bytearray(b'\xD9' * 24),
        SDK_VOICES: bytearray(b'\xE3' * 84), SYNTH: bytearray(b'\xF5' * 64),
        STATE: bytearray(b'\x97' * 32), 0x80192818: bytearray(word(VOICES)),
        0x80190200: bytearray(word(SDK_VOICES)), 0x8008F160: bytearray(word(SYNTH)),
        0x8008DA1C: bytearray(bytes([case['music']]) + b'\x45' * 3 +
                            bytes([case['effects']]) + b'\x67' * 3 +
                            bytes([case['pan_enabled']]) + b'\x79' * 11 +
                            struct.pack('>f', 1.0)),
    }
    hardware, region, wave = images[HARDWARE], images[REGION], images[WAVE]
    hardware[2:7] = bytes(case[key] for key in ('index', 'owner', 'priority', 'key', 'velocity'))
    hardware[8:16] = word(REGION) + word(WAVE)
    offset = case['owner'] * 80
    voice = images[VOICES]
    voice[offset + 3] = case['category']
    voice[offset + 6:offset + 8] = struct.pack('>h', case['bend'])
    voice[offset + 12:offset + 15] = bytes(case[key] for key in ('effect', 'volume', 'pan'))
    region[1] = case['region_volume']
    region[2] = case['region_pan'] & 255
    region[4] = case['root']
    region[5] = case['detune'] & 255
    region[8:10] = bytes(case[key] & 255 for key in ('down', 'up'))
    region[12:14] = struct.pack('>H', case['attack'])
    region[18] = case['attack_volume']
    wave[20:24] = word(case['tuning'])
    expected = {address: bytearray(blob) for address, blob in images.items()}
    master = case['music'] if case['category'] == 0 else case['effects']
    volume = ((case['velocity'] * case['region_volume'] * case['volume'] * master) & 0xFFFFFFFF) >> 13
    volume = ((volume * case['attack_volume']) & 0xFFFFFFFF) >> 7
    pan = max(0, min(127, case['pan'] + case['region_pan'] - 64)) if case['pan_enabled'] else 64
    bend = int(case['bend'] * (case['up'] if case['bend'] > 0 else case['down']) * 0.0122) if case['bend'] else 0
    cents = case['tuning'] + bend + (case['key'] - case['root']) * 100 - case['detune']
    pitch = pitch_bits(cents)
    state = expected[STATE]
    state[0:10] = word(VOICES + offset) + word(volume) + struct.pack('>h', pan)
    state[12:16] = word(bend)
    state[16:21] = struct.pack('>hhB', min(case['priority'], 127), 0, 0)
    state[24:32] = word(pitch) + word(case['attack'] * 1000)
    calls = [
        [ALLOCATE, [SYNTH, SDK_VOICES + case['index'] * 28, CONFIGURATION]],
        [START, [SYNTH, SDK_VOICES + case['index'] * 28, WAVE, pitch,
                 volume, pan, case['effect'], case['attack'] * 1000]],
    ]
    return images, expected, calls


def execute(code, support, case):
    images, expected, expected_calls = fixture(case)
    # Floating register APIs are unavailable in this Unicorn build. These MIPS
    # instructions seed and observe registers, and clobber caller-saved F0..F19.
    fp_seed = b''.join(word(0x3F000000 + i * 0x10000) for i in range(32))
    initializer = b''.join(word(0xC4003000 | i << 16 | i * 4) for i in range(32))
    initializer += word(0x08000000 | ((ENTRY >> 2) & 0x3FFFFFF)) + word(0)
    clobber = b''.join(word(0xC4003080 | i << 16) for i in range(20))
    clobber += word(0x03E00008) + word(0)
    observe = b''.join(word(0xE4003100 | i << 16 | (i - 20) * 4) for i in range(20, 32))
    observe += word(0x08000000 | ((SENTINEL >> 2) & 0x3FFFFFF)) + word(0)
    uc, write, run = machine([(ENTRY, code), (FP_INIT, initializer),
                              (FP_STUB, clobber), (FP_RETURN, observe)], support)
    write(0x3000, fp_seed + word(0x42E00000))
    write(0x3100, b'\x89' * 48)
    guard = bytes(range(16))
    for address, blob in images.items():
        write(address - 16, guard + bytes(blob) + guard)
    write(0x802FFFC0, b'\x47' * 16)
    write(0x80300010, b'\x93' * 32)
    def read(address, size):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, size))
    trace = []
    def boundary(uc, address, size, user):
        args = [uc.reg_read(reg) for reg in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                            regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)]
        if address == ALLOCATE:
            args = args[:3]
            assert read(CONFIGURATION, 6) == bytes(expected[STATE][16:22]), case
        else:
            sp = uc.reg_read(regs.UC_MIPS_REG_SP)
            args.extend(int.from_bytes(read(sp + offset, 4), 'big') for offset in (16, 20, 24, 28))
        event = [address, args]
        assert len(trace) < len(expected_calls) and event == expected_calls[len(trace)], (case, event, expected_calls)
        trace.append(event)
        for i, reg in enumerate(CALLER_SAVED):
            uc.reg_write(reg, 0xB1230000 + i * 257)
        uc.reg_write(regs.UC_MIPS_REG_PC, FP_STUB)
    for address in (ALLOCATE, START):
        uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)
    uc.reg_write(regs.UC_MIPS_REG_A0, HARDWARE)
    uc.reg_write(regs.UC_MIPS_REG_RA, FP_RETURN)
    try:
        run(FP_INIT)
    except Exception as error:
        raise RuntimeError((case, hex(uc.reg_read(regs.UC_MIPS_REG_PC)), trace)) from error
    assert trace == expected_calls, case
    assert read(0x3100, 48) == fp_seed[80:128], ('Floating callee-saved registers', case)
    digest = hashlib.sha256()
    for address, blob in expected.items():
        observed = read(address - 16, len(blob) + 32)
        assert observed == guard + bytes(blob) + guard, (case, hex(address), observed.hex(), blob.hex())
        digest.update(word(address) + observed)
    assert read(0x802FFFC0, 16) == b'\x47' * 16
    assert read(0x80300010, 32) == b'\x93' * 32
    return dict(trace=trace, state_sha256=digest.hexdigest())


def cases():
    base = dict(owner=0, index=0, priority=64, key=60, velocity=127,
                category=0, bend=0, effect=17, volume=127, pan=64,
                region_volume=127, region_pan=64, root=60, detune=0,
                down=2, up=2, attack=123, attack_volume=127,
                tuning=0, music=127, effects=31, pan_enabled=1)
    yield base
    fields = dict(owner=(1, 3), index=(1, 2), priority=(0, 127, 128, 255),
                  key=(0, 127, 255), root=(0, 127, 255), velocity=(0, 1, 255),
                  category=(1, 255), effect=(0, 255), volume=(0, 1, 255),
                  region_volume=(0, 1, 255), music=(0, 1, 255), effects=(0, 1, 255),
                  attack_volume=(0, 1, 255), attack=(0, 1, 65535),
                  detune=(-128, 127), tuning=(-1200, 1200))
    for field, values in fields.items():
        for value in values:
            yield dict(base, **{field: value})
    for enabled, pan, region_pan in itertools.product((0, 1, 255), (0, 64, 127, 255), (-128, -1, 0, 64, 127)):
        yield dict(base, pan_enabled=enabled, pan=pan, region_pan=region_pan)
    # Extreme signed bend values use small factors to keep pitch finite.
    for bend, factor in itertools.product((0, 1, -1, 8192, -8192, 32767, -32768), (-8, -1, 0, 1, 8)):
        yield dict(base, bend=bend, up=factor, down=-factor)
    for bend, up, down in itertools.product((0, 1, -1, 127, -127), (-128, 127), (-128, 127)):
        yield dict(base, bend=bend, up=up, down=down)
    for category, level, attack in itertools.product((0, 1, 255), (0, 1, 127, 255), (0, 127, 255)):
        yield dict(base, category=category, velocity=level, region_volume=level,
                   volume=level, music=level, effects=255 - level, attack_volume=attack)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    family = 'audio-playback-execution'
    comparison = compare_block(NAME, 'src/game/audio/backend/playback.c', ENTRY,
                               0x5BC64, 0x5BFA8, target, family=family, layout=layout)
    pitch = compare_block('audio_pitch_scale', 'src/game/audio_pitch_scale.c', 0x8005B000,
                          0x5BC00, 0x5BC64, target, family=family, layout=layout)
    assert comparison['matches'] and pitch['matches'], (comparison, pitch)
    output = ROOT / 'build' / family
    compiled = (output / NAME / (NAME + '.bin')).read_bytes()
    pitch_code = (output / 'audio_pitch_scale/audio_pitch_scale.bin').read_bytes()
    constants = [(0x80095CD0, target[0x968D0:0x968E0]),
                 (0x80095CC4, target[0x968C4:0x968CC])]
    rebuilt_constants = []
    for unit, section in [(NAME, '.audio_backend_playback_rodata'),
                          ('audio_pitch_scale', '.audio_pitch_scale_rodata')]:
        with (output / unit / (unit + '.elf')).open('rb') as file:
            record = ELFFile(file).get_section_by_name(section)
            rebuilt_constants.append((record['sh_addr'], record.data()))
    assert rebuilt_constants == constants
    digest, count = hashlib.sha256(), 0
    for case in cases():
        original = execute(target[0x5BC64:0x5BFA8], [(0x8005B000, target[0x5BC00:0x5BC64])] + constants, case)
        rebuilt = execute(compiled, [(0x8005B000, pitch_code)] + rebuilt_constants, case)
        assert original == rebuilt, case
        digest.update(json.dumps([case, rebuilt], sort_keys=True).encode())
        count += 1
    report = dict(matches=True, cases=count, comparison=comparison, pitch_comparison=pitch,
                  trace_sha256=digest.hexdigest(), emulator=version('unicorn'),
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  machine_helper_sha256=hashlib.sha256((ROOT / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
                  target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  limits=['SDK allocation and start use recorded stubs; devices and SDK callees are outside scope.',
                          'Caller-saved integer and floating registers are clobbered at both SDK boundaries.',
                          'Private BSS including padding, input records, pointer globals, guards, stack and callee-saved registers checked.',
                          'Finite pitch fixtures cover signed bend and separate up/down factors; volume uses observed 32-bit wrapping.'])
    (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Passed audio playback:', count, 'cases;', output / 'report.json')


if __name__ == '__main__':
    main()
