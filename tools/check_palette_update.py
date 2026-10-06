"""Execute the complete palette updater with real memory, palette and lighting callees."""
import hashlib, itertools, json, struct
from rom import ROOT as root
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from compare_startup import compare_block, SymbolLayoutSnapshot
from compare_runtime import MATCHING_BLOCKS
from check_actor_group_path import machine, word, SENTINEL
from rom import validate
from owned_sections import elf_sections_and_symbols
from importlib.metadata import version
SOURCE_COLOR_COUNT = 550
TRANSITION_ORDER = (15, 6, 2, 4, 1, 3, 7)
ENTRY, POOL, BASE, SOURCE, TABLE = (0x80031ECC, 0x8009D120, 0x8009CD18, 0x800BB230, 0x80077C20)
OUTPUT, PACKED, LIGHTS, DIRECTION, STACK = (0x8007BB34, 0x8007D6D0, 0x80123B28, 0x8007D5DC, 0x80300000)

def signed(value):
    return (value + 0x80000000 & 0xFFFFFFFF) - 0x80000000

def divide(value, denominator):
    return abs(value) // abs(denominator) * (-1 if (value < 0) != (denominator < 0) else 1)

def remainder(value, denominator):
    return value - divide(value, denominator) * denominator

def get(data, offset):
    return int.from_bytes(data[offset:offset + 4], 'big', signed=True)

def state(case):
    slots, indices, modes, position, step, first, second, phase, channel_seed = case
    pool = bytearray((i * 29 + i // 52 * 17 + 53 & 255 for i in range(5216)))
    for i in range(100):
        pool[i * 52 + 1] &= 127
    for n, slot in enumerate(slots):
        o = slot * 52
        pool[o] = indices[n % len(indices)]
        pool[o + 1] = 0x80 | modes[n % len(modes)]
        values = (step, first, second, position, phase)
        channels = ((0, 1, 255, -1, 65537, -65537, 0x7FFFFFFF, -0x80000000)[(channel_seed + n + j) % 8] for j in range(6))
        for j, value in enumerate((*values, *channels)):
            pool[o + 4 + j * 4:o + 8 + j * 4] = word(value)
    data = {POOL: pool, BASE - 16: bytearray(((i * 19 ^ i // 4 * 31 >> 2) & 255 for i in range(1040))), SOURCE - 0x40: bytearray(((i * 47 + 13 ^ i // 4 * 23 >> 3) & 255 for i in range((SOURCE_COLOR_COUNT + 32) * 4))), TABLE - 0x40: bytearray().join((word(value) for value in (*range(16), *TRANSITION_ORDER, *range(16)))), OUTPUT - 16: bytearray(((i * 13 ^ i // 4 * 19 >> 2) & 255 for i in range(1056))), PACKED - 16: bytearray((i * 37 + 17 & 255 for i in range(544))), LIGHTS - 16: bytearray(((i * 23 ^ i // 16 * 41 >> 1) & 255 for i in range(4128))), DIRECTION: bytearray(word(-97) + word(191) + word(-257))}
    return data

def oracle(initial):
    data = {address: bytearray(value) for address, value in initial.items()}
    trace = []
    changed = set()
    snapshots = {}
    pool = data[POOL]
    base = data[BASE - 16]
    source = data[SOURCE - 0x40]
    table = data[TABLE - 0x40]
    output = data[OUTPUT - 16]
    packed = data[PACKED - 16]
    lights = data[LIGHTS - 16]
    for slot in range(100):
        o = slot * 52
        if not pool[o + 1] & 0x80:
            continue
        index = pool[o]
        mode = pool[o + 1] & 127
        changed.add(index)
        color = 16 + index * 4
        step, first, second, position, phase = (get(pool, o + offset) for offset in (4, 8, 12, 16, 20))
        if mode in (8, 16, 32):
            quotient = divide(position, 32)
            numerator = signed(quotient + (first if mode == 8 else phase if mode == 32 else 0))
            rem = remainder(numerator, second)
            source_index = get(table, 0x40 + rem * 4) if mode == 8 else signed(first + rem)
            assert -16 <= source_index < SOURCE_COLOR_COUNT + 16
            rgb = source[0x40 + source_index * 4:67 + source_index * 4]
        else:
            inverse = signed(65536 - position)
            rgb = bytearray()
            for channel in range(3):
                start, end = (get(pool, o + 24 + channel * 4), get(pool, o + 36 + channel * 4))
                value = signed(start * inverse + end * position)
                rgb.append(divide(value, 65536) & 255)
        base[color:color + 3] = rgb
        snapshots[index] = bytes(base[color:color + 4])
        trace.append(('color', index, snapshots[index].hex()))
        output[color:color + 3] = rgb
        rgba16 = rgb[0] >> 3 << 11 | rgb[1] >> 3 << 6 | rgb[2] >> 3 << 1 | 1
        packed[16 + index * 2:18 + index * 2] = struct.pack('>H', rgba16)
        trace.append(('light', index, *rgb))
        lit = bytes((min(v * 380 >> 8, 255) for v in rgb))
        light = 16 + index * 16
        lights[light:light + 3] = lit
        lights[light + 4:light + 7] = lit
        lights[light + 8:light + 11] = bytes((get(data[DIRECTION], i * 4) & 255 for i in range(3)))
        next_position = signed(position + divide(signed(step * 32), 32))
        pool[o + 16:o + 20] = word(next_position)
        if next_position < 0:
            if mode & 4:
                pool[o + 1] &= 127
                continue
            next_position = (-next_position if mode & 2 else next_position) & 65535
            pool[o + 16:o + 20] = word(next_position)
        if next_position >= 65536:
            pool[o + 16:o + 20] = word((131072 - next_position if mode & 2 else next_position) & 65535)
    for index in sorted(changed):
        count = 1
        while index + count < 256 and index + count in changed:
            count += 1
        trace.append(('upload', index, count, b''.join((snapshots[j] for j in range(index, index + count))).hex()))
    return (data, trace)

def execute(code, support, case):
    uc, write, _ = machine([(ENTRY, code)], support)
    initial = state(case)
    expected, trace = oracle(initial)
    for address, data in initial.items():
        write(address, bytes(data))
    stack_start = STACK - 0x940
    stack = bytes((i * 31 + 17 & 255 for i in range(0x980)))
    write(stack_start, stack)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xABCD1234)
    saved = {getattr(regs, 'UC_MIPS_REG_' + name): uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + name)) for name in ('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP')}
    allowed = [(STACK - 0x910, STACK)]
    pool = initial[POOL]
    indices = set()
    for slot in range(100):
        o = slot * 52
        if pool[o + 1] & 0x80:
            indices.add(pool[o])
            allowed.extend(((POOL + o + 1, POOL + o + 2), (POOL + o + 16, POOL + o + 20)))
    for i in indices:
        allowed.extend(((BASE + i * 4, BASE + i * 4 + 3), (OUTPUT + i * 4, OUTPUT + i * 4 + 3), (PACKED + i * 2, PACKED + i * 2 + 2)))
        allowed.extend(((LIGHTS + i * 16 + j, LIGHTS + i * 16 + j + 3) for j in (0, 4, 8)))
    touched = set()
    observed = []

    def guard_write(uc, access, address, size, value, user):
        address |= 0x80000000
        assert any((a <= address and address + size <= b for a, b in allowed)), ('Write guard', case, hex(address), size)
        if stack_start <= address < STACK:
            touched.update(range(address, address + size))

    def guard_read(uc, access, address, size, value, user):
        address |= 0x80000000
        reads = [(a, a + len(v)) for a, v in initial.items()] + [(STACK - 0x910, STACK)]
        assert any((a <= address and address + size <= b for a, b in reads)), ('Read guard', case, hex(address), size)

    def observe(uc, address, size, user):
        a = [uc.reg_read(r) for r in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)]
        if address == 0x8003C0DC:
            observed.append(('color', a[1], bytes(uc.mem_read(a[0] & 0x1FFFFFFF, 4)).hex()))
        if address == 0x80046EA8:
            observed.append(('light', *a))
        if address == 0x8003C020:
            observed.append(('upload', a[1], a[2], bytes(uc.mem_read(a[0] & 0x1FFFFFFF, a[2] * 4)).hex()))
    uc.hook_add(UC_HOOK_MEM_WRITE, guard_write)
    uc.hook_add(UC_HOOK_MEM_READ, guard_read)
    for address in (0x8003C0DC, 0x80046EA8, 0x8003C020):
        uc.hook_add(UC_HOOK_CODE, observe, begin=address, end=address)
    uc.emu_start(ENTRY, 0, count=1000000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, ('Did not return', case)
    assert uc.reg_read(regs.UC_MIPS_REG_SP) == STACK
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xABCD1234
    assert all((uc.reg_read(r) == v for r, v in saved.items()))
    assert observed == trace, ('Call trace oracle', case, trace, observed)
    digest = hashlib.sha256()
    for address, data in expected.items():
        actual = bytes(uc.mem_read(address & 0x1FFFFFFF, len(data)))
        assert actual == data, ('State oracle', case, hex(address))
        digest.update(actual)
    actual_stack = bytes(uc.mem_read(stack_start & 0x1FFFFFFF, len(stack)))
    assert all((value == stack[i] for i, value in enumerate(actual_stack) if stack_start + i not in touched)), ('Stack guard', case)
    return (digest.hexdigest(), observed)

def main():
    target = (root / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    assert target[0x78820:0x7883C] == b''.join(word(value) for value in TRANSITION_ORDER)
    layout = SymbolLayoutSnapshot()
    reports = {}
    support = []
    for name in ('game_memory', 'palette', 'graphics_lights'):
        _, source, start, end = next((x for x in MATCHING_BLOCKS if x[0] == name))
        reports[name] = compare_block(name, source, start, start - 0x80000000 + 0xC00, end - 0x80000000 + 0xC00, target, 'palette-update-execution', layout)
        assert reports[name]['matches']
        support.append((start, (root / 'build/palette-update-execution' / name / (name + '.bin')).read_bytes()))
    source = 'src/game/palette_effects/transition_update.c'
    reports['update'] = compare_block('update', source, ENTRY, 0x32ACC, 0x32F7C, target, 'palette-update-execution', layout)
    assert reports['update']['matches'], 'Complete updater instructions'
    sections, symbols = elf_sections_and_symbols(root / 'build/palette-update-execution/update/update.raw.o')
    assert sections['.text']['size'] == 1200
    assert symbols['func_80031ECC']['size'] == 1200
    assert all((name in ('.text', '.reginfo') or not (section['flags'] & 2 and section['size']) for name, section in sections.items())), 'Unexpected generated data'
    compiled = (root / 'build/palette-update-execution/update/update.bin').read_bytes()
    original = target[0x32ACC:0x32F7C]
    cases = [((), (0,), (0,), 0, 0, 0, 1, 0, 0)]
    positions = (-0x80000000, -65537, -65536, -33, -1, 0, 1, 31, 32, 65535, 65536, 131073, 0x7FFFFFFF)
    steps = (-0x80000000, -67108865, -1, 0, 1, 67108863, 67108864, 0x7FFFFFFF)
    for n, (slot, pos, step) in enumerate(itertools.product((0, 50, 99), positions, steps)):
        cases.append(((slot,), ((0, 127, 255)[n % 3],), ((0, 1, 2, 4, 6, 8, 16, 32, 63, 127)[n % 10],), pos, step, (0, 8, 248)[n % 3], (1, 7, -7)[n % 3], (-17, 0, 0x7FFFFFFF)[n % 3], n % 8))
    for mode, sign in itertools.product(range(0x80), (-1, 1)):
        cases.append(((0, 99), (0, 255), (mode,), sign * 65537, sign * 67108864, 8, 7, 31, mode % 8))
    for slots, indices, modes, pos, step in itertools.product(((0, 1, 2), (0, 50, 99), tuple(range(100))), ((0, 1, 2), (254, 255, 254), (127, 127, 127)), ((0, 2, 4), (8, 16, 32)), (-1, 65535), (-1, 1)):
        cases.append((slots, indices, modes, pos, step, 8, 7, 3, 0))
    for slot, first, mode in itertools.product((0, 50, 99), (548, 549), (16, 32)):
        cases.append(((slot,), (255,), (mode,), 0, 0, first, 1, 0, slot % 8))
    for index in range(256):
        cases.append(((index % 100,), (index,), (32,), 0, 0, 549, 1, 0, index % 8))
    assert len(compiled) == len(original) == 1200
    digest = hashlib.sha256()
    for i, case in enumerate(cases):
        retail = execute(original, support, case)
        candidate = execute(compiled, support, case)
        assert candidate == retail, case
        digest.update(json.dumps((case, retail), separators=(',', ':')).encode())
        if (i + 1) % 0x80 == 0:
            print('Update guarded cases', i + 1, flush=True)
    mutations = (('step scaling', 0x334, 0x40), ('negative stop bit', 0x364, 1), ('reflection mask', 0x394, 1), ('overlapping upload count', 0x448, 1))
    detected = {}
    for name, offset, bits in mutations:
        mutant = bytearray(compiled)
        mutant[offset:offset + 4] = word(int.from_bytes(mutant[offset:offset + 4], 'big') ^ bits)
        for case in cases:
            try:
                execute(bytes(mutant), support, case)
            except (AssertionError, ValueError):
                detected[name] = case
                break
        assert name in detected, ('Mutation escaped independent oracle', name)
    layout.verify()
    result = {'instruction_matches': reports['update']['matches'], 'execution_cases': len(cases), 'trace_sha256': digest.hexdigest(), 'comparisons': reports, 'mutations_detected': detected, 'target_rom_sha256': hashlib.sha256(target).hexdigest(), 'checker_sha256': hashlib.sha256((root / 'tools/check_palette_update.py').read_bytes()).hexdigest(), 'machine_helper_sha256': hashlib.sha256((root / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(), 'emulator': 'Unicorn ' + version('unicorn'), 'limits': ['All 1200 instruction bytes and the complete raw object size match.', 'Fresh matched memory, palette and lighting support execute without stubs.', 'The 550-entry source-color fixture and seven-entry control table are complete.', 'Signed invalid lookup indices sample guarded neighboring fixture bytes.', 'Deterministic BSS inputs are not a complete gameplay snapshot.']}
    (root / 'build/palette-update-execution/report.json').write_text(json.dumps(result, indent=2) + '\n')
    print('All update cases passed', len(cases), 'instruction match', result['instruction_matches'], flush=True)
if __name__ == '__main__':
    main()
