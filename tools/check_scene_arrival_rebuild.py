"""Compare the complete rebuild candidate and execute guarded retail/source pairs.

The boundary layer observes insertion arguments with caller-clobbering O32
stubs. The integrated layer executes matching insertion, memory, random and
diagnostic helpers. Fatal display rendering returns synthetically. The rebuild
candidate remains excluded until its complete code and dispatch table match.
"""

from collections import Counter
import hashlib
from importlib.metadata import version
import json
from pathlib import Path
import re
import subprocess
import tempfile

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UcError
from unicorn import mips_const as regs

from check_actor_group_path import machine, word, SENTINEL
from check_boss_trigger import fpu_code, FPU_OUT, FPU_BITS, SEED_FPU, READ_FPU
from check_movie_storage import CALLER_SAVED, PRESERVED, pattern
from check_scene_arrivals import (SUPPORT, DATA_SOURCES, compile_image, frame,
                                 OUTPUT, REPORTER, RANDOM, MOVE, FATAL, WARNING, MESSAGES)
from compare_runtime import MATCHING_BLOCKS
from compare_startup import SymbolLayoutSnapshot, external_assignments, comparison_input_hashes
from compare_data import compare_unit, comparison_directory, data_input_hashes
from compiler import compile_source, profile_for_source
from manifest import load_manifest
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate
from scene_arrival_rebuild_model import (prepare, model, cases, POOL, HEAD, STRIDE,
    ACTOR_RESOURCES, RESOURCE_STRIDE, LIMITS, LIMIT_SIZE, SCENE, SCENE_SIZE,
    DEFAULTS, DEFAULT_STRIDE, SEED)
from toolchain import installed_identity
from trim_padding import trim

ENTRY, END, TABLE, TABLE_SIZE = 0x80020F8C, 0x800214D4, 0x800919E4, 36
INSERT, CLEAR, STACK, CLOBBER = 0x8001FCE4, 0x8003B694, 0x80300000, 0x80000100
SOURCE = 'src/game/scene_arrivals/rebuild.c'
FAMILY = 'scene-arrival-rebuild-audit'


def signed(value):
    value &= 0xFFFFFFFF
    return value - 0x100000000 if value & 0x80000000 else value


def compile_candidate(source, name, target, layout):
    inputs = comparison_input_hashes(source)
    directory = ROOT / 'build' / FAMILY / name
    directory.mkdir(parents=True, exist_ok=True)
    raw, obj, elf = (directory / (name + suffix) for suffix in ('.raw.o', '.o', '.elf'))
    compile_source(source, raw)
    sections, symbols = elf_sections_and_symbols(raw)
    natural = symbols['func_80020F8C']['size']
    assert symbols['func_80020F8C']['value'] == 0 and natural > 0
    assert not any(sections['.text']['bytes'][natural:]), 'Live rebuild tail outside natural function'
    assert sections['.rodata']['size'] >= TABLE_SIZE and not any(sections['.rodata']['bytes'][TABLE_SIZE:]), 'Live rebuild table tail'
    assert all(not sections.get(name, {}).get('size', 0) for name in ('.data', '.bss')), 'Unowned rebuild allocation'
    data = trim(raw.read_bytes(), '.text', natural)
    obj.write_bytes(trim(data, '.rodata', TABLE_SIZE))
    undefined = {line.split()[-1] for line in subprocess.check_output(
        ['mips-linux-gnu-nm', '-u', str(obj)], text=True).splitlines() if line.strip()}
    script = directory / 'candidate.ld'
    script.write_text(external_assignments(undefined, layout.addresses) +
        'SECTIONS { .text 0x80020F8C : SUBALIGN(4) { *(.text) } '
        '.rodata 0x800919E4 : SUBALIGN(4) { *(.rodata) } '
        '/DISCARD/ : { *(.reginfo .MIPS.abiflags) } }\n')
    subprocess.run(['mips-linux-gnu-ld', '-T', str(script), '-e', 'func_80020F8C',
                    '-o', str(elf), str(obj)], check=True)
    sections, _ = elf_sections_and_symbols(elf)
    code, table = sections['.text']['bytes'], sections['.rodata']['bytes']
    assert len(code) == natural and len(table) == TABLE_SIZE
    retail, retail_table = target[0x21B8C:0x220D4], target[0x925E4:0x92608]
    report = dict(source=source, natural_instruction_bytes=natural, retail_instruction_bytes=len(retail),
        candidate_frame=frame(code), retail_frame=frame(retail), matches=code == retail and table == retail_table,
        different_words=sum(retail[i:i+4] != code[i:i+4] for i in range(0, max(len(code), len(retail)), 4)),
        different_table_words=sum(table[i:i+4] != retail_table[i:i+4] for i in range(0, TABLE_SIZE, 4)),
        inputs_sha256=inputs, compiler_profile=profile_for_source(source),
        toolchain_identity=installed_identity(profile_for_source(source)['version']))
    for path, sha in inputs.items():
        assert hashlib.sha256((ROOT/path).read_bytes()).hexdigest() == sha, path
    layout.verify()
    return code, table, report


def run(code, table, helpers, constants, case, integrated, fault=None):
    panels = prepare(case)
    expected, wanted_calls, wanted_messages = model(case, panels, integrated)
    clobber = word(0x3C013F80) + b''.join(word(0x44810000 | (i << 11)) for i in range(20))
    clobber += word(0x03E00008) + word(0)
    if fault in ('saved_integer', 'saved_fpu', 'read_guard', 'write_guard', 'code_guard', 'stack_guard'):
        opcode = {'saved_integer': 0x24170000, 'saved_fpu': 0x4480A000,
                  'read_guard': 0x8C025000, 'write_guard': 0xAC005000,
                  'code_guard': 0x08000140, 'stack_guard': 0xAFA0F000}[fault]
        clobber = word(opcode) + word(0) + clobber
    if fault == 'dispatch_table':
        table = table[:32] + word(ENTRY + len(code) - 8)
    uc, write, _ = machine([(ENTRY, code)], helpers + list(constants.items()) +
                           [(TABLE, table), (CLOBBER, clobber)] + fpu_code())
    uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS, uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | (1 << 29))
    uc.emu_start(SEED_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA57281D9)
    saved = {register: uc.reg_read(register) for register in PRESERVED}
    extent = frame(code) + 0x448 + 0x450 + 0x100
    panels['stack'] = (STACK - extent, bytes(pattern(extent + 32, 173)))
    panels['fpu'] = (FPU_OUT, bytes(pattern(48, 211)))
    initial = {}
    for name, (address, data) in panels.items():
        guarded = b'\xA7'*16 + data + b'\xB9'*16
        initial[name] = guarded
        write(address - 16, guarded)

    def norm(address):
        return (address & 0x1FFFFFFF) | 0x80000000

    def inside(address, size, ranges):
        return any(start <= address and address + size <= end for start, end in ranges)

    executable = [(ENTRY, ENTRY + len(code)), (OUTPUT, OUTPUT + 4), (REPORTER, REPORTER + 4), (SENTINEL, SENTINEL + 4)]
    executable += [(address, address + len(data)) for address, data in helpers + [(CLOBBER, clobber)] + fpu_code()]
    readable = [(address, address + len(data)) for address, data in panels.values()]
    readable += [(address, address + len(data)) for address, data in constants.items()] + [(TABLE, TABLE + len(table))]
    allowed = [(STACK - extent, STACK), (POOL, HEAD + 4), (LIMITS, LIMITS + LIMIT_SIZE)]
    if integrated:
        allowed += [(SCENE, SCENE + SCENE_SIZE), (SEED, SEED + 4)]
    records = {record['slot']: record for record in case.get('actors', [])}
    trace, calls, clears, outputs, reports = Counter(), [], [], [], []
    phase = ['function']

    def cstring(address):
        address = norm(address)
        result = bytearray()
        for index in range(500):
            assert inside(address + index, 1, readable), 'Diagnostic string bounds'
            value = uc.mem_read((address + index) & 0x1FFFFFFF, 1)[0]
            if not value:
                return bytes(result)
            result.append(value)
        raise AssertionError('Unterminated diagnostic string')

    def instruction(uc, address, size, user):
        address = norm(address)
        assert address % 4 == 0 and inside(address, size, executable), ('Rebuild code guard', hex(address))
        if address in (INSERT, CLEAR, RANDOM, MOVE, FATAL, WARNING):
            trace[address] += 1
        if address == CLEAR:
            assert uc.reg_read(regs.UC_MIPS_REG_A1) == 0, 'Rebuild clear fill'
            destination = norm(uc.reg_read(regs.UC_MIPS_REG_A0))
            length = uc.reg_read(regs.UC_MIPS_REG_A2)
            assert destination % 4 == 0 and inside(destination, length, [(STACK-frame(code), STACK)]), 'Rebuild clear object bounds'
            clears.append(length)
        if address == INSERT:
            values = [uc.reg_read(getattr(regs, 'UC_MIPS_REG_A'+str(i))) for i in range(4)]
            sp = norm(uc.reg_read(regs.UC_MIPS_REG_SP))
            assert inside(sp + 16, 16, [(STACK-frame(code), STACK)]), 'Insertion outgoing argument bounds'
            values += [int.from_bytes(uc.mem_read((sp + 16 + i*4) & 0x1FFFFFFF, 4), 'big') for i in range(4)]
            calls.append(tuple(value if index == 5 else signed(value) for index, value in enumerate(values)))
        if address in (OUTPUT, REPORTER) or address == INSERT and not integrated:
            if address == OUTPUT:
                outputs.append(cstring(uc.reg_read(regs.UC_MIPS_REG_A0)))
            elif address == REPORTER:
                reports.append((cstring(uc.reg_read(regs.UC_MIPS_REG_A0)),
                    cstring(uc.reg_read(regs.UC_MIPS_REG_A1)), cstring(uc.reg_read(regs.UC_MIPS_REG_A2)),
                    uc.reg_read(regs.UC_MIPS_REG_A3)))
            for index, register in enumerate(CALLER_SAVED):
                uc.reg_write(register, 0xB2340000 + index*256)
            uc.reg_write(regs.UC_MIPS_REG_PC, CLOBBER)

    def read(uc, access, address, size, value, user):
        address = norm(address)
        assert inside(address, size, readable), ('Rebuild read guard', hex(address), size)
        if POOL <= address < HEAD:
            slot, offset = divmod(address - POOL, STRIDE)
            assert slot in records and (offset, size) in ((0x1C,1),(0x22,1),(0x24,4),(0x28,4),(0x3C,4),(0x60,4),(0x64,4),(0x78,4)), ('Actor scalar read', slot, hex(offset), size)
        elif address == HEAD:
            assert size == 4, 'Actor-list head width'
        elif ACTOR_RESOURCES <= address < ACTOR_RESOURCES + 200*RESOURCE_STRIDE:
            slot, offset = divmod(address - ACTOR_RESOURCES, RESOURCE_STRIDE)
            assert slot in records and (offset,size)==(2,1), ('Actor resource kind width', slot, offset, size)
        elif DEFAULTS <= address < DEFAULTS + 36*DEFAULT_STRIDE:
            index, offset = divmod(address - DEFAULTS, DEFAULT_STRIDE)
            assert index < 36 and (offset,size)==(100,4), 'Default delay read width'
        elif TABLE <= address < TABLE + TABLE_SIZE:
            assert size == 4 and (address-TABLE)%4==0, 'Dispatch read width'

    def store(uc, access, address, size, value, user):
        address = norm(address)
        ranges = [(FPU_OUT, FPU_OUT + 48)] if phase[0]=='observer' else allowed
        assert inside(address, size, ranges), ('Rebuild write guard', hex(address), size)
        if phase[0]=='function' and POOL <= address < HEAD + 4:
            slot, offset = divmod(address - POOL, STRIDE)
            assert slot in records and records[slot].get('category',0)==8 and (offset,size,value)==(0x21,1,2), 'Actor state write gate'

    uc.hook_add(UC_HOOK_CODE, instruction)
    uc.hook_add(UC_HOOK_MEM_READ, read)
    uc.hook_add(UC_HOOK_MEM_WRITE, store)
    uc.emu_start(ENTRY, 0, count=500000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC)==SENTINEL, 'Rebuild instruction bound'
    assert all(uc.reg_read(register)==value for register,value in saved.items()), 'Rebuild saved integer registers'
    assert calls==wanted_calls, ('Rebuild insertion arguments', calls, wanted_calls)
    assert clears==[144,32,44], ('Rebuild clear lengths', clears)
    assert trace[RANDOM]==0 and trace[FATAL]==wanted_messages.count('fatal') and trace[WARNING]==wanted_messages.count('warning'), 'Rebuild diagnostic/random calls'
    wanted_outputs, wanted_reports = [], []
    for message in wanted_messages:
        text=MESSAGES[message]
        wanted_outputs.extend((b'FATAL ERROR: ' if message=='fatal' else b'WARNING: ',text))
        if message=='fatal':wanted_reports.append((b'FATAL ERROR: %s %s %d\n',text,b'errors.c',77))
    assert outputs==wanted_outputs and reports==wanted_reports, 'Rebuild diagnostic output'
    for name,data in expected.items():
        address=panels[name][0]
        assert bytes(uc.mem_read(address & 0x1FFFFFFF,len(data)))==data, ('Rebuild complete fixture',name,case)
    phase[0]='observer'
    uc.emu_start(READ_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC)==SENTINEL
    assert bytes(uc.mem_read(FPU_OUT & 0x1FFFFFFF,48))==b''.join(word(value) for value in FPU_BITS), 'Rebuild saved FPU registers'
    for name,(address,data) in panels.items():
        actual=bytes(uc.mem_read((address-16)&0x1FFFFFFF,len(data)+32))
        assert actual[:16]==initial[name][:16] and actual[-16:]==initial[name][-16:], ('Rebuild canary',name)
    assert bytes(uc.mem_read(STACK & 0x1FFFFFFF,32))==panels['stack'][1][-32:], 'Rebuild immutable caller homes'
    return hashlib.sha256(b''.join(expected[name] for name in sorted(expected))+json.dumps(calls).encode()).hexdigest()


MUTATIONS = (
    ('behavior-bound','if (kind < 11)','if (kind < 10)',dict(slot=0,category=7,kind=10)),
    ('blocked-state','actor->field28 == 0','actor->field28 != 0',dict(slot=0,kind=2)),
    ('group-value','values[slot] += actor->value22;','values[slot] += 1;',dict(slot=0,kind=9,value=255)),
    ('parent-kind','kinds[slot] = kind - 4;','kinds[slot] = kind - 3;',dict(slot=199,kind=13,parent=0)),
    ('secondary-window','entry < (&counts[21])','entry < (&counts[20])',dict(slot=0,kind=20)),
    ('player-state','actor->state21 = 2;','actor->state21 = 3;',dict(slot=0,category=8)),
    ('coordinate-axis','actor->position[0], actor->position[1]','actor->position[1], actor->position[1]',dict(slot=0,category=1,kind=3,x=-257,y=257)),
    ('default-scale','arrivalDelay / 100','arrivalDelay / 101',dict(slot=0,kind=0)),
)


def main():
    target=(ROOT/'baseroms/us/baserom.z64').read_bytes();validate(target)
    layout=SymbolLayoutSnapshot();checker_hash=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    model_hash=hashlib.sha256((ROOT/'tools/scene_arrival_rebuild_model.py').read_bytes()).hexdigest()
    blocks={name:(source,start,end) for name,source,start,end in MATCHING_BLOCKS}
    helpers,constants,support_reports=[],{},{}
    for name in SUPPORT+('scene_arrival_insert',):
        source,start,end=blocks[name]
        report,code,data=compile_image('rebuild_'+name,source,start,end,target,layout)
        assert report['matches'], ('Rebuild support mismatch',name)
        helpers.append((start,code));constants.update(data);support_reports[name]=report
    data_reports={}
    for source in DATA_SOURCES:
        records=source_sections(source)
        report=compare_unit(source,records,target,layout);assert report['matches']
        sections,_=elf_sections_and_symbols(comparison_directory(source)/'compiled.elf')
        for record in records:
            if record['rom'] is not None:constants[record['vram']]=sections[record['section']]['bytes']
        data_reports[source]=report
    candidate,table,comparison=compile_candidate(SOURCE,'candidate',target,layout)
    original,original_table=target[0x21B8C:0x220D4],target[0x925E4:0x92608]
    corpus=list(cases());digests=[]
    for index,case in enumerate(corpus):
        for integrated in (False,True):
            retail=run(original,original_table,helpers,constants,case,integrated)
            current=run(candidate,table,helpers,constants,case,integrated)
            assert current==retail, ('Rebuild execution pair',index,integrated)
            digests.append(current)
        if index%100==0:print('Rebuild fixture',index+1,'/',len(corpus),flush=True)
    controls={};body=(ROOT/SOURCE).read_text();out=ROOT/'build'/FAMILY
    with tempfile.TemporaryDirectory(prefix='mutations-',dir=out) as directory:
        for name,before,after,actor in MUTATIONS:
            assert body.count(before)==1, ('Rebuild mutation site',name)
            case={'actors':[actor]}
            for integrated in (False,True):
                run(original,original_table,helpers,constants,case,integrated)
                run(candidate,table,helpers,constants,case,integrated)
            source=re.sub(r'#include "([^"]+)"',lambda m:'#include "'+str((ROOT/SOURCE).parent.joinpath(m[1]).resolve())+'"',body.replace(before,after))
            path=Path(directory)/(name+'.c');path.write_text(source)
            code,data,report=compile_candidate(path.relative_to(ROOT).as_posix(),'mutant_'+name,target,layout)
            try:run(code,data,helpers,constants,case,True)
            except (AssertionError,UcError) as error:controls[name]=dict(rejected=True,reason=str(error))
            else:raise AssertionError(('Rebuild accepted mutation',name))
            for integrated in (False,True):run(candidate,table,helpers,constants,case,integrated)
    fault_case={'actors':[dict(slot=0,category=8),dict(slot=199,category=1,kind=3)]}
    for fault in ('saved_integer','saved_fpu','read_guard','write_guard','code_guard','stack_guard','dispatch_table'):
        run(candidate,table,helpers,constants,fault_case,False)
        try:run(candidate,table,helpers,constants,fault_case,False,fault)
        except (AssertionError,UcError) as error:controls[fault]=dict(rejected=True,reason=str(error))
        else:raise AssertionError(('Rebuild accepted guest fault',fault))
        run(candidate,table,helpers,constants,fault_case,False)
    layout.verify()
    assert hashlib.sha256(Path(__file__).read_bytes()).hexdigest()==checker_hash
    assert hashlib.sha256((ROOT/'tools/scene_arrival_rebuild_model.py').read_bytes()).hexdigest()==model_hash
    for report in [comparison]+list(support_reports.values()):
        for path,sha in report['inputs_sha256'].items():assert hashlib.sha256((ROOT/path).read_bytes()).hexdigest()==sha,path
    for source,report in data_reports.items():assert data_input_hashes(source)==report['inputs_sha256']
    claimed=any(f['name']=='func_80020F8C' and f['source']==SOURCE for f in load_manifest())
    report=dict(comparison=comparison,matching_source_claim=claimed and comparison['matches'],
        fixtures=len(corpus),paired_boundary_cases=len(corpus),paired_integrated_cases=len(corpus),
        executions=len(corpus)*4,negative_controls=controls,checker_sha256=checker_hash,model_sha256=model_hash,
        case_corpus_sha256=hashlib.sha256(json.dumps(corpus,sort_keys=True).encode()).hexdigest(),
        outcomes_sha256=hashlib.sha256(''.join(digests).encode()).hexdigest(),
        support_comparisons=support_reports,data_comparisons=data_reports,
        versions={name:version(name) for name in ('unicorn','capstone','pyelftools')},
        limits=['Rebuild remains excluded until complete code and dispatch table match.',
                'Fixtures use acyclic lists within the 200-slot actor pool and at most 50 global group/secondary writes.',
                'Insertion boundary observers clobber caller-saved integer and FPU registers.',
                'Integrated pairs execute real insertion, copy, random and diagnostic helper code.',
                'Terminal fatal rendering returns synthetically; display hardware and unrestricted gameplay are not proved.'])
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print('Passed rebuild:',len(corpus),'fixtures in both layers;',len(controls),'rejected controls;',comparison['different_words'],'code words differ',flush=True)


if __name__=='__main__':main()
