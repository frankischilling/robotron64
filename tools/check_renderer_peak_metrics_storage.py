"""Execute complete peak-metrics reset/update code with exact storage guards."""

import argparse
from collections import Counter
import hashlib
from importlib.metadata import version
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UC_MEM_WRITE
from unicorn import mips_const as regs

from check_actor_group_path import SENTINEL, machine, word
from check_movie_storage import PRESERVED, pattern
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


BASE, COUNT, STRIDE = 0x8013DC30, 201, 20
END, HEAP = BASE + COUNT * STRIDE, 0x8013EBF0
CLEAR, UPDATE, MEMSET = 0x8004CCA4, 0x8004CCD0, 0x8003B694
STACK = 0x80300000
SOURCE = 'src/game/renderer_peak_metrics_storage.c'
SUPPORT = ('runtime_buffer_clear', 'renderer_metrics_update', 'game_memory')
# Fields in actual write order; source inputs are deliberately separate from
# the physical record offsets used by the independent expected-state model.
OFFSETS = (8, 12, 0, 16, 4)
INPUTS = (0x800C8DFC, 0x8013D9C0, 0x8013D9C4, 0x80138250,
          0x80123B18, 0x8007D6A8, 0x80126B84, 0x80123B20)


def signed(value):
    value &= 0xFFFFFFFF
    return value if value < 0x80000000 else value - 0x100000000


def run(code, case, boundary=False):
    uc, write, execute = machine(code, [])
    uc.reg_write(regs.UC_MIPS_REG_GP, 0x9157AF39)
    saved = {r: uc.reg_read(r) for r in PRESERVED}
    panel_start, panel_end = BASE - 16, END + 36
    panel = pattern(panel_end - panel_start, case['seed'])
    index = case.get('index', 0)
    slot = min(max(index, 0), 201)
    selected = BASE + slot * STRIDE
    if case['kind'] == 'update':
        for offset, value in zip(OFFSETS, case['old']):
            panel[selected + offset - panel_start:selected + offset - panel_start + 4] = word(value)
    expected = bytearray(panel)
    write(panel_start, bytes(panel))
    input_panels = {}
    # Subtraction operands have real 32-bit addresses/counters and deliberately
    # exercise wraparound in the target's SUBU instructions.
    values = case.get('values', (0, 0, 0, 0, 0))
    arena_base = case.get('arena_base', 0x80200000)
    vertex_base = case.get('vertex_base', 0x34567890)
    input_words = (index, arena_base + values[0], arena_base, values[1],
                   values[2], values[3], vertex_base + values[4], vertex_base)
    groups = ((INPUTS[0], 4), (INPUTS[1], 8), (INPUTS[3], 4),
              (INPUTS[4], 12), (INPUTS[5], 4), (INPUTS[6], 4))
    for i, (address, size) in enumerate(groups):
        blob = pattern(size + 32, case['seed'] + i + 11)
        for at, value in zip(INPUTS, input_words):
            if address <= at < address + size:
                blob[16 + at - address:20 + at - address] = word(value)
        input_panels[address] = bytes(blob)
        write(address - 16, bytes(blob))
    stack = pattern(72, case['seed'] + 29)
    write(STACK - 40, bytes(stack))
    expected_stack = bytearray(stack)
    wanted_reads, wanted_writes, wanted_calls = [], [], []
    if case['kind'] == 'clear':
        expected[16:16 + COUNT * STRIDE] = bytes(COUNT * STRIDE)
        expected_stack[36:40] = word(SENTINEL)
        wanted_writes.append((STACK - 4, 4, SENTINEL))
        # The real fill callee stores +1/+2/+3, then +0 in the loop's
        # branch delay slot. Record that schedule as well as its final image.
        wanted_writes.extend((BASE + i + offset, 1, 0)
                             for i in range(0, COUNT * STRIDE, 4)
                             for offset in (1, 2, 3, 0))
        wanted_reads.append((STACK - 4, 4))
        wanted_calls.append((MEMSET, BASE, 0, COUNT * STRIDE))
        entry = CLEAR
    else:
        wanted_reads = [(INPUTS[0], 4), (INPUTS[2], 4), (INPUTS[1], 4),
                        (selected + 8, 4), (INPUTS[3], 4), (selected + 12, 4),
                        (INPUTS[4], 4), (selected, 4), (INPUTS[5], 4),
                        (selected + 16, 4), (INPUTS[6], 4), (INPUTS[7], 4),
                        (selected + 4, 4)]
        for offset, old, value in zip(OFFSETS, case['old'], values):
            value = signed(value)
            if signed(old) < value:
                expected[selected + offset - panel_start:selected + offset - panel_start + 4] = word(value)
                wanted_writes.append((selected + offset, 4, value & 0xFFFFFFFF))
        entry = UPDATE
    reads, writes, calls = [], [], []
    normal = (BASE, END)
    record = (selected, selected + STRIDE)
    code_bounds = ((CLEAR, CLEAR + 44), (UPDATE, UPDATE + 228), (MEMSET, MEMSET + 80))

    def inside(address, size, bounds):
        return bounds[0] <= address and address + size <= bounds[1]

    def access(uc, access, address, size, value, user):
        address = (address & 0x1FFFFFFF) | 0x80000000
        if access == UC_MEM_WRITE:
            allowed = inside(address, size, (STACK - 24, STACK)) if case['kind'] == 'clear' else False
            allowed |= inside(address, size, normal if not boundary else record)
            assert allowed, ('Write bounds', hex(address), size, index)
            writes.append((address, size, value & ((1 << (8 * size)) - 1)))
        else:
            allowed = address in INPUTS and size == 4
            allowed |= inside(address, size, normal if not boundary else record)
            allowed |= case['kind'] == 'clear' and inside(address, size, (STACK - 24, STACK))
            assert allowed, ('Read bounds', hex(address), size, index)
            reads.append((address, size))

    def instruction(uc, address, size, user):
        if address != SENTINEL:
            assert any(inside(address, size, bounds) for bounds in code_bounds), ('Code bounds', hex(address))
        if address == MEMSET:
            calls.append((address, *[uc.reg_read(r) for r in
                         (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2)]))

    uc.hook_add(UC_HOOK_MEM_READ, access)
    uc.hook_add(UC_HOOK_MEM_WRITE, access)
    uc.hook_add(UC_HOOK_CODE, instruction)
    execute(entry)
    assert all(uc.reg_read(r) == value for r, value in saved.items()), 'O32 preserved integer registers'
    assert reads == wanted_reads, ('Ordered reads', reads, wanted_reads)
    assert writes == wanted_writes, ('Ordered writes', writes[:8], wanted_writes[:8])
    assert calls == wanted_calls, ('Real memset arguments', calls, wanted_calls)
    result = bytes(uc.mem_read(panel_start & 0x1FFFFFFF, len(panel)))
    assert result == expected, 'Complete metrics, neighboring bytes and heap-pointer image'
    assert bytes(uc.mem_read((STACK - 40) & 0x1FFFFFFF, len(stack))) == expected_stack, 'Complete stack and guards'
    for address, blob in input_panels.items():
        assert bytes(uc.mem_read((address - 16) & 0x1FFFFFFF, len(blob))) == blob, 'Input and guard mutation'
    return hashlib.sha256(result + json.dumps((reads, writes, calls)).encode()).hexdigest()


def prepare_images():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    records = source_sections(SOURCE)
    assert len(records) == 1 and (records[0]['vram'], records[0]['size'], records[0]['rom']) == (BASE, 4020, None)
    data = compare_unit(SOURCE, records, target, layout)
    directory = ROOT / 'build/renderer-peak-metrics-check'
    comparisons, retail, compiled = {}, [], []
    for name, source, start, end in MATCHING_BLOCKS:
        if name not in SUPPORT:
            continue
        result = compare_block(name, source, start, start - 0x7FFFF400,
                               end - 0x7FFFF400, target, family='renderer-peak-metrics-check', layout=layout)
        assert result['matches'], name
        comparisons[name] = result
        retail.append((start, target[start - 0x7FFFF400:end - 0x7FFFF400]))
        compiled.append((start, (directory / name / (name + '.bin')).read_bytes()))
    assert set(comparisons) == set(SUPPORT)
    raw = ROOT / 'build/data-comparison' / Path(SOURCE).with_suffix('') / 'raw.o'
    sections, symbols = elf_sections_and_symbols(raw)
    assert symbols['D_8013DC30']['size'] == 4020, 'Natural IDO object extent'
    assert sections['.bss']['size'] == 4032, 'Natural IDO section alignment'
    assert not any(s['size'] and s['flags'] & 2 for name, s in sections.items()
                   if name not in ('.bss', '.reginfo', '.MIPS.abiflags')), 'Unexpected allocated payload'
    return target, layout, data, comparisons, retail, compiled


MUTATIONS = {
    'short_clear': ('src/game/runtime_buffer_clear.c', 'sizeof(D_8013DC30)', 'sizeof(D_8013DC30) - 1', dict(kind='clear', seed=173)),
    'long_clear': ('src/game/runtime_buffer_clear.c', 'sizeof(D_8013DC30)', 'sizeof(D_8013DC30) + 1', dict(kind='clear', seed=173)),
    'negative_index': ('src/game/renderer_metrics_update.c', 'index = 0;', 'index = 1;', dict(kind='update', seed=173, index=-1, old=(0,) * 5, values=(1,) * 5)),
    'repair_limit': ('src/game/renderer_metrics_update.c', 'index = 201;', 'index = 200;', dict(kind='update', seed=173, index=202, old=(0,) * 5, values=(1,) * 5)),
    'unsigned_peak': ('src/game/renderer_metrics_update.c', 'metrics->framesPerSecond < index', '(unsigned int)metrics->framesPerSecond < (unsigned int)index', dict(kind='update', seed=173, index=200, old=(0, -1, 0, 0, 0), values=(1,) * 5)),
    'equal_store': ('src/game/renderer_metrics_update.c', 'metrics->primitives < index', 'metrics->primitives <= index', dict(kind='update', seed=173, index=200, old=(1,) * 5, values=(1,) * 5)),
    'swapped_fields': ('src/game/renderer_metrics_update.c', 'metrics->vertices = index;', 'metrics->primitives = index;', dict(kind='update', seed=173, index=200, old=(0,) * 5, values=(1,) * 5)),
}


def mutation_check(name):
    if ROOT.parent.name != '.local' or not ROOT.name.startswith('peak-metrics-' + name + '-'):
        raise ValueError('Source mutations require an isolated audit directory')
    target, layout, _, _, retail, compiled = prepare_images()
    relative, old, new, case = MUTATIONS[name]
    boundary = case.get('index', 0) >= COUNT
    assert run(retail, case, boundary) == run(compiled, case, boundary), 'Mutation positive control'
    path = ROOT / relative
    contents = path.read_text()
    assert contents.count(old) == 1, ('Mutation anchor', name)
    path.write_text(contents.replace(old, new))
    _, _, start, end = next(row for row in MATCHING_BLOCKS if row[1] == relative)
    report = compare_block('mutated', relative, start, start - 0x7FFFF400,
                           end - 0x7FFFF400, target, family='peak-metrics-mutation', layout=layout)
    assert not report['matches'], 'Unchanged source mutation'
    blob = (ROOT / 'build/peak-metrics-mutation/mutated/mutated.bin').read_bytes()
    changed = [(address, data) for address, data in compiled if address != start] + [(start, blob)]
    try:
        run(changed, case, boundary)
    except AssertionError as error:
        print(json.dumps(dict(name=name, control_passed=True, mutation_rejected=True,
                             different_words=len(report['different_words']), reason=str(error))))
        return
    raise ValueError('Missed source mutation: ' + name)


def check_mutations():
    results = []
    for name in MUTATIONS:
        with tempfile.TemporaryDirectory(prefix='peak-metrics-' + name + '-', dir=ROOT / '.local') as temporary:
            root = Path(temporary)
            assert root.resolve().parent == (ROOT / '.local').resolve()
            for folder in ('src', 'include', 'config', 'tools', 'docs'):
                shutil.copytree(ROOT / folder, root / folder)
            shutil.copy2(ROOT / 'Makefile', root / 'Makefile')
            (root / '.local').mkdir()
            (root / '.local/toolchain').symlink_to(ROOT / '.local/toolchain', target_is_directory=True)
            (root / 'baseroms/us').mkdir(parents=True)
            (root / 'baseroms/us/baserom.z64').symlink_to(ROOT / 'baseroms/us/baserom.z64')
            result = subprocess.run([sys.executable, str(root / 'tools/check_renderer_peak_metrics_storage.py'), '--mutation', name], capture_output=True, text=True)
            if result.returncode:
                raise ValueError(f'Mutation {name} failed:\n{result.stdout}\n{result.stderr}')
            record = json.loads(result.stdout.splitlines()[-1])
            assert record['control_passed'] and record['mutation_rejected']
            results.append(record)
    return results


def main(mutations):
    _, layout, data, comparisons, retail, compiled = prepare_images()
    cases = [dict(kind='clear', seed=seed) for seed in (0, 173, 255)]
    for index in range(COUNT):
        for mask in (0, 10, 21, 31):
            cases.append(dict(kind='update', seed=index, index=index,
                              old=tuple(-1 if mask & (1 << i) else 1 for i in range(5)), values=(0,) * 5))
    for index in (0, 100, 200, 201, 202, -1, -2147483648, 2147483647):
        for mask in range(32):
            cases.append(dict(kind='update', seed=173, index=index,
                              old=tuple(-1 if mask & (1 << i) else 1 for i in range(5)), values=(0,) * 5))
    edges = (-2147483648, -2147483647, -1, 0, 1, 2147483646, 2147483647)
    for index in (0, 200, 201):
        for old in edges:
            for value in edges:
                cases.append(dict(kind='update', seed=255, index=index, old=(old,) * 5,
                                  values=(value,) * 5, arena_base=0x7FFFFFFF, vertex_base=0xFFFFFFFF))
    records, boundary_controls = [], []
    for case in cases:
        boundary = case.get('index', 0) >= COUNT
        if boundary:
            for image in (retail, compiled):
                try:
                    run(image, case)
                except AssertionError as error:
                    assert str(error).startswith("('Read bounds'"), ('Wrong boundary rejection', error)
                else:
                    raise ValueError('Array-only guard accepted index 201')
            boundary_controls.append(case)
        result = run(retail, case, boundary)
        assert result == run(compiled, case, boundary), case
        records.append(dict(case=case, sha256=result))
    controls = check_mutations() if mutations else []
    layout.verify()
    report = dict(matches=True, paired_cases=len(cases), target_executions=2 * len(cases),
                  bounded_record_cases=sum(c.get('index', 0) < COUNT for c in cases),
                  boundary_alias_cases=len(boundary_controls),
                  array_only_controls_rejected=2 * len(boundary_controls), bss_bytes=4020,
                  case_kinds=dict(Counter(c['kind'] for c in cases)), storage=data, comparisons=comparisons,
                  cases_sha256=hashlib.sha256(json.dumps(records, sort_keys=True).encode()).hexdigest(),
                  source_mutations=controls,
                  versions={name: version(name) for name in ('unicorn', 'capstone', 'pyelftools')},
                  limitations=['Index 201 is outside the recovered array; its raw retail accesses are checked with a separate twenty-byte boundary fixture, including the heap pointer alias.',
                               'Reset executes the freshly matched real memory-fill callee. The writer has no service calls.',
                               'Complete memory, exact ordered accesses and O32 preserved integer registers are checked. No graphics, hardware or whole-game execution is claimed.'])
    path = ROOT / 'build/renderer-peak-metrics-check/report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: report[key] for key in ('matches', 'paired_cases', 'target_executions', 'bss_bytes', 'boundary_alias_cases', 'array_only_controls_rejected')}))
    print(f'Rejected {len(controls)} source mutations; report: {path.relative_to(ROOT)}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mutation', choices=MUTATIONS)
    parser.add_argument('--mutations', action='store_true')
    args = parser.parse_args()
    mutation_check(args.mutation) if args.mutation else main(args.mutations)
