"""Audit the excluded heap initializer against retail effects and independent oracles."""
from collections import Counter
from importlib.metadata import version
import hashlib
import itertools
import json
from unicorn import Uc, UcError, UC_ARCH_MIPS, UC_MODE_MIPS32, UC_MODE_BIG_ENDIAN
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE, UC_HOOK_MEM_READ
from unicorn import mips_const as registers
from compare_startup import compare_block, SymbolLayoutSnapshot
from manifest import load_manifest
from owned_sections import elf_sections_and_symbols
from rom import ROOT, validate

entry, head_slot = 0x8004DE8C, 0x8013EBF0

def physical(address):
    return address&0x1FFFFFFF

def expected(start,end):
    block=((start+3)&0xFFFFFFFF)&0xFFFFFFFC
    capacity=(((end&0xFFFFFFFC)-block-8)&0xFFFFFFFF)&0xFFFFFFFC
    header=capacity|1
    terminator=((end&0xFFFFFFFC)-4)&0xFFFFFFFF
    writes=[[hex(physical(head_slot)|0x80000000),4,hex(block)],
        [hex(physical(block)|0x80000000),4,hex(header)],
        [hex(physical(terminator)|0x80000000),4,hex(0xFFFFFFFE)]]
    return dict(block=block,header=header,terminator=terminator,writes=writes)

def run(binary,start,end,seed):
    oracle=expected(start,end)
    uc=Uc(UC_ARCH_MIPS,UC_MODE_MIPS32|UC_MODE_BIG_ENDIAN)
    for alias in (0,0x80000000,0xA0000000): uc.mem_map(alias,0x400000)
    def write(address,payload):
        address=physical(address)
        for alias in (0,0x80000000,0xA0000000): uc.mem_write(address|alias,payload)
    windows=set()
    for address in (head_slot,oracle['block'],oracle['terminator'],0x80300000):
        base=physical(address)&~0xFF
        assert 0x100<=base<0x3FFE00
        windows.add((base-0x100,0x300))
    for address,size in windows: write(address,bytes([0x5A])*size)
    write(0x80300000,bytes([0xA5])*64)
    write(head_slot,bytes.fromhex('deadbeef'))
    write(entry,binary)
    fp_value=0x3F800000+seed*0x400
    fp_init=0x800F0000
    fp_probe=0x800F0100
    fp_result=0x80214000
    def words(values): return b''.join(value.to_bytes(4,'big') for value in values)
    init=words([0x3C010000|(fp_value>>16),0x34210000|(fp_value&0xFFFF)]+
        [0x44810000|(i<<11) for i in range(20,32)]+[0x03E00008,0])
    probe=words([0x3C010000|(fp_result>>16),0x34210000|(fp_result&0xFFFF)]+
        [0xE4200000|(i<<16)|((i-20)*4) for i in range(20,32)]+[0x03E00008,0])
    write(fp_init,init)
    write(fp_probe,probe)
    write(fp_result,bytes([0xCC])*48)
    uc.reg_write(registers.UC_MIPS_REG_CP0_STATUS,uc.reg_read(registers.UC_MIPS_REG_CP0_STATUS)|(1<<29))
    uc.reg_write(registers.UC_MIPS_REG_RA,0x80000080)
    uc.emu_start(fp_init,0x80000080,count=50)
    assert uc.reg_read(registers.UC_MIPS_REG_PC)==0x80000080
    fp_phase=[False]
    fp_writes=[]
    writes,reads,violations=[],[],[]
    permitted_writes={physical(int(address,16)) for address,_,_ in oracle['writes']}
    permitted_reads={physical(head_slot),physical(oracle['block'])}
    def memory_write(machine,access,address,size,value,user):
        address=physical(address)
        value&=(1<<(size*8))-1
        if fp_phase[0]:
            assert size==4 and physical(fp_result)<=address<physical(fp_result)+48
            fp_writes.append([hex(address|0x80000000),size,hex(value)])
            write(address,value.to_bytes(size,'big'))
            return
        writes.append([hex(address|0x80000000),size,hex(value)])
        if size!=4 or address not in permitted_writes:
            violations.append(['unexpected_write',hex(address),size])
            machine.emu_stop()
        write(address,value.to_bytes(size,'big'))
    def memory_read(machine,access,address,size,value,user):
        address=physical(address)
        reads.append([hex(address|0x80000000),size])
        if size!=4 or address not in permitted_reads:
            violations.append(['unexpected_read',hex(address),size])
            machine.emu_stop()
    uc.hook_add(UC_HOOK_MEM_WRITE,memory_write)
    uc.hook_add(UC_HOOK_MEM_READ,memory_read)
    def code_guard(machine,address,size,user):
        valid = (fp_probe <= address < fp_probe+len(probe)) if fp_phase[0] else (entry <= address < entry+len(binary))
        if address != 0x80000080 and not valid:
            violations.append(['unexpected_code',hex(address)])
            machine.emu_stop()
    uc.hook_add(UC_HOOK_CODE,code_guard)
    returned=[False]
    def stop(machine,address,size,user):
        returned[0]=True
        machine.emu_stop()
    uc.hook_add(UC_HOOK_CODE,stop,begin=0x80000080,end=0x80000080)
    callers=['AT','V0','V1','A2','A3']+['T'+str(i) for i in range(10)]
    for i,name in enumerate(callers):
        uc.reg_write(getattr(registers,'UC_MIPS_REG_'+name),(0xB2340000+seed*0x400+i*0x20)&0xFFFFFFFF)
    saved=['S'+str(i) for i in range(8)]+['FP','GP','SP','RA']
    for i,name in enumerate(saved):
        value=(0xA2340000+seed*0x400+i*0x20)&0xFFFFFFFF
        if name=='GP': value=0x80310000
        if name=='SP': value=0x80300000
        if name=='RA': value=0x80000080
        uc.reg_write(getattr(registers,'UC_MIPS_REG_'+name),value)
    before={name:uc.reg_read(getattr(registers,'UC_MIPS_REG_'+name)) for name in saved}
    uc.reg_write(registers.UC_MIPS_REG_A0,start)
    uc.reg_write(registers.UC_MIPS_REG_A1,end)
    uc.emu_start(entry,0x80000090,count=500)
    assert not violations,violations
    assert returned[0] and uc.reg_read(registers.UC_MIPS_REG_PC)==0x80000080, ('did_not_return',hex(uc.reg_read(registers.UC_MIPS_REG_PC)))
    after={name:uc.reg_read(getattr(registers,'UC_MIPS_REG_'+name)) for name in saved}
    assert after==before,('abi_changed',before,after)
    assert writes==oracle['writes'],('ordered_write_mismatch',oracle['writes'],writes)
    assert bytes(uc.mem_read(physical(0x80300000),64))==bytes([0xA5])*64,'stack_canary_changed'
    snapshots={hex(address)+':'+str(size):hashlib.sha256(uc.mem_read(address,size)).hexdigest() for address,size in sorted(windows)}
    result=uc.reg_read(registers.UC_MIPS_REG_V0)
    fp_phase[0]=True
    returned[0]=False
    uc.emu_start(fp_probe,0x80000090,count=50)
    assert returned[0] and uc.reg_read(registers.UC_MIPS_REG_PC)==0x80000080 and len(fp_writes)==12
    assert not violations, violations
    fp_bytes=bytes(uc.mem_read(physical(fp_result),48))
    assert fp_bytes==fp_value.to_bytes(4,'big')*12,'floating_saved_state_changed'
    after['F20_F31']=fp_bytes.hex()
    return dict(writes=writes,snapshots=snapshots,abi=after,reads=reads,v0=result)

def independent_windows(start, end):
    oracle = expected(start, end)
    windows = {(physical(address) & ~0xFF) - 0x100 for address in
               (head_slot, oracle['block'], oracle['terminator'], 0x80300000)}
    images = {address: bytearray([0x5A]) * 0x300 for address in windows}
    def apply(address, data):
        address = physical(address)
        for base, image in images.items():
            lower, upper = max(base, address), min(base + len(image), address + len(data))
            if lower < upper:
                image[lower-base:upper-base] = data[lower-address:upper-address]
    apply(0x80300000, bytes([0xA5]) * 64)
    apply(head_slot, bytes.fromhex('deadbeef'))
    for address, size, value in oracle['writes']:
        apply(int(address, 16), int(value, 16).to_bytes(size, 'big'))
    return {hex(address) + ':768': hashlib.sha256(image).hexdigest()
            for address, image in sorted(images.items())}


def fixtures():
    cases = []
    for start, end, capacity in itertools.product(range(8), range(8), (16, 20, 64, 1024)):
        cases.append(('ordinary', 0x80204000 + start, 0x80204000 + capacity + end))
    for start, end, capacity in itertools.product(range(-3, 1), range(4), (0, 4, 8, 64)):
        cases.append(('head_collision', head_slot + start, head_slot + capacity + end))
    for start, end in itertools.product(range(8), range(4)):
        cases.append(('terminator_collision', head_slot - 0x100 + start, head_slot + 4 + end))
    for start, end, delta in itertools.product(range(4), range(4), (-16, -4, 0, 4)):
        cases.append(('undersized', 0x80208000 + start, 0x80208000 + delta + end))
    for start, end, capacity in itertools.product(range(4), range(4), (16, 64)):
        cases.append(('uncached_inputs', 0xA020C000 + start, 0xA020C000 + capacity + end))
    cases.append(('retail_caller_bounds', 0x80225800, 0x803CDFFC))
    assert len(cases) == 449
    return cases


def main():
    rom = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(rom)
    source = 'src/game/heap/initialize.c'
    assert not any(record['source'] == source for record in load_manifest())
    layout = SymbolLayoutSnapshot()
    family = 'heap-initializer-execution'
    comparison = compare_block('initialize', source, entry, 0x4EA8C, 0x4EAD8, rom, family, layout)
    build = ROOT / 'build' / family / 'initialize'
    sections, symbols = elf_sections_and_symbols(build / 'initialize.raw.o')
    natural = symbols['func_8004DE8C']['size']
    raw_text = sections['.text']['bytes']
    assert natural == 76 and not any(raw_text[natural:]), 'Function bytes and zero alignment differ'
    candidate = (build / 'initialize.bin').read_bytes()
    assert len(candidate) == natural
    retail = rom[0x4EA8C:0x4EAD8]
    trace = hashlib.sha256()
    cases = fixtures()
    v0_matches = 0
    for index, (label, start, end) in enumerate(cases):
        expected_result = run(retail, start, end, index % 8)
        actual = run(candidate, start, end, index % 8)
        oracle = expected(start, end)
        windows = independent_windows(start, end)
        for result in (expected_result, actual):
            assert result['writes'] == oracle['writes']
            assert result['snapshots'] == windows
        for field in ('writes', 'snapshots', 'abi'):
            assert actual[field] == expected_result[field], (index, field)
        assert expected_result['v0'] == oracle['terminator']
        v0_matches += actual['v0'] == expected_result['v0']
        trace.update(json.dumps([label, start, end, index % 8, actual], sort_keys=True).encode())
        if (index + 1) % 100 == 0:
            print('Compared', index + 1, 'heap fixtures.', flush=True)

    ordinary = (0x80204000, 0x80204010)
    collision = (head_slot, head_slot + 64)
    controls = [
        ('extra_write', bytes.fromhex('ac800000') + retail, ordinary),
        ('wrong_terminator', retail[:-4] + bytes.fromhex('ac4c0004'), ordinary),
        ('saved_integer_clobber', bytes.fromhex('00008025') + retail, ordinary),
        ('saved_float_clobber', bytes.fromhex('4480a000') + retail, ordinary),
        ('unexpected_read', bytes.fromhex('8f8d0000') + retail, ordinary),
        ('unexpected_code', bytes.fromhex('0803c00000000000') + retail, ordinary),
        ('missing_return', retail[:-8] + bytes(4) + retail[-4:], ordinary),
    ]
    original = (ROOT / source).read_text()
    mutations = [
        ('free_bit', 'header = size | 1;', 'header = size | 3;', ordinary),
        ('sentinel', '*terminator = -2;', '*terminator = -3;', ordinary),
        ('head_reload', 'terminator = block + ((header >> 2) + 1);',
         'terminator = (unsigned int *)D_8013EBF0 + ((header >> 2) + 1);', collision),
    ]
    mutation_rows = []
    mutant_directory = ROOT / 'build' / family / 'mutants'
    mutant_directory.mkdir(exist_ok=True)
    for name, before, after, case in mutations:
        assert original.count(before) == 1
        mutant = mutant_directory / (name + '.c')
        mutant.write_text(original.replace(before, after))
        mutant_comparison = compare_block(name, mutant.relative_to(ROOT).as_posix(), entry,
                                          0x4EA8C, 0x4EAD8, rom, family, layout)
        binary = (ROOT / 'build' / family / name / (name + '.bin')).read_bytes()
        controls.append((name, binary, case))
        mutation_rows.append(dict(name=name, source_sha256=hashlib.sha256(mutant.read_bytes()).hexdigest(),
                                  comparison=mutant_comparison))
    control_rows = []
    for name, binary, (start, end) in controls:
        positive = run(retail, start, end, 3)
        assert positive['snapshots'] == independent_windows(start, end)
        assert run(candidate, start, end, 3)['snapshots'] == positive['snapshots']
        try:
            result = run(binary, start, end, 3)
            assert result['snapshots'] == independent_windows(start, end)
        except (AssertionError, UcError) as error:
            control_rows.append(dict(name=name, detected=True, reason=str(error)[:500],
                                     code_sha256=hashlib.sha256(binary).hexdigest()))
        else:
            raise AssertionError(('Control was not rejected', name))
        print('Detected heap control:', name, flush=True)
    layout.verify()
    report = dict(behavior_matches=True, instruction_matches=comparison['matches'],
                  source_ownership_added=0, source=source,
                  source_sha256=hashlib.sha256((ROOT / source).read_bytes()).hexdigest(),
                  checker_sha256=hashlib.sha256((ROOT / 'tools/check_heap_initializer.py').read_bytes()).hexdigest(),
                  compiler_comparison=comparison, natural_function_bytes=natural,
                  raw_text_bytes=len(raw_text), zero_alignment_bytes=len(raw_text)-natural,
                  retail_code_sha256=hashlib.sha256(retail).hexdigest(),
                  candidate_code_sha256=hashlib.sha256(candidate).hexdigest(),
                  cases=len(cases), paired_comparisons=len(cases), principal_fixture_executions=2*len(cases),
                  distinct_argument_pairs=len({(start, end) for _, start, end in cases}),
                  case_classes=dict(Counter(label for label, _, _ in cases)),
                  candidate_v0_matches_retail_cases=v0_matches, return_declaration_unresolved=True,
                  trace_sha256=trace.hexdigest(), controls=control_rows, source_mutations=mutation_rows,
                  callee_stubs=0, emulator=dict(name='Unicorn', version=version('unicorn')),
                  limits=['449 finite fixtures validate ordered writes, independent memory windows, permitted accesses, return PC, saved integer/F20-F31 state, SP/GP/RA and stack canaries.',
                          'V0 is observed but excluded from equivalence under the existing void interface; the caller ignores the result.',
                          'Collisions, undersized bounds and uncached pointers are diagnostic cases, not evidence of valid game allocations.',
                          'These checks do not prove exact instructions, hardware behavior or complete gameplay.'])
    output = ROOT / 'build' / family / 'proof.json'
    output.write_text(json.dumps(report, indent=2) + chr(10))
    print('Passed', len(cases), 'heap pairs and', len(controls), 'controls;',
          len(comparison['different_words']), 'differing words; proof:', output, flush=True)


if __name__ == '__main__':
    main()
