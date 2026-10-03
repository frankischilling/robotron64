"""Execute the sequence loader against retail bytes and a guarded array model.

Validation and file/DMA services are recorded ABI boundaries. Their I/O effects
are fixtures; this checker does not validate devices or the service callees.
"""
import hashlib
import itertools
import json
import struct
from pathlib import Path
from importlib.metadata import version

from unicorn import UC_HOOK_CODE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word
from check_audio_instance_allocate import CALLER_SAVED
from compare_startup import compare_block, SymbolLayoutSnapshot
from rom import ROOT, validate

NAME = 'audio_sequence_data_load'
ENTRY, END = 0x8005CE0C, 0x8005D220
CONTEXT, TABLE, ENTRIES, DEST = 0x80201010, 0x80202010, 0x80203010, 0x80210010
GLOBALS, LIMIT = 0x80192BA0, 0x8008D858
HANDLE, SOURCE = 0x12345678, 0x81234560
VALIDATE, OPEN, SEEK, READ, CLOSE, ERROR, DMA = (
    0x8005CD1C, 0x8005CD48, 0x80058B74, 0x80058B20,
    0x8005CDB8, 0x8005CCC0, 0x800588D4)
BOUNDARIES = {VALIDATE: 1, OPEN: 0, SEEK: 3, READ: 3, CLOSE: 0, ERROR: 1, DMA: 5}


def fixture(case):
    count, mode, alignment, labels, failure, index = case
    memory = DEST + alignment
    data = (memory + count * 12 + 7) & ~7
    payload = bytearray()
    records = []
    cursor = 0
    # Oversized counts are used only in cases rejected before touching storage.
    for track in range(min(count, 16)):
        label_count = labels if track % 2 == 0 else 0
        commands = 32 + 4 * (track % 3)
        next_cursor = cursor + 20 + 4 * label_count + commands
        payload.extend(b'\x65' * max(0, next_cursor - len(payload)))
        payload[cursor:cursor + 20] = bytes((track * 7 + j) & 255 for j in range(20))
        payload[cursor + 14:cursor + 16] = struct.pack('>h', label_count)
        payload[cursor + 16:cursor + 20] = word(commands)
        records.append((data + cursor, data + cursor + 20, data + cursor + 20 + 4 * label_count))
        cursor = next_cursor
    payload.extend(b'\x6D' * 16)
    images = {CONTEXT: bytearray(b'\xA7' * 36), TABLE: bytearray(b'\xB3' * 40),
              ENTRIES: bytearray(b'\xC5' * 64), DEST: bytearray(b'\xD9' * 8192),
              GLOBALS: bytearray(b'\xE3' * 36), LIMIT: bytearray(word(count - 1 if failure == 'limit' and count else 32))}
    images[CONTEXT][12:16] = word(TABLE)
    images[TABLE][32:36] = word(ENTRIES)
    slot = index * 16
    images[ENTRIES][slot:slot + 16] = struct.pack('>HBBIII', count, mode, 0xAB, len(payload), 0xFFFFFFF0, 0x87654320)
    images[GLOBALS][0:8] = word(CONTEXT) + word(SOURCE)
    images[GLOBALS][24:36] = word(HANDLE) + word(0x30) + word(0 if failure == 'inactive' else 1)
    expected = {address: bytearray(blob) for address, blob in images.items()}
    calls = []
    result = 0
    transfer = None
    if failure != 'inactive':
        calls.append([VALIDATE, [index]])
        if failure != 'invalid' and not (failure == 'limit' and count):
            expected[ENTRIES][slot + 12:slot + 16] = word(memory)
            succeeded = True
            if mode == 0:
                calls.append([OPEN, []])
                if failure == 'open':
                    calls.append([ERROR, [1]])
                    succeeded = False
                else:
                    calls.append([SEEK, [HANDLE, 0x20, 0]])
                    if failure == 'seek':
                        calls.append([ERROR, [3]])
                        succeeded = False
                    else:
                        calls.append([READ, [data, len(payload), HANDLE]])
                        transferred = len(payload) - 1 if failure == 'read' else len(payload)
                        transfer = (data, bytes(payload[:transferred]))
                        if failure == 'read':
                            calls.append([ERROR, [2]])
                            succeeded = False
                        else:
                            calls.append([CLOSE, []])
            else:
                calls.append([DMA, [mode, SOURCE, 0x20, data, len(payload)]])
                transfer = (data, bytes(payload[:7] if failure == 'dma' else payload))
                succeeded = failure != 'dma'
            if transfer:
                start = transfer[0] - DEST
                expected[DEST][start:start + len(transfer[1])] = transfer[1]
            if succeeded:
                for track, pointers in enumerate(records):
                    start = alignment + track * 12
                    expected[DEST][start:start + 12] = b''.join(word(p) for p in pointers)
                result = data + len(payload) - memory
    return images, expected, calls, result, transfer


def execute(code, case):
    images, expected, expected_calls, result, transfer = fixture(case)
    uc, write, run = machine([(ENTRY, code)], [])
    guard = bytes(range(16))
    for address, blob in images.items():
        write(address - 16, guard + bytes(blob) + guard)
    def read(address, size):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, size))
    write(0x80300010, b'\x93' * 48)
    write(0x802FFF90, b'\x47' * 16)
    trace = []
    def boundary(uc, address, size, user):
        count = BOUNDARIES[address]
        args = [uc.reg_read(reg) for reg in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)[:min(count, 4)]]
        if count == 5:
            args.append(int.from_bytes(read(uc.reg_read(regs.UC_MIPS_REG_SP) + 16, 4), 'big'))
        event = [address, args]
        assert len(trace) < len(expected_calls) and event == expected_calls[len(trace)], (case, event, expected_calls)
        trace.append(event)
        failure = case[4]
        returned = 0
        if address == VALIDATE:
            returned = int(failure != 'invalid')
        elif address == OPEN:
            returned = int(failure != 'open')
        elif address == SEEK:
            returned = 0xFFFFFFFF if failure == 'seek' else 0
        elif address in (READ, DMA):
            assert transfer is not None
            write(*transfer)
            returned = len(transfer[1]) if address == READ else (0xFFFFFFFF if failure == 'dma' else 7)
        for i, reg in enumerate(CALLER_SAVED):
            uc.reg_write(reg, 0xB1230000 + i * 257)
        uc.reg_write(regs.UC_MIPS_REG_V0, returned)
        uc.reg_write(regs.UC_MIPS_REG_PC, uc.reg_read(regs.UC_MIPS_REG_RA))
    for address in BOUNDARIES:
        uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)
    uc.reg_write(regs.UC_MIPS_REG_A0, case[5])
    uc.reg_write(regs.UC_MIPS_REG_A1, DEST + case[2])
    try:
        run(ENTRY)
    except Exception as error:
        raise RuntimeError((case, hex(uc.reg_read(regs.UC_MIPS_REG_PC)), trace)) from error
    assert trace == expected_calls
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == result, (case, result)
    digest = hashlib.sha256()
    for address, blob in expected.items():
        observed = read(address - 16, len(blob) + 32)
        assert observed == guard + bytes(blob) + guard, (case, hex(address))
        digest.update(word(address) + observed)
    assert read(0x80300010, 48) == b'\x93' * 48
    assert read(0x802FFF90, 16) == b'\x47' * 16
    return dict(returned=result, trace=trace, state_sha256=digest.hexdigest())


def cases():
    for count, mode, alignment, labels, index in itertools.product(
            (0, 1, 2, 3, 4, 5, 7, 8, 16), (0, 1, 255), (0, 4), (-5, -1, 0, 3), (0, 2)):
        yield count, mode, alignment, labels, 'success', index
    for failure, mode, alignment in itertools.product(
            ('inactive', 'invalid', 'limit', 'open', 'seek', 'read', 'dma'), (0, 1), range(8)):
        if failure in ('open', 'seek', 'read') and mode != 0 or failure == 'dma' and mode == 0:
            continue
        yield 5, mode, alignment, 2, failure, 1
    for alignment in range(8):
        yield 0, 0, alignment, 0, 'success', 0
    for count, failure in itertools.product((32768, 65535), ('inactive', 'invalid', 'limit')):
        yield count, 255, 0, 0, failure, 2


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    comparison = compare_block(NAME, 'src/game/' + NAME + '.c', ENTRY,
                               0x5DA0C, 0x5DE20, target,
                               family='audio-sequence-load-execution', layout=SymbolLayoutSnapshot())
    assert comparison['matches'], comparison['different_words'][:8]
    output = ROOT / 'build/audio-sequence-load-execution'
    compiled = (output / NAME / (NAME + '.bin')).read_bytes()
    retail = target[0x5DA0C:0x5DE20]
    digest = hashlib.sha256()
    count = 0
    for case in cases():
        original = execute(retail, case)
        rebuilt = execute(compiled, case)
        assert original == rebuilt, case
        digest.update(json.dumps([case, rebuilt], sort_keys=True).encode())
        count += 1
    report = dict(matches=True, cases=count, comparison=comparison,
                  trace_sha256=digest.hexdigest(), emulator=version('unicorn'),
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  machine_helper_sha256=hashlib.sha256((ROOT / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
                  target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  limits=['Validation and file/DMA services are recorded ABI stubs.',
                          'Guarded caller buffers, context, globals, entry pointers and callee-saved registers checked.',
                          'Signed label counts use bounded synthetic payloads; arbitrary malformed buffers are outside scope.',
                          'Successful nonempty descriptor arrays are word aligned as required by retail MIPS.'])
    (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Passed audio sequence loader:', count, 'cases;', output / 'report.json')


if __name__ == '__main__':
    main()
