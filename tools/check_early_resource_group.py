
"""Verify the complete first early resource group, selector and command writes."""
import hashlib,json,struct
from pathlib import Path
from unicorn import UC_HOOK_CODE,UC_HOOK_MEM_READ,UC_HOOK_MEM_WRITE,UC_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine,SENTINEL,word
from compare_runtime import MATCHING_BLOCKS
from compare_startup import SymbolLayoutSnapshot,compare_block
from compare_data import compare_unit,comparison_directory
from compiler import compile_source
from owned_sections import source_sections,elf_sections_and_symbols
from rom import ROOT,validate

BASE,SELECTOR,COMMAND=0x8009EA18,0x8009EE04,0x80210010
ENTRY,RESET=0x8000EC30,0x8000ECD0
STACK=0x80300000
SOURCE='src/game/actor_resources/early.c'
BUILD=ROOT/'build/early-resource-group-check'


def run(code,entry,seed,values):
    uc,write,execute=machine(code,[])
    initial=bytes((i*37+seed)&255 for i in range(1008))
    expected=bytearray(initial)
    command=word(27)+word(0)+word(0x7139A504)+b''.join(word(v) for v in values)
    wanted_reads={};wanted_writes={}
    if entry==ENTRY:
        expected[:4]=word(5)
        expected[964:1004]=b''.join(word(v) for v in values)
        expected[1004:]=word(0)
        wanted_reads={COMMAND+4:4,**{COMMAND+12+i*4:4 for i in range(10)}}
        wanted_writes={BASE:4,**{BASE+964+i*4:4 for i in range(10)},SELECTOR:4}
    else:
        assert entry==RESET
        expected[1004:]=word(-1)
        wanted_writes={SELECTOR:4,STACK:4}
    write(BASE-16,b'\xa5'*16+initial+b'\xb6'*16)
    write(COMMAND-16,b'\xc7'*16+command+b'\xd8'*16)
    write(STACK-16,b'\xe9'*64)
    uc.reg_write(regs.UC_MIPS_REG_A0,COMMAND)
    uc.reg_write(regs.UC_MIPS_REG_GP,0xA571AB93)
    saved={getattr(regs,'UC_MIPS_REG_'+n):uc.reg_read(getattr(regs,'UC_MIPS_REG_'+n)) for n in ('S0','S1','S2','S3','S4','S5','S6','S7','FP','SP','GP','RA')}
    reads,writes={},{}
    def guard(uc,kind,address,size,value,user):
        address=address&0x1fffffff|0x80000000
        wanted=wanted_writes if kind==UC_MEM_WRITE else wanted_reads
        counts=writes if kind==UC_MEM_WRITE else reads
        assert wanted.get(address)==size,('field access',hex(address),size)
        counts[address]=counts.get(address,0)+1
        assert counts[address]==1,('repeated field access',hex(address))
        if kind==UC_MEM_WRITE:
            offset=address-BASE
            wanted_value=COMMAND if address==STACK else int.from_bytes(expected[offset:offset+size],'big')
            assert value&0xffffffff==wanted_value,('field value',hex(address))
    def instruction(uc,address,size,user):
        assert address==SENTINEL or any(a<=address and address+size<=a+len(blob) for a,blob in code),('instruction bounds',hex(address))
    uc.hook_add(UC_HOOK_CODE,instruction)
    uc.hook_add(UC_HOOK_MEM_READ|UC_HOOK_MEM_WRITE,guard)
    execute(entry)
    assert all(uc.reg_read(reg)==value for reg,value in saved.items()),'O32 preservation'
    assert reads==dict.fromkeys(wanted_reads,1) and writes==dict.fromkeys(wanted_writes,1),'complete field traces'
    assert bytes(uc.mem_read((BASE-16)&0x1fffffff,1040))==b'\xa5'*16+bytes(expected)+b'\xb6'*16,'complete group and selector'
    assert bytes(uc.mem_read((COMMAND-16)&0x1fffffff,84))==b'\xc7'*16+command+b'\xd8'*16,'complete read-only command'
    expected_stack=bytearray(b'\xe9'*64)
    if entry==RESET:expected_stack[16:20]=word(COMMAND)
    assert bytes(uc.mem_read((STACK-16)&0x1fffffff,64))==bytes(expected_stack),'complete stack and canaries'
    return {'memory_sha256':hashlib.sha256(expected).hexdigest(),'reads':reads,'writes':writes}


def main():
    BUILD.mkdir(parents=True,exist_ok=True)
    inputs={name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in ('tools/check_early_resource_group.py','tools/check_actor_group_path.py','include/actor_resource_internal.h','include/text.h','src/game/actor_resources/early.c','config/owned_sections.json','config/runtime_symbols.ld','config/startup_symbols.ld','linker_scripts/us.ld')}
    target=(ROOT/'baseroms/us/baserom.z64').read_bytes();validate(target);layout=SymbolLayoutSnapshot()
    records=source_sections(SOURCE)
    assert len(records)==1 and records[0]['rom'] is None and records[0]['size']==1008
    assert records[0]['vram']==BASE and records[0]['symbols']=={'D_8009EA18':0,'D_8009EE04':1004}
    data=compare_unit(SOURCE,records,target,layout);assert data['matches']
    sections,symbols=elf_sections_and_symbols(comparison_directory(SOURCE)/'compiled.elf')
    assert sections[records[0]['section']]['size']==1008 and sections[records[0]['section']]['type']==8
    assert symbols['D_8009EA18']['size']==1004 and symbols['D_8009EE04']['size']==4
    probe=BUILD/'layout.c'
    probe.write_text('#include "'+str(ROOT/'include/actor_resource_internal.h')+'"\n'+
        '#define OFFSET(t,f) ((unsigned int)&((t *)0)->f)\n'+
        'struct GroupAlignment { char c; ActorResourceGroupInternal value; };\n'+
        'struct EntryAlignment { char c; ActorGroupedResourceEntryInternal value; };\n'+
        'const unsigned int layout[] = { sizeof(TextGlyphResource), sizeof(ActorGroupedResourceEntryInternal), sizeof(ActorResourceGroupInternal), OFFSET(struct GroupAlignment,value), OFFSET(struct EntryAlignment,value), OFFSET(ActorResourceGroupInternal,count), OFFSET(ActorResourceGroupInternal,resources), OFFSET(ActorResourceGroupInternal,parameters), OFFSET(ActorResourceGroupInternal,resources[0].resource.flags06), OFFSET(ActorResourceGroupInternal,resources[0].resource.playbackSpeed), OFFSET(ActorResourceGroupInternal,resources[9].resource.flags06), OFFSET(ActorResourceGroupInternal,parameters[9]) };\n')
    obj=BUILD/'layout.o';compile_source(probe,obj);sections,symbols=elf_sections_and_symbols(obj)
    expected_layout=[88,96,1004,4,4,0,4,964,10,84,874,1000]
    actual_layout=list(struct.unpack('>12I',sections['.rodata']['bytes'][:48]))
    assert actual_layout==expected_layout and symbols['layout']['size']==48
    original,compiled,reports=[],[],{}
    for name,source,first,last in MATCHING_BLOCKS:
        if source not in ('src/game/early_resource_arguments.c','src/game/early_global_reset.c'):continue
        offset=first-0x80000000+0xC00
        result=compare_block(name,source,first,offset,offset+last-first,target,'early-resource-group-check',layout)
        assert result['matches'];reports[name]=result
        original.append((first,target[offset:offset+last-first]))
        compiled.append((first,(BUILD/name/(name+'.bin')).read_bytes()))
    assert len(reports)==2
    # Assemble six deterministic value families without relying on compiler memory effects.
    sets=[[0]*10,[-1]*10,[0x7fffffff]*10,[-0x80000000]*10,list(range(10)),[(-1 if i&1 else 1)*(i*73951+173) for i in range(10)]]
    digest=hashlib.sha256();pairs=0
    for seed in (0,73,173,255):
        for values in sets:
            for entry in (ENTRY,RESET):
                a=run(compiled,entry,seed,values);b=run(original,entry,seed,values)
                assert a==b;digest.update(json.dumps([seed,values,entry,a],sort_keys=True).encode());pairs+=1
    mutations=[]
    command_image=next(blob for a,blob in compiled if a==ENTRY)
    words=[int.from_bytes(command_image[i:i+4],'big') for i in range(0,len(command_image),4)]
    constants=[i for i,v in enumerate(words) if v>>26==9 and v>>21&31==0 and v&65535==5]
    stores=[i for i,v in enumerate(words) if v>>26==0x2b and v&65535==0]
    assert len(constants)==1 and stores
    for name,index,replacement in [('count_four',constants[0],(words[constants[0]]&0xffff0000)|4),('count_halfword',stores[0],(words[stores[0]]&0x03ffffff)|(0x29<<26))]:
        bad=bytearray(command_image);bad[index*4:index*4+4]=word(replacement)
        altered=[(a,bytes(bad) if a==ENTRY else blob) for a,blob in compiled]
        try:run(altered,ENTRY,173,sets[-1])
        except AssertionError as error:mutations.append({'name':name,'rejected':True,'reason':str(error)})
        else:raise AssertionError('Missed negative control: '+name)

    layout.verify()
    assert all(hashlib.sha256((ROOT/name).read_bytes()).hexdigest()==value for name,value in inputs.items())
    report={'matches':True,'additional_bss_bytes':528,'complete_storage_size':1008,'group_size':1004,'selector_size':4,'layout':actual_layout,'layout_checks':12,'paired_cases':pairs,'executions':pairs*2,'digest':digest.hexdigest(),'data_comparison':data,'code_comparisons':reports,'mutations':mutations,'inputs_sha256':inputs,'scope':'Only the complete first group is source-owned. Commands use index zero. Larger indexed views do not establish additional array storage.'}
    (BUILD/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print('Early resource group:',1008,'complete BSS bytes;',pairs,'guarded pairs;',len(mutations),'negative controls')


if __name__=='__main__':main()
