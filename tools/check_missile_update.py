"""Run complete retail/C callbacks with real support and a bounded child ABI."""
from pathlib import Path
import hashlib
import itertools
import json
import math
import struct
import sys
from importlib.metadata import version
from capstone import Cs, CS_ARCH_MIPS, CS_MODE_MIPS32, CS_MODE_BIG_ENDIAN
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UcError
from unicorn import mips_const as regs

from missile_update_model import *
from check_actor_group_path import machine, SENTINEL
from compare_startup import compare_block, SymbolLayoutSnapshot
from compare_runtime import MATCHING_BLOCKS
from compare_data import compare_unit, comparison_directory
from owned_sections import source_sections, elf_sections_and_symbols
from rom import ROOT, validate
from missile_update_compare import compare_candidate_block

r = ROOT
FAMILY = 'missile-update-execution'
OUTPUT = ROOT / 'build' / FAMILY
SOURCE = ROOT / 'src/game/actor_projectiles/missile_update.c'
SUPPORT = ('actor_behavior_state', 'actor_behavior_blend_motion', 'actor_nearest_match',
           'runtime_random', 'gu_random', 'object_transforms', 'fixed_geometry_setup',
           'object_recovery_fixed_trig', 'short_sine', 'short_cosine',
           'object_recovery_angle_scale', 'object_recovery_direction_angle', 'object_recovery_angle_table')
CALLS = {0x80039BE4: 2, 0x80039BF0: 2, 0x80039514: 2, 0x8004CDE8: 0,
         0x8002A3E8: 3, 0x8002A5DC: 2, 0x8003CD4C: 2, 0x80027D8C: 5,
         0x8003CC88: 1, 0x8003CC58: 1, 0x80015218: 1}

def child_stub():
    instructions = []
    # The child creator has an explicit clobbering O32 boundary in this audit.
    for register in (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 24, 25):
        instructions.extend((0x3C000000 | register << 16 | 0x55AA,
                             0x34000000 | register << 21 | register << 16 | register))
    instructions.extend(0x44880000 | register << 11 for register in range(20))
    instructions.extend((0x03E00008, 0))
    return b''.join(word(i) for i in instructions)

def execute(code, dispatch, support, owned, case, actor_override=None, trap_expected=False):
    data, info = initial(case)
    if trap_expected:
        expected, allowed, expected_trace, branches = data, [(a, a + len(b)) for a, b in data.items()], [], []
    else:
        expected, allowed, expected_trace, branches = oracle(data, case, info)
    fpu = [0x3F800101 + i * 257 for i in range(12)]
    boot = b''.join(word(i) for i in [0x3C08802A, 0x35080000] +
        [0xC5000000 | (i + 20) << 16 | i * 4 for i in range(12)] +
        [0x3C088003, 0x35088830, 0x01000008, 0])
    finish = b''.join(word(i) for i in [0x3C08802A, 0x35080100] +
        [0xE5000000 | (i + 20) << 16 | i * 4 for i in range(12)] +
        [0x3C088000, 0x35080080, 0x01000008, 0])
    boundary = child_stub()
    uc, write, _ = machine([(ENTRY, code), (TABLE, dispatch), (BOOT, boot),
                            (RETURN, finish), (0x80015218, boundary)], support)
    for address, blob in data.items():
        write(address, bytes(blob))
    write(FP_INPUT, b''.join(word(v) for v in fpu))
    write(FP_OUTPUT, b'\x6D' * 48)
    stack_start = STACK - 0x820
    stack = bytes((i * 29 + case[3]) & 255 for i in range(0x860))
    write(stack_start, stack)
    reads = [(a, a + len(b)) for a, b in data.items()] + [(STACK - 0x800, STACK), (FP_INPUT, FP_INPUT + 48), (TABLE, TABLE + len(dispatch))]
    reads += [(a, a + len(b)) for a, b in owned]
    allowed += [(STACK - 0x800, STACK), (FP_OUTPUT, FP_OUTPUT + 48)]
    executable = [(ENTRY, ENTRY + len(code)), (BOOT, BOOT + len(boot)),
                  (RETURN, RETURN + len(finish)), (0x80015218, 0x80015218 + len(boundary))]
    executable += [(a, a + len(b)) for a, b in support if a not in {p[0] for p in owned}]
    saved = {getattr(regs, 'UC_MIPS_REG_' + name): uc.reg_read(getattr(regs, 'UC_MIPS_REG_' + name))
             for name in ('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP')}
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xABCD1234)
    uc.reg_write(regs.UC_MIPS_REG_RA, RETURN)
    uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS, uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | 1 << 29)
    uc.reg_write(regs.UC_MIPS_REG_A0, ACTOR if actor_override is None else actor_override)
    uc.reg_write(regs.UC_MIPS_REG_A1, case[1])
    trace, touched, instruction_count, last_instruction = [], set(), [0], [None]
    def on_write(uc, access, address, size, value, user):
        address |= 0x80000000
        assert any(a <= address and address + size <= b for a, b in allowed), ('Write guard', hex(address), case)
        if stack_start <= address < STACK:
            touched.update(range(address, address + size))
    def on_read(uc, access, address, size, value, user):
        address |= 0x80000000
        assert any(a <= address and address + size <= b for a, b in reads), ('Read guard', hex(address), case)
    def on_code(uc, address, size, user):
        instruction_count[0] += 1
        last_instruction[0] = address
        assert address == SENTINEL or any(a <= address and address + size <= b for a, b in executable), ('Escaped code', hex(address), case)
        if address in CALLS:
            count = CALLS[address]
            arguments = [uc.reg_read(regs.UC_MIPS_REG_A0 + i) for i in range(min(4, count))]
            if count == 5:
                arguments.append(int.from_bytes(uc.mem_read((uc.reg_read(regs.UC_MIPS_REG_SP) + 16) & 0x1FFFFFFF, 4), 'big'))
            trace.append((address, tuple(arguments), bytes(uc.mem_read(ACTOR & 0x1FFFFFFF, 124)).hex()))
    uc.hook_add(UC_HOOK_MEM_WRITE, on_write)
    uc.hook_add(UC_HOOK_MEM_READ, on_read)
    uc.hook_add(UC_HOOK_CODE, on_code)
    try:
        uc.emu_start(BOOT, 0, count=30000)
    except UcError:
        if not trap_expected:
            raise
        instruction = bytes(uc.mem_read(last_instruction[0] & 0x1FFFFFFF, 4))
        decoded = next(Cs(CS_ARCH_MIPS, CS_MODE_MIPS32 | CS_MODE_BIG_ENDIAN).disasm(instruction, last_instruction[0]))
        assert decoded.mnemonic == 'break', ('Expected arithmetic trap', decoded.mnemonic)
        assert int.from_bytes(instruction, 'big') == 0x0007000D, ('Expected divide-by-zero break', instruction.hex())
        return dict(expected_divide_by_zero=True, address=hex(last_instruction[0]), instruction=instruction.hex(), instructions=instruction_count[0])
    assert not trap_expected, 'Zero divisor failed to trap'
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, 'No return'
    assert uc.reg_read(regs.UC_MIPS_REG_SP) == STACK and uc.reg_read(regs.UC_MIPS_REG_GP) == 0xABCD1234, 'SP/GP'
    assert all(uc.reg_read(k) == v for k, v in saved.items()), 'Integer saved registers'
    assert bytes(uc.mem_read(FP_OUTPUT & 0x1FFFFFFF, 48)) == b''.join(word(v) for v in fpu), 'Saved FPU words'
    assert trace == expected_trace, ('Call trace', case, next(((i, a, b) for i, (a, b) in enumerate(itertools.zip_longest(trace, expected_trace)) if a != b), None))
    digest = hashlib.sha256()
    for address, expected_blob in expected.items():
        actual = bytes(uc.mem_read(address & 0x1FFFFFFF, len(expected_blob)))
        assert actual == bytes(expected_blob), ('Independent memory oracle', hex(address), case,
            next(((i, a, b) for i, (a, b) in enumerate(zip(actual, expected_blob)) if a != b), None))
        digest.update(actual)
    actual = bytes(uc.mem_read(stack_start & 0x1FFFFFFF, len(stack)))
    assert all(value == stack[i] for i, value in enumerate(actual) if stack_start + i not in touched), 'Stack canary'
    digest.update(json.dumps(trace).encode())
    return digest.hexdigest(), instruction_count[0], branches

def check_controls(candidate, dispatch, retail, retail_dispatch, support, owned, target, layout):
    results = []
    def reject(name, code, table, case, reason, **kwargs):
        execute(retail, retail_dispatch, support, owned, case)
        execute(candidate, dispatch, support, owned, case)
        try:
            execute(code, table, support, owned, case, **kwargs)
        except (AssertionError, UcError) as error:
            message = str(error)
            assert reason in message, (name, reason, message)
            results.append(dict(name=name, rejected_by=reason))
            print('Rejected', name, reason, flush=True)
        else:
            raise AssertionError(('Control escaped the guard', name))
    source = SOURCE.read_text()
    mutants = (
        ('expiry_boundary', 'elapsed > (unsigned int)resource->value58', 'elapsed >= (unsigned int)resource->value58', (4, 0, 1000, 0)),
        ('timer_boundary', 'actor->field50 > 250', 'actor->field50 >= 250', (10, 0, 249, 1)),
        ('speed_halving', 'speed = speed * 5 / 10', 'speed = speed * 6 / 10', (8, 0, 249, 0)),
        ('heading_mask', '& 0xFF00', '& 0xFFF0', (8, 0, 249, 0)),
        ('velocity_division', '/ 4096', '/ 4095', (7, 0, 128, 2)),
        ('nearest_kind', '&actor->position, 3, 0, 4, 0', '&actor->position, 2, 0, 4, 0', (8, 0, 249, 0)),
        ('random_shift', 'func_8004CDE8() >> 3', 'func_8004CDE8() >> 2', (10, 1, 128, 1)),
        ('progress_byte', 'actor->unknown23 = progress;', 'actor->unknown23 = progress + 1;', (8, 0, 249, 0)),
        ('draw_callback', 'actor->callback00 = func_80005560;', 'actor->callback00 = 0;', (5, 1, 249, 0)),
    )
    for name, before, after, case in mutants:
        assert before in source, ('Mutation anchor changed', name)
        path = OUTPUT / 'control-sources' / ('mutant_' + name + '.c')
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(source.replace(before, after))
        compare_candidate_block('mutant_' + name, path.relative_to(ROOT).as_posix(), target, layout, FAMILY + '-controls')
        code = (ROOT / 'build' / (FAMILY + '-controls') / ('mutant_' + name) / ('mutant_' + name + '.bin')).read_bytes()
        table = (ROOT / 'build' / (FAMILY + '-controls') / ('mutant_' + name) / ('mutant_' + name + '-dispatch.bin')).read_bytes()
        # A changed field can be observed at the next call snapshot or final memory.
        try:
            execute(code, table, support, owned, case)
        except AssertionError as error:
            reason = next((reason for reason in ('Call trace', 'Independent memory oracle', 'Write guard', 'Read guard')
                           if reason in str(error)), None)
            assert reason is not None, ('Unexpected semantic rejection', name, str(error))
        else:
            raise AssertionError(('Semantic control escaped', name))
        reject(name, code, table, case, reason)
    instructions = list(Cs(CS_ARCH_MIPS, CS_MODE_MIPS32 | CS_MODE_BIG_ENDIAN).disasm(candidate, ENTRY))
    slot = next(i.address - ENTRY for i in instructions[:35] if i.mnemonic == 'nop')
    case = (10, 1, 128, 1)
    for number in range(20, 32):
        bad = bytearray(candidate)
        bad[slot:slot + 4] = word(0x44880000 | number << 11)
        reject('saved_fpu_f' + str(number), bytes(bad), dispatch, case, 'Saved FPU words')
    for number in list(range(17, 24)) + [30]:
        bad = bytearray(candidate)
        bad[slot:slot + 4] = word(number << 11 | 0x25)
        reject('saved_integer_' + str(number), bytes(bad), dispatch, case, 'Integer saved registers')
    restore = next(i.address - ENTRY for i in reversed(instructions) if i.mnemonic == 'lw' and i.op_str.startswith('$s0,'))
    bad = bytearray(candidate)
    bad[restore:restore + 4] = word(16 << 11 | 0x25)
    reject('saved_s0_epilogue', bytes(bad), dispatch, case, 'Integer saved registers')
    for name, instruction, reason in (('saved_gp', 0x0000E025, 'SP/GP'), ('invalid_read', 0x8C000000, 'Read guard'), ('invalid_write', 0xAC000000, 'Write guard')):
        bad = bytearray(candidate)
        bad[slot:slot + 4] = word(instruction)
        reject(name, bytes(bad), dispatch, case, reason)
    for label, code, table in (('retail', retail, retail_dispatch), ('candidate', candidate, dispatch)):
        reject('null_actor_' + label, code, table, case, 'Read guard', actor_override=0)
        for kind in (7, 8):
            trap = execute(code, table, support, owned, (kind, 0, 0, 5), trap_expected=True)
            results.append(dict(name='zero_duration_' + label + '_' + str(kind), **trap))
    jal = next(i.address - ENTRY for i in instructions if i.mnemonic == 'jal')
    bad = bytearray(candidate)
    bad[jal:jal + 4] = word(0x0C0AC000)
    reject('escaped_code', bytes(bad), dispatch, (4, 1, 128, 0), 'Escaped code')
    return results

def main():
    target = (r / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    inputs = (SOURCE, Path(__file__), *(ROOT / 'tools' / filename for filename in (
        'missile_update_model.py', 'missile_update_compare.py', 'check_actor_group_path.py',
        'compare_startup.py', 'compare_runtime.py', 'compare_data.py', 'owned_sections.py',
        'compiler.py', 'provenance.py', 'trim_padding.py', 'toolchain.py', 'rom.py')))
    guard_inputs = {path.relative_to(ROOT).as_posix(): hashlib.sha256(path.read_bytes()).hexdigest() for path in inputs}
    reports, support, owned = {}, [], []
    for name in SUPPORT:
        _, source, start, end = next(x for x in MATCHING_BLOCKS if x[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target, 'missile-update-support', layout)
        assert report['matches'], ('Full support mismatch', name)
        reports[name] = report
        directory = r / 'build/missile-update-support' / name
        support.append((start, (directory / (name + '.bin')).read_bytes()))
        sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
        for section in source_sections(source):
            if section['rom'] is not None:
                address, payload = section['vram'], sections[section['section']]['bytes']
                support.append((address, payload))
                owned.append((address, payload))
                if name == 'short_sine':
                    assert payload == struct.pack('>1024h', *(math.floor(32767 * math.sin(i * math.pi / 2046)) for i in range(1024)))
        print('Fresh matched support', name, flush=True)
    for source in ('src/game/actor_groups/direction_table.c', 'src/game/object_angle_setter_constants.c'):
        records = source_sections(source)
        report = compare_unit(source, records, target, layout)
        reports[source] = report
        sections, _ = elf_sections_and_symbols(comparison_directory(source) / 'compiled.elf')
        for record in records:
            payload = sections[record['section']]['bytes']
            support.append((record['vram'], payload))
            owned.append((record['vram'], payload))
            if source.endswith('direction_table.c'):
                assert payload == struct.pack('>65i', *TANGENT)
            else:
                assert payload == struct.pack('>3f', *([3.141592] * 3))
    comparison = compare_candidate_block('candidate', SOURCE.relative_to(ROOT).as_posix(), target, layout, FAMILY)
    candidate = (OUTPUT / 'candidate/candidate.bin').read_bytes()
    dispatch = (OUTPUT / 'candidate/candidate-dispatch.bin').read_bytes()
    retail, retail_dispatch = target[0x39430:0x3998C], target[0x957F0:0x9580C]
    cases = list(itertools.product(range(11), (0, 1), (0, 1, 127, 128, 249, 250, 251, 4001, -1), range(8)))
    cases = [case for case in cases if not (case[0] in (7, 8) and case[2] == 0 and case[3] == 5)]
    cases += [(4, initialize, age, 0) for initialize, age in itertools.product((0, 1), (989, 990, 991, 999, 1000, 1001))]
    digest, max_instructions, coverage = hashlib.sha256(), 0, {}
    for index, case in enumerate(cases):
        a, n, branches = execute(retail, retail_dispatch, support, owned, case)
        b, m, _ = execute(candidate, dispatch, support, owned, case)
        assert a == b, ('Retail/candidate execution', case)
        digest.update(a.encode())
        max_instructions = max(max_instructions, n, m)
        for branch in branches:
            coverage[branch] = coverage.get(branch, 0) + 1
        if (index + 1) % 200 == 0:
            print('Guarded missile pairs', index + 1, '/', len(cases), flush=True)
    controls = check_controls(candidate, dispatch, retail, retail_dispatch, support, owned, target, layout)
    layout.verify()
    receipt = dict(paired_cases=len(cases), principal_executions=len(cases) * 2,
        max_instructions=max_instructions, trace_sha256=digest.hexdigest(), coverage=coverage,
        comparison=comparison, real_support=reports, controls=controls, source_ownership_added=0,
        guard_inputs_sha256=guard_inputs,
        emulator=dict(package='unicorn', version=version('unicorn')),
        limits=['Finite synthetic CPU cases. Full instruction comparison still fails.',
                'Thirteen complete matched support units and their owned data execute real code.',
                'The child creator uses an explicit caller-clobbering O32 boundary; its allocation effects are not proved.',
                'Four actual divide-by-zero traps are checked separately. Invalid objects and gameplay remain outside the successful sweep.',
                'Stack interiors are bounded and ABI-checked, not claimed byte-identical.'])
    for report in list(reports.values()) + [comparison]:
        for filename, digest in report['inputs_sha256'].items():
            assert hashlib.sha256((ROOT / filename).read_bytes()).hexdigest() == digest, ('Changed comparison input', filename)
    for filename, digest in guard_inputs.items():
        assert hashlib.sha256((ROOT / filename).read_bytes()).hexdigest() == digest, ('Changed guard input', filename)
    (OUTPUT / 'report.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('Missile execution guard passed', len(cases), 'pairs', coverage, 'with zero ownership', flush=True)

if __name__ == '__main__':
    main()
