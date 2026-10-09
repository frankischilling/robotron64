"""Check transition allocation against retail execution and a guarded record oracle."""

import hashlib
import itertools
import json
from importlib.metadata import version

from unicorn import UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs

from check_actor_group_path import machine, word
from compare_startup import SymbolLayoutSnapshot, compare_block
from rom import ROOT, validate


ENTRY, END, STACK = 0x80031B28, 0x80031C10, 0x80300000
POOL, PALETTE, COLORS = 0x8009D120, 0x8009CD18, 0x800BB230
COUNT, STRIDE = 100, 52
SOURCE_COLOR_COUNT = 550


def state(case):
    slot, palette, mode, first, second, phase, step = case
    pool = bytearray((i * 37 + 13) & 255 for i in range(COUNT * STRIDE + 16))
    for i in range(COUNT):
        pool[i * STRIDE + 1] = 0x80 | ((i * 11 + 7) & 127)
    if slot < COUNT:
        pool[slot * STRIDE + 1] &= 127
        if slot + 1 < COUNT:
            pool[(slot + 1) * STRIDE + 1] &= 127
    palette_data = bytes(((i * 19 + 29) ^ ((i // 4) * 31 >> 3)) & 255
                         for i in range(1024 + 24))
    color_data = bytes((i * 23 + 41) & 255 for i in range(SOURCE_COLOR_COUNT * 4 + 32))
    return {POOL: bytes(pool), PALETTE - 16: palette_data, COLORS - 16: color_data}


def oracle(case, initial):
    slot, palette, mode, first, second, phase, step = case
    expected = dict(initial)
    if slot == COUNT:
        return expected
    pool = bytearray(initial[POOL])
    offset = slot * STRIDE
    pool[offset] = palette & 255
    pool[offset + 1] = 0x80 | (mode & 127)
    fields = {4: step, 8: first, 12: second, 16: 0, 20: phase}
    colors = initial[COLORS - 16]
    for channel in range(3):
        fields[24 + channel * 4] = colors[16 + first * 4 + channel]
        fields[36 + channel * 4] = colors[16 + second * 4 + channel]
    for field, value in fields.items():
        pool[offset + field:offset + field + 4] = word(value)
    palette_data = initial[PALETTE - 16]
    color_offset = 16 + (palette & 255) * 4
    pool[offset + 48:offset + 52] = palette_data[color_offset:color_offset + 4]
    expected[POOL] = bytes(pool)
    return expected


def execute(code, case):
    uc, write, run = machine([(ENTRY, code)], [])
    initial = state(case)
    expected = oracle(case, initial)
    for address, data in initial.items():
        write(address, data)
    stack_start = STACK - 32
    stack = bytearray((i * 31 + 17) & 255 for i in range(96))
    stack[48:52] = word(case[5])
    stack[52:56] = word(case[6])
    write(stack_start, bytes(stack))
    for register, value in zip((regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                                regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3),
                               (case[1], case[3], case[4], case[2])):
        uc.reg_write(register, value & 0xFFFFFFFF)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xABCD1234)
    touched = set()
    slot = case[0]
    allowed_writes = [(STACK + 12, STACK + 16)]
    if slot < COUNT:
        record = POOL + slot * STRIDE
        allowed_writes.extend(((record, record + 2), (record + 4, record + 52)))

    def guard_write(uc, access, address, size, value, user):
        address |= 0x80000000
        assert any(a <= address and address + size <= b for a, b in allowed_writes), (
            'Write outside allocated record and argument home', case, hex(address), size)
        touched.update(range(address, address + size))

    def guard_read(uc, access, address, size, value, user):
        address |= 0x80000000
        allowed = [(a, a + len(data)) for a, data in initial.items()]
        allowed.append((STACK, STACK + 24))
        assert any(a <= address and address + size <= b for a, b in allowed), (
            'Read outside guarded input storage', case, hex(address), size)

    uc.hook_add(UC_HOOK_MEM_WRITE, guard_write)
    uc.hook_add(UC_HOOK_MEM_READ, guard_read)
    run(ENTRY)
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xABCD1234
    digest = hashlib.sha256()
    for address, data in expected.items():
        actual = bytes(uc.mem_read(address & 0x1FFFFFFF, len(data)))
        assert actual == data, ('Independent record oracle', case, hex(address))
        digest.update(actual)
    observed_stack = bytes(uc.mem_read(stack_start & 0x1FFFFFFF, len(stack)))
    assert all(value == stack[i] for i, value in enumerate(observed_stack)
               if stack_start + i not in touched), ('Stack guard', case)
    return digest.hexdigest()


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    report = compare_block('palette_transition_allocate',
                           'src/game/palette_effects/transition_allocate.c', ENTRY,
                           0x32728, 0x32810, target, 'palette-transition-execution',
                           SymbolLayoutSnapshot())
    assert report['matches'], report
    compiled = (ROOT / 'build/palette-transition-execution/palette_transition_allocate/'
                'palette_transition_allocate.bin').read_bytes()
    original = target[0x32728:0x32810]
    assert len(compiled) == len(original) == END - ENTRY
    cases = [(slot, index, mode, first, second, phase, step)
             for slot, index, mode, (first, second), (phase, step) in itertools.product(
                 (0, 1, 50, 99, 100),
                 (-2147483648, -257, -129, -1, 0, 1, 127, 128, 255, 256, 2147483647),
                 (0, 1, 2, 4, 8, 16, 32, 63, 127, 128, -1),
                 ((0, 1), (1, 0), (-1, 255), (255, -1),
                  (SOURCE_COLOR_COUNT - 2, SOURCE_COLOR_COUNT - 1),
                  (SOURCE_COLOR_COUNT - 1, SOURCE_COLOR_COUNT - 2)),
                 ((0, 0), (-1, 1), (-2147483648, 2147483647), (2147483647, -2147483648)))]
    digest = hashlib.sha256()
    for i, case in enumerate(cases):
        retail = execute(original, case)
        assert execute(compiled, case) == retail
        digest.update(json.dumps((case, retail), separators=(',', ':')).encode())
        if (i + 1) % 1024 == 0:
            print('Palette allocation guarded cases:', i + 1, flush=True)
    mutations = {'index_mask': (0x78, 0x80), 'mode_mask': (0x84, 0x40),
                 'step_destination': (0x70, 0x0C), 'activation_destination': (0xC8, 3),
                 'source_blue': (0x40, 1)}
    detected = {}
    probes = [(slot, index, mode, 0, 1, -1, 2147483647)
              for slot, index, mode in itertools.product((0, 50, 99, 100), (0, 128, 255), (0, 127))]
    for name, (offset, bits) in mutations.items():
        mutant = bytearray(compiled)
        mutant[offset:offset + 4] = word(int.from_bytes(mutant[offset:offset + 4], 'big') ^ bits)
        for case in probes:
            try:
                execute(bytes(mutant), case)
            except (AssertionError, ValueError):
                detected[name] = case
                break
        assert name in detected, ('Mutation escaped oracle', name)
    proof = dict(matches=True, comparison=report, cases=len(cases),
                 full_pool_cases=sum(case[0] == COUNT for case in cases), mutations_detected=detected,
                 trace_sha256=digest.hexdigest(), target_rom_sha256=hashlib.sha256(target).hexdigest(),
                 checker_sha256=hashlib.sha256((ROOT / 'tools/check_palette_transitions.py').read_bytes()).hexdigest(),
                 machine_helper_sha256=hashlib.sha256((ROOT / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
                 emulator='Unicorn ' + version('unicorn'),
                 limits=['Complete allocation instructions execute without callee stubs.',
                         'Palette/source-color BSS uses deterministic input images, not a whole-game snapshot.',
                         'Pool, padding, read/write ranges, stack, GP, SP and saved integer registers are checked.',
                         'The per-frame update, concurrent pool mutation and arbitrary invalid color indices are outside this proof.'])
    (ROOT / 'build/palette-transition-execution/report.json').write_text(json.dumps(proof, indent=2) + '\n')
    print('All palette allocation guarded cases passed:', len(cases), '; mutants detected:', len(detected), flush=True)


if __name__ == '__main__':
    main()
