"""Guard the six source-owned angle constants with real setters and getters."""
import hashlib
import itertools
import json
import math
from pathlib import Path
import struct
import subprocess
import tempfile
from importlib.metadata import version

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UC_MEM_WRITE, UcError, UC_ERR_EXCEPTION
from unicorn import mips_const as regs
from check_actor_group_path import machine, SENTINEL, word
from check_movie_storage import pattern, PRESERVED
from check_boss_trigger import fpu_code, FPU_OUT, FPU_BITS, SEED_FPU, READ_FPU
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from compare_data import compare_unit, comparison_directory
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate

POOL, TRANSFORM, STACK = 0x800BF918, 0x80210010, 0x80300000
SETTERS = (0x800396F4, 0x80039514, 0x80039740)
GETTERS = (0x80039A90, 0x80039B00, 0x80039B74)
FLOATS = (0x80094C24, 0x80094C20, 0x80094C28)
DOUBLES = (0x80094C30, 0x80094C38, 0x80094C40)
SOURCES = ('src/game/object_angle_setter_constants.c', 'src/game/object_angle_getter_constants.c')
ENTRY, END = 0x800394C0, 0x80039C78


def signed(value):
    return ((value + 0x80000000) & 0xFFFFFFFF) - 0x80000000


def single(value):
    return struct.unpack('>f', struct.pack('>f', value))[0]


def scalar(data, address, kind):
    size = struct.calcsize('>' + kind)
    for start, payload in data:
        if start <= address and address + size <= start + len(payload):
            return struct.unpack_from('>' + kind, payload, address - start)[0]
    raise AssertionError(('Constant extent', hex(address), size))


def constant_images(data, profile):
    images = [(address, bytearray(payload)) for address, payload in data]
    if profile:
        index = profile - 1
        address = (FLOATS + DOUBLES)[index]
        replacement = struct.pack('>f' if index < 3 else '>d', 3.0)
        for start, payload in images:
            if start <= address and address + len(replacement) <= start + len(payload):
                payload[address - start:address - start + len(replacement)] = replacement
                break
        else:
            raise AssertionError('Missing live constant')
    return [(address, bytes(payload)) for address, payload in images]


def prepare():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    _, source, start, end = next(row for row in MATCHING_BLOCKS if row[0] == 'object_transforms')
    comparison = compare_block('object_transforms', source, start, start - 0x7FFFF400,
        end - 0x7FFFF400, target, family='object-angle-constants-check', layout=layout)
    assert comparison['matches'] and comparison['actual_size'] == 1976
    directory = ROOT / 'build/object-angle-constants-check/object_transforms'
    compiled = (directory / 'object_transforms.bin').read_bytes()
    retail = target[start - 0x7FFFF400:end - 0x7FFFF400]
    data, reports = [], {}
    for source in SOURCES + ('src/game/object_storage/records.c',):
        records = source_sections(source)
        report = compare_unit(source, records, target, layout)
        assert report['matches']
        sections, _ = elf_sections_and_symbols(comparison_directory(source) / 'compiled.elf')
        for record in records:
            if record['rom'] is not None:
                payload = sections[record['section']]['bytes']
                assert payload == target[record['rom']:record['rom'] + record['size']]
                data.append((record['vram'], payload))
        reports[source] = report
    assert sum(len(payload) for _, payload in data) == 36
    assert all(scalar(data, address, 'f') == single(3.141592) for address in FLOATS)
    assert all(scalar(data, address, 'd') == 3.13159 for address in DOUBLES)
    return layout, retail, compiled, data, reports, comparison


def run(code, constants, case, negative=False, oracle_constants=None):
    axis, obj, local, profile, mode, value = case
    data = constant_images(constants, profile)
    expected_data = constant_images(constants if oracle_constants is None else oracle_constants, profile)
    uc, write, _ = machine([(ENTRY, code)], data + fpu_code())
    uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS,
        uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | (1 << 29))
    uc.emu_start(SEED_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    uc.reg_write(regs.UC_MIPS_REG_GP, 0x9137AC59)
    saved = {r: uc.reg_read(r) for r in PRESERVED}
    record = POOL + obj * 120
    transform = record + 0x1C if local else TRANSFORM
    pool, extra = pattern(36032, axis * 19 + profile), pattern(60, obj + 31)
    pool[16 + obj * 120 + 0x18:20 + obj * 120 + 0x18] = word(transform)
    images = [(POOL - 16, pool), (TRANSFORM - 16, extra)]

    def put(address, payload):
        for at, panel in images:
            if at <= address and address + len(payload) <= at + len(panel):
                panel[address - at:address - at + len(payload)] = payload
                return
        raise AssertionError(('Fixture bounds', hex(address)))

    if mode == 'getter':
        put(transform + 4 + axis * 4, struct.pack('>f', value))
    for at, panel in images:
        write(at, bytes(panel))
    setter = mode != 'getter'
    if setter:
        adjusted = signed(value - 1024) if axis == 1 else value
        angle = single(single(single(float(adjusted)) * scalar(expected_data, FLOATS[axis], 'f')) / 2048.0)
        put(transform + 4 + axis * 4, struct.pack('>f', angle))
        put(record + 0x48 + axis * 4, word(((1024 - value) if axis == 1 else value) & 0xFFD))
    else:
        angle = single(value)
    getter = mode != 'setter-only'
    result = None
    if getter:
        result = math.trunc(single(angle * 2048.0) / scalar(expected_data, DOUBLES[axis], 'd'))
        assert -0x80000000 <= result < 0x80000000, ('Outside integer conversion domain', case)
        result = (signed(result + 1024) if axis == 1 else result) & 4095
    boundary = negative if isinstance(negative, str) else None
    argument = obj
    if boundary == 'object-negative': argument = -1
    elif boundary == 'object-overrun': argument = 300
    elif boundary == 'null-transform': write(record + 0x18, word(0))
    elif boundary == 'unaligned-transform': write(record + 0x18, word(transform + 1))
    elif boundary == 'short-transform': write(record + 0x18, word(TRANSFORM + 28))
    stack_before = bytes(pattern(320, 211))
    write(STACK - 256, stack_before)
    reads = [(POOL, POOL + 36000), (transform, transform + 28), (STACK - 256, STACK + 16)]
    reads += [(address, address + len(payload)) for address, payload in data]
    writes = [(record, record + 120), (transform, transform + 28), (STACK - 256, STACK)]

    def access(uc, kind, address, size, value, user):
        address = (address & 0x1FFFFFFF) | 0x80000000
        ranges = writes if kind == UC_MEM_WRITE else reads
        assert any(start <= address and address + size <= end for start, end in ranges), (
            'Access bounds', hex(address), size, case, boundary)

    def instruction(uc, address, size, user):
        assert ENTRY <= address and address + 4 <= END or address == SENTINEL, (
            'Instruction bounds', hex(address))

    handles = [uc.hook_add(UC_HOOK_MEM_READ | UC_HOOK_MEM_WRITE, access), uc.hook_add(UC_HOOK_CODE, instruction)]
    for entry in ([SETTERS[axis]] if setter else []) + ([GETTERS[axis]] if getter else []):
        uc.reg_write(regs.UC_MIPS_REG_A0, argument & 0xFFFFFFFF)
        uc.reg_write(regs.UC_MIPS_REG_A1, value & 0xFFFFFFFF if setter else 0xB9371845)
        uc.reg_write(regs.UC_MIPS_REG_RA, SENTINEL)
        uc.emu_start(entry, 0, count=3000)
        assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, 'Instruction budget'
        assert all(uc.reg_read(r) == v for r, v in saved.items()), ('Preserved integer ABI', case)
        for at, panel in images:
            assert bytes(uc.mem_read(at & 0x1FFFFFFF, len(panel))) == bytes(panel), (
                'Full memory oracle', hex(at), case)
    if getter:
        assert uc.reg_read(regs.UC_MIPS_REG_V0) == result, ('Getter arithmetic oracle', case,
            uc.reg_read(regs.UC_MIPS_REG_V0), result)
    for handle in handles:
        uc.hook_del(handle)
    assert bytes(uc.mem_read((STACK - 256) & 0x1FFFFFFF, 320)) == stack_before, 'Leaf stack canaries'
    for address, payload in data:
        assert bytes(uc.mem_read(address & 0x1FFFFFFF, len(payload))) == payload, 'Constant write'
    uc.emu_start(READ_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    assert bytes(uc.mem_read(FPU_OUT & 0x1FFFFFFF, 48)) == b''.join(word(x) for x in FPU_BITS), 'Preserved floating ABI'
    return hashlib.sha256(b''.join(bytes(panel) for _, panel in images) +
        word(result or 0) + b''.join(payload for _, payload in data)).hexdigest()


def cases():
    angles = (-32768, -4096, -1024, -1, 0, 1, 1023, 1024, 1025, 4095, 4096, 32767, 1000000)
    values = (-1000000.0, -3.141592, -1.0, -0.0, 0.0, 0.125, 3.141592, 1000000.0)
    for axis, obj, local, profile in itertools.product(range(3), (0, 17, 299), (False, True), range(7)):
        for angle in angles: yield axis, obj, local, profile, 'roundtrip', angle
        for value in values: yield axis, obj, local, profile, 'getter', value
        for angle in (-0x80000000, 0x7FFFFFFF): yield axis, obj, local, profile, 'setter-only', angle


def mutations(compiled, data):
    records = []
    for axis, address in enumerate(FLOATS + DOUBLES):
        setter = axis < 3
        source = SOURCES[0 if setter else 1]
        name = f'D_{"FLT" if setter else "DBL"}_{address:08X}'
        original = (ROOT / source).read_text()
        before = f'{name} = {"3.141592f" if setter else "3.13159"};'
        after = f'{name} = {"3.0f" if setter else "3.141592653589793"};'
        assert original.count(before) == 1
        changed = original.replace(before, after).replace('../../include/object.h', str(ROOT / 'include/object.h'))
        with tempfile.TemporaryDirectory(prefix='object-angle-', dir=ROOT / '.local') as temporary:
            path = Path(temporary)
            (path / 'source.c').write_text(changed)
            subprocess.run([str(ROOT / '.local/toolchain/5.3/cc'), '-O2', '-G', '0', '-non_shared', '-mips1', '-32',
                '-c', str(path / 'source.c'), '-o', str(path / 'compiled.o')], check=True, cwd=ROOT)
            sections, _ = elf_sections_and_symbols(path / 'compiled.o')
            ownership = source_sections(source)[0]
            raw = sections['.data']['bytes']
            assert not any(raw[ownership['size']:])
            assert not any(s['size'] for n, s in sections.items() if n in ('.text', '.rodata', '.bss'))
            replacement = raw[:ownership['size']]
            mutant = [(start, replacement if start == ownership['vram'] else payload) for start, payload in data]
            case = (axis % 3, 17, False, 0, 'roundtrip', -32768)
            control = run(compiled, data, case)
            try:
                run(compiled, mutant, case, oracle_constants=data)
            except AssertionError as error:
                assert 'Full memory oracle' in str(error) or 'Getter arithmetic oracle' in str(error), str(error)
                records.append(dict(symbol=name, control_passed=True, mutation_rejected=True,
                    source_sha256=hashlib.sha256(changed.encode()).hexdigest(),
                    object_sha256=hashlib.sha256((path / 'compiled.o').read_bytes()).hexdigest(),
                    witness=case, reason=str(error)))
                assert run(compiled, data, case) == control
            else:
                raise AssertionError(('Compiled constant mutation escaped', name))
    return records


def main():
    layout, retail, compiled, data, storage, comparison = prepare()
    observations = []
    for index, case in enumerate(cases()):
        expected = run(retail, data, case)
        assert expected == run(compiled, data, case), case
        observations.append(expected)
        if index % 500 == 0: print('Object angle constant paired cases:', index + 1, flush=True)
    controls = []
    for boundary in ('object-negative', 'object-overrun', 'null-transform', 'unaligned-transform', 'short-transform'):
        for name, code in (('retail', retail), ('compiled', compiled)):
            try:
                run(code, data, (0, 17, False, 0, 'setter-only', 1024), negative=boundary)
            except Exception as error:
                assert 'Access bounds' in str(error) or (isinstance(error, UcError) and error.errno == UC_ERR_EXCEPTION), str(error)
                controls.append(dict(boundary=boundary, implementation=name, rejected=True, reason=str(error)))
            else:
                raise AssertionError(('Invalid boundary escaped', boundary, name))
    rejected = mutations(compiled, data)
    layout.verify()
    report = dict(matches=True, paired_cases=len(observations), principal_executions=len(observations) * 2,
        initialized_bytes=36, storage=storage, complete_consumer=comparison,
        live_constant_profiles=7, source_mutations=rejected, boundary_controls=controls,
        observations_sha256=hashlib.sha256(''.join(observations).encode()).hexdigest(),
        checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        versions={name: version(name) for name in ('unicorn', 'capstone', 'pyelftools')},
        limitations=['The complete transform unit and both complete constant sections are freshly compiled and matched.',
            'All three setters/getters execute real code with no call stubs. All 300 records, selected external/local transform storage, access bounds and preserved integer/FPU registers are checked.',
            'The default floating rounding mode and finite in-range getter conversions are tested. Extreme signed setter inputs are checked without asserting an out-of-range getter conversion.',
            'Each of six live scalar constants is changed independently to 3.0 to check load behavior. Compiled-source mutations use independent expected retail values.',
            'The 4-byte retail gap and 12 total compiler alignment bytes remain outside ownership.',
            'These finite execution checks do not prove whole-game or N64 hardware behavior.'])
    output = ROOT / 'build/object-angle-constants-check/report.json'
    output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k: report[k] for k in ('matches', 'paired_cases', 'principal_executions', 'initialized_bytes')}), flush=True)
    print('Rejected compiled-data mutations:', len(rejected), 'invalid bounds:', len(controls), flush=True)


if __name__ == '__main__':
    main()
