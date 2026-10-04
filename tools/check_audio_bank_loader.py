"""Check the complete SN64 loader against independent memory and error models.

File IO, storage decoding, prior-bank release and backend initialization are
recorded ABI boundaries. Matching clear, control and host routines execute.
"""
import hashlib
import itertools
import json
from importlib.metadata import version
from pathlib import Path
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL
from check_audio_instance_allocate import CALLER_SAVED
from check_audio_synthesis_startup import FP_INIT, FP_STUB, FP_RETURN
from compare_startup import compare_block, SymbolLayoutSnapshot
from rom import ROOT, validate

ENTRY, ARENA, SOURCE, FILE = 0x8005303C, 0x80210000, 0x80201880, 0x80202080
STATE, CONFIG, BSS, CONTEXT = 0x8008D7B0, 0x8008D828, 0x80190280, 0x801902C8
ERROR, ARENA_SIZE = 0x80070F00, 0x20000
SUPPORT = (('audio_control', 'src/game/audio_control.c', 0x80052A00, 0x80052D70),
           ('audio_host_control', 'src/game/audio_host_control.c', 0x8005891C, 0x8005895C))
BOUNDARIES = (0x80052CF4, 0x80058B0C, 0x80058B20, 0x80058BBC,
              0x800588D4, 0x800596C4, 0x8005B3A8, ERROR)


def aligned(address, alignment):
    return (address + alignment - 1) & -alignment


def fixture(case):
    stage, mode, loaded, error_callback, offset, hardware, instances, voices, gates, iterations, callbacks, indices, depth, payload_size = case
    start = ARENA + offset
    payload = bytes((index * 31 + 7) & 255 for index in range(payload_size))
    table = bytearray(b'\x63' * 32)
    table[:8] = word(0x534E3634 if stage != 'bad_magic' else 0x534E3635) + word(2 if stage != 'bad_version' else 3)
    table[16] = mode
    table[24:28] = word(payload_size)
    patch = bytes(range(24))
    position = aligned(start, 8) + payload_size + instances * 24 + voices * 80 + (hardware & 255) * 20 + callbacks * 8
    for _ in range(instances):
        position = aligned(position + gates, 4)
        position = aligned(position + iterations, 4)
        position = aligned(position + (indices & 255), 4)
    position = aligned(position + voices * (depth & 255) * 4, 4)
    supplied_size = aligned(position - start + 4096, 16)
    assert offset + supplied_size <= ARENA_SIZE
    allocation = 0 if stage == 'allocator_null' else start
    source = 0 if stage == 'null_source' else SOURCE
    globals_image = bytearray(word(0x80201100) + word(stage != 'inactive') + word(loaded) + word(0) * 3 + word(0x80205500) + word(0x91827364) + word(ERROR if error_callback else 0) + word(0xA1B2C3D4))
    configuration = bytearray(b''.join(word(value) for value in [24, 32, 2048, 80, 1, hardware, 48, instances, voices, gates, iterations, callbacks, indices, depth, 0, 0, 0x12345678, 0x23456789, 2, 0x3456789A]))
    images = {STATE: globals_image, CONFIG: configuration, BSS: bytearray(b'\xC7' * 112),
              ARENA: bytearray(b'\xD9' * ARENA_SIZE), SOURCE: bytearray(b'\x67' * 32)}
    expected = {address: bytearray(blob) for address, blob in images.items()}
    state, bss, arena = expected[STATE], expected[BSS], expected[ARENA]
    calls = []
    def put(image, location, value):
        image[location:location + 4] = word(value)
    if loaded:
        calls.append([0x80052CF4, []])
        put(state, 8, 0)
    put(state, 16, allocation == 0)
    put(state, 20, allocation)
    if not allocation:
        return images, expected, calls, 0, allocation, source, supplied_size, payload, table, patch
    put(state, 28, supplied_size)
    arena[offset:offset + supplied_size] = bytes(supplied_size)
    if stage in ('inactive', 'null_source'):
        return images, expected, calls, 0, allocation, source, supplied_size, payload, table, patch
    calls.append([0x80058B0C, [source]])
    put(state, 0, 0 if stage == 'open_null' else FILE)
    def error(value):
        if error_callback:
            calls.append([ERROR, [0xA1B2C3D4, value]])
    if stage == 'open_null':
        error(1)
        return images, expected, calls, 0, allocation, source, supplied_size, payload, table, patch
    put(bss, 108, CONTEXT)
    bss[79] = hardware & 255
    put(bss, 72, 0x8008D86C)
    put(bss, 84, BSS)
    put(bss, 92, BSS + 40)
    table_bytes = 31 if stage == 'header_short' else 32
    calls.append([0x80058B20, [BSS, 32, FILE]])
    bss[:table_bytes] = table[:table_bytes]
    if stage == 'header_short':
        error(2)
    elif stage not in ('bad_magic', 'bad_version'):
        patch_bytes = 23 if stage == 'patch_short' else 24
        calls.append([0x80058B20, [BSS + 40, 24, FILE]])
        bss[40:40 + patch_bytes] = patch[:patch_bytes]
        if stage == 'patch_short':
            error(2)
        else:
            cursor = aligned(start, 8)
            put(bss, 64, cursor)
            if mode:
                calls.append([0x80058BBC, [FILE]])
                calls.append([0x800588D4, [mode, source, 56, cursor, payload_size]])
                if stage == 'decode_negative':
                    return images, expected, calls, 0, allocation, source, supplied_size, payload, table, patch
                arena[cursor - ARENA:cursor - ARENA + payload_size] = payload
            else:
                calls.append([0x80058B20, [cursor, payload_size, FILE]])
                data_bytes = max(payload_size - 1, 0) if stage == 'payload_short' else payload_size
                arena[cursor - ARENA:cursor - ARENA + data_bytes] = payload[:data_bytes]
                if stage == 'payload_short':
                    assert payload_size > 0
                    error(2)
                    return images, expected, calls, 0, allocation, source, supplied_size, payload, table, patch
                calls.append([0x80058BBC, [FILE]])
            cursor += payload_size
            instance_base = cursor
            put(bss, 96, cursor)
            cursor += instances * 24
            voice_base = cursor
            put(bss, 100, cursor)
            cursor += voices * 80
            put(bss, 104, cursor)
            for index in range(hardware & 255):
                arena[cursor - ARENA + index * 20 + 1:cursor - ARENA + index * 20 + 3] = bytes([1, index])
            cursor += (hardware & 255) * 20
            put(bss, 88, cursor)
            cursor += callbacks * 8
            bss[82] = indices & 255
            for index in range(instances):
                record = instance_base - ARENA + index * 24
                put(arena, record + 16, cursor)
                cursor = aligned(cursor + gates, 4)
                put(arena, record + 20, cursor)
                cursor = aligned(cursor + iterations, 4)
                put(arena, record + 12, cursor)
                arena[cursor - ARENA:cursor - ARENA + (indices & 255)] = b'\xFF' * (indices & 255)
                cursor = aligned(cursor + (indices & 255), 4)
            bss[83] = depth & 255
            for index in range(voices):
                record = voice_base - ARENA + index * 80
                arena[record + 1] = index & 255
                put(arena, record + 60, cursor)
                cursor += (depth & 255) * 4
                put(arena, record + 68, cursor)
            cursor = aligned(cursor, 4)
            calls.extend([[0x800596C4, [CONTEXT]], [0x8005B3A8, [CONTEXT]]])
            put(state, 24, cursor)
            put(state, 8, 1)
            put(expected[CONFIG], 72, 1)
            return images, expected, calls, 1, allocation, source, supplied_size, payload, table, patch
    return images, expected, calls, 0, allocation, source, supplied_size, payload, table, patch


def execute(code, support, case):
    images, expected, calls, result, allocation, source, supplied_size, payload, table, patch = fixture(case)
    stage, mode = case[:2]
    fp_seed = b''.join(word(0x3F000000 + index * 0x10000) for index in range(32))
    initializer = b''.join(word(0xC4003000 | index << 16 | index * 4) for index in range(32)) + word(0x08000000 | ((ENTRY >> 2) & 0x3FFFFFF)) + word(0)
    clobber = b''.join(word(0xC4003080 | index << 16) for index in range(20)) + word(0x03E00008) + word(0)
    observer = b''.join(word(0xE4003100 | index << 16 | (index - 20) * 4) for index in range(20, 32)) + word(0x08000000 | ((SENTINEL >> 2) & 0x3FFFFFF)) + word(0)
    uc, write, _ = machine([(ENTRY, code), (FP_INIT, initializer), (FP_STUB, clobber), (FP_RETURN, observer)], support)
    write(0x3000, fp_seed + word(0x42E00000))
    write(0x3100, b'\x89' * 48)
    guards = bytes(range(16))
    for address, blob in images.items():
        write(address - 16, guards + bytes(blob) + guards)
    write(0x802FFF60, b'\x79' * 192)
    writable = [(STATE, STATE + 40), (CONFIG + 72, CONFIG + 76), (BSS, BSS + 112),
                (ARENA, ARENA + supplied_size + case[4]), (0x802FFF70, 0x8030000C), (0x3100, 0x3130)]
    readable = [(address, address + len(blob)) for address, blob in images.items()] + [(0x802FFF70, 0x8030000C), (0x3000, 0x3084)]
    # These three fully source-owned callback tables retain their retail words.
    rom = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    for address, rom_start, size in [(0x8008D800, 0x8E400, 8), (0x8008D920, 0x8E520, 4),
                                     (0x8008D9D0, 0x8E5D0, 4), (0x80095CB8, 0x968B8, 8)]:
        write(address, rom[rom_start:rom_start + size])
        readable.append((address, address + size))
    def memory_guard(uc, access, address, size, value, mode):
        address &= 0x1FFFFFFF
        allowed = readable if mode == 'read' else writable
        assert any((start & 0x1FFFFFFF) <= address and address + size <= (end & 0x1FFFFFFF) for start, end in allowed), (mode, hex(address), size, case)
    uc.hook_add(UC_HOOK_MEM_READ, memory_guard, user_data='read')
    uc.hook_add(UC_HOOK_MEM_WRITE, memory_guard, user_data='write')
    trace = []
    def boundary(uc, address, size, user):
        argument_count = {0x80052CF4: 0, 0x80058B0C: 1, 0x80058B20: 3, 0x80058BBC: 1,
                          0x800588D4: 5, 0x800596C4: 1, 0x8005B3A8: 1, ERROR: 2}[address]
        arguments = [uc.reg_read(reg) for reg in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)][:argument_count]
        if argument_count == 5:
            arguments.append(int.from_bytes(uc.mem_read((uc.reg_read(regs.UC_MIPS_REG_SP) + 16) & 0x1FFFFFFF, 4), 'big'))
        assert len(trace) < len(calls) and [address, arguments] == calls[len(trace)], (case, [hex(address), arguments], calls, trace)
        trace.append([address, arguments])
        returned = 0
        if address == 0x80052CF4:
            uc.mem_write((STATE + 8) & 0x1FFFFFFF, word(0))
        elif address == 0x80058B0C:
            returned = 0 if stage == 'open_null' else FILE
        elif address == 0x80058B20:
            destination, requested, _ = arguments
            if destination == BSS:
                blob = table[:31 if stage == 'header_short' else 32]
            elif destination == BSS + 40:
                blob = patch[:23 if stage == 'patch_short' else 24]
            else:
                blob = payload[:max(len(payload) - 1, 0)] if stage == 'payload_short' else payload
            assert requested >= len(blob)
            if blob:
                uc.mem_write(destination & 0x1FFFFFFF, bytes(blob))
            returned = len(blob)
        elif address == 0x800588D4:
            returned = 0xFFFFFFFF if stage == 'decode_negative' else 0
            if stage != 'decode_negative' and payload:
                uc.mem_write(arguments[3] & 0x1FFFFFFF, payload)
        elif address in (0x800596C4, 0x8005B3A8):
            for location, blob in expected.items():
                boundary_blob = bytearray(blob)
                if location == STATE:
                    boundary_blob[8:12] = word(0)
                    boundary_blob[24:28] = images[STATE][24:28]
                elif location == CONFIG:
                    boundary_blob[72:76] = images[CONFIG][72:76]
                assert bytes(uc.mem_read(location & 0x1FFFFFFF, len(blob))) == bytes(boundary_blob), (case, address, hex(location))
        for index, reg in enumerate(CALLER_SAVED):
            uc.reg_write(reg, 0xB1230000 + index * 257)
        uc.reg_write(regs.UC_MIPS_REG_V0, returned)
        uc.reg_write(regs.UC_MIPS_REG_PC, FP_STUB)
    for address in BOUNDARIES:
        uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)
    uc.reg_write(regs.UC_MIPS_REG_A0, source)
    uc.reg_write(regs.UC_MIPS_REG_A1, allocation)
    uc.reg_write(regs.UC_MIPS_REG_A2, supplied_size)
    uc.reg_write(regs.UC_MIPS_REG_RA, FP_RETURN)
    uc.emu_start(FP_INIT, 0, count=300000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    assert uc.reg_read(regs.UC_MIPS_REG_SP) == 0x80300000 and uc.reg_read(regs.UC_MIPS_REG_V0) == result
    assert trace == calls
    for index, name in enumerate(('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP')):
        assert uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + name)) == 0xA2340000 + index * 256
    read = lambda address, size: bytes(uc.mem_read(address & 0x1FFFFFFF, size))
    assert read(0x3100, 48) == fp_seed[80:128]
    digest = hashlib.sha256()
    for address, blob in expected.items():
        actual = read(address - 16, len(blob) + 32)
        assert actual == guards + bytes(blob) + guards, (case, hex(address))
        digest.update(word(address) + actual)
    assert read(0x802FFF60, 16) == b'\x79' * 16 and read(0x8030000C, 20) == b'\x79' * 20
    # The incoming argument-home words belong to the caller's reserved area.
    assert read(0x80300000, 4) == word(source) and read(0x80300008, 4) == word(supplied_size)
    assert read(0x80300004, 4) == (word(allocation) if case[2] else b'\x79' * 4)
    # The engine and its matching helpers never touch the frame's final words.
    assert read(0x802FFFF4, 12) == b'\x79' * 12
    return dict(trace=trace, return_value=result, state_sha256=digest.hexdigest())


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    comparisons, original_support, compiled_support = {}, [], []
    for name, source, start, end in (('audio_bank_load', 'src/game/audio/startup/bank_load.c', ENTRY, 0x8005362C),) + SUPPORT:
        rom_start, rom_end = start - 0x80000000 + 0xC00, end - 0x80000000 + 0xC00
        comparisons[name] = compare_block(name, source, start, rom_start, rom_end, target, family='audio-bank-load-execution', layout=layout)
        assert comparisons[name]['matches'], {key: value for key, value in comparisons[name].items() if key != 'inputs_sha256'}
        code = (ROOT / 'build/audio-bank-load-execution' / name / (name + '.bin')).read_bytes()
        if start == ENTRY:
            compiled = code
        else:
            original_support.append((start, target[rom_start:rom_end]))
            compiled_support.append((start, code))
    base = ('success', 0, 0, 1, 0, 24, 26, 25, 0, 0, 0, 16, 0, 32)
    cases = []
    for stage, loaded, error_callback in itertools.product(['allocator_null', 'inactive', 'null_source', 'open_null', 'header_short', 'bad_magic', 'bad_version', 'patch_short', 'payload_short'], range(2), range(2)):
        cases.append((stage, 0, loaded, error_callback) + base[4:])
    for mode, loaded, error_callback in itertools.product((1, 255), range(2), range(2)):
        cases.append(('decode_negative', mode, loaded, error_callback) + base[4:])
    for mode, loaded, offset in itertools.product((0, 1, 255), range(2), range(8)):
        cases.append(('success', mode, loaded, 1, offset) + base[5:])
    for field, values in [(5, (0, 1, 255, 256, 257)), (6, (0, 1, 128)), (7, (0, 1, 257)),
                          (8, (0, 1, 7)), (9, (0, 1, 7)), (10, (0, 1, 16)),
                          (11, (0, 1, 255, 256, 257)), (12, (0, 1, 255, 256, 257)), (13, (0, 8, 32, 2048))]:
        for value in values:
            case = list(base)
            case[field] = value
            cases.append(tuple(case))
    digest = hashlib.sha256()
    for case in cases:
        original = execute(target[0x53C3C:0x5422C], original_support, case)
        rebuilt = execute(compiled, compiled_support, case)
        assert original == rebuilt
        digest.update(json.dumps([case, rebuilt], sort_keys=True).encode())
    report = dict(matches=True, cases=len(cases), comparisons=comparisons, trace_sha256=digest.hexdigest(), emulator=version('unicorn'),
        checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(), target_rom_sha256=hashlib.sha256(target).hexdigest(),
        limits=['File open/read/close, storage decoding, prior-bank release and both backend initializers use recorded ABI boundaries.',
                'Fresh matching clear, state/error/cleanup control and null-returning host allocator/host timing routines execute.',
                'Complete supplied arena and unused capacity, BSS and alignment gaps, source token, globals, guards, integer/float callee-saved registers, SP and untouched frame tail are checked.',
                'Bounded valid headers and arenas, all visible early returns, byte truncation and alignment are covered; malformed sizes, unaligned payload records and undersized arenas retain original unchecked behavior and are outside scope.'])
    path = ROOT / 'build/audio-bank-load-execution/report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed SN64 bank loader:', len(cases), 'cases;', path)


if __name__ == '__main__':
    main()
