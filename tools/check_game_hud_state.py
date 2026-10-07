"""Guard the complete HUD state candidate and its fifteen-word O32 call."""
import argparse
from collections import Counter
import hashlib
from importlib.metadata import version
import itertools
import json
from pathlib import Path
import sys
import tempfile

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL
from check_movie_storage import CALLER_SAVED, PRESERVED, pattern
from check_boss_trigger import fpu_code, FPU_OUT, FPU_BITS, SEED_FPU, READ_FPU
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols
from rom import ROOT, validate

ENTRY, END, CALLEE = 0x800371FC, 0x80037408, 0x8004B590
SOURCE = 'src/game/game_hud_state.c'
PLAYERS, PLAYER_SIZE, SESSION, SCENE = 0x8009B190, 3508, 0x800AD138, 0x800B9A78
CONTROL, ACTOR, STACK, FRAME = 0x800AD280, 0x80210010, 0x80300000, 248
CLOBBER = 0x80000100


def signed(value):
    return (value + 0x80000000) % 0x100000000 - 0x80000000


def run(image, case):
    clobber = word(0x3C013F80)
    clobber += b''.join(word(0x44810000 | (i << 11)) for i in range(20))
    clobber += word(0x03E00008) + word(0)
    helpers = fpu_code() + [(CLOBBER, clobber)]
    uc, write, _ = machine([(ENTRY, image)], helpers)
    uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS,
        uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | (1 << 29))
    uc.emu_start(SEED_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA57281D9)
    preserved = {r: uc.reg_read(r) for r in PRESERVED}
    panels = {}
    seed = case.get('seed', 37)
    for name, start, size in (
        ('players', PLAYERS, PLAYER_SIZE * 2), ('session', SESSION, 340),
        ('scene', SCENE, 3348), ('actor', ACTOR, 124),
        ('stack', STACK - FRAME, FRAME), ('fpu', FPU_OUT, 48),
    ):
        panels[name] = (start - 16, pattern(size + 32, seed + len(panels) * 31))

    def put(name, address, data):
        start, blob = panels[name]
        at = address - start
        assert 16 <= at and at + len(data) <= len(blob) - 16
        blob[at:at + len(data)] = data

    def iw(name, address, value):
        put(name, address, word(value))

    values = []
    for index in range(2):
        at = PLAYERS + index * PLAYER_SIZE
        data = [signed(seed * 1009 + index * 2711 + n * 193 - 250000) for n in range(5)]
        powers = (case.get('powers', 31) + index * 17) & 255
        put('players', at + 1, bytes([powers]))
        for offset, number in zip((0x18, 0x1C, 0x70, 0x74, 0x6C), data):
            iw('players', at + offset, number)
        iw('players', at + 0xD70, case.get('stored_levels', (-1, 7))[index])
        values.append((data, powers))
    mode, selected = case.get('mode', 2), case.get('selected', 0)
    animation = case.get('animation', 0)
    current_level = case.get('level', 17)
    iw('session', SESSION + 0x2C, mode)
    iw('session', SESSION + 0x30, selected)
    iw('session', SESSION + 0x80, ACTOR if animation else 0)
    iw('session', SESSION + 0x90, animation)
    put('actor', ACTOR + 0x10, (case.get('actor_level', -32768) & 65535).to_bytes(2, 'big'))
    iw('scene', SCENE + 0xCD0, current_level)
    iw('scene', SCENE + 0xCD4, case.get('resource', -1))
    iw('session', CONTROL + 4, case.get('skip', 0))
    iw('session', CONTROL + 8, case.get('state', 3))
    initial = {name: bytes(blob) for name, (_, blob) in panels.items()}
    for start, blob in panels.values():
        write(start, bytes(blob))

    expected = []
    show = case.get('skip', 0) == 0 and case.get('resource', -1) == -1 and case.get('state', 3) in (3, 4)
    if show and not case.get('invalid_index', False):
        primary = 0 if mode == 2 else selected
        data, powers = values[primary]
        level = current_level
        secondary = [0] * 6
        # Retail reads this word before writing it in single-player mode.
        uninitialized = int.from_bytes(initial['stack'][16 + 0x48:20 + 0x48], 'big')
        other_powers, count = uninitialized, 1
        if mode == 2:
            other, other_powers = values[1]
            if selected == 0:
                other_level = max(case.get('stored_levels', (-1, 7))[1], 1)
            else:
                level = max(case.get('stored_levels', (-1, 7))[0], 1)
                other_level = current_level
            secondary = [other[0], other_level, other[1], other[2], other[3], other[4]]
            count = 2
        if animation:
            level = case.get('actor_level', -32768)
        expected = [(value & 0xFFFFFFFF) for value in
            [data[0], level, data[1], data[2], data[3], data[4], powers, *secondary, other_powers, count]]
        assert len(expected) == 15

    reads = [(start + 16, start + len(blob) - 16) for name, (start, blob) in panels.items() if name != 'fpu']
    executable = [(ENTRY, ENTRY + len(image)), (CALLEE, CALLEE + 4), (SENTINEL, SENTINEL + 4)]
    executable += [(start, start + len(blob)) for start, blob in helpers]
    stage, trace, stores = ['function'], [], []

    def norm(address):
        return (address & 0x1FFFFFFF) | 0x80000000

    def inside(address, size, ranges):
        return any(first <= address and address + size <= last for first, last in ranges)

    def instruction(uc, address, size, user):
        address = norm(address)
        assert not address & 3 and inside(address, size, executable), ('HUD instruction bounds', hex(address))
        if address == CALLEE:
            actual = [uc.reg_read(getattr(regs, 'UC_MIPS_REG_A' + str(i))) for i in range(4)]
            sp = uc.reg_read(regs.UC_MIPS_REG_SP)
            actual += [int.from_bytes(uc.mem_read((sp + 16 + i * 4) & 0x1FFFFFFF, 4), 'big') for i in range(11)]
            assert show and actual == expected, ('HUD arguments', actual, expected)
            trace.append(actual)
            for i, register in enumerate(CALLER_SAVED):
                uc.reg_write(register, 0xB2340000 + i * 256)
            uc.reg_write(regs.UC_MIPS_REG_PC, CLOBBER)

    def read(uc, access, address, size, value, user):
        address = norm(address)
        assert inside(address, size, reads), ('HUD read bounds', hex(address), size, hex(uc.reg_read(regs.UC_MIPS_REG_PC)))
        if ACTOR <= address < ACTOR + 124:
            assert show and animation and address == ACTOR + 0x10 and size == 2, 'HUD actor read gate'

    def store(uc, access, address, size, value, user):
        address = norm(address)
        if stage[0] == 'observer':
            assert inside(address, size, [(FPU_OUT, FPU_OUT + 48)])
        else:
            assert inside(address, size, [(STACK - FRAME, STACK)]), ('HUD write bounds', hex(address), size)
            stores.append((address, size, value & ((1 << (size * 8)) - 1)))

    uc.hook_add(UC_HOOK_CODE, instruction)
    uc.hook_add(UC_HOOK_MEM_READ, read)
    uc.hook_add(UC_HOOK_MEM_WRITE, store)
    uc.emu_start(ENTRY, 0, count=2000)
    # The shared machine's sentinel hook stops before later code hooks run.
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, 'HUD did not return'
    assert all(uc.reg_read(r) == value for r, value in preserved.items()), 'HUD O32 preserved registers'
    assert len(trace) == int(show), ('HUD call count', case, trace)
    wanted_stores = [(STACK - FRAME + 0x44, 4, SENTINEL)]
    if mode == 2:
        wanted_stores.append((STACK - FRAME + 0x48, 4, values[1][1]))
    if show:
        for arg in (4, 5, 14, 12, 11, 10, 9, 8, 7, 13, 6):
            wanted_stores.append((STACK - FRAME + arg * 4, 4, expected[arg]))
    assert stores == wanted_stores, ('HUD ordered CPU writes', stores, wanted_stores)
    expected_stack = bytearray(initial['stack'])
    stack_start = panels['stack'][0]
    for address, size, value in stores:
        offset = address - stack_start
        expected_stack[offset:offset + size] = value.to_bytes(size, 'big')
    assert bytes(uc.mem_read(stack_start & 0x1FFFFFFF, len(expected_stack))) == expected_stack
    stage[0] = 'observer'
    uc.emu_start(READ_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    for name, (start, blob) in panels.items():
        if name == 'stack':
            continue
        expected_blob = bytearray(initial[name])
        if name == 'fpu':
            expected_blob[16:64] = b''.join(word(bits) for bits in FPU_BITS)
        assert bytes(uc.mem_read(start & 0x1FFFFFFF, len(blob))) == expected_blob, ('HUD immutable panel', name)
    return dict(trace=trace, stores=stores, stack=hashlib.sha256(expected_stack).hexdigest())


def cases():
    levels = (-0x80000000, -1, 0, 1, 7, 0x7FFFFFFF)
    for mode, selected, stored, animation, powers in itertools.product((0, 1, 2), (0, 1), levels,
        (0, 1), (0, 1, 31, 255)):
        yield dict(group='levels', mode=mode, selected=selected, stored_levels=(stored, stored),
            animation=animation, powers=powers, actor_level=(-32768, -1, 0, 1, 32767)[(stored & 255) % 5],
            level=levels[(stored & 255) % 6], seed=37 + powers)
    for skip, resource, state, mode, selected, animation in itertools.product((-1, 0, 1), (-2, -1, 0),
        (2, 3, 4, 5), (1, 2), (0, 1), (0, 1)):
        yield dict(group='gates', skip=skip, resource=resource, state=state, mode=mode,
            selected=selected, animation=animation, stored_levels=(-1, 99), seed=181)
    for seed, selected, animation in itertools.product((0, 1, 127, 255), (0, 1), (0, 1)):
        yield dict(group='stack-seeds', mode=1, seed=seed, selected=selected, animation=animation)
    for selected in (-1, 2, 0x7FFFFFFF):
        yield dict(group='two-player-selection', mode=2, selected=selected, stored_levels=(-7, 123))


MUTATIONS = {
    'fixed-selected-player': ('player = &D_8009B190[D_800AD168];', 'player = &D_8009B190[0];', dict(mode=1, selected=1)),
    'mode-selection': ('D_800AD164 == 2', 'D_800AD164 == 1', dict(mode=2)),
    'zero-level-clamp': ('D_8009CCB4 <= 0', 'D_8009CCB4 < 0', dict(mode=2, stored_levels=(0, 0))),
    'scene-gate': ('resourceCD4 == -1', 'resourceCD4 == 0', dict()),
    'display-state': ('D_800AD288 == 4', 'D_800AD288 == 5', dict(state=4)),
    'animation-short-sign': ('D_800AD1B8->value10[0]', '(unsigned short)D_800AD1B8->value10[0]', dict(animation=1, actor_level=-32768)),
    'other-stat-word': ('second.field70 = D_8009B190[1].saved.field70;', 'second.field70 = D_8009B190[1].saved.field6C;', dict()),
    'powers-byte': ('player->saved.unknown00[1]', 'player->saved.unknown00[0]', dict()),
    'player-count': ('players = 2;', 'players = 1;', dict()),
    'default-score': ('second.value18 = 0;', 'second.value18 = 1;', dict(mode=1)),
    'initialize-unused-word': ('int secondPowers;', 'int secondPowers = 0;', dict(mode=1, seed=37)),
}


def compile_image(name, source, target, layout, exact=False):
    report = compare_block(name, source, ENTRY, ENTRY - 0x7FFFF400, END - 0x7FFFF400,
        target, 'hud-state-check', layout)
    directory = ROOT / 'build/hud-state-check' / name
    sections, symbols = elf_sections_and_symbols(directory / (name + '.elf'))
    if exact:
        assert report['matches'] and report['actual_size'] == 524
        assert symbols['func_800371FC']['size'] == 524
        assert not {name: row['size'] for name, row in sections.items()
            if row['size'] and row['flags'] & 2 and name not in ('.text', '.reginfo', '.MIPS.abiflags')}
    return (directory / (name + '.bin')).read_bytes(), report


def main(mutations=False):
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, report = compile_image('game_hud_state', SOURCE, target, layout, exact=True)
    retail = target[ENTRY - 0x7FFFF400:END - 0x7FFFF400]
    counts, digest = Counter(), hashlib.sha256()
    for case in cases():
        expected, actual = run(retail, case), run(compiled, case)
        assert actual == expected, ('HUD retail execution', case)
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
        counts['cases'] += 1
        counts[case['group']] += 1
        if counts['cases'] % 250 == 0:
            print('Compared', counts['cases'], 'paired HUD state cases.', flush=True)
    bounds = []
    for selected in (-1, 2):
        for name, image in (('retail', retail), ('compiled', compiled)):
            try:
                run(image, dict(mode=1, selected=selected, invalid_index=True))
            except AssertionError as error:
                assert 'HUD read bounds' in str(error), str(error)
                bounds.append(dict(image=name, selected=selected, rejection=str(error)))
            else:
                raise AssertionError('Out-of-pool player read escaped the guard')
    controls = []
    if mutations:
        base = (ROOT / SOURCE).read_text()
        with tempfile.TemporaryDirectory(prefix='hud-controls-', dir=ROOT / '.local/tool-continuation') as temporary:
            for name, (old, new, case) in MUTATIONS.items():
                assert old in base, name
                path = Path(temporary) / (name + '.c')
                path.write_text(base.replace(old, new).replace('../../include/', '../../../include/'))
                image, result = compile_image(name, path.relative_to(ROOT).as_posix(), target, layout)
                try:
                    run(image, case)
                except AssertionError as error:
                    controls.append(dict(name=name, rejected=True, reason=str(error)[:500],
                        compiled_bytes=result['actual_size']))
                else:
                    raise AssertionError('HUD source mutation escaped: ' + name)
    layout.verify()
    output = ROOT / 'build/hud-state-check/report.json'
    output.write_text(json.dumps(dict(matches=True, counts=dict(counts), comparisons={'game_hud_state': report},
        execution_sha256=digest.hexdigest(), checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        target_sha256=hashlib.sha256(target).hexdigest(), bounds_controls=bounds, source_controls=controls,
        emulator=dict(package='unicorn', version=version('unicorn')),
        limits=['One complete source and retail procedure execute; the HUD drawing callee is a recorded fifteen-word ABI boundary.',
            'No rendering, framebuffer, gameplay or hardware behavior is claimed.',
            'The historical uninitialized single-player second-powers word is seeded and compared; it is not initialized by reconstructed source.',
            'Two complete player records, the session, scene, controls, actor and guards remain unchanged; writes are restricted to the verified 248-byte frame.',
            'The boundary clobbers caller-saved integer, HI/LO and F0 through F19 state; O32 preserved registers and F20 through F31 are checked.']), indent=2) + '\n')
    print('Passed HUD state execution:', dict(counts), '; source controls:', len(controls), '; bounds controls:', len(bounds), flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mutations', action='store_true')
    main(parser.parse_args().mutations)
