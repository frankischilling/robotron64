"""Audit complete arrival-update code and call boundaries against retail.

Matching clear and random helpers execute. Constructor, position-selection,
sound, callback and fatal calls use explicit returning O32 observers. This
checks the update function's decisions and caller-visible effects, not the
callee implementations or unrestricted gameplay. The candidate is excluded.
"""
from pathlib import Path
import hashlib, json, re, struct, subprocess, tempfile
import random
from importlib.metadata import version
import scene_arrival_update_model as m
from rom import ROOT, validate
from compiler import compile_source, profile_for_source
from toolchain import installed_identity
from trim_padding import trim
from compare_startup import external_assignments, comparison_input_hashes
from manifest import load_manifest
from check_actor_group_path import machine, word, SENTINEL
from check_movie_storage import PRESERVED, CALLER_SAVED, pattern
from check_boss_trigger import fpu_code, SEED_FPU, READ_FPU, FPU_OUT, FPU_BITS
from check_scene_arrivals import compile_image, frame
from compare_startup import SymbolLayoutSnapshot
from compare_runtime import MATCHING_BLOCKS
from owned_sections import elf_sections_and_symbols
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UcError
from unicorn import mips_const as regs
ENTRY, CLOBBER, STACK = (0x80020134, 0x80000100, 0x80300000)
SOURCE = 'src/game/scene_arrivals/update.c'
FAMILY = 'scene-arrival-update-audit'

def compile_candidate(source, name, target, layout):
    inputs = comparison_input_hashes(source)
    out = ROOT / 'build' / FAMILY / name
    out.mkdir(parents=True, exist_ok=True)
    raw, obj, elf = (out / (name + suffix) for suffix in ('.raw.o', '.o', '.elf'))
    compile_source(source, raw)
    sections, symbols = elf_sections_and_symbols(raw)
    natural = symbols['func_80020134']['size']
    assert natural > 0 and symbols['func_80020134']['value'] == 0
    assert not any(sections['.text']['bytes'][natural:]), 'Live update code tail'
    assert sections['.rodata']['size'] >= 132 and (not any(sections['.rodata']['bytes'][132:])), 'Live update table tail'
    assert all((not sections.get(k, {}).get('size', 0) for k in ('.data', '.bss'))), 'Unowned update allocation'
    obj.write_bytes(trim(trim(raw.read_bytes(), '.text', natural), '.rodata', 132))
    undefined = {line.split()[-1] for line in subprocess.check_output(['mips-linux-gnu-nm', '-u', str(obj)], text=True).splitlines() if line.strip()}
    ld = out / 'candidate.ld'
    ld.write_text(external_assignments(undefined, layout.addresses) + 'SECTIONS { .text 0x80020134 : SUBALIGN(4) { *(.text) } .rodata 0x80091960 : SUBALIGN(4) { *(.rodata) } /DISCARD/ : { *(.reginfo .MIPS.abiflags) } }\n')
    subprocess.run(['mips-linux-gnu-ld', '-T', str(ld), '-e', 'func_80020134', '-o', str(elf), str(obj)], check=True)
    sections, _ = elf_sections_and_symbols(elf)
    code = sections['.text']['bytes']
    table = sections['.rodata']['bytes']
    retail = target[0x20D34:0x21B24]
    retail_table = target[0x92560:0x925E4]
    assert len(code) == natural and len(table) == 132
    report = dict(source=source, natural_instruction_bytes=natural, retail_instruction_bytes=3568, candidate_frame=frame(code), retail_frame=288, different_words=sum((retail[i:i + 4] != code[i:i + 4] for i in range(0, max(len(retail), len(code)), 4))), different_table_words=sum((retail_table[i:i + 4] != table[i:i + 4] for i in range(0, 132, 4))), matches=code == retail and table == retail_table, inputs_sha256=inputs, compiler_profile=profile_for_source(source), toolchain_identity=installed_identity(profile_for_source(source)['version']))
    for path, sha in inputs.items():
        assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == sha, path
    layout.verify()
    return (code, table, report)

def norm(address):
    return address & 0x1FFFFFFF | 0x80000000

def inside(address, size, ranges):
    return any((start <= address and address + size <= end for start, end in ranges))
STUBS = (m.NORMAL, m.BOSS, m.SCENE_CREATE, m.TEXT_CREATE, m.OTHER_CREATE, m.POSITION, m.SOUND_CALL, m.FATAL, m.CALLBACK)

def run(code, tables, helpers, constants, case, fault=None):
    panels = m.prepare(case)
    expected, events, total, draws = m.model(case, panels)
    clobber = word(0x3C013F80) + b''.join((word(0x44810000 | i << 11) for i in range(20))) + word(0x3E00008) + word(0)
    if fault == 'dispatch_table':
        tables = word(ENTRY + len(code) - 8) + tables[4:]
    elif fault:
        clobber = word({'saved_integer': 0x24170000, 'saved_fpu': 0x4480A000, 'read_guard': 0x8C025000, 'write_guard': 0xAC005000, 'code_guard': 0x80001C0, 'stack_guard': 0xAFA0F000}[fault]) + word(0) + clobber
    uc, write, _ = machine([(ENTRY, code)], helpers + list(constants.items()) + [(0x80091960, tables), (CLOBBER, clobber)] + [(address, word(0)) for address in STUBS] + fpu_code())
    uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS, uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | 1 << 29)
    uc.emu_start(SEED_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA57281D9)
    saved = {r: uc.reg_read(r) for r in PRESERVED}
    extent = frame(code) + 512
    panels['stack'] = (STACK - extent, bytes(pattern(extent + 32, 193)))
    panels['fpu'] = (FPU_OUT, bytes(pattern(48, 211)))
    initial = {}
    intervals = sorted(((address - 16, address + len(blob) + 16, name) for name, (address, blob) in panels.items()))
    for left, right in zip(intervals, intervals[1:]):
        assert left[1] <= right[0], ('Fixture panel overlap', left, right)
    for name, (address, blob) in panels.items():
        initial[name] = b'\xa7' * 16 + blob + b'\xb9' * 16
        write(address - 16, initial[name])
    readable = [(a, a + len(b)) for a, b in panels.values()] + [(0x80091960, 0x80091960 + len(tables))] + [(a, a + len(b)) for a, b in constants.items()]
    executable = [(ENTRY, ENTRY + len(code)), (SENTINEL, SENTINEL + 4), (CLOBBER, CLOBBER + len(clobber))] + [(a, a + len(b)) for a, b in helpers + fpu_code()] + [(a, a + 4) for a in STUBS]
    writable = [(STACK - extent, STACK), (m.SCENE, m.SCENE + 3348), (m.LAST, m.LAST + 4), (m.SOUND, m.SOUND + 4), (m.SEED, m.SEED + 4)]
    seen = []
    attempt = 0
    position_attempt = 0
    random_calls = 0
    observer = False
    observer_saved = None
    current_frame = frame(code)

    def position(address):
        a = norm(address)
        assert inside(a, 12, [(STACK - current_frame, STACK)]), 'Position argument bounds'
        return struct.unpack('>iii', bytes(uc.mem_read(a & 0x1FFFFFFF, 12)))

    def args(count):
        return tuple((uc.reg_read(getattr(regs, 'UC_MIPS_REG_A' + str(i))) for i in range(count)))

    def code_hook(uc, address, size, _):
        nonlocal attempt, position_attempt, random_calls, observer_saved
        address = norm(address)
        assert inside(address, size, executable), ('Update code guard', hex(address))
        if address == CLOBBER + len(clobber) - 8:
            assert observer_saved is not None, 'Observed callee return without entry'
            assert all(uc.reg_read(register) == value for register, value in observer_saved.items()), 'Observed callee saved integer registers'
            observer_saved = None
        if address == 0x8004CDE8:
            random_calls += 1
        if address not in STUBS:
            return
        assert observer_saved is None, 'Nested returning observer'
        observer_saved = {register: uc.reg_read(register) for register in PRESERVED}
        result = 0
        if address == m.NORMAL:
            kind, p, parent = args(3)
            event = (address, (kind, position(p), parent))
            choices = case.get('spawn_success', [True])
            result = m.BORN if choices[attempt % len(choices)] else 0
            attempt += 1
        elif address == m.BOSS:
            kind, p, phase = args(3)
            event = (address, (kind, position(p), m.signed(phase)))
            choices = case.get('spawn_success', [True])
            result = m.BORN if choices[attempt % len(choices)] else 0
            attempt += 1
        elif address in (m.SCENE_CREATE, m.TEXT_CREATE):
            resource, p = args(2)
            event = (address, (resource, position(p)))
            choices = case.get('spawn_success', [True])
            result = m.BORN if choices[attempt % len(choices)] else 0
            attempt += 1
        elif address == m.OTHER_CREATE:
            cat, resource, p = args(3)
            event = (address, (cat, resource, position(p)))
            choices = case.get('spawn_success', [True])
            result = m.BORN if choices[attempt % len(choices)] else 0
            attempt += 1
        elif address == m.POSITION:
            p, axes, spacing = args(3)
            event = (address, (position(p), axes, spacing))
            choices = case.get('position_success', [True])
            result = int(choices[position_attempt % len(choices)])
            position_attempt += 1
            if result:
                uc.mem_write(p & 0x1FFFFFFF, struct.pack('>iii', *case.get('position_result', [257, -513, 0])))
        elif address == m.SOUND_CALL:
            event = (address, args(4))
        elif address == m.CALLBACK:
            event = (address, args(2))
        elif address == m.FATAL:
            format_address = uc.reg_read(regs.UC_MIPS_REG_A0)
            event = (address, args(1 if format_address == 0x80091834 else 2))
        seen.append(event)
        for i, r in enumerate(CALLER_SAVED):
            uc.reg_write(r, 0xB2340000 + i * 256)
        uc.reg_write(regs.UC_MIPS_REG_V0, result)
        uc.reg_write(regs.UC_MIPS_REG_PC, CLOBBER)

    def read_hook(uc, access, address, size, value, _):
        address = norm(address)
        assert inside(address, size, readable), ('Update read guard', hex(address), size)
        if 0x80091960 <= address < 0x800919E4:
            assert size == 4 and address % 4 == 0, 'Update dispatch width'
        elif m.BORN_RESOURCE <= address < m.BORN_RESOURCE + 88:
            assert (address - m.BORN_RESOURCE, size) == (84, 4), 'Callback field width'
        elif m.BORN <= address < m.BORN + 124:
            assert (address - m.BORN, size) == (36, 4), 'Callback actor field width'
        elif m.SCENE <= address < m.SCENE + m.SCENE_SIZE:
            if address == m.SCENE + 0xCC8:
                assert size == 4, 'Arrival count width'
            else:
                index, field = divmod(address - m.SCENE - 0x44, 12)
                assert 0 <= index < len(case.get('arrivals', []))
                assert (field, size) in ((0, 1), (1, 1), (2, 1), (3, 1),
                                       (4, 2), (6, 2), (8, 2), (10, 2)), 'Arrival read width'
        elif m.SESSION <= address < m.SESSION + 328:
            offset = address - m.SESSION
            fields = {(0x30, 4), (0x38, 4), (0x3C, 4), (0x68, 4), (0x90, 4)}
            fields.update((start + 2 * i, 2) for start, count in
                          ((0xB8, 5), (0x100, 8), (0x110, 11), (0x126, 16))
                          for i in range(count))
            assert (offset, size) in fields, 'Session field width'
        elif m.PLAYERS <= address < m.PLAYERS + 3508 * 2:
            assert ((address - m.PLAYERS) % 3508, size) in ((0x1C, 4), (0x24, 4), (0x9C, 4)), 'Player field width'
        elif m.DEFAULTS <= address < m.DEFAULTS + m.DEFAULT_STRIDE * 36:
            assert ((address - m.DEFAULTS) % m.DEFAULT_STRIDE, size) == (0x64, 4), 'Default delay width'
        elif m.POOL <= address < m.HEAD:
            assert ((address - m.POOL) % m.STRIDE, size) in ((0x24, 4), (0x78, 4)), 'Census actor field width'
        elif m.ACTOR_RESOURCES <= address < m.ACTOR_RESOURCES + m.RESOURCE_STRIDE * 200:
            assert ((address - m.ACTOR_RESOURCES) % m.RESOURCE_STRIDE, size) in ((0, 1), (2, 1)), 'Census resource width'
        elif address == m.LIMITS or address == m.LIMITS + 2:
            assert (address - m.LIMITS, size) in ((0, 4), (2, 2)), 'Limit flag width'
        elif address in (m.HEAD, m.LAST, m.CLOCK, m.OLD_DELAY, m.SOUND, m.ACTIVE, m.ENABLED, m.RATE, m.SEED):
            assert size == 4, 'Update global scalar width'

    def write_hook(uc, access, address, size, value, _):
        address = norm(address)
        allowed = [(FPU_OUT, FPU_OUT + 48)] if observer else writable
        assert inside(address, size, allowed), ('Update write guard', hex(address), size)
        if not observer and address in (m.LAST, m.SOUND, m.SEED):
            assert size == 4, 'Update global store width'
        if not observer and m.SCENE <= address < m.SCENE + 3348:
            offset = address - m.SCENE - 68
            index, field = divmod(offset, 12)
            assert 0 <= index < len(case.get('arrivals', [])) and (field, size) in ((1, 1), (4, 2), (6, 2)), ('Arrival store width', index, field, size)
    uc.hook_add(UC_HOOK_CODE, code_hook)
    uc.hook_add(UC_HOOK_MEM_READ, read_hook)
    uc.hook_add(UC_HOOK_MEM_WRITE, write_hook)
    uc.emu_start(ENTRY, 0, count=500000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, 'Update instruction bound'
    assert observer_saved is None, 'Observed callee did not return'
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == total & 0xFFFFFFFF, ('Update total', total, uc.reg_read(regs.UC_MIPS_REG_V0))
    assert seen == events, ('Update boundary events', seen, events, case)
    assert random_calls == draws, 'Update RNG calls'
    assert all((uc.reg_read(r) == v for r, v in saved.items())), 'Update saved integer registers'
    for name, blob in expected.items():
        assert bytes(uc.mem_read(panels[name][0] & 0x1FFFFFFF, len(blob))) == blob, ('Update complete panel', name, case)
    observer = True
    uc.emu_start(READ_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    assert bytes(uc.mem_read(FPU_OUT & 0x1FFFFFFF, 48)) == b''.join((word(v) for v in FPU_BITS)), 'Update saved FPU registers'
    for name, (address, blob) in panels.items():
        actual = bytes(uc.mem_read(address - 16 & 0x1FFFFFFF, len(blob) + 32))
        assert actual[:16] == initial[name][:16] and actual[-16:] == initial[name][-16:], ('Update canary', name)
    assert bytes(uc.mem_read(STACK & 0x1FFFFFFF, 32)) == panels['stack'][1][-32:], 'Update immutable caller homes'
    return hashlib.sha256(b''.join((expected[k] for k in sorted(expected))) + json.dumps(events).encode()).hexdigest()

def cases():
    cases = []
    for category, limit in ((0, 36), (1, 16), (3, 8), (7, 11), (8, 4), (9, 244)):
        for resource in range(limit):
            for count, success in ((1, True), (3, True), (2, False)):
                cases.append(dict(arrivals=[dict(category=category, resource=resource, count=count)], spawn_success=[success]))
    for trigger in range(6):
        for elapsed in (0, 499, 500, 501, 999, 1000, 1001, 2000, 0xFFFFFFFF):
            for delay in (-0x8000, -2, -1, 0, 1, 2, 7, 20, 32767):
                if trigger == 4 and delay == 0:
                    continue
                cases.append(dict(clock=elapsed, arrivals=[dict(trigger=trigger, delay=delay, resource=25, count=3)], scores=[2001, 2001]))
    for x in (-0x8000, -257, -1, 0, 1, 32767):
        for y in (-0x8000, -257, -1, 0, 1, 32767):
            for success in (False, True):
                cases.append(dict(arrivals=[dict(x=x, y=y)], position_success=[success]))
    for active in (0, 46, 47, 48, 49, 50, 51):
        for trigger in (0, 1, 2, 4, 5):
            cases.append(dict(active=active, arrivals=[dict(trigger=trigger, delay=2, count=3)]))
    for category, limit in ((0, 36), (1, 16), (3, 8), (7, 11), (8, 4), (9, 244)):
        cases.append(dict(arrivals=[dict(category=category, resource=0, count=2), dict(state=2, category=category, resource=min(1, limit - 1), trigger=1, delay=1, count=1), dict(state=2, category=category, resource=0, trigger=1, count=1)], spawn_success=[True, False, True]))
    # Every conditional trigger-3 branch has passing and failing fixtures.
    for delay in range(7):
        for player in (0, 1):
            for clock in (1000, 1001, 2000):
                for value in (-1, 0, 1, 2000, 2001):
                    scene = [0] * 8
                    scene[7] = value
                    behavior = [0] * 36
                    behavior[4] = value
                    cases.append(dict(player=player, clock=clock, scores=[value, value],
                        choice0=1, choice1=0, active_players=[value, value],
                        scene_counts=scene, behavior=behavior, player_present=value,
                        flags=0x20000000 | (value & 0xFFFF),
                        arrivals=[dict(trigger=3, delay=delay)]))
    for category, count, key in ((1, 16, 'text_counts'), (3, 8, 'scene_counts'), (7, 11, 'other_counts')):
        for kind in range(count):
            for value in (-0x8000, -1, 0, 1, 32767):
                counters = [0] * count
                counters[kind] = value
                for trigger in (0, 2):
                    cases.append({key: counters, 'arrivals': [dict(category=category,
                        resource=kind, trigger=trigger, delay=1, count=3)]})
    for kind in range(36):
        for category in (0, 1):
            cases.append(dict(actors=[dict(slot=199, kind=kind, resource_category=category)],
                arrivals=[dict(resource=kind, trigger=2, delay=1, count=3)]))
    for kind in range(25, 29):
        for sound in (0, 1):
            for success in (False, True):
                cases.append(dict(sound=sound, arrivals=[dict(resource=kind, trigger=1,
                    delay=(1200 + kind * 100) // 100, count=2)], spawn_success=[success]))
    for seed in (0, 1, 174823885, 0xFFFFFFFF):
        for rate in (0, 1, 10, 100, -1):
            for delay in (-0x8000, -1, 1, 2, 32767):
                cases.append(dict(seed=seed, rate=rate, arrivals=[dict(trigger=4, delay=delay)]))
    for state in (0, 2, 3, 255):
        for category in range(256):
            cases.append(dict(arrivals=[dict(state=state, category=category, count=-1)]))
    # Deterministic mixed lists exercise census totals, cascades and repeated calls.
    rng = random.Random(0x20134)
    for _ in range(128):
        records = []
        for _ in range(rng.randrange(1, 17)):
            category, limit = rng.choice(((0, 36), (1, 16), (3, 8), (7, 11), (8, 4), (9, 244)))
            records.append(dict(category=category, resource=rng.randrange(limit),
                state=rng.choice((0, 1, 2)), trigger=rng.randrange(6),
                delay=rng.choice((-2, -1, 1, 2, 6, 7, 20)), count=rng.randrange(-1, 5),
                x=rng.choice((-1, 0, 257)), y=rng.choice((-1, 0, -257))))
        cases.append(dict(arrivals=records, actors=[dict(slot=i, kind=rng.randrange(36),
            resource_category=rng.randrange(2)) for i in range(rng.randrange(16))],
            clock=rng.choice((0, 500, 501, 1000, 1001, 2000, 0xFFFFFFFF)),
            timestamp=rng.choice((0, 1, 0xFFFFFFFF)), active=rng.randrange(45, 52),
            spawn_success=[False, True, True], position_success=[True, False], rate=100))
    return cases

MUTATIONS = (
    ('position-axis', 'arrival->x == -1 && arrival->x == -1', 'arrival->x == -1 && arrival->y == -1',
     dict(arrivals=[dict(x=-1, y=257)])),
    ('capacity', 'arrival->count + D_800C8B7C < 50', 'arrival->count + D_800C8B7C <= 50',
     dict(active=47, arrivals=[dict(trigger=1, count=3)])),
    ('spacing', 'elapsed >= 501U', 'elapsed >= 500U',
     dict(clock=500, arrivals=[dict(x=-1, y=-1)])),
    ('score-trigger', '>= 2001', '>= 2000',
     dict(scores=[2000, 2000], arrivals=[dict(trigger=3, delay=0)])),
    ('callback-state', ')(actor, 1);', ')(actor, 0);',
     dict(arrivals=[dict(category=0)])),
    ('count-down', 'arrival->count--', 'arrival->count++',
     dict(arrivals=[dict(trigger=1, count=3)])),
    ('cascade-time', '/ 100U;', '/ 101U;',
     dict(clock=10000, arrivals=[dict(count=1), dict(state=2, trigger=1, count=2)])),
    ('scene-census', 'activeSceneActors + 8', 'activeSceneActors + 7',
     dict(scene_counts=[0]*7+[1], arrivals=[dict(trigger=3, delay=2)])),
    ('normal-census', 'kind != 33 && kind != 34', 'kind != 32 && kind != 34',
     dict(actors=[dict(slot=0, kind=32)], arrivals=[])),
)

def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    blocks = {name: (source, start, end) for name, source, start, end in MATCHING_BLOCKS}
    helpers = []
    constants = {}
    support = {}
    checker_hash = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    model_hash = hashlib.sha256((ROOT / 'tools/scene_arrival_update_model.py').read_bytes()).hexdigest()
    for name in ('game_memory', 'runtime_random', 'gu_random'):
        source, start, end = blocks[name]
        report, code, data = compile_image('update_' + name, source, start, end, target, layout)
        assert report['matches']
        helpers.append((start, code))
        constants.update(data)
        support[name] = report
    candidate, candidate_table, comparison = compile_candidate(SOURCE, 'candidate', target, layout)
    corpus = cases()
    digests = []
    for i, case in enumerate(corpus):
        a = run(target[0x20D34:0x21B24], target[0x92560:0x925E4], helpers, constants, case)
        b = run(candidate, candidate_table, helpers, constants, case)
        assert a == b
        digests.append(b)
        if i % 200 == 0:
            print('Arrival-update pair', i + 1, '/', len(corpus), flush=True)
    controls = {}
    fault_case = dict(arrivals=[dict(x=-1, y=-1)])
    body = (ROOT / SOURCE).read_text()
    out = ROOT / 'build' / FAMILY
    with tempfile.TemporaryDirectory(prefix='mutations-', dir=out) as directory:
        for name, before, after, case in MUTATIONS:
            assert before in body, ('Update mutation site', name)
            run(target[0x20D34:0x21B24], target[0x92560:0x925E4], helpers, constants, case)
            run(candidate, candidate_table, helpers, constants, case)
            source = re.sub(r'#include "([^"]+)"', lambda match:
                '#include "' + str((ROOT / SOURCE).parent.joinpath(match[1]).resolve()) + '"',
                body.replace(before, after))
            path = Path(directory) / (name + '.c')
            path.write_text(source)
            code, table, _ = compile_candidate(path.relative_to(ROOT).as_posix(), 'mutant_' + name, target, layout)
            try:
                run(code, table, helpers, constants, case)
            except (AssertionError, UcError) as error:
                controls[name] = dict(rejected=True, reason=str(error))
            else:
                raise AssertionError(('Update accepted mutation', name))
            run(candidate, candidate_table, helpers, constants, case)
    for fault in ('saved_integer', 'saved_fpu', 'read_guard', 'write_guard', 'code_guard', 'stack_guard', 'dispatch_table'):
        run(candidate, candidate_table, helpers, constants, fault_case)
        try:
            run(candidate, candidate_table, helpers, constants, fault_case, fault)
        except (AssertionError, UcError) as error:
            controls[fault] = dict(rejected=True, reason=str(error))
        else:
            raise AssertionError(('Update accepted guest fault', fault))
        run(candidate, candidate_table, helpers, constants, fault_case)
    layout.verify()
    assert hashlib.sha256(Path(__file__).read_bytes()).hexdigest() == checker_hash
    assert hashlib.sha256((ROOT / 'tools/scene_arrival_update_model.py').read_bytes()).hexdigest() == model_hash
    for report in [comparison] + list(support.values()):
        for path, sha in report['inputs_sha256'].items():
            assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == sha, path
    claimed = any((f['name'] == 'func_80020134' and f['source'] == SOURCE for f in load_manifest()))
    record = dict(comparison=comparison, paired_cases=len(corpus), executions=2 * len(corpus), all_pairs_passed=True, negative_controls=controls, support_comparisons=support, matching_source_claim=claimed and comparison['matches'], source_ownership_added=0, model_sha256=model_hash, checker_sha256=checker_hash, case_corpus_sha256=hashlib.sha256(json.dumps(corpus, sort_keys=True).encode()).hexdigest(), outcomes_sha256=hashlib.sha256(''.join(digests).encode()).hexdigest(), versions={name: version(name) for name in ('unicorn', 'capstone', 'pyelftools')}, limits=['Constructors, position selection, callbacks, sound and fatal handling are explicit returning ABI observers; their internal game-world effects are not proved.', 'Real matching memory-clear and RNG helpers execute. Saved integer/FPU registers, complete panels, scalar stores, code/memory/stack guards and caller homes are checked.', 'Valid acyclic actor lists and resource indices are used. Invalid state-1 categories and zero modulo divisors are excluded.', 'Complete code and dispatch bytes still differ; no matching source or unrestricted gameplay claim.'])
    (ROOT / 'build' / FAMILY / 'report.json').write_text(json.dumps(record, indent=2) + '\n')
    print('Arrival-update audit passed', len(corpus), 'pairs;', len(controls), 'controls;', comparison['different_words'], 'code words differ', flush=True)
if __name__ == '__main__':
    main()
