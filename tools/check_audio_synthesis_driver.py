"""Execute driver startup with actual heap, clear, link and queue helpers.

The SDK synthesizer constructor is a recorded ABI boundary. Finite sample-rate
fixtures and bounded allocations are modeled independently of retail code.
"""
import hashlib
import itertools
import json
import struct
from importlib.metadata import version
from pathlib import Path
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL
from check_audio_synthesis_startup import f32, FP_STUB, FP_INIT, FP_RETURN
from check_audio_instance_allocate import CALLER_SAVED
from compare_startup import compare_block, SymbolLayoutSnapshot
from rom import ROOT, validate

ENTRY = 0x80051C00
CONFIGURATION, SETTINGS, HEAP, ARENA = 0x80201010, 0x80202010, 0x80203010, 0x80210000
ARENA_SIZE, SYNTH, CONSTRUCTOR = 0x20000, 0x80190194, 0x80065B3C
SUPPORT = (
    ('audio_heap_allocate', 'src/sdk/audio_heap_allocate.c', 0x80065730, 0x80065784),
    ('audio_link_nodes', 'src/sdk/audio_link_nodes.c', 0x80065AB0, 0x80065B04),
    ('message_queue', 'src/sdk/message_queue.c', 0x80060450, 0x8006047C),
    ('audio_io', 'src/game/audio_io.c', 0x800518E0, 0x80051A0C),
)


def fixture(case):
    rate, frame_rate, voices, buffers, dma_size, commands, messages, extra = case
    configuration = bytearray(b'\xA3' * 36)
    configuration[20:28] = word(HEAP) + word(rate)
    settings = bytearray(b'\xB5' * 28)
    settings[0:4] = struct.pack('>f', frame_rate)
    settings[8:12] = word(commands)
    images = {CONFIGURATION: configuration, SETTINGS: settings,
        HEAP: bytearray(word(ARENA) * 2 + word(ARENA_SIZE) + word(0x91234567)),
        0x8008D828: bytearray(word(buffers) + word(messages) + word(dma_size) + word(extra) + word(1) + word(voices) + word(48)),
        0x80190180: bytearray(b'\xC7' * 224), ARENA: bytearray(b'\xD9' * ARENA_SIZE)}
    expected = {address: bytearray(blob) for address, blob in images.items()}
    state, arena = expected[0x80190180], expected[ARENA]
    ratio = f32(f32(rate) / f32(frame_rate))
    truncated = int(ratio)
    samples = truncated if 0 <= truncated <= 0xFFFFFFFF else 0xFFFFFFFF
    if f32(samples) < ratio:
        samples = (samples + 1) & 0xFFFFFFFF
    if samples & 15:
        samples = ((samples & 0xFFFFFFF0) + 16) & 0xFFFFFFFF
    capacity = (samples + extra + 16) & 0xFFFFFFFF
    state[0x70:0x80] = word(samples - 16) + word(samples) + word(capacity) + word(commands)
    position, trace, allocations = 0, [], []
    def allocate(size):
        nonlocal position
        start = position
        length = (size + 15) & ~15
        assert start + length <= ARENA_SIZE, case
        position += length
        allocations.append((ARENA + start, size))
        trace.append([0x80065730, [0, 0, HEAP, 1, size], ARENA + start])
        arena[start:start + size] = bytes(size)
        return ARENA + start
    def state_word(offset, value):
        state[offset:offset + 4] = word(value)
    state_word(0x80, allocate(voices * 28))
    state_word(0x84, allocate(voices))
    pool = allocate(buffers * 20)
    state_word(0x6C, pool)
    for index in range(buffers):
        offset = pool - ARENA + index * 20
        arena[offset:offset + 8] = word(pool + (index + 1) * 20 if index + 1 < buffers else 0) + word(pool + (index - 1) * 20 if index else 0)
        data = allocate(dma_size)
        arena[offset + 16:offset + 20] = word(data)
    for index in range(2):
        state_word(index * 4, allocate(commands * 8))
    for index in range(3):
        record = allocate(72)
        state_word(8 + index * 4, record)
        data = allocate(capacity * 4)
        arena[record - ARENA:record - ARENA + 4] = word(data)
    dma = allocate(messages * 24)
    state_word(0xA0, dma)
    message_array = allocate(messages * 4)
    state_word(0xA4, message_array)
    state[0x88:0xA0] = word(0x8008F1A0) * 2 + word(0) * 2 + word(messages) + word(message_array)
    expected[HEAP][4:8] = word(ARENA + position)
    return images, expected, trace, allocations, position


def execute(code, support, case):
    images, expected, calls, allocations, used = fixture(case)
    fp_seed = b''.join(word(0x3F000000 + index * 0x10000) for index in range(32))
    initializer = b''.join(word(0xC4003000 | index << 16 | index * 4) for index in range(32))
    initializer += word(0x08000000 | ((ENTRY >> 2) & 0x3FFFFFF)) + word(0)
    clobber = b''.join(word(0xC4003080 | index << 16) for index in range(20)) + word(0x03E00008) + word(0)
    observer = b''.join(word(0xE4003100 | index << 16 | (index - 20) * 4) for index in range(20, 32))
    observer += word(0x08000000 | ((SENTINEL >> 2) & 0x3FFFFFF)) + word(0)
    uc, write, _ = machine([(ENTRY, code), (FP_INIT, initializer), (FP_STUB, clobber), (FP_RETURN, observer)], support)
    write(0x3000, fp_seed + word(0x42E00000))
    write(0x3100, b'\x89' * 48)
    guards = bytes(range(16))
    for address, blob in images.items():
        write(address - 16, guards + bytes(blob) + guards)
    write(0x802FFFB0, b'\x79' * 112)
    writable = [(HEAP + 4, HEAP + 8), (0x80190180, 0x80190228),
                (ARENA, ARENA + used), (0x802FFFC0, 0x80300000), (0x3100, 0x3130)]
    readable = [(address, address + len(blob)) for address, blob in images.items()] + [(0x802FFFC0, 0x80300000), (0x3000, 0x3084)]
    def memory_guard(uc, access, address, size, value, mode):
        address &= 0x1FFFFFFF
        allowed = readable if mode == 'read' else writable
        assert any((start & 0x1FFFFFFF) <= address and address + size <= (end & 0x1FFFFFFF) for start, end in allowed), (mode, hex(address), size, case)
    uc.hook_add(UC_HOOK_MEM_READ, memory_guard, user_data='read')
    uc.hook_add(UC_HOOK_MEM_WRITE, memory_guard, user_data='write')
    trace = []
    constructor_calls = []
    def allocation_entry(uc, address, size, user):
        arguments = [uc.reg_read(reg) for reg in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)]
        sp = uc.reg_read(regs.UC_MIPS_REG_SP)
        arguments.append(int.from_bytes(uc.mem_read((sp + 16) & 0x1FFFFFFF, 4), 'big'))
        expected_call = calls[len(trace)]
        assert [address, arguments] == expected_call[:2], (case, arguments, expected_call)
        trace.append(expected_call)
    def constructor(uc, address, size, user):
        arguments = [uc.reg_read(reg) for reg in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1)]
        assert arguments == [SYNTH, CONFIGURATION]
        assert len(trace) == len(calls) and not constructor_calls
        constructor_calls.append([address, arguments])
        for location, blob in expected.items():
            assert bytes(uc.mem_read(location & 0x1FFFFFFF, len(blob))) == bytes(blob), (case, hex(location))
        for index, reg in enumerate(CALLER_SAVED):
            uc.reg_write(reg, 0xB1230000 + index * 257)
        uc.reg_write(regs.UC_MIPS_REG_PC, FP_STUB)
    uc.hook_add(UC_HOOK_CODE, allocation_entry, begin=0x80065730, end=0x80065730)
    uc.hook_add(UC_HOOK_CODE, constructor, begin=CONSTRUCTOR, end=CONSTRUCTOR)
    uc.reg_write(regs.UC_MIPS_REG_A0, CONFIGURATION)
    uc.reg_write(regs.UC_MIPS_REG_A1, SETTINGS)
    uc.reg_write(regs.UC_MIPS_REG_RA, FP_RETURN)
    # Byte clearing makes this full routine exceed the shared helper's 20,000
    # instruction limit. Retain its sentinel and verify every saved register.
    uc.emu_start(FP_INIT, 0, count=400000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL and uc.reg_read(regs.UC_MIPS_REG_SP) == 0x80300000, (case, hex(uc.reg_read(regs.UC_MIPS_REG_PC)), hex(uc.reg_read(regs.UC_MIPS_REG_SP)), len(trace), used)
    for index, name in enumerate(('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP')):
        assert uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + name)) == 0xA2340000 + index * 256, (name, case)
    read = lambda address, size: bytes(uc.mem_read(address & 0x1FFFFFFF, size))
    assert read(0x3100, 48) == fp_seed[80:128]
    assert constructor_calls == [[CONSTRUCTOR, [SYNTH, CONFIGURATION]]]
    digest = hashlib.sha256()
    for address, blob in expected.items():
        actual = read(address - 16, len(blob) + 32)
        assert actual == guards + bytes(blob) + guards, (case, hex(address))
        digest.update(word(address) + actual)
    assert read(0x802FFFB0, 16) == b'\x79' * 16
    assert read(0x80300000, 32) == b'\x79' * 32
    return dict(allocations=trace, constructor=constructor_calls, used=used, state_sha256=digest.hexdigest())


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    comparisons, original_support, compiled_support = {}, [], []
    for name, source, start, end in (('audio_synthesis_driver', 'src/game/audio/startup/driver.c', ENTRY, 0x8005211C),) + SUPPORT:
        rom_start, rom_end = start - 0x80000000 + 0xC00, end - 0x80000000 + 0xC00
        comparisons[name] = compare_block(name, source, start, rom_start, rom_end, target, family='audio-driver-execution', layout=layout)
        assert comparisons[name]['matches'], {key: value for key, value in comparisons[name].items() if key != 'inputs_sha256'}
        code = (ROOT / 'build/audio-driver-execution' / name / (name + '.bin')).read_bytes()
        if start == ENTRY:
            compiled = code
        else:
            original_support.append((start, target[rom_start:rom_end]))
            compiled_support.append((start, code))
    base = (22050, 60.0, 24, 2, 16, 8, 4, 80)
    cases = [base]
    for field, values in enumerate([(-22050, -1, 0, 32000, 44100, 48000), (50.0, 59.94, 20.0, 100000.0), (0, 1, 128), (1, 4), (0, 1, 2048), (0, 1, 128), (0, 1, 32), (0, 1, 4095)]):
        for value in values:
            case = list(base)
            case[field] = value
            cases.append(tuple(case))
    for voices, buffers, size in itertools.product((1, 24), (1, 4), (1, 2048)):
        cases.append((48000, 59.94, voices, buffers, size, 8, 4, 80))
    digest = hashlib.sha256()
    for case in cases:
        original = execute(target[0x52800:0x52D1C], original_support, case)
        rebuilt = execute(compiled, compiled_support, case)
        assert original == rebuilt
        digest.update(json.dumps([case, rebuilt], sort_keys=True).encode())
    report = dict(matches=True, cases=len(cases), comparisons=comparisons, trace_sha256=digest.hexdigest(), emulator=version('unicorn'),
        checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(), target_rom_sha256=hashlib.sha256(target).hexdigest(),
        limits=['SDK synthesizer construction is a recorded ABI stub; SDK/device behavior is outside scope.',
                'Actual freshly matched heap allocation, byte clearing, linked-list insertion and queue setup execute.',
                'Full arena including allocation alignment and unused capacity, inputs, globals, BSS, guards, stack, integer and floating callee-saved registers are checked.',
                'Finite rates and bounded successful allocations are covered; malformed zero buffer counts and heap exhaustion retain original behavior and are outside scope.'])
    path = ROOT / 'build/audio-driver-execution/report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed audio synthesis driver:', len(cases), 'cases;', path)


if __name__ == '__main__':
    main()
