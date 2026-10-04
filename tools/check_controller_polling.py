"""Compare both complete controller polls with guarded retail executions.

The SI read, message wait, access gates and SDK unpack are ABI stubs. Their
arguments, order and memory at each boundary are checked independently.
"""

import hashlib
import itertools
import json
from importlib.metadata import version

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL
from check_error_formatters import CALLER_SAVED
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import load_owned_sections
from rom import ROOT, validate


PAD, MASK, QUEUE, STACK = 0x8013DBA0, 0x8013D9D0, 0x80141228, 0x80300000
ARRAYS = (0x8013DBB8, 0x8013DBC8, 0x8013DBD8, 0x8013DBE8, 0x8013DBF8)
POLLERS = {'controller_poll': (0x8004F330, 424, 0x80143440),
           'controller_legacy_poll': (0x8004C1E0, 408, 0x8013DC08)}
READ, WAIT, UNPACK, ACQUIRE, RELEASE = 0x80061FE0, 0x80062240, 0x800620A4, 0x8004F000, 0x8004F040
STUBS = (READ, WAIT, UNPACK, ACQUIRE, RELEASE)
BUTTONS = (0, 0xFFFF, 0x8000, 0x7FFF, 0xAAAA, 0x5555) + tuple(1 << i for i in range(16))
PREVIOUS = (0, 0xFFFFFFFF, 0x80000000, 0x7FFFFFFF, 0xFFFF0000, 0xAAAA5555)
STICKS = (-128, -127, -1, 0, 1, 126, 127)


def setup(name, case):
    port, mask, pattern, repeat = case
    scratch = POLLERS[name][2]
    images = {PAD - 16: bytearray((i * 31 + pattern * 17) & 255 for i in range(138)),
              MASK - 16: bytearray((i * 29 + pattern) & 255 for i in range(33)),
              QUEUE - 16: bytearray((i * 23 + pattern) & 255 for i in range(56))}
    if scratch != 0x8013DC08:
        images[scratch - 16] = bytearray((i * 37 + pattern) & 255 for i in range(34))

    def put(address, data):
        for start, image in images.items():
            if start <= address and address + len(data) <= start + len(image):
                image[address - start:address - start + len(data)] = data
                return
        raise AssertionError(('Outside guarded image', hex(address)))

    pads = []
    for i in range(4):
        buttons = BUTTONS[(pattern + i * 3) % len(BUTTONS)]
        x, y = STICKS[(pattern + i) % len(STICKS)], STICKS[(pattern * 3 + i) % len(STICKS)]
        # Nonzero error fields are deliberately ignored by the game loop.
        pads.append(buttons.to_bytes(2, 'big') + bytes((x & 255, y & 255)) +
                    ((pattern * 17 + i * 0x8001) & 0xFFFF).to_bytes(2, 'big'))
        for j, array in enumerate(ARRAYS):
            value = buttons if j == 3 and repeat else PREVIOUS[(pattern + i + j) % len(PREVIOUS)]
            put(array + i * 4, word(value))
    put(MASK, bytes([mask ^ 0xFF]))
    return images, b''.join(pads), put


def run_case(name, binary, case):
    port, mask, pattern, repeat = case
    entry, size, scratch = POLLERS[name]
    initial, pads, put = setup(name, case)
    original = {a: bytes(b) for a, b in initial.items()}
    uc, write, execute = machine([(entry, binary)], [])
    for address, data in initial.items():
        write(address, bytes(data))
    stack_start = STACK - 0x60
    stack_seed = bytes((i * 43 + 19) & 255 for i in range(0xA0))
    write(stack_start, stack_seed)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xAC501234)
    uc.reg_write(regs.UC_MIPS_REG_A0, port & 0xFFFFFFFF)
    sequence = ([] if port < 0 else ([ACQUIRE] if name == 'controller_poll' else []) +
                [READ, WAIT] + ([RELEASE] if name == 'controller_poll' else []) + [UNPACK])
    calls, touched, reads = [], set(), []

    def check_images():
        for address, data in initial.items():
            assert bytes(uc.mem_read(address & 0x1FFFFFFF, len(data))) == bytes(data), (name, case, hex(address))

    def boundary(uc, address, unused_size, unused_user):
        assert len(calls) < len(sequence) and address == sequence[len(calls)], ('Protocol order', name, case, hex(address))
        check_images()
        args = [uc.reg_read(getattr(regs, 'UC_MIPS_REG_A' + str(i))) for i in range(3)]
        if address == READ:
            assert args[0] == QUEUE
        elif address == WAIT:
            assert args == [QUEUE, 0, 1]
        elif address == UNPACK:
            assert args[0] == PAD
            put(PAD, pads)
            write(PAD, pads)
        # A changing mask proves the loop snapshots it after the SDK unpack.
        current_mask = mask if address == UNPACK else (mask + len(calls) + 37) & 255
        put(MASK, bytes([current_mask]))
        write(MASK, bytes([current_mask]))
        calls.append(address)
        returned_to = uc.reg_read(regs.UC_MIPS_REG_RA)
        for i, register in enumerate(CALLER_SAVED):
            uc.reg_write(register, (0xBD450000 + len(calls) * 0x10000 + i * 256) & 0xFFFFFFFF)
        uc.reg_write(regs.UC_MIPS_REG_HI, 0xCA551234)
        uc.reg_write(regs.UC_MIPS_REG_LO, 0xFA551234)
        uc.reg_write(regs.UC_MIPS_REG_PC, returned_to)

    def guard_write(uc, unused_access, address, length, unused_value, unused_user):
        address |= 0x80000000
        allowed = [(STACK - 12, STACK)]
        if port >= 0:
            for i in range(4):
                if mask & (1 << i):
                    allowed.extend((a + i * 4, a + i * 4 + 4) for a in ARRAYS)
            if mask & 15:
                allowed.append((scratch, scratch + 2))
        assert any(a <= address and address + length <= b for a, b in allowed), ('Unexpected write', name, case, hex(address), length)
        touched.update(range(address, address + length))

    def guard_read(uc, unused_access, address, length, unused_value, unused_user):
        address |= 0x80000000
        allowed = [(STACK - 12, STACK)]
        if port >= 0:
            allowed.append((MASK, MASK + 1))
            for i in range(4):
                if mask & (1 << i):
                    allowed.extend([(PAD + i * 6, PAD + i * 6 + 4),
                                    (ARRAYS[3] + i * 4, ARRAYS[3] + i * 4 + 4)])
        assert any(a <= address and address + length <= b for a, b in allowed), ('Unexpected read', name, case, hex(address), length)
        reads.append((address, length))

    def guard_pc(uc, address, unused_size, unused_user):
        assert entry <= address < entry + size or address in STUBS or address == SENTINEL, ('Unexpected execution', name, case, hex(address))

    for stub in STUBS:
        uc.hook_add(UC_HOOK_CODE, boundary, begin=stub, end=stub)
    uc.hook_add(UC_HOOK_CODE, guard_pc)
    uc.hook_add(UC_HOOK_MEM_READ, guard_read)
    uc.hook_add(UC_HOOK_MEM_WRITE, guard_write)
    execute(entry)
    assert calls == sequence
    returned = uc.reg_read(regs.UC_MIPS_REG_V0)
    assert returned == (0 if port < 0 else mask)
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xAC501234
    if port >= 0:
        assert reads.count((MASK, 1)) == 1
        for i in range(4):
            if mask & (1 << i):
                buttons = int.from_bytes(pads[i * 6:i * 6 + 2], 'big')
                previous = int.from_bytes(original[PAD - 16][ARRAYS[3] + i * 4 - PAD + 16:
                                                          ARRAYS[3] + i * 4 - PAD + 20], 'big')
                values = [int.from_bytes(pads[i * 6 + 2:i * 6 + 3], 'big', signed=True),
                          int.from_bytes(pads[i * 6 + 3:i * 6 + 4], 'big', signed=True),
                          buttons, buttons, buttons & (buttons ^ previous)]
                for array, value in zip(ARRAYS, values):
                    put(array + i * 4, word(value))
                put(scratch, buttons.to_bytes(2, 'big'))
    check_images()
    stack = bytes(uc.mem_read(stack_start & 0x1FFFFFFF, len(stack_seed)))
    assert all(value == stack_seed[i] for i, value in enumerate(stack) if stack_start + i not in touched)
    return returned, calls, hashlib.sha256(b''.join(bytes(b) for b in initial.values())).hexdigest(), reads


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    comparisons, data_reports, counts = {}, {}, {}
    records = load_owned_sections()
    source = 'src/game/controller_pad_state.c'
    data_reports[source] = compare_unit(source, [r for r in records if r['source'] == source], target, layout)
    cases = list(itertools.product((0, 0x7FFFFFFF), range(256), (0, 1, 4, 9), (0,)))
    cases += list(itertools.product((0, 1, 4, 0x12345678), (1, 5, 10, 15, 0xF0, 0xFF), range(len(BUTTONS)), (0, 1)))
    cases += list(itertools.product((-1, -2, -0x80000000), (0, 15, 0xFF), (0, 5, 21), (0, 1)))
    digest = hashlib.sha256()
    for name, (entry, size, unused_scratch) in POLLERS.items():
        unused, source, start, end = next(b for b in MATCHING_BLOCKS if b[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target,
                               family='controller-polling-execution', layout=layout)
        assert report['matches'], report
        comparisons[name] = report
        compiled = (ROOT / 'build/controller-polling-execution' / name / (name + '.bin')).read_bytes()
        assert len(compiled) == size
        retail = target[entry - 0x80000000 + 0xC00:entry - 0x80000000 + 0xC00 + size]
        for i, case in enumerate(cases):
            original = run_case(name, retail, case)
            assert run_case(name, compiled, case) == original
            digest.update(json.dumps([name, case, original], separators=(',', ':')).encode())
            if (i + 1) % 512 == 0:
                print(name, 'guarded cases:', i + 1, flush=True)
        counts[name] = {'cases': len(cases), 'negative_argument': sum(c[0] < 0 for c in cases),
                        'repeat_buttons': sum(c[3] == 1 for c in cases)}
    proof = dict(matches=True, comparisons=comparisons, data_comparisons=data_reports,
                 counts=counts, trace_sha256=digest.hexdigest(),
                 target_rom_sha256=hashlib.sha256(target).hexdigest(), emulator='Unicorn ' + version('unicorn'),
                 checker_sha256=hashlib.sha256((ROOT / 'tools/check_controller_polling.py').read_bytes()).hexdigest(),
                 limits=['All 256 connection masks, negative and arbitrary nonnegative arguments, individual button bits, wide previous words, signed stick limits, ignored pad errors, repeated buttons and disconnected preservation are exercised.',
                         'Every support boundary checks order, arguments and complete guarded images; ABI stubs clobber caller-saved integer registers and HI/LO.',
                         'Both two-byte statics and pad arrays are independently linked and bounded; full images, legal read/write ranges, stack guards and callee-saved integer registers are checked.',
                         'Actual SDK/access synchronization, controller hardware, concurrent mask changes during the loop, floating-register preservation and full-game input are outside this proof.'])
    (ROOT / 'build/controller-polling-execution/report.json').write_text(json.dumps(proof, indent=2) + '\n')
    print('Both complete polling procedures passed:', counts, flush=True)


if __name__ == '__main__':
    main()
