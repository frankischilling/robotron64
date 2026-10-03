"""Execute both collision responses against retail and independent state oracles."""

import hashlib
import itertools
import json
import struct
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE
from unicorn import mips_const as regs
from check_actor_group_path import SENTINEL, word
from check_actor_boundary_boss import environment, signed, divide
from check_boss_trigger import pattern, fingerprint
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


ENTRY, FIRST, SECOND = 0x80015BF8, 0x80201010, 0x80202010
RESOURCE, OWNER, OTHER_OWNER, CALLBACK = 0x80203010, 0x80204010, 0x80205010, 0x80000180
CLOCK, LIMIT, WIDTH, MODE = 0x8009EFA0, 0x800B6FD0, 0x800B8F60, 0x800BA74C
ANGLE, COSINE, SINE = 0x8003CD4C, 0x8003CC88, 0x8003CC58
ANIMATE, OBJECT, DAMAGE, SCORE, RETIRE = 0x80027AB8, 0x80039514, 0x80035244, 0x80037144, 0x8001B4F8
ARG_COUNTS = {ANGLE: 2, COSINE: 1, SINE: 1, ANIMATE: 3, OBJECT: 2,
              DAMAGE: 2, SCORE: 2, RETIRE: 2, CALLBACK: 1}
PICKUP, SESSION, SEQUENCE, ORDER = 0x80015F00, 0x800AD138, 0x8009CD08, 0x800739BC
MENU, GAME_MODE, DELAY = 0x800B8F78, 0x800AE560, 0x800B6FD4
FIRST_POSITION, SECOND_POSITION = 0x80206010, 0x80207010
CHILDREN, CHILD_RESOURCES = (0x80208010, 0x80209010), (0x8020A010, 0x8020B010)
COLOR, CUE, SOUND, CREATE, CHILD_CALLBACK = 0x80039C1C, 0x8003BF9C, 0x8003614C, 0x800283D4, 0x800001C0


def run_pickup(code, support, case):
    uc, write, execute, read, finish_call = environment(code, support)
    images = {}
    for ordinal, (address, size) in enumerate(((FIRST, 124), (SECOND, 124), (RESOURCE, 88),
            (SESSION, 328), (SEQUENCE, 4), (ORDER, 12), (MENU, 16), (GAME_MODE, 4), (DELAY, 4),
            (FIRST_POSITION, 12), (SECOND_POSITION, 12)) + tuple((address, 124) for address in CHILDREN)
            + tuple((address, 88) for address in CHILD_RESOURCES)):
        images[address - 16] = pattern(size + 32, ordinal * 19 + case['id'])

    def put(state, address, data):
        for start, image in state.items():
            if start <= address and address + len(data) <= start + len(image):
                image[address-start:address-start+len(data)] = data
                return
        raise AssertionError(('Outside pickup guards', hex(address)))

    def get(state, address, size=4, signed_value=True):
        for start, image in state.items():
            if start <= address and address + size <= start + len(image):
                return int.from_bytes(image[address-start:address-start+size], 'big', signed=signed_value)
        raise AssertionError(hex(address))

    def short(state, address, value):
        put(state, address, struct.pack('>H', value & 65535))

    put(images, FIRST + 31, bytes([case['animation']]))
    short(images, FIRST + 12, -17)
    put(images, FIRST + 60, word(OWNER))
    put(images, SECOND + 36, word(RESOURCE))
    put(images, RESOURCE + 2, bytes([case['kind']]))
    short(images, MENU + 4, case['menu'])
    put(images, SEQUENCE, word(case['sequence']))
    put(images, ORDER - 4, word(0))
    put(images, ORDER, word(1) + word(0) + word(2))
    put(images, SESSION + 76, word(case['score']))
    put(images, GAME_MODE, word(case['mode']))
    put(images, DELAY, word(case['delay']))
    put(images, FIRST_POSITION, b''.join(word(value) for value in case['first_position']))
    put(images, SECOND_POSITION, b''.join(word(value) for value in case['second_position']))
    for index in range(8):
        short(images, SESSION + 256 + index*2, -32768 if index == case['kind'] else 7)
    for child, resource in zip(CHILDREN, CHILD_RESOURCES):
        put(images, child + 36, word(resource))
        put(images, child + 72, word(-12345))
        put(images, resource + 84, word(CHILD_CALLBACK))
    expected = {address: bytearray(data) for address, data in images.items()}
    events, positions = [], []
    calls = {SOUND: 0, SCORE: 0, CREATE: 0, CHILD_CALLBACK: 0}

    def mutate(state, address, ordinal):
        mutation = case['mutation']
        if address == SOUND and ordinal == 2 and mutation == 1:
            put(state, SESSION + 76, word(4999))
        if address == SCORE and ordinal == 1 and mutation == 2:
            put(state, FIRST + 60, word(OTHER_OWNER))
            put(state, FIRST_POSITION, word(-11) + word(13) + word(333))
            put(state, SECOND_POSITION, word(4) + word(-8) + word(-333))
        if address == CHILD_CALLBACK and ordinal == 1 and mutation == 3:
            put(state, SEQUENCE, word(3))
            put(state, SESSION + 76, word(5000))
        if address == CHILD_CALLBACK and ordinal == 2 and mutation == 4:
            put(state, CHILDREN[1] + 72, word(12345678))
            put(state, DELAY, word(-4))
        if address == CHILD_CALLBACK and mutation == 5:
            put(state, RESOURCE + 2, bytes([(case['kind']+1) % 4]))
        if address == SCORE and ordinal == 1 and mutation == 6:
            put(state, GAME_MODE, word(3))

    def event(address, args, position=None):
        ordinal = calls.get(address, 0) + 1
        calls[address] = ordinal
        events.append([address, [value & 0xFFFFFFFF for value in args], fingerprint(expected)])
        if position is not None:
            positions.append([len(events)-1, position])
        mutate(expected, address, ordinal)

    result = 0
    if case['kind'] < 4:
        if case['menu'] == 0:
            short(expected, MENU + 4, -1)
        index = case['sequence']
        if index < 3 and case['kind'] == get(expected, ORDER + index*4):
            put(expected, SEQUENCE, word(index+1))
        colors = {0: (65, 0, 0, 240), 1: (64, 240, 0, 240),
                  2: (66, 240, 0, 0), 3: (67, 240, 240, 128)}
        sound, red, green, blue = colors[case['kind']]
        event(COLOR, [-17, red, green, blue])
        event(CUE, [8])
        event(SOUND, [8, 0, 1, 0])
        event(SOUND, [sound, 0, 1, 0])
        score = get(expected, SESSION + 76)
        if score < 5000:
            put(expected, SESSION + 76, word(score+1000))
        event(SCORE, [get(expected, SESSION+76), get(expected, FIRST+60)])
        midpoint = [divide(signed(get(expected, FIRST_POSITION+axis*4) + get(expected, SECOND_POSITION+axis*4)), 2)
                    for axis in range(2)] + [0]
        for spawn in range(2):
            if spawn == 1:
                if get(expected, SEQUENCE) != 3:
                    break
                event(SCORE, [get(expected, SESSION+76), get(expected, FIRST+60)])
            if get(expected, GAME_MODE) == 3:
                continue
            resource = 0x800B1BE8 + (divide(get(expected, SESSION+76), 1000)+9)*88
            event(CREATE, [9, resource], midpoint)
            if case['allocation'] & (1 << spawn):
                event(CHILD_CALLBACK, [CHILDREN[spawn], 1])
                if spawn == 1:
                    put(expected, CHILDREN[spawn]+72, word(get(expected, CHILDREN[spawn]+72)-divide(get(expected, DELAY), 3)))
        index = get(expected, RESOURCE+2, 1, False)
        short(expected, SESSION+256+index*2, get(expected, SESSION+256+index*2, 2)-1)
        result = 32
    elif case['animation'] != 1:
        event(DAMAGE, [FIRST, SECOND])

    for address, data in images.items():
        write(address, bytes(data))
    home = bytes(pattern(32, case['id']+19))
    write(0x80300000, home)
    observed, actual_counts = [], {}
    arg_counts = {COLOR: 4, CUE: 1, SOUND: 4, SCORE: 2, CREATE: 2, CHILD_CALLBACK: 2, DAMAGE: 2}
    snapshots = dict(positions)
    def observe(uc, address, size, user):
        if address not in arg_counts:
            return
        args = [uc.reg_read(register) for register in
                (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)[:arg_counts[address]]]
        state = {start: bytearray(read(start, len(data))) for start, data in images.items()}
        actual = [address, args, fingerprint(state)]
        assert len(observed) < len(events) and actual == events[len(observed)], (case, actual, events[len(observed):len(observed)+1])
        if address == CREATE:
            vector = [int.from_bytes(read(uc.reg_read(regs.UC_MIPS_REG_A2)+i*4, 4), 'big', signed=True) for i in range(3)]
            assert vector == snapshots[len(observed)], (case, vector, snapshots)
        observed.append(actual)
        ordinal = actual_counts.get(address, 0)+1
        actual_counts[address] = ordinal
        mutate(state, address, ordinal)
        for start, data in state.items():
            write(start, bytes(data))
        returned = CHILDREN[ordinal-1] if address == CREATE and case['allocation'] & (1 << (ordinal-1)) else 0
        finish_call(returned)
    uc.hook_add(UC_HOOK_CODE, observe)
    for register, value in zip((regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3),
                               (FIRST, SECOND, FIRST_POSITION, SECOND_POSITION)):
        uc.reg_write(register, value)
    execute(PICKUP)
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == result and observed == events
    assert read(0x80300000, 32) == word(FIRST)+word(SECOND)+word(FIRST_POSITION)+word(SECOND_POSITION)+home[16:]
    for address, data in expected.items():
        assert read(address, len(data)) == bytes(data), (case, 'Pickup final state', hex(address))
    return dict(events=observed, positions=positions, final_sha256=fingerprint(expected), result=result)


def pickup_cases():
    for kind, sequence, score, allocation in itertools.product(range(4), (-1, 0, 1, 2, 3, 4),
            (-1000, 0, 3999, 4999, 5000, 6000), range(4)):
        yield dict(group='pickup', kind=kind, sequence=sequence, score=score, allocation=allocation)
    for kind, mutation, mode, allocation in itertools.product(range(4), range(1, 7), (0, 3), range(4)):
        yield dict(group='pickup_mutation', kind=kind, mutation=mutation, mode=mode, allocation=allocation, sequence=3)
    for kind, animation in itertools.product((4, 5, 8, 9, 33, 255), (0, 1, 255)):
        yield dict(group='pickup_guard', kind=kind, animation=animation)


def run_case(code, support, case):
    uc, write, execute, read, finish_call = environment(code, support)
    images = {}
    for ordinal, (address, size) in enumerate(((FIRST, 124), (SECOND, 124),
            (RESOURCE, 88), (OWNER, 32), (OTHER_OWNER, 32),
            (CLOCK, 4), (LIMIT, 4), (WIDTH, 4), (MODE, 4))):
        images[address - 16] = pattern(size + 32, ordinal * 17 + case['id'])

    def put(state, address, data):
        for start, image in state.items():
            if start <= address and address + len(data) <= start + len(image):
                image[address-start:address-start+len(data)] = data
                return
        raise AssertionError(('Outside guarded state', hex(address)))

    def get(state, address, size=4, signed_value=True):
        for start, image in state.items():
            if start <= address and address + size <= start + len(image):
                return int.from_bytes(image[address-start:address-start+size], 'big', signed=signed_value)
        raise AssertionError(hex(address))

    def short(state, address, value):
        put(state, address, struct.pack('>H', value & 65535))

    for actor, animation, flags in ((FIRST, case['animation'], case['flags']),
                                     (SECOND, case['second_animation'], case['second_flags'])):
        put(images, actor + 31, bytes([animation]))
        put(images, actor + 20, word(flags))
        short(images, actor + 8, case['angle'])
        short(images, actor + 12, -17 if actor == FIRST else 32767)
        put(images, actor + 36, word(RESOURCE))
        put(images, actor + 60, word(OWNER if actor == SECOND else OTHER_OWNER))
        put(images, actor + 68, word(CALLBACK))
        put(images, actor + 84, word(case['cooldown'] if actor == FIRST else case['count']))
        put(images, actor + 96, word(111 if actor == FIRST else -222) + word(-333 if actor == FIRST else 444) + word(case['z']))
        short(images, actor + 16, case['health'])
    put(images, RESOURCE + 2, bytes([case['kind']]))
    short(images, RESOURCE + 4, case['score'])
    for address, value in ((CLOCK, case['clock']), (LIMIT, case['limit']),
                           (WIDTH, case['width']), (MODE, case['mode'])):
        put(images, address, word(value))
    expected = {address: bytearray(data) for address, data in images.items()}
    events = []

    def mutate(state, address):
        mutation = case['mutation']
        if address == ANIMATE and mutation == 1:
            short(state, FIRST + 8, -32768)
            put(state, FIRST + 20, word(0x140))
        if address == OBJECT and mutation == 2:
            put(state, FIRST + 20, word(0x140))
            put(state, SECOND + 84, word(case['limit']))
        if address == CALLBACK and mutation in (3, 4):
            put(state, FIRST + 20, word(0x200))
            put(state, SECOND + 84, word(case['limit'] if mutation == 3 else signed(case['limit'] - 1)))
        if address == DAMAGE:
            if mutation == 5:
                short(state, FIRST + 16, -1)
                put(state, SECOND + 60, word(OTHER_OWNER))
                put(state, MODE, word(-1))
            if mutation == 6:
                short(state, FIRST + 16, 1)
                put(state, MODE, word(7))
            if mutation == 7:
                put(state, FIRST + 36, word(RESOURCE + 8))
                short(state, RESOURCE + 12, -32768)

    def event(address, *args):
        events.append([address, [value & 0xFFFFFFFF for value in args], fingerprint(expected)])
        mutate(expected, address)

    enabled = not (case['second_animation'] == 1 or case['second_flags'] & 0x4400)
    if enabled:
        if case['kind'] in (6, 7, 8):
            event(ANGLE, 777, -333)
            angle = case['angle_return'] & 65535
            angle = angle - 65536 if angle & 32768 else angle
            enabled = (abs(angle - case['angle']) & 2047) <= {6: 700, 7: 1000, 8: 850}[case['kind']]
        elif case['kind'] == 1:
            enabled = signed(abs(case['z'])) <= abs(divide(case['width'], 2))
        elif case['kind'] == 33:
            if case['animation'] not in (3, 6) and ((case['clock'] - case['cooldown']) & 0xFFFFFFFF) > 500:
                put(expected, SECOND + 84, word(case['count'] + 1))
                put(expected, FIRST + 60, word(SECOND))
                event(ANIMATE, FIRST, 6, 1)
                put(expected, FIRST + 44, word(0))
                event(COSINE, get(expected, FIRST + 8, 2))
                put(expected, FIRST + 108, word(0))
                event(SINE, get(expected, FIRST + 8, 2))
                put(expected, FIRST + 112, word(0))
                event(OBJECT, -17, get(expected, FIRST + 8, 2))
                if get(expected, FIRST + 20, signed_value=False) & 0x40:
                    put(expected, FIRST + 20, word(get(expected, FIRST + 20, signed_value=False) & ~0x40))
                    event(CALLBACK, FIRST)
                put(expected, FIRST + 20, word(get(expected, FIRST + 20, signed_value=False) | 0x40))
                short(expected, FIRST + 14, 999)
                put(expected, FIRST + 68, word(0x80015BD4))
            enabled = get(expected, SECOND + 84) >= get(expected, LIMIT)
        if enabled:
            event(DAMAGE, SECOND, FIRST)
            if get(expected, FIRST + 16, 2) <= 0 or get(expected, MODE) != -1:
                if get(expected, MODE) == -1:
                    event(SCORE, get(expected, get(expected, FIRST + 36, signed_value=False) + 4, 2), OWNER)
                event(RETIRE, FIRST, 0)

    for address, data in images.items():
        write(address, bytes(data))
    stack_home = bytes(pattern(32, case['id'] + 31))
    write(0x80300000, stack_home)
    trace = []

    def observe(uc, address, size, user):
        if address not in ARG_COUNTS:
            return
        args = [uc.reg_read(register) for register in
                (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2)[:ARG_COUNTS[address]]]
        current = {start: bytearray(read(start, len(data))) for start, data in images.items()}
        actual = [address, args, fingerprint(current)]
        assert len(trace) < len(events) and actual == events[len(trace)], (case, actual, events[len(trace):len(trace)+1])
        trace.append(actual)
        mutate(current, address)
        for start, data in current.items():
            write(start, bytes(data))
        finish_call(case['angle_return'] if address == ANGLE else 0x71234567)

    uc.hook_add(UC_HOOK_CODE, observe)
    unused = (0x12345678, 0x87654321)
    for register, value in zip((regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3),
                               (FIRST, SECOND) + unused):
        uc.reg_write(register, value)
    execute(ENTRY)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == 0 and trace == events
    assert read(0x80300000, 32) == stack_home[:8] + word(unused[0]) + word(unused[1]) + stack_home[16:]
    for address, data in expected.items():
        assert read(address, len(data)) == bytes(data), (case, 'Final guarded state', hex(address))
    return dict(events=trace, final_sha256=fingerprint(expected))


def cases():
    for kind, returned, angle in itertools.product((6, 7, 8),
            (-32768, -2048, -1001, -1000, -851, -850, -701, -700, -1, 0, 700, 701, 850, 851, 1000, 1001, 2047, 32767, 0x12348000),
            (-32768, -2048, -1, 0, 2047, 32767)):
        yield dict(group='angle', kind=kind, angle_return=returned, angle=angle)
    for z, width in itertools.product((-2147483648, -501, -500, -1, 0, 1, 500, 501, 2147483647),
                                     (-1001, -1000, -1, 0, 1, 1000, 1001)):
        yield dict(group='width', kind=1, z=z, width=width)
    for animation, elapsed, count, flags, mutation in itertools.product((0, 3, 6, 255),
            (-1, 0, 500, 501, 0x7FFFFFFF), (-1, 9, 10, 2147483647), (0, 0x40, 0x140), range(8)):
        yield dict(group='capture', kind=33, animation=animation, cooldown=0, clock=elapsed, count=count, flags=flags, mutation=mutation)
    for kind, health, mode, mutation in itertools.product((0, 2, 5, 9, 32, 34, 255),
            (-32768, -1, 0, 1, 32767), (-1, 0, 7), (0, 5, 6, 7)):
        yield dict(group='default', kind=kind, health=health, mode=mode, mutation=mutation)
    for kind, animation, flags in itertools.product((0, 1, 6, 7, 8, 33, 255), (0, 1, 255), (0, 0x400, 0x4000, 0x4400, 0x100)):
        yield dict(group='guards', kind=kind, second_animation=animation, second_flags=flags)


def main():
    target = (ROOT/'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, retail, support, comparisons = [], [], [], {}
    for name in ('actor_collision_response_gate', 'actor_collision_pickup_response', 'fixed_geometry_setup'):
        _, source, start, end = next(record for record in MATCHING_BLOCKS if record[0] == name)
        report = compare_block(name, source, start, start-0x80000000+0xC00, end-0x80000000+0xC00,
                               target, family='actor-collision-execution', layout=layout)
        assert report['matches'], name
        comparisons[name] = report
        directory = ROOT/'build/actor-collision-execution'/name
        data = (directory/(name+'.bin')).read_bytes()
        if name.startswith('actor_collision_'):
            compiled.append((start, data))
            retail.append((start, target[start-0x80000000+0xC00:end-0x80000000+0xC00]))
        else:
            support.append((start, data))
        sections, _ = elf_sections_and_symbols(directory/(name+'.elf'))
        for record in source_sections(source):
            if record['rom'] is not None:
                data = sections[record['section']]['bytes']
                if name.startswith('actor_collision_'):
                    compiled.append((record['vram'], data))
                    retail.append((record['vram'], target[record['rom']:record['rom']+record['size']]))
                else:
                    support.append((record['vram'], data))
    counts, digest = {}, hashlib.sha256()
    for index, parameters in enumerate(cases()):
        case = dict(id=index, kind=0, animation=0, flags=0x40, second_animation=0, second_flags=0,
                    angle=0, angle_return=0, z=0, width=1000, cooldown=0, clock=501, count=10,
                    limit=10, health=1, mode=-1, score=(-32768, -1, 0, 1, 32767)[index % 5], mutation=0)
        case.update(parameters)
        expected = run_case(retail, support, case)
        actual = run_case(compiled, support, case)
        assert actual == expected, case
        counts[case['group']] = counts.get(case['group'], 0) + 1
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
        if (index+1) % 500 == 0:
            print('Collision cases compared:', index+1, flush=True)
    order_source = 'src/game/collisions/pickup_order.c'
    order_comparison = compare_unit(order_source, source_sections(order_source), target, layout)
    assert order_comparison['matches']
    for index, parameters in enumerate(pickup_cases()):
        case = dict(id=index, kind=0, sequence=0, score=0, mode=0, delay=(-4, -3, 0, 3, 4, 2147483647)[index % 6],
                    allocation=3, animation=0, menu=(-32768, -1, 0, 1, 32767)[index % 5], mutation=0,
                    first_position=(-11, 13, 12345), second_position=(4, -8, -12345))
        case.update(parameters)
        expected = run_pickup(retail, support, case)
        actual = run_pickup(compiled, support, case)
        assert actual == expected, case
        counts[case['group']] = counts.get(case['group'], 0)+1
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
    report = dict(matches=True, counts=counts, cases=sum(counts.values()), trace_sha256=digest.hexdigest(),
        comparisons=comparisons, order_comparison=order_comparison, checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        helpers_sha256={name: hashlib.sha256((ROOT/'tools'/name).read_bytes()).hexdigest()
                        for name in ('check_actor_group_path.py', 'check_actor_boundary_boss.py', 'check_boss_trigger.py')},
        target_rom_sha256=hashlib.sha256(target).hexdigest(), emulator=dict(package='unicorn', version=version('unicorn')),
        limits=['Both complete callbacks, the generated gate table, pickup order and absolute-value helper are freshly compiled and byte compared.',
                'Angle, animation, trigonometry, object, damage, score, retirement, sound, constructor and callback boundaries use clobbering ABI stubs.',
                'Independent arithmetic, event order, mutations, guarded state and stack/callee-saved registers are checked.',
                'Synthetic callback mutations test reloads and saved ownership; they do not claim real callees cause those changes.',
                'Signed wrapping and narrowing model pinned IDO/MIPS behavior; full gameplay and enclosing resource bounds remain unproved.'])
    output = ROOT/'build/actor-collision-execution/report.json'
    output.write_text(json.dumps(report, indent=2)+'\n')
    print('Passed collision execution:', report['cases'], counts, output, flush=True)


if __name__ == '__main__':
    main()
