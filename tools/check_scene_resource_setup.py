"""Audit the complete excluded scene resource setup and its generated dispatch table."""
from pathlib import Path
import copy
import hashlib
import json
import random
import struct
import subprocess
from importlib.metadata import version
from compiler import compile_source, profile_for_source
from compare_startup import SymbolLayoutSnapshot, compare_block, comparison_input_hashes, external_assignments
from owned_sections import elf_sections_and_symbols
from toolchain import installed_identity
from trim_padding import trim
from rom import ROOT, validate
BUILD = ROOT / 'build/scene-resource-setup-audit'
SOURCE = 'src/game/scene_resources/setup.c'
ENTRY = 0x8001D3F0
STATE = 0x800B8F78
SCENE = 0x800B9A78
COUNTER = 0x80074A20
GROUP = 0x8009EA18
CHAIN = 0x80073590
POOL_PTR = 0x800AE4F4
POOL_A = 0x80201010
POOL_B = 0x80205010
TRACK_A = 0x80210010
TRACK_B = 0x80210110
RESOURCE = 0x8009B138
ANIM = 0x800A4538
DEST = 0x8009AFC0
STACK = 0x80300000
LOADER = 0x8001CF68
COPY = 0x8003B520
RESOLVE = 0x8001CE70
SERVICE = 0x80036670
DIAGNOSTIC = 0x8001C0D0
LITERAL = 0x800907A8
DISPATCH = 0x800907C8
CODE_ROM = 0x1DFF0
CODE_SIZE = 2660
LITERAL_ROM = 0x913A8
DISPATCH_ROM = 0x913C8


def word(value):
    return struct.pack('>I', value & 0xFFFFFFFF)


def dispatch_relocations(raw, sections):
    """Require ten pointer relocations into this object's code section."""
    section = sections.get('.rel.rodata')
    if section is None or section['type'] != 9 or section['size'] != 80:
        raise ValueError('Setup candidate must emit ten complete R_MIPS_32 dispatch entries')
    data = Path(raw).read_bytes()
    table_offset = struct.unpack_from('>I', data, 32)[0]
    headers = [struct.unpack_from('>10I', data, table_offset + i * 40)
               for i in range(struct.unpack_from('>H', data, 48)[0])]
    header = headers[section['index']]
    if header[7] != sections['.rodata']['index'] or header[9] != 8:
        raise ValueError('Dispatch relocations target the wrong section')
    symbols = headers[header[6]]
    if symbols[1] != 2 or symbols[5] % 16:
        raise ValueError('Malformed dispatch symbol table')
    strings = headers[symbols[6]]
    names = data[strings[4]:strings[4] + strings[5]]
    result = []
    for offset, info in struct.iter_unpack('>II', section['bytes']):
        index, kind = info >> 8, info & 255
        if index >= symbols[5] // 16:
            raise ValueError('Invalid dispatch relocation symbol')
        name, value, size, flags, other, section_index = struct.unpack_from(
            '>IIIBBH', data, symbols[4] + index * 16)
        if section_index != sections['.text']['index']:
            raise ValueError('Dispatch target lies outside the candidate procedure')
        symbol_name = names[name:].split(b'\0', 1)[0].decode('ascii')
        result.append({'offset': offset, 'type': kind,
                       'symbol': symbol_name or '.text'})
    if [item['offset'] for item in result] != list(range(0, 40, 4)) or any(
            item['type'] != 2 for item in result):
        raise ValueError('Setup candidate must emit ten complete R_MIPS_32 dispatch entries')
    return result


def audit_input_hashes():
    inputs = comparison_input_hashes(SOURCE)
    for name in ('tools/check_scene_resource_setup.py', 'tools/compare_runtime.py',
                 'tools/compare_startup.py', 'tools/check_actor_boundary_boss.py',
                 'tools/check_actor_group_path.py', 'tools/rom.py',
                 'tools/toolchain.py', 'tools/trim_padding.py',
                 'src/game/game_memory.c', 'src/game/script_animation_resolve.c'):
        inputs[name] = hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
    return dict(sorted(inputs.items()))

def compare_candidate_block(name, source, target, layout, family='runtime-candidates'):
    """Compare all natural code and dispatch words without granting ownership."""
    validate(target)
    directory = ROOT / 'build' / family / name
    directory.mkdir(parents=True, exist_ok=True)
    inputs = comparison_input_hashes(source)
    raw = directory / (name + '.raw.o')
    obj = directory / (name + '.o')
    elf_path = directory / (name + '.elf')
    layout.verify()
    compile_source(source, raw)
    sections, symbols = elf_sections_and_symbols(raw)
    function = symbols.get('func_8001D3F0')
    if function is None or function['type'] != 2 or function['section'] != '.text' or (function['value'] != 0):
        raise ValueError('Setup candidate must define its complete procedure')
    if any((key != 'func_8001D3F0' and value['type'] == 2 and (value.get('index') != 0) for key, value in symbols.items())):
        raise ValueError('Setup candidate defines an additional procedure')
    for key, info in sections.items():
        if info['size'] and info['flags'] & 2 and (key not in ('.text', '.rodata', '.reginfo', '.MIPS.abiflags')):
            raise ValueError('Unowned setup allocation: ' + key)
    relocations = dispatch_relocations(raw, sections)
    contents = trim(raw.read_bytes(), '.text', function['size'])
    contents = trim(contents, '.rodata', 40)
    obj.write_bytes(contents)
    undefined = {line.split()[-1] for line in subprocess.check_output(['mips-linux-gnu-nm', '-u', str(obj)], text=True).splitlines() if line.strip()}
    script = directory / 'candidate.ld'
    script.write_text(external_assignments(undefined, layout.addresses) + 'SECTIONS { .text 0x8001D3F0 : SUBALIGN(4) { *(.text) } .rodata 0x800907C8 : SUBALIGN(4) { *(.rodata) } /DISCARD/ : { *(.reginfo .MIPS.abiflags) } }\n')
    subprocess.run(['mips-linux-gnu-ld', '-EB', '-T', str(script), '-e', 'func_8001D3F0', '-o', str(elf_path), str(obj)], check=True)
    sections, linked_symbols = elf_sections_and_symbols(elf_path)
    actual = sections['.text']['bytes']
    dispatch = sections['.rodata']['bytes']
    assert len(actual) == function['size'] and len(dispatch) == 40
    if sections['.text']['address'] != ENTRY or sections['.rodata']['address'] != DISPATCH:
        raise ValueError('Setup code or complete dispatch table was displaced')
    if sections['.rodata']['flags'] & 1:
        raise ValueError('Setup dispatch table is writable')
    if any(not ENTRY <= pointer < ENTRY + len(actual) or pointer % 4
           for pointer in struct.unpack('>10I', dispatch)):
        raise ValueError('Linked dispatch target lies outside the candidate procedure')
    expected = target[CODE_ROM:CODE_ROM + CODE_SIZE]
    expected_dispatch = target[DISPATCH_ROM:DISPATCH_ROM + 40]
    (directory / (name + '.bin')).write_bytes(actual)
    (directory / 'dispatch.bin').write_bytes(dispatch)
    profile = profile_for_source(source)
    result = {'source': source, 'compiler_profile': profile, 'toolchain_identity': installed_identity(profile['version']), 'inputs_sha256': inputs, 'expected_size': len(expected), 'actual_size': len(actual), 'natural_function_size': function['size'], 'matches': actual == expected and dispatch == expected_dispatch, 'different_words': [{'vram': hex(ENTRY + i), 'expected': expected[i:i + 4].hex(), 'actual': actual[i:i + 4].hex()} for i in range(0, max(len(expected), len(actual)), 4) if expected[i:i + 4] != actual[i:i + 4]], 'dispatch': {'vram': hex(2148075464), 'expected_size': 40, 'actual_size': len(dispatch), 'matches': dispatch == expected_dispatch, 'different_words': [{'offset': i, 'expected': expected_dispatch[i:i + 4].hex(), 'actual': dispatch[i:i + 4].hex()} for i in range(0, 40, 4) if expected_dispatch[i:i + 4] != dispatch[i:i + 4]], 'relocations': relocations}, 'retained_literal': {'vram': hex(2148075432), 'size': 32, 'sha256': hashlib.sha256(target[594856:594888]).hexdigest(), 'source_owned': False}, 'matching_source_claim': False}
    layout.verify()
    if comparison_input_hashes(source) != inputs:
        raise ValueError('Setup comparison inputs changed')
    (directory / 'report.json').write_text(json.dumps(result, indent=2) + '\n')
    return result

def half(v):
    return struct.pack('>H', v & 65535)

def norm(a):
    return a & 536870911 | 2147483648

def get(images, a, n, signed=False):
    for base, data in images.items():
        if base <= a and a + n <= base + len(data):
            return int.from_bytes(data[a - base:a - base + n], 'big', signed=signed)
    raise AssertionError(('oracle read', hex(a), n))

def put(images, a, data):
    for base, blob in images.items():
        if base <= a and a + len(data) <= base + len(blob):
            blob[a - base:a - base + len(data)] = data
            return
    raise AssertionError(('fixture write', hex(a), len(data)))

def pattern(n, salt):
    return bytearray((i * 37 + salt & 255 for i in range(n)))

def fixture(case):
    images = {a: pattern(n, i * 13 + 71) for i, (a, n) in enumerate([(STATE, 416), (SCENE, 3348), (COUNTER, 4), (GROUP, 3012), (CHAIN, 28 * 12), (POOL_PTR, 4), (POOL_A, 9096), (POOL_B, 9096), (RESOURCE, 88), (ANIM, 64), (DEST, 16), (TRACK_A, 16), (TRACK_B, 16)])}
    put(images, STATE, bytes([case.get('flags', 169)]))
    put(images, COUNTER, word(case.get('counter', 0)))
    put(images, SCENE + 3140, word(case.get('resourceC44', -1)))
    put(images, SCENE + 3284, word(case.get('resourceCD4', -1)))
    arrivals = case.get('arrivals', [])
    put(images, SCENE + 3272, word(case.get('arrival_count', len(arrivals))))
    for i, (category, index, count) in enumerate(arrivals):
        put(images, SCENE + 68 + i * 12, bytes([17, 29, index, category]) + half(-1) + half(count) + half(3) + half(-4))
    for i, count in enumerate(case.get('group_counts', [0, 0, 0])):
        put(images, GROUP + i * 1004, word(count))
    chain = case.get('chain', [(-1, -1)])
    for i, (resource, extra) in enumerate(chain):
        put(images, CHAIN + i * 28 + 8, word(resource))
        put(images, CHAIN + i * 28 + 20, word(extra))
    put(images, POOL_PTR, word(POOL_A))
    for pool, groups in [(POOL_A, case.get('pool', [])), (POOL_B, case.get('pool_b', []))]:
        put(images, pool + 4, word(len(groups)))
        for g, entries in enumerate(groups):
            put(images, pool + 16 + g * 124, word(len(entries)))
            for i, index in enumerate(entries):
                put(images, pool + 20 + g * 124 + i * 12, word(index))
    put(images, RESOURCE + 72, word(TRACK_A))
    put(images, RESOURCE + 44, word(TRACK_B))
    put(images, TRACK_A + 8, half(-7) + half(case.get('referenceA', -32768)) + half(234) + bytes([83, 17]))
    put(images, TRACK_B + 8, half(-3) + half(case.get('referenceB', 32767)) + half(-44) + bytes([39, 101]))
    for i in range(4):
        put(images, ANIM + i * 16 + 8, half(-2 if i in case.get('unchanged_animations', []) else -1))
    return images

def oracle(case, initial):
    images = copy.deepcopy(initial)
    trace = []
    occurrences = {}

    def snapshot():
        return bytes(images[STATE][:6]).hex() + bytes(images[COUNTER]).hex()

    def emit(address, args):
        trace.append([address, [x & 4294967295 for x in args], snapshot()])
        if address == LOADER:
            pointer = args[0] & 4294967295
            occurrences[pointer] = occurrences.get(pointer, 0) + 1
            for trigger, n, writes in case.get('mutations', []):
                if pointer == trigger and occurrences[pointer] == n:
                    for a, data in writes:
                        put(images, a, bytes.fromhex(data))

    def load(pointer, geometry=1):
        emit(LOADER, [pointer, geometry])

    def flag(bits):
        put(images, STATE, bytes([get(images, STATE, 1) | bits]))

    def idx(a):
        return get(images, a + 70, 1)
    flags = get(images, STATE, 1) & 15
    put(images, STATE, bytes([flags]))
    put(images, STATE + 2, half(0))
    put(images, STATE + 4, half(0))
    mode = case['mode']
    if mode != 3:
        for pointer in list(range(2148226648, 2148227528, 88)) + list(range(2148220224, 2148222512, 88)) + [2148215032, 2148224800, 2148216880, 2148219608, 2148219696, 2148219784, 2148219872, 2148231048, 2148219960, 2148220048, 2148220136, 2148216792]:
            load(pointer, 0)
    if mode == 1:
        load(2148224800)
        load(2148224888)
    if mode == 2:
        load(RESOURCE)
        if case.get('load_result', 2) == 1:
            old = get(images, COUNTER, 4)
            put(images, COUNTER, word(old + 1))
            if old == 0:
                for dest, track in [(DEST, TRACK_A), (DEST + 8, TRACK_B)]:
                    emit(COPY, [dest, track + 8, 8])
                    put(images, dest, bytes(images[track][8:16]))
            for i in range(4):
                track = TRACK_A if i < 2 else TRACK_B
                reference = get(images, track + 10, 2, True)
                emit(RESOLVE, [RESOURCE, ANIM + i * 16, reference])
                if get(images, ANIM + i * 16 + 8, 2, True) != -2:
                    put(images, ANIM + i * 16 + 10, half(reference))
        for pointer in [2148118488, 2148118576, 2148118664, 2148118752] + list(range(2148190616, 2148191628, 92)):
            load(pointer)
        for pointer in range(2148116992, 2148118464, 92):
            load(pointer, 0)
        for pointer in list(range(2148212568, 2148213008, 88)) + [2148213360, 2148213712, 2148213800, 2148213888, 2148214504, 2148214592, 2148224272]:
            load(pointer)
        emit(SERVICE, [])
        if get(images, SCENE + 3140, 4, True) != -1:
            load(2148137432)
            load(2148137168)
        if get(images, SCENE + 3284, 4, True) != -1:
            g = 0
            while g < get(images, get(images, POOL_PTR, 4) + 4, 4, True):
                i = 0
                while i < get(images, get(images, POOL_PTR, 4) + 16 + g * 124, 4, True):
                    resource = get(images, get(images, POOL_PTR, 4) + 20 + g * 124 + i * 12, 4, True)
                    load(2148200944 + resource * 104)
                    i += 1
                g += 1
        a = SCENE
        n = 0
        while n < get(images, SCENE + 3272, 4, True):
            category = get(images, a + 71, 1)
            if category == 1:
                flag(32)
                put(images, STATE + 2, half(get(images, STATE + 2, 2, True) + get(images, a + 74, 2, True)))
                load(2148136288 + idx(a) * 88)
            elif category == 7:
                if idx(a) in (3, 4):
                    flag(16)
            elif category == 9:
                load(2148211688 + idx(a) * 88)
            elif category == 0:
                load(2148200944 + idx(a) * 104)
                i = idx(a)
                if 25 <= i < 29:
                    flag(128)
                if i == 28:
                    load(2148214768)
                if idx(a) in (24, 20):
                    load(2148204376)
                    load(2148204480)
                if idx(a) == 14:
                    load(2148137256)
                if idx(a) == 4:
                    load(2148137080)
                if 9 <= idx(a) < 13:
                    load(2148200944 + (idx(a) + 4) * 104)
                    if idx(a) == 10:
                        load(2148137256)
                if 17 <= idx(a) < 21:
                    load(2148200944 + (idx(a) + 4) * 104)
            elif category == 8:
                flag(64)
                i = 0
                while i < get(images, GROUP + idx(a) * 1004, 4, True):
                    load(GROUP + idx(a) * 1004 + 4 + i * 96)
                    i += 1
                c = CHAIN
                while get(images, c + 8, 4, True) > 0:
                    load(2148211688 + get(images, c + 8, 4, True) * 88)
                    extra = get(images, c + 20, 4, True)
                    if extra != -1:
                        load(2148200944 + extra * 104)
                    c += 28
                load(2148204376)
                c = CHAIN
                while get(images, c + 8, 4, True) != -1:
                    load(2148211688 + get(images, c + 8, 4, True) * 88)
                    c += 28
            elif category == 3:
                load(2148191832 + idx(a) * 88)
                if get(images, STATE, 4) & 2415919104:
                    load(2148191832 + (idx(a) + 4) * 88)
                put(images, STATE + 4, half(get(images, STATE + 4, 2, True) + get(images, a + 74, 2, True)))
            else:
                emit(DIAGNOSTIC, [2148075432, category])
            n += 1
            a += 12
    return (images, trace)

def run(case, text, table, support, target):
    from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UC_MEM_WRITE
    from unicorn import mips_const as regs
    from check_actor_boundary_boss import environment, CLOBBER
    from check_actor_group_path import SENTINEL
    initial = fixture(case)
    expected, wanted = oracle(case, initial)
    uc, write, execute, read, finish = environment([(ENTRY, text)], support)
    for a, blob in initial.items():
        write(a - 8, b'\xa5' * 8 + bytes(blob) + b'\xb6' * 8)
    write(2148075432, target[594856:594888] + table)
    write(STACK - 272, b'\xc7' * 320)
    trace = []
    stores = []
    occurrences = {}
    saved = {getattr(regs, 'UC_MIPS_REG_' + n): uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + n)) for n in ['S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP']}
    uc.reg_write(regs.UC_MIPS_REG_A0, case['mode'] & 4294967295)
    uc.reg_write(regs.UC_MIPS_REG_GP, 2775744985)
    readable = [(a, a + len(blob)) for a, blob in initial.items()] + [(2148075432, 2148075504), (STACK - 256, STACK + 16)]
    writable = [(STATE, STATE + 6), (COUNTER, COUNTER + 4), (DEST, DEST + 16), (STACK - 256, STACK + 16)] + [(ANIM + i * 16 + 10, ANIM + i * 16 + 12) for i in range(4)]
    ranges = [(ENTRY, ENTRY + len(text)), (CLOBBER, CLOBBER + 92)] + [(a, a + len(blob)) for a, blob in support]
    arity = {LOADER: 2, COPY: 3, RESOLVE: 3, SERVICE: 0, DIAGNOSTIC: 2}
    boundaries = (LOADER, SERVICE, DIAGNOSTIC)

    def inside(a, n, r):
        return any((lo <= a and a + n <= hi for lo, hi in r))

    def access(uc, kind, a, n, value, user):
        a = norm(a)
        assert inside(a, n, writable if kind == UC_MEM_WRITE else readable), ('guest memory bounds', hex(a), n, hex(uc.reg_read(regs.UC_MIPS_REG_PC)))
        if kind == UC_MEM_WRITE and (not STACK - 256 <= a < STACK + 16):
            stores.append([a, n, value & (1 << 8 * n) - 1])

    def instruction(uc, a, n, user):
        a = norm(a)
        assert a in boundaries + (SENTINEL,) or inside(a, n, ranges), ('execution bounds', hex(a))
        if a not in arity:
            return
        args = [uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + name)) for name in ['A0', 'A1', 'A2'][:arity[a]]]
        event = [a, args, read(STATE, 6).hex() + read(COUNTER, 4).hex()]
        pos = len(trace)
        assert pos < len(wanted) and event == wanted[pos], ('call/state oracle', pos, event, wanted[pos] if pos < len(wanted) else 'end', case)
        trace.append(event)
        if a in boundaries:
            uc.reg_write(regs.UC_MIPS_REG_HI, 0xA517C39D)
            uc.reg_write(regs.UC_MIPS_REG_LO, 0xB62AE40E)
        if a == LOADER:
            pointer = args[0]
            occurrences[pointer] = occurrences.get(pointer, 0) + 1
            for trigger, count, writes in case.get('mutations', []):
                if pointer == trigger and occurrences[pointer] == count:
                    for destination, data in writes:
                        write(destination, bytes.fromhex(data))
            finish(case.get('load_result', 2) if pointer == RESOURCE else 2)
        elif a in (SERVICE, DIAGNOSTIC):
            finish()
    uc.hook_add(UC_HOOK_MEM_READ | UC_HOOK_MEM_WRITE, access)
    uc.hook_add(UC_HOOK_CODE, instruction)
    uc.emu_start(ENTRY, 0, count=500000)
    assert norm(uc.reg_read(regs.UC_MIPS_REG_PC)) == SENTINEL, 'instruction budget/return'
    assert uc.reg_read(regs.UC_MIPS_REG_SP) == STACK and uc.reg_read(regs.UC_MIPS_REG_GP) == 2775744985
    assert all((uc.reg_read(reg) == val for reg, val in saved.items())), 'callee saved GPR'
    assert trace == wanted, 'complete trace'
    digest = hashlib.sha256()
    for a, blob in expected.items():
        assert read(a, len(blob)) == bytes(blob), ('complete fixture effect', hex(a), case)
        assert read(a - 8, 8) == b'\xa5' * 8 and read(a + len(blob), 8) == b'\xb6' * 8, ('object canary', hex(a))
        digest.update(word(a) + bytes(blob))
    assert read(STACK - 272, 16) == b'\xc7' * 16 and read(STACK + 16, 32) == b'\xc7' * 32, 'stack canary'
    return {'trace': trace, 'stores': stores, 'memory_sha256': digest.hexdigest()}

def cases():
    out = []

    def add(**kw):
        out.append(dict(mode=2, **kw))
    for mode in [-2147483648, -1, 0, 1, 2, 3, 4, 2147483647]:
        for flags in [0, 1, 15, 16, 32, 64, 128, 255]:
            out.append(dict(mode=mode, flags=flags))
    for counter in [0, 1, -1, 2147483647, -2147483648]:
        for result in [1, 2]:
            add(counter=counter, load_result=result, unchanged_animations=[1, 3])
    for i in range(36):
        add(arrivals=[(0, i, 0)])
    for i in range(4):
        for count in [-32768, -1, 0, 1, 32767]:
            add(arrivals=[(1, i, count), (1, i, count)])
    for i in range(4):
        for count in [-32768, -1, 1, 32767]:
            for prefix in [[], [(7, 3, 0)], [(0, 25, 0)]]:
                add(arrivals=prefix + [(3, i, count), (3, i, count)])
    for i in range(9):
        add(arrivals=[(7, i, 0)])
    for group in range(3):
        for count in [-1, 0, 1, 5, 10]:
            add(arrivals=[(8, group, 0)], group_counts=[count] * 3)
    for chain in [[(-1, -1)], [(0, -1), (-1, -1)], [(1, -1), (-1, -1)], [(1, 2), (0, 4), (-1, -1)], [(2, 3), (4, -1), (-1, -1)]]:
        add(arrivals=[(8, 0, 0)], chain=chain, group_counts=[2, 0, 0])
    for i in [0, 1, 17, 243]:
        add(arrivals=[(9, i, 0)])
    for category in [2, 4, 5, 6, 10, 255]:
        add(arrivals=[(category, 0, 0)])
    for first in [-1, 0, 1, 10]:
        for second in [-1, 0, 1, 10]:
            add(resourceC44=first, resourceCD4=second, pool=[[0, 17], [5], [], [25, 35]])
    add(arrivals=[(0, 28, 0)], mutations=[(2148200944 + 28 * 104, 1, [(SCENE + 70, '18')]), (2148204480, 1, [(SCENE + 70, '0e')]), (2148137256, 1, [(SCENE + 70, '04')]), (2148137080, 1, [(SCENE + 70, '0a')]), (2148200944 + 14 * 104, 1, [(SCENE + 70, '11')])])
    add(arrivals=[(1, 0, 1), (0, 25, 0), (3, 0, 1)], mutations=[(2148136288, 1, [(SCENE + 3272, word(1).hex())])])
    add(arrivals=[(8, 0, 0)], group_counts=[1, 2, 0], mutations=[(GROUP + 4, 1, [(SCENE + 70, '01')])])
    add(resourceCD4=0, pool=[[31, 2]], pool_b=[[31, 5, 9], [17]], mutations=[(2148200944 + 31 * 104, 1, [(POOL_PTR, word(POOL_B).hex())])])
    add(arrivals=[(7, 3, 0), (3, 0, 32767), (3, 1, 1), (1, 0, 32767), (1, 1, 1)])
    add(arrivals=[[(0, 28, 0), (1, 0, 32767), (3, 1, -32768), (7, 3, 0), (8, 0, 0), (9, 17, 0), (2, 0, 0)][i % 7] for i in range(256)])
    rng = random.Random(119792)
    for _ in range(80):
        arrivals = []
        for i in range(rng.randrange(1, 9)):
            kind = rng.choice([0, 1, 3, 7, 8, 9])
            idx = rng.randrange({0: 36, 1: 4, 3: 4, 7: 9, 8: 3, 9: 244}[kind])
            arrivals.append((kind, idx, rng.choice([-32768, -1, 0, 1, 32767])))
        add(arrivals=arrivals, flags=rng.randrange(256), counter=rng.choice([0, 1, -1]), load_result=rng.choice([1, 2]), group_counts=[rng.randrange(0, 4) for i in range(3)], chain=[(1, 2), (3, -1), (-1, -1)], resourceC44=0, resourceCD4=0, pool=[[0, 5], [17]])
    return out


def check_layout():
    checks = [
        ('glyph_size', 'sizeof(TextGlyphResource)', 88),
        ('glyph_tracks8', 'OFFSET(TextGlyphResource,animation.tracks[8])', 72),
        ('glyph_tracks1', 'OFFSET(TextGlyphResource,animation.tracks[1])', 44),
        ('animation_size', 'sizeof(ActorAnimation)', 16),
        ('animation_field08', 'OFFSET(ActorAnimation,field08)', 8),
        ('animation_loop_index', 'OFFSET(ActorAnimation,loopIndex)', 10),
        ('animation_loop_width', 'sizeof(((ActorAnimation *)0)->loopIndex)', 2),
        ('record_size', 'sizeof(ActorResource5CInternal)', 92),
        ('indexed_record_size', 'sizeof(ActorResource68Internal)', 104),
        ('group_size', 'sizeof(ActorResourceGroupInternal)', 1004),
        ('group_alignment', 'OFFSET(struct GroupAlignment,value)', 4),
        ('group_count', 'OFFSET(ActorResourceGroupInternal,count)', 0),
        ('group_resources', 'OFFSET(ActorResourceGroupInternal,resources)', 4),
        ('group_slot_size', 'sizeof(ActorGroupedResourceEntryInternal)', 96),
        ('group_slot_resource', 'OFFSET(ActorGroupedResourceEntryInternal,resource)', 0),
        ('chain_size', 'sizeof(ActorSetupChainEntryInternal)', 28),
        ('chain_resource', 'OFFSET(ActorSetupChainEntryInternal,actorResourceIndex)', 8),
        ('chain_extra', 'OFFSET(ActorSetupChainEntryInternal,extraResourceIndex)', 20),
        ('scene_size', 'sizeof(SceneDefinition)', 3348),
        ('scene_arrivals', 'OFFSET(SceneDefinition,arrivals)', 68),
        ('scene_count', 'OFFSET(SceneDefinition,arrivalCount)', 3272),
        ('scene_resourceC44', 'OFFSET(SceneDefinition,resourceC44)', 3140),
        ('scene_resourceCD4', 'OFFSET(SceneDefinition,resourceCD4)', 3284),
        ('arrival_size', 'sizeof(SceneArrival)', 12),
        ('arrival_index', 'OFFSET(SceneArrival,resourceIndex)', 2),
        ('arrival_category', 'OFFSET(SceneArrival,category)', 3),
        ('arrival_count', 'OFFSET(SceneArrival,count)', 6),
        ('arrival_index_width', 'sizeof(((SceneArrival *)0)->resourceIndex)', 1),
        ('arrival_count_width', 'sizeof(((SceneArrival *)0)->count)', 2),
        ('state_size', 'sizeof(SceneResourceState)', 416),
        ('state_flags', 'OFFSET(SceneResourceState,word00.fields.flags00)', 0),
        ('state_flags_width', 'sizeof(((SceneResourceState *)0)->word00.fields.flags00)', 1),
        ('state_value02', 'OFFSET(SceneResourceState,word00.fields.value02)', 2),
        ('state_value04', 'OFFSET(SceneResourceState,value04)', 4),
        ('state_value_width', 'sizeof(((SceneResourceState *)0)->value04)', 2),
        ('pool_size', 'sizeof(ActorDynamicPool)', 9096),
        ('pool_group_count', 'OFFSET(ActorDynamicPool,groupCount)', 4),
        ('pool_first_groups', 'OFFSET(ActorDynamicPool,firstGroups)', 16),
        ('pool_group_size', 'sizeof(ActorDynamicFirstGroup)', 124),
        ('pool_entries', 'OFFSET(ActorDynamicFirstGroup,entries)', 4),
        ('pool_entry_size', 'sizeof(ActorDynamicFirstEntry)', 12),
        ('pool_entry_index', 'OFFSET(ActorDynamicFirstEntry,resourceIndex)', 0),
    ]
    probe = BUILD / 'layout.c'
    probe.write_text('#include "' + str(ROOT / 'include/actor_setup_internal.h') + '"\n'
                     '#define OFFSET(t,f) ((unsigned int)&((t *)0)->f)\n'
                     'struct GroupAlignment { char c; ActorResourceGroupInternal value; };\n'
                     'const unsigned int setup_layout[] = { ' +
                     ', '.join(expression for name, expression, expected in checks) + ' };\n')
    obj = BUILD / 'layout.o'
    compile_source(probe, obj)
    sections, symbols = elf_sections_and_symbols(obj)
    count = len(checks)
    values = struct.unpack('>' + str(count) + 'I', sections['.rodata']['bytes'][:count * 4])
    assert symbols['setup_layout']['size'] == count * 4
    assert list(values) == [expected for name, expression, expected in checks], 'setup layout'
    return {name: value for (name, expression, expected), value in zip(checks, values)}


def negative_controls(text, dispatch, support, target, layout):
    original = (ROOT / SOURCE).read_text()
    callback_case = next(case for case in cases() if case.get('mutations') and
                         case.get('arrivals') == [(0, 28, 0)])
    count_case = next(case for case in cases() if case.get('mutations') and
                     case.get('arrivals') == [(1, 0, 1), (0, 25, 0), (3, 0, 1)])
    mutations = [
        ('counter_preincrement', 'if (D_80074A20++ == 0)', 'if (++D_80074A20 == 0)',
         {'mode': 2, 'counter': 0, 'load_result': 1}),
        ('stale_callback_index',
         'func_8001CF68((TextGlyphResource *)&D_800AFFC0, 1);\n'
         '                    index = D_800B9A78.arrivals[arrival].resourceIndex;',
         'func_8001CF68((TextGlyphResource *)&D_800AFFC0, 1);', callback_case),
        ('cached_arrival_count',
         'for (arrival = 0; arrival < D_800B9A78.arrivalCount; arrival++)',
         'arrivalLimit = D_800B9A78.arrivalCount;\n'
         '        for (arrival = 0; arrival < arrivalLimit; arrival++)', count_case),
        ('dropped_flag10', '0x90000000', '0x80000000',
         {'mode': 2, 'arrivals': [(7, 3, 0), (3, 0, 1)]}),
    ]
    directory = ROOT / '.local/scene-resource-setup-mutations'
    directory.mkdir(parents=True, exist_ok=True)
    controls = []

    def check(name, case, mutant_text, mutant_dispatch, report=None):
        positive = run(case, text, dispatch, support, target)
        retail = run(case, target[CODE_ROM:CODE_ROM + CODE_SIZE],
                     target[DISPATCH_ROM:DISPATCH_ROM + 40], support, target)
        assert positive == retail, ('mutation positive baseline', name)
        try:
            run(case, mutant_text, mutant_dispatch, support, target)
        except AssertionError as error:
            controls.append({'name': name, 'positive_baseline_passed': True,
                             'rejected': True, 'reason': str(error),
                             'comparison': report})
        else:
            raise AssertionError('Missed setup negative control: ' + name)

    for name, before, after, case in mutations:
        assert original.count(before) == 1, ('isolated setup mutation', name)
        source = original.replace(before, after, 1)
        if name == 'cached_arrival_count':
            source = source.replace('    int arrival;', '    int arrival;\n    int arrivalLimit;', 1)
        source = source.replace('../../../include/', str(ROOT / 'include') + '/')
        path = directory / (name + '.c')
        path.write_text(source)
        report = compare_candidate_block(name, path.relative_to(ROOT).as_posix(),
                                         target, layout, 'scene-resource-setup-mutations')
        built = ROOT / 'build/scene-resource-setup-mutations' / name
        check(name, case, (built / (name + '.bin')).read_bytes(),
              (built / 'dispatch.bin').read_bytes(), report)
    altered = bytearray(dispatch)
    altered[4:8] = altered[36:40]
    check('dispatch_category1_to9', {'mode': 2, 'arrivals': [(1, 0, 1)]},
          text, bytes(altered))
    return controls


def main():
    from compare_runtime import MATCHING_BLOCKS
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    BUILD.mkdir(parents=True, exist_ok=True)
    inputs = audit_input_hashes()
    layout_values = check_layout()
    support, reports = [], {}
    for name, source, first, last in MATCHING_BLOCKS:
        if name not in ('game_memory', 'script_animation_resolve'):
            continue
        offset = first - 0x80000000 + 0xC00
        report = compare_block(name, source, first, offset, offset + last - first,
                               target, 'scene-resource-setup-support', layout)
        assert report['matches']
        reports[name] = report
        support.append((first, (ROOT / 'build/scene-resource-setup-support' /
                                name / (name + '.bin')).read_bytes()))
    assert len(reports) == 2
    candidate = compare_candidate_block('scene_resource_setup', SOURCE, target,
                                        layout, 'scene-resource-setup-comparison')
    directory = ROOT / 'build/scene-resource-setup-comparison/scene_resource_setup'
    text = (directory / 'scene_resource_setup.bin').read_bytes()
    dispatch = (directory / 'dispatch.bin').read_bytes()
    tests = cases()
    digest, total = hashlib.sha256(), 0
    for i, case in enumerate(tests):
        compiled = run(case, text, dispatch, support, target)
        original = run(case, target[CODE_ROM:CODE_ROM + CODE_SIZE],
                       target[DISPATCH_ROM:DISPATCH_ROM + 40], support, target)
        assert compiled == original, ('paired instruction effects', i, case)
        digest.update(json.dumps([case, compiled], sort_keys=True).encode())
        total += len(compiled['trace'])
        if (i + 1) % 50 == 0:
            print('Guarded scene setup pairs:', i + 1, flush=True)
    controls = negative_controls(text, dispatch, support, target, layout)
    layout.verify()
    assert audit_input_hashes() == inputs
    result = {
        'matches_behavior': True, 'matching_source_claim': False,
        'source_instruction_bytes_added': 0, 'initialized_bytes_added': 0,
        'bss_bytes_added': 0, 'pairs': len(tests), 'executions': len(tests) * 2,
        'calls_per_image': total, 'trace_and_effects_sha256': digest.hexdigest(),
        'inputs_sha256': inputs, 'layout': layout_values,
        'layout_checks': len(layout_values), 'negative_controls': controls,
        'candidate': candidate, 'support': reports, 'unicorn': version('unicorn'),
        'limits': [
            'Resource loading, scene service and diagnostics use recorded O32 boundaries.',
            'Boundary calls clobber caller GPR/FPR and HI/LO; saved O32 GPR are checked.',
            'Matching copying and animation resolution execute C; animation fixtures cover negative references only.',
            'Larger indexed group views are isolated fixtures and establish no additional BSS ownership.',
            'Default diagnostics are modeled as returning boundaries; actual fatal-service behavior and complete gameplay are not established.',
            'The complete setup candidate and dispatch table remain excluded from the matching build.',
        ],
    }
    (BUILD / 'report.json').write_text(json.dumps(result, indent=2) + '\n')
    print({key: result[key] for key in ('pairs', 'executions', 'calls_per_image',
                                       'layout_checks', 'trace_and_effects_sha256',
                                       'matching_source_claim')})
    print('Setup negative controls rejected:', len(controls))


if __name__ == '__main__':
    main()
