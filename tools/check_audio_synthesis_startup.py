"""Execute complete synthesis startup against retail and independent fixtures.

Queue setup, capture token, rate scale and delay helpers execute freshly matched
source. SDK frequency/device setup and driver/reset callbacks are ABI stubs.
"""

import hashlib
import itertools
import json
import struct
from importlib.metadata import version
from pathlib import Path
from elftools.elf.elffile import ELFFile
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs

from check_actor_group_path import machine, word, SENTINEL
from check_audio_instance_allocate import CALLER_SAVED
from compare_data import compare_unit, comparison_directory
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import load_owned_sections
from rom import ROOT, validate

NAME, ENTRY = 'audio_synthesis_startup', 0x80051A0C
SETTINGS, PARAMETERS, HEAP = 0x80201010, 0x80202010, 0x80203010
QUEUE, MESSAGES, CONFIGURATION = 0x80190228, 0x80190240, 0x802FFFDC
FREQUENCY, DRIVER, RESET, CONTROL = 0x80065950, 0x80051C00, 0x80052700, 0x80052BA4
FP_STUB, FP_INIT, FP_RETURN = 0x80001000, 0x80001800, 0x80002000
SUPPORT = (
    ('message_queue', 'src/sdk/message_queue.c', 0x80060450, 0x8006047C),
    ('audio_voice_capture_control', 'src/game/audio_voice_capture_control.c', 0x8005AD88, 0x8005ADD0),
    ('audio_rate_scale', 'src/game/audio_rate_scale.c', 0x8005AD50, 0x8005AD88),
    ('audio_io', 'src/game/audio_io.c', 0x800518E0, 0x80051A0C),
    ('audio_pool_callback', 'src/game/audio_pool_callback.c', 0x8005254C, 0x80052580),
)


def f32(value):
    return struct.unpack('>f', struct.pack('>f', value))[0]


def fixture(case):
    frequency, effect, count, delay, error = case
    images = {
        SETTINGS: bytearray(struct.pack('>f', 60.0) + word(frequency) + word(184) +
                            word(HEAP) + word(0x0066BEE0) + word(effect) +
                            word(0 if error and effect & 255 != 6 else PARAMETERS)),
        PARAMETERS: bytearray(b''.join(word(0x61230000 + i) for i in range(34))),
        HEAP: bytearray(b'\xA3' * 16),
        QUEUE: bytearray(b'\xB5' * 56),
        0x8008D79C: bytearray(b'\xC7' * 12),
        0x8008D83C: bytearray(word(128 if error else 24) + word(96 if error else 48)),
        0x8008DA30: bytearray(b'\xD9' * 4),
        0x80192A98: bytearray(b'\xE3' * 4),
    }
    parameters = images[PARAMETERS]
    parameters[0:8] = word(count) + word(delay)
    for index in range(4):
        parameters[8 + index * 32:16 + index * 32] = word(delay + index) + word(-delay - index - 1)
    expected = {address: bytearray(blob) for address, blob in images.items()}
    expected[QUEUE][:24] = word(0x8008F1A0) * 2 + word(0) * 2 + word(8) + word(MESSAGES)
    expected[0x8008D79C][:] = word(0) + word(0) + word(1)
    expected[0x80192A98][:] = word(0x0066BEE0)
    expected[0x8008DA30][:] = struct.pack('>f', f32(22050.0 / f32(frequency)))
    configuration = bytearray(b'\x79' * 36)
    configuration[:12] = word(128 if error else 24) * 2 + word(96 if error else 48)
    output_rate = -1 if error else 22047
    configuration[16:29] = word(0x8005254C) + word(HEAP) + word(output_rate) + bytes([effect & 255])
    if effect & 255 == 6:
        ratio = f32(f32(frequency) / 1000.0)
        for index in [1] + [2 + row * 8 + field for row in range(max(0, count)) for field in (0, 1)]:
            value = int.from_bytes(parameters[index * 4:index * 4 + 4], 'big', signed=True)
            converted = int(f32(f32(value) * ratio)) & ~7
            assert -0x80000000 <= converted <= 0x7FFFFFFF, case
            expected[PARAMETERS][index * 4:index * 4 + 4] = word(converted)
        configuration[32:36] = word(PARAMETERS)
    calls = [[FREQUENCY, [frequency]], [DRIVER, [CONFIGURATION, SETTINGS]], [RESET, []], [CONTROL, []]]
    return images, expected, bytes(configuration), calls, output_rate


def execute(code, support, case):
    images, expected, configuration, calls, output_rate = fixture(case)
    fp_seed = b''.join(word(0x3F000000 + index * 0x10000) for index in range(32))
    initializer = b''.join(word(0xC4003000 | index << 16 | index * 4) for index in range(32))
    initializer += word(0x08000000 | ((ENTRY >> 2) & 0x3FFFFFF)) + word(0)
    clobber = b''.join(word(0xC4003080 | index << 16) for index in range(20))
    clobber += word(0x03E00008) + word(0)
    observer = b''.join(word(0xE4003100 | index << 16 | (index - 20) * 4) for index in range(20, 32))
    observer += word(0x08000000 | ((SENTINEL >> 2) & 0x3FFFFFF)) + word(0)
    uc, write, run = machine([(ENTRY, code), (FP_INIT, initializer), (FP_STUB, clobber), (FP_RETURN, observer)], support)
    write(0x3000, fp_seed + word(0x42E00000))
    write(0x3100, b'\x89' * 48)
    guards = bytes(range(16))
    for address, blob in images.items():
        write(address - 16, guards + bytes(blob) + guards)
    write(0x802FFF70, b'\x79' * 176)
    writable = [(PARAMETERS, PARAMETERS + 136), (QUEUE, QUEUE + 24),
                (0x8008D79C, 0x8008D7A8), (0x8008DA30, 0x8008DA34),
                (0x80192A98, 0x80192A9C), (0x802FFF80, 0x80300000), (0x3100, 0x3130)]
    readable = [(address, address + len(blob)) for address, blob in images.items()]
    readable += [(0x802FFF80, 0x80300000), (0x80095CC0, 0x80095CC4), (0x3000, 0x3084)]
    def memory_guard(uc, access, address, size, value, mode):
        address = address & 0x1FFFFFFF
        allowed = readable if mode == 'read' else writable
        assert any((start & 0x1FFFFFFF) <= address and address + size <= (end & 0x1FFFFFFF)
                   for start, end in allowed), (mode, hex(address), size, case)
    uc.hook_add(UC_HOOK_MEM_READ, memory_guard, user_data='read')
    uc.hook_add(UC_HOOK_MEM_WRITE, memory_guard, user_data='write')
    trace = []
    def boundary(uc, address, size, user):
        args = [uc.reg_read(reg) for reg in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1)]
        args = args[:1] if address == FREQUENCY else args[:2] if address == DRIVER else []
        event = [address, args]
        assert len(trace) < len(calls) and event == calls[len(trace)], (case, event, calls)
        if address == DRIVER:
            actual = bytes(uc.mem_read(CONFIGURATION & 0x1FFFFFFF, 36))
            assert actual == configuration, (case, actual.hex(), configuration.hex())
            for location in [PARAMETERS, QUEUE, 0x8008DA30, 0x80192A98]:
                assert bytes(uc.mem_read(location & 0x1FFFFFFF, len(expected[location]))) == bytes(expected[location]), (case, hex(location))
            assert bytes(uc.mem_read(0x8D79C, 8)) == word(0) * 2
            assert bytes(uc.mem_read(0x8D7A4, 4)) == b'\xC7' * 4
        trace.append(event)
        for index, reg in enumerate(CALLER_SAVED):
            uc.reg_write(reg, 0xB1230000 + index * 257)
        uc.reg_write(regs.UC_MIPS_REG_V0, output_rate & 0xFFFFFFFF)
        uc.reg_write(regs.UC_MIPS_REG_PC, FP_STUB)
    for address in (FREQUENCY, DRIVER, RESET, CONTROL):
        uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)
    uc.reg_write(regs.UC_MIPS_REG_A0, SETTINGS)
    uc.reg_write(regs.UC_MIPS_REG_RA, FP_RETURN)
    run(FP_INIT)
    assert trace == calls, case
    read = lambda address, size: bytes(uc.mem_read(address & 0x1FFFFFFF, size))
    assert read(0x3100, 48) == fp_seed[80:128], ('Floating callee-saved registers', case)
    digest = hashlib.sha256()
    for address, blob in expected.items():
        actual = read(address - 16, len(blob) + 32)
        assert actual == guards + bytes(blob) + guards, (case, hex(address))
        digest.update(word(address) + actual)
    assert read(0x802FFF70, 16) == b'\x79' * 16
    assert read(0x80300000, 32) == b'\x79' * 32
    assert read(0x802FFFA8, 52) == b'\x79' * 52, ('Untouched frame gap', case)
    assert read(CONFIGURATION, 36) == configuration
    return dict(trace=trace, state_sha256=digest.hexdigest(), configuration=configuration.hex())


def execute_factory(code, initialized, pool, state):
    image = bytes([initialized]) + b'\x83' * 3 + word(0x80212340) + word(0x80223450) + word(pool)
    expected = bytearray(image)
    if initialized == 0:
        expected[0] = 1
        expected[4:12] = word(0) + word(pool)
    uc, write, run = machine([(0x8005254C, code)], [])
    write(0x801901D0, b'\x79' * 16 + image + b'\x79' * 16)
    def memory_guard(uc, access, address, size, value, mode):
        address |= 0x80000000
        assert 0x801901E0 <= address and address + size <= 0x801901F0, (mode, hex(address), state)
    uc.hook_add(UC_HOOK_MEM_READ, memory_guard, user_data='read')
    uc.hook_add(UC_HOOK_MEM_WRITE, memory_guard, user_data='write')
    uc.reg_write(regs.UC_MIPS_REG_A0, state)
    run(0x8005254C)
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == 0x80052378
    assert bytes(uc.mem_read(0x1901D0, 48)) == b'\x79' * 16 + bytes(expected) + b'\x79' * 16
    return bytes(expected).hex()


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    comparisons = {}
    original_support, compiled_support = [], []
    for name, source, start, end in ((NAME, 'src/game/audio/startup/synthesis.c', ENTRY, 0x80051C00),) + SUPPORT:
        rom_start, rom_end = start - 0x80000000 + 0xC00, end - 0x80000000 + 0xC00
        comparisons[name] = compare_block(name, source, start, rom_start, rom_end, target, family='audio-synthesis-execution', layout=layout)
        assert comparisons[name]['matches'], {key: value for key, value in comparisons[name].items() if key != 'inputs_sha256'}
        code = (ROOT / 'build/audio-synthesis-execution' / name / (name + '.bin')).read_bytes()
        if name == NAME:
            compiled = code
        else:
            original_support.append((start, target[rom_start:rom_end]))
            compiled_support.append((start, code))
    records = load_owned_sections()
    data_comparisons = {}
    for source in ('src/game/audio/startup/storage.c', 'src/game/audio/startup/rate_constant.c'):
        owned = [record for record in records if record['source'] == source]
        data_comparisons[source] = compare_unit(source, owned, target, layout)
        with (comparison_directory(source) / 'compiled.elf').open('rb') as file:
            elf = ELFFile(file)
            for record in owned:
                if record['rom'] is not None:
                    section = elf.get_section_by_name(record['section'])
                    if record['vram'] == 0x80095CC0:
                        compiled_support.append((record['vram'], section.data()))
                        original_support.append((record['vram'], target[record['rom']:record['rom'] + record['size']]))
    digest, count = hashlib.sha256(), 0
    for frequency, effect, rows, delay, error in itertools.product(
            (1, 8000, 22050, 32000, 44100, 48000, 0x7FFFFFFF, 0x80000000, 0xFFFFFFFF),
            (0, 5, 6, 7, 262, -250, -1), (-3, 0, 1, 3), (-17, 0, 1, 9, 255, -255), (0, 1)):
        case = (frequency, effect, rows, delay, error)
        original = execute(target[0x5260C:0x52800], original_support, case)
        rebuilt = execute(compiled, compiled_support, case)
        assert original == rebuilt, case
        digest.update(json.dumps([case, rebuilt], sort_keys=True).encode())
        count += 1
    factory_cases = 0
    retail_factory = next(code for address, code in original_support if address == 0x8005254C)
    compiled_factory = next(code for address, code in compiled_support if address == 0x8005254C)
    for initialized, pool, state in itertools.product((0, 1, 255), (0, 0x80234560, 0xFFFFFFFF), (0, 0x80245670, 3)):
        original = execute_factory(retail_factory, initialized, pool, state)
        rebuilt = execute_factory(compiled_factory, initialized, pool, state)
        assert original == rebuilt
        digest.update(json.dumps([initialized, pool, state, rebuilt]).encode())
        factory_cases += 1
    report = dict(matches=True, cases=count, factory_cases=factory_cases, comparisons=comparisons, data_comparisons=data_comparisons,
        trace_sha256=digest.hexdigest(), emulator=version('unicorn'),
        checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        machine_helper_sha256=hashlib.sha256((ROOT / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
        target_rom_sha256=hashlib.sha256(target).hexdigest(),
        limits=['SDK frequency, driver, reset and control use recorded ABI stubs; devices and downstream driver behavior are outside scope.',
                'Freshly matched queue, capture token, unsigned rate scale and delay helpers execute complete retail code.',
                'Caller-saved integer and floating registers are clobbered; callee-saved integer/float registers and SP are checked.',
                'Full settings, parameters, heap, queue/messages, state, configuration padding, frame gap, guards and memory bounds are checked.',
                'Finite conversions cover signed delays and unsigned high-bit frequencies; out-of-range float-to-int and malformed parameter pointers are outside scope.'])
    path = ROOT / 'build/audio-synthesis-execution/report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed audio synthesis startup:', count, 'cases;', factory_cases, 'factory cases;', path)


if __name__ == '__main__':
    main()
