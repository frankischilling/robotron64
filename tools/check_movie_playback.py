"""Check complete movie-update code against retail with memory and ABI guards."""
from collections import Counter
import hashlib
import itertools
import json
from pathlib import Path
import subprocess
import tempfile

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UC_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import SENTINEL, machine, word
from check_movie_storage import CALLER_SAVED, PRESERVED, pattern
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot, external_assignments
from owned_sections import elf_sections_and_symbols, load_owned_sections
from rom import ROOT, validate

ENTRY, END = 0x80004C3C, 0x80005354
SOURCE = 'src/game/movie_update.c'
CONFIG, POINTER, SESSION = 0x800B14B0, 0x800B14A8, 0x800AD138
ACTORS, RESOURCES, ANIMATIONS = 0x80210010, 0x80220010, 0x80230010
OBJECTS, MESHES, ALTERNATE = 0x800BF918, 0x8007A1CC, 0x80240010
OBJECT_COUNT, OBJECT_STRIDE = 300, 120
OBJECT_SOURCE = 'src/game/object_storage/records.c'
FADE, TICK, CALLBACKS, STACK = 0x8009E570, 0x8009EF94, 0x802F0100, 0x80300000
SUPPORT = ('movie_status', 'fixed_geometry_setup', 'object_helpers_index_limit', 'object_helpers_properties')


def signed(value):
    return (value + 0x80000000) % 0x100000000 - 0x80000000


def divide(value, divisor):
    assert divisor != 0 and not (value == -0x80000000 and divisor == -1)
    return (abs(value) // abs(divisor)) * (-1 if (value < 0) != (divisor < 0) else 1)


def remainder(value, divisor):
    return value - divide(value, divisor) * divisor


def prepare():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    rows = [('movie_update', SOURCE, ENTRY, END)] + [row for row in MATCHING_BLOCKS if row[0] in SUPPORT]
    original, compiled, reports = [], [], {}
    for name, source, start, end in rows:
        report = compare_block(name, source, start, start - 0x7FFFF400,
                               end - 0x7FFFF400, target, 'movie-playback-check', layout)
        assert report['matches'], (name, report['different_words'])
        original.append((start, target[start - 0x7FFFF400:end - 0x7FFFF400]))
        compiled.append((start, (ROOT / 'build/movie-playback-check' / name / (name + '.bin')).read_bytes()))
        reports[name] = report
    assert set(reports) == set(SUPPORT) | {'movie_update'}
    functions = {row['name']: row for row in json.loads((ROOT / 'config/functions.json').read_text())}
    object_storage = [row for row in load_owned_sections() if row.get('symbols', {}).get('D_800BF918') == 0]
    assert len(object_storage) == 1
    assert (object_storage[0]['rom'] is None and object_storage[0]['vram'] == OBJECTS and
            object_storage[0]['size'] == OBJECT_COUNT * OBJECT_STRIDE and
            object_storage[0]['source'] == OBJECT_SOURCE), 'Object pool extent changed'
    for address, size in ((0x80005354, 248), (0x8004CEF0, 24),
                          (0x80039CD0, 124), (0x80039E0C, 16)):
        assert functions[f'func_{address:08X}']['size'] == size, 'Helper extent changed'
    constants = []
    for address in (0x8008F914, 0x8008F920):
        first = address - 0x7FFFF400
        last = target.index(0, first) + 1
        constants.append((address, target[first:last]))
    return target, layout, original, compiled, reports, constants


def run(code, constants, case, entry=ENTRY, corrupt_object_index=None):
    for (a, blob), (other, other_blob) in itertools.combinations(code, 2):
        assert a + len(blob) <= other or other + len(other_blob) <= a, 'Overlapping executable images'
    seed = case.get('seed', 173)
    uc, write, _ = machine(code, constants)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA57281D9)
    saved = {r: uc.reg_read(r) for r in PRESERVED}
    panels = {}

    def panel(name, address, size):
        panels[name] = (address - 16, pattern(size + 32, seed + len(panels)))

    panel('configuration', POINTER, CONFIG + 1836 - POINTER)
    panel('alternate', ALTERNATE, 1836)
    panel('session', SESSION, 336)
    panel('fade', FADE, 20)
    panel('tick', TICK, 24)
    panel('color', 0x80075990, 4)
    panel('actors', ACTORS, 10 * 124)
    panel('resources', RESOURCES, 10 * 88)
    panel('animations', ANIMATIONS, 10 * 16)
    panel('objects', OBJECTS, OBJECT_COUNT * OBJECT_STRIDE)
    panel('meshes', MESHES, 255 * 16)
    base = ALTERNATE if case.get('alternate', False) else CONFIG

    def destination(address, size, objects):
        for name, (start, data) in panels.items():
            if start <= address and address + size <= start + len(data):
                return objects[name], address - start
        raise AssertionError(('Missing panel', hex(address), size))

    def initial(address, blob):
        data, offset = destination(address, len(blob), {name: p[1] for name, p in panels.items()})
        data[offset:offset + len(blob)] = blob

    def iw(address, value):
        initial(address, word(value))

    props = case.get('props', 10)
    strings = case.get('strings', 7)
    indexed = case.get('indexed', 30)
    colors = case.get('colors', 3)
    callbacks = case.get('callbacks', 3)
    assert 0 <= props <= 10 and 0 <= strings <= 7 and 0 <= indexed <= 30
    assert 0 <= colors <= 3 and 0 <= callbacks <= 3
    mode, time = case.get('mode', 0), case.get('time', 4095)
    repeats, rate, tick = case.get('repeats', 2), case.get('rate', 300), case.get('tick', 1)
    fading, fade_position = case.get('fading', 0), case.get('fade_position', -1024)
    iw(POINTER, base)
    for offset, value in {4: rate, 8: mode, 0x20: 4, 0x24: repeats, 0x28: time,
                          0x2C: 16, 0x30: 24, 0x38: case.get('pair', 0), 0x64: props,
                          0x68: 0, 0x6C: fading, 0x49C: indexed, 0x4A0: colors,
                          0x660: strings, 0x664: callbacks}.items():
        iw(base + offset, value)
    for i in range(5):
        iw(base + 0x3C + i * 8, -1 if case.get('no_camera', False) else 50 + i)
        iw(base + 0x40 + i * 8, i * 5)
    iw(SESSION + 0x20, case.get('skip', 0))
    iw(0x800AD280, case.get('game_mode', 5))
    iw(FADE + 8, fade_position)
    iw(TICK, tick)
    iw(0x8009EFA8, case.get('color_gate', 0))
    durations = (1, 0, 100, 4, 7, -4, 2, 3, 5, 9)
    object_indices = case.get('object_indices', (0, 3, OBJECT_COUNT - 1))
    assert len(object_indices) == 3 and all(0 <= index < OBJECT_COUNT for index in object_indices)
    actor_metadata = []
    for i in range(10):
        actor, resource, animation = ACTORS + i * 124, RESOURCES + i * 88, ANIMATIONS + i * 16
        null = case.get('null_props', False) and i % 3 == 0
        flag = 0 if case.get('idle_props', False) and i % 3 == 0 else 0x20
        count = 0 if not flag else (i + case.get('trigger_offset', 0)) % 11
        iw(base + 0x80 + i * 104, 0 if null else actor)
        iw(base + 0x84 + i * 104, count)
        for j in range(10):
            iw(base + 0x88 + i * 104 + j * 4, j * 2 - 2)
            iw(base + 0xB0 + i * 104 + j * 4, 1000 + i * 10 + j)
        object_id = object_indices[i % 3]
        initial(actor + 0xC, object_id.to_bytes(2, 'big'))
        iw(actor + 0x14, flag | 0x100)
        iw(actor + 0x24, resource)
        initial(actor + 0x1F, bytes([i]))
        iw(resource + 0x28 + i * 4, animation)
        duration = durations[(i + case.get('duration_offset', 0)) % 10]
        loop = -1 if i % 2 else 0
        initial(animation + 0xC, (duration & 65535).to_bytes(2, 'big'))
        initial(animation + 0xA, (loop & 65535).to_bytes(2, 'big'))
        mesh_id = 255 if object_id == OBJECT_COUNT - 1 else (object_id + 7) % 255
        initial(OBJECTS + object_id * OBJECT_STRIDE + 14, bytes([mesh_id]))
        limit = (3, 0)[object_id == 3]
        if mesh_id != 255:
            iw(MESHES + mesh_id * 16, limit)
        actor_metadata.append((actor, null, flag, count, duration, loop, object_id, mesh_id,
                               1 if mesh_id == 255 else max(limit, 1)))
    for i in range(7):
        for offset, value in {4: i * 4, 8: i * 3, 0x14: 80 + i, 0x18: -2 + i}.items():
            iw(base + 0x668 + i * 28 + offset, value)
    for i in range(30):
        for offset, value in {0: 900 + i, 4: i - 5, 8: i % 2}.items():
            iw(base + 0x4A4 + i * 12 + offset, value)
    for i in range(3):
        for offset, value in {4: i * 5, 8: 102400 if i != 1 else -102400,
                              12: 0, 16: 15 + i}.items():
            iw(base + 0x60C + i * 20 + offset, value)
        iw(base + 0x648 + i * 8, CALLBACKS + i * 32)
        iw(base + 0x64C + i * 8, (0, 2, 7)[i])
    expected = {name: bytearray(data) for name, (_, data) in panels.items()}
    expected_trace, trace, permitted_writes = [], [], []
    wanted_writes = Counter()

    def read(address):
        data, offset = destination(address, 4, expected)
        return signed(int.from_bytes(data[offset:offset + 4], 'big'))

    def store(address, blob, cpu=True):
        data, offset = destination(address, len(blob), expected)
        data[offset:offset + len(blob)] = blob
        permitted_writes.append((address, address + len(blob)))
        if cpu:
            wanted_writes[(address, len(blob))] += 1

    def sw(address, value):
        store(address, word(value))

    def fade_event(address, position, step):
        expected_trace.append(('fade', address, position, step))
        data, offset = destination(address, 4, expected)
        store(FADE, bytes(data[offset:offset + 4]), cpu=False)
        store(FADE + 8, word(position), cpu=False)
        store(FADE + 16, word(step), cpu=False)

    expected_trace.append(('select', 0x8008F914))
    if case.get('erase', 0):
        expected_trace.append(('select', 0x8008F920))
    if case.get('skip', 0) and not fading and case.get('game_mode', 5) != 12 and mode != -1:
        if mode == 0:
            fading = 1
            sw(base + 0x6C, 1)
            if fade_position == 0:
                fade_event(0x80075990, -102400, divide(signed(102400 * rate), 10240))
                fade_position = -102400
        elif mode == 1:
            mode, time = 2, 16 << 8
            sw(base + 8, mode)
            sw(base + 0x28, time)
    stopped = False
    if fading:
        stopped = -1 <= fade_position < 2
        if stopped:
            sw(base + 0x68, 2)
    elif mode == 2:
        stopped = time >= 24 * 256
        if stopped:
            sw(base + 0x68, 2)
    elif repeats != 999:
        stopped = time >= (max(repeats - 1, 0) * 13 + 16) * 256
        if stopped:
            sw(base + 0x68, 1)
    if not stopped:
        final = 24 if mode == 2 else 16
        actor_frame = None
        for i in range(props):
            actor, null, flag, count, duration, loop, obj, mesh, limit = actor_metadata[i]
            if null:
                continue
            if flag:
                duration = 4 if duration in (0, 100) else duration
                actor_frame = divide(time, duration * 64)
                if actor_frame >= final:
                    actor_frame = remainder(actor_frame, final - 4) + 4 if divide(actor_frame, final - 4) < repeats else final - 1
                if loop != -1:
                    if mesh != 255:
                        expected_trace.append(('mesh', -1, mesh, 0))
                    value = remainder(actor_frame, limit)
                else:
                    value = actor_frame
                sw(actor + 0x18, value * 256)
            for j in range(count):
                assert actor_frame is not None, 'Primary frames require the movie-start animation flag'
                if actor_frame >= j * 2 - 2:
                    expected_trace.append(('primary', obj, 1000 + i * 10 + j))
        whole = divide(time, 256)
        if time >= final * 256:
            whole = remainder(whole, final - 4) + 4 if divide(whole, final - 4) < repeats else 15
        if not case.get('no_camera', False):
            expected_trace.append(('camera', whole, case.get('pair', 0) * 5))
        for i in range(strings):
            expected_trace.append(('string', i * 4, i * 3, whole, 80 + i, 0, 0, 0, -2 + i))
        for i in range(indexed):
            if whole >= i - 5 and i % 2 == 0:
                expected_trace.append(('sound', 900 + i, 0, 1, 0))
                sw(base + 0x4AC + i * 12, 1)
        if not fading:
            for i in range(colors):
                position = 102400 if i != 1 else -102400
                gate = strings != 5 or (position == 102400 and not case.get('color_gate', 0))
                if gate and whole >= i * 5:
                    fade_event(base + 0x60C + i * 20, position, 15 + i)
                    sw(base + 0x618 + i * 20, 1)
        next_time = signed(time + signed(rate * tick))
        sw(base + 0x28, next_time)
        for i in range(callbacks):
            frame = (0, 2, 7)[i] * 256
            if time < frame <= next_time:
                expected_trace.append(('callback', i, 0))
    for address, data in panels.values():
        write(address, bytes(data))
    if corrupt_object_index is not None:
        # A negative control corrupts the CPU input after the valid oracle is built.
        write(ACTORS + 0xC, (corrupt_object_index & 0xFFFF).to_bytes(2, 'big'))
    lower, upper = STACK - 0x110, STACK + 32
    write(lower, bytes([0xD7]) * 16)
    write(upper, bytes([0xE9]) * 16)
    stack_range = (lower + 16, upper)
    readable = [(address + 16, address + len(data) - 16) for address, data in panels.values()]
    readable += [(address, address + len(data)) for address, data in constants] + [stack_range]
    uc.reg_write(regs.UC_MIPS_REG_A0, case.get('erase', 0))
    writes = Counter()

    def contains(address, size, bounds):
        return any(first <= address and address + size <= last for first, last in bounds)

    def access(uc, access, address, size, value, bounds):
        address = (address & 0x1FFFFFFF) | 0x80000000
        assert contains(address, size, bounds), ('Memory bounds', hex(address), size)
        if access == UC_MEM_WRITE and not contains(address, size, [stack_range]):
            writes[(address, size)] += 1

    uc.hook_add(UC_HOOK_MEM_READ, access, user_data=readable)
    uc.hook_add(UC_HOOK_MEM_WRITE, access, user_data=permitted_writes + [stack_range])
    primary = next(blob for address, blob in code if address == entry)
    code_ranges = [(entry, entry + len(primary)),
                   (0x80005354, 0x8000544C), (0x8004CEF0, 0x8004CF08),
                   (0x80039CD0, 0x80039D4C), (0x80039E0C, 0x80039E1C)]
    code_ranges += [(SENTINEL, SENTINEL + 4)]
    boundaries = {0x800360B8, 0x80003ECC, 0x80002D70, 0x8003614C, 0x80031658, 0x8004BD00}
    boundaries |= {CALLBACKS + i * 32 for i in range(3)}

    def args(count=4):
        values = [signed(uc.reg_read(r)) for r in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)]
        sp = uc.reg_read(regs.UC_MIPS_REG_SP)
        for i in range(4, count):
            address = sp + i * 4
            assert contains(address, 4, [stack_range]), 'Service argument outside stack'
            values.append(signed(int.from_bytes(uc.mem_read(address & 0x1FFFFFFF, 4), 'big')))
        return values[:count]

    def event(actual):
        assert len(trace) < len(expected_trace) and actual == expected_trace[len(trace)], ('Call oracle', actual, expected_trace[len(trace):len(trace) + 2])
        trace.append(actual)

    def instruction(uc, address, size, user):
        if address == 0x80039E0C:
            event(('primary', *args(2)))
        if address in boundaries:
            returned = 0
            if address == 0x800360B8:
                actual = ('select', args(1)[0] & 0xFFFFFFFF)
            elif address == 0x80003ECC:
                actual = ('camera', *args(2))
            elif address == 0x80002D70:
                actual = ('string', *args(8))
            elif address == 0x8003614C:
                actual = ('sound', *args())
            elif address == 0x8004BD00:
                actual, returned = ('mesh', *args(3)), 2
            elif address == 0x80031658:
                color, position, step = args(3)
                color &= 0xFFFFFFFF
                actual, returned = ('fade', color, position, step), position
                assert contains(color, 4, readable), 'Fade color bounds'
                uc.mem_write(FADE & 0x1FFFFFFF, bytes(uc.mem_read(color & 0x1FFFFFFF, 4)))
                uc.mem_write((FADE + 8) & 0x1FFFFFFF, word(position))
                uc.mem_write((FADE + 16) & 0x1FFFFFFF, word(step))
            else:
                actual = ('callback', (address - CALLBACKS) // 32, *args(1))
            event(actual)
            ra = uc.reg_read(regs.UC_MIPS_REG_RA)
            for i, register in enumerate(CALLER_SAVED):
                uc.reg_write(register, 0xA1387500 + i * 17)
            uc.reg_write(regs.UC_MIPS_REG_V0, returned & 0xFFFFFFFF)
            uc.reg_write(regs.UC_MIPS_REG_PC, ra)
        else:
            assert contains(address, size, code_ranges), ('Code bounds', hex(address))

    uc.hook_add(UC_HOOK_CODE, instruction)
    uc.emu_start(entry, 0, count=200000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, 'Movie update did not return'
    assert all(uc.reg_read(r) == value for r, value in saved.items()), 'O32 preservation'
    assert trace == expected_trace, ('Missing service', trace, expected_trace)
    assert writes == wanted_writes, ('Exact target write footprint', writes, wanted_writes)
    for name, (address, data) in panels.items():
        actual = bytes(uc.mem_read(address & 0x1FFFFFFF, len(data)))
        differences = [(hex(address + i), actual[i], expected[name][i])
                       for i in range(len(data)) if actual[i] != expected[name][i]]
        assert not differences, ('Complete guarded object', name, differences[:8], case)
    assert bytes(uc.mem_read(lower & 0x1FFFFFFF, 16)) == bytes([0xD7]) * 16
    assert bytes(uc.mem_read(upper & 0x1FFFFFFF, 16)) == bytes([0xE9]) * 16
    return hashlib.sha256(b''.join(bytes(expected[name]) for name in sorted(expected)) + json.dumps(trace).encode()).hexdigest()


MUTATIONS = {
    'default_duration': ('frameDuration = 4;', 'frameDuration = 5;', {'duration_offset': 0}),
    'last_primary_frame': ('triggerIndex < D_800B14A8->props[index].primaryFrameCount', 'triggerIndex < D_800B14A8->props[index].primaryFrameCount - 1', {'time': 6144, 'repeats': 999}),
    'last_string': ('index < D_800B14A8->stringCount', 'index < D_800B14A8->stringCount - 1', {}),
    'color_gate': ('D_800B14A8->stringCount != 5', 'D_800B14A8->stringCount == 5', {'strings': 5}),
    'callback_threshold': ('previousFrame < (D_800B14A8->callbacks[index].frame << 8)', 'previousFrame <= (D_800B14A8->callbacks[index].frame << 8)', {'time': 512}),
    'time_step': ('D_800B14A8->field04 * D_8009EF94', 'D_800B14A8->field04 * (D_8009EF94 + 1)', {}),
}


def relocated(obj, directory, layout):
    start = 0x80100000
    undefined = {line.split()[-1] for line in subprocess.check_output(
        ['mips-linux-gnu-nm', '-u', str(obj)], text=True).splitlines() if line.strip()}
    linker = directory / 'relocated.ld'
    linker.write_text(external_assignments(undefined, layout.addresses) +
                      f'SECTIONS {{ .text 0x{start:X} : SUBALIGN(4) {{ *(.text) }} }}\n')
    output = directory / 'relocated.elf'
    subprocess.run(['mips-linux-gnu-ld', '-T', str(linker), '-e', 'func_80004C3C',
                    '-o', str(output), str(obj)], check=True, capture_output=True)
    sections, symbols = elf_sections_and_symbols(output)
    live = symbols['func_80004C3C']['size']
    assert symbols['func_80004C3C']['value'] == start
    blob = sections['.text']['bytes']
    assert not any(blob[live:]), 'Unexpected executable tail'
    return start, blob[:live]


def main(include_mutations=False):
    target, layout, original, compiled, reports, constants = prepare()
    cases = []
    for seed in (0, 173, 255):
        for count, time in itertools.product(range(31), (-513, 0, 255, 256, 4095, 6144, 7423)):
            cases.append(dict(seed=seed, props=count % 11, strings=count % 8, indexed=count,
                              colors=count % 4, callbacks=count % 4, time=time, erase=count % 2,
                              alternate=bool(count % 2), pair=count % 5, duration_offset=count % 10,
                              trigger_offset=count % 11, null_props=bool(count % 2),
                              idle_props=bool(count % 3), no_camera=bool(count % 5 == 0)))
        for mode, skip, fading, position, game_mode in itertools.product((-1, 0, 1, 2), (0, 1), (0, 1), (-1, 0, 1, 2), (5, 12)):
            cases.append(dict(seed=seed, mode=mode, skip=skip, fading=fading,
                              fade_position=position, game_mode=game_mode, erase=1))
        for time, tick, repeats in itertools.product((-1, 0, 511, 512, 1791, 1792, 6144, 7424), (0, 1, -1), (0, 1, 2, 999)):
            cases.append(dict(seed=seed, time=time, tick=tick, repeats=repeats))
        for strings, gate in itertools.product((4, 5, 6), (0, 1)):
            cases.append(dict(seed=seed, strings=strings, color_gate=gate, time=6144))
        for object_index in range(OBJECT_COUNT):
            cases.append(dict(seed=seed, props=1, strings=0, indexed=0, colors=0, callbacks=0,
                              object_indices=(object_index, object_index, object_index)))
    proofs = []
    for case in cases:
        retail = run(original, constants, case)
        recovered = run(compiled, constants, case)
        assert retail == recovered, case
        proofs.append(recovered)
    object_bounds = []
    boundary_case = dict(props=1, strings=0, indexed=0, colors=0, callbacks=0,
                         object_indices=(OBJECT_COUNT - 1,) * 3)
    assert run(original, constants, boundary_case) == run(compiled, constants, boundary_case)
    for invalid_index in (-1, OBJECT_COUNT):
        address = OBJECTS + invalid_index * OBJECT_STRIDE + 14
        rejected = []
        for name, image in (('retail', original), ('recovered', compiled)):
            try:
                run(image, constants, boundary_case, corrupt_object_index=invalid_index)
            except AssertionError as error:
                assert error.args[0] == ('Memory bounds', hex(address), 1), ('Wrong bounds rejection', name, error)
                rejected.append(name)
            else:
                raise AssertionError(('Out-of-pool object read accepted', name, invalid_index))
        object_bounds.append({'invalid_index': invalid_index, 'read_address': hex(address),
                              'last_valid_index_control_passed': True, 'rejected_images': rejected})
    mutations = []
    path = ROOT / SOURCE
    source = path.read_text()
    for name, (old, new, case) in (MUTATIONS.items() if include_mutations else ()):
        assert run(original, constants, case) == run(compiled, constants, case), ('Positive control', name)
        assert source.count(old) == 1, ('Mutation anchor', name)
        with tempfile.TemporaryDirectory(prefix='movie-playback-' + name + '-', dir=ROOT / '.local') as temporary:
            temporary = Path(temporary)
            control = relocated(ROOT / 'build/movie-playback-check/movie_update/movie_update.o', temporary, layout)
            assert control[1] == next(b for a, b in compiled if a == ENTRY), 'Relocated control bytes changed'
            control_image = [(a, b) for a, b in compiled if a != ENTRY] + [control]
            assert run(original, constants, case) == run(control_image, constants, case, entry=control[0]), ('Relocated positive control', name)
            mutant = temporary / 'mutated.c'
            mutant.write_text(source.replace(old, new))
            report = compare_block('mutated', str(mutant.relative_to(ROOT)), ENTRY,
                                   ENTRY - 0x7FFFF400, END - 0x7FFFF400, target,
                                   'movie-playback-mutations-' + name, layout)
            assert not report['matches'], ('Unchanged mutation', name)
            mutant_image = relocated(ROOT / ('build/movie-playback-mutations-' + name) / 'mutated/mutated.o', temporary, layout)
            changed = [(a, b) for a, b in compiled if a != ENTRY] + [mutant_image]
            try:
                run(changed, constants, case, entry=mutant_image[0])
            except AssertionError as error:
                mutations.append({'name': name, 'control_passed': True, 'mutation_rejected': True,
                                  'different_words': len(report['different_words']), 'reason': str(error)[:600]})
            else:
                raise AssertionError(('Mutation survived', name))
    assert path.read_text() == source, 'Candidate changed during isolated controls'
    layout.verify()
    report = {'matches': True, 'paired_cases': len(cases), 'target_executions': len(cases) * 2,
              'cases_sha256': hashlib.sha256(json.dumps(proofs).encode()).hexdigest(),
              'comparisons': reports, 'mutations': mutations,
              'object_storage': {'source': OBJECT_SOURCE, 'source_sha256': hashlib.sha256((ROOT / OBJECT_SOURCE).read_bytes()).hexdigest(),
                                 'records': OBJECT_COUNT,
                                 'stride': OBJECT_STRIDE, 'bytes': OBJECT_COUNT * OBJECT_STRIDE,
                                 'every_valid_index_paired': True, 'bounds_controls': object_bounds},
              'limitations': ['Sound selection/events, camera/text submission, mesh loading, palette fade and callbacks use recorded clobbering integer ABI boundaries.',
                              'Movie status, integer absolute value, object frame limit and the retail no-op primary-frame setter execute as real freshly compared code.',
                              'Actor flags cleared before an uninitialized primary-frame read are invalid setup and excluded; movie-start sets bit 0x20 on each allocated prop.',
                              'Fixtures cover valid arrays and pointers. Complete movie rendering, callback bodies and gameplay are not established.']}
    output = ROOT / 'build/movie-playback-check/report.json'
    output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k: report[k] for k in ('matches', 'paired_cases', 'target_executions')}))
    print('Rejected ' + str(len(mutations)) + ' mutations; report: ' + str(output.relative_to(ROOT)))


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mutations', action='store_true', help='Run isolated source controls')
    main(parser.parse_args().mutations)
