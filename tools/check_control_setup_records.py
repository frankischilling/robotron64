"""Guard complete control-setup records with the matching menu display routine."""
from pathlib import Path
import hashlib,itertools,json
from unicorn import UC_HOOK_CODE,UC_HOOK_MEM_READ,UC_HOOK_MEM_WRITE,UC_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_boundary_boss import environment,CLOBBER,signed,divide
from check_actor_group_path import word,SENTINEL
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block,SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols
from rom import ROOT as r,validate
from compare_data import compare_unit,comparison_directory
from owned_sections import source_sections
from importlib.metadata import version

ENTRY,NAV,STACK=0x8002741C,0x800AEE98,0x80300000
PAGE,LABELS,CHOICES=0x800771E8,0x800770A8,0x80077088
PLAYERS=(0x8009B1C4,0x8009BF78)
STUBS=(0x80000518,0x800011AC,0x8000177C,0x80000E74,0x80000B7C,0x80001270,0x8003BCC4,0x8004CDE8)
LABEL_TEXT=(b'\\\\cancel',b'\\\\use setup',b'\\control stick 4 fires',b'\\control stick 3 ',b'\\player 2 ',b'control stick 2 fires',b'control stick 1 ',b'player 1 ')
CHOICE_TEXT=(b'walks',b'fires',b'walks',b'fires')

def run(code,image,target,case):
    first,second,selected,alternate,tick,rng,properties=case
    uc,write,execute,read,finish_call=environment(code,[]);fixtures={}
    def seed(address,data):fixtures[address]=bytearray(data)
    for address,size in (((CHOICES,404),(0x80093398,184),(NAV,100),(0x800761F4,4),(0x8009EF94,4))+
                         tuple((p,4) for p in PLAYERS)):
        seed(address-16,b'\xA5'*16+bytes(size)+b'\xB6'*16)
    seed(STACK-0x300,b'\xC7'*0x340)
    def put(state,address,data):
        for base,storage in state.items():
            if base<=address and address+len(data)<=base+len(storage):storage[address-base:address-base+len(data)]=data;return
        raise AssertionError(('Fixture write escaped extent',hex(address),len(data)))
    for address,size in ((CHOICES,404),(0x80093398,184)):
        start=address-0x80000000+0xC00;put(fixtures,address,target[start:start+size])
    put(fixtures,NAV+4,word(PAGE));put(fixtures,NAV+0x44,word(123)+word(-234)+word(345))
    put(fixtures,NAV+0x50,word(LABELS+selected*40 if selected>=0 else 0))
    put(fixtures,PLAYERS[0],word(first));put(fixtures,PLAYERS[1],word(second))
    put(fixtures,0x800761F4,word(alternate));put(fixtures,0x8009EF94,word(tick))
    expected={a:bytearray(b) for a,b in fixtures.items()};actual={a:bytearray(b) for a,b in fixtures.items()}
    for address,data in image:put(actual,address,data)
    for address,data in actual.items():write(address,bytes(data))
    expected_trace=[];expected_properties={};handle=100
    def draw(slot,y,title,mode):
        return ['draw',[slot,123,-40234,345+y*130-(45500 if title else 39000),2278,0,0,2500,0,0,0,1,1,20 if title else 32767,mode]]
    expected_trace += [['convert',b'control setup'.hex()],['create',PAGE+4,b'control setup'.hex(),1500,11,0,0],draw(100,260-(60 if alternate else 0),True,180)]
    put(expected,PAGE+4,word(handle));y=260
    for i in range(7,-1,-1):
        handle+=1;label=LABELS+i*40;text=LABEL_TEXT[i];expected_properties[handle]=properties
        expected_trace += [['convert',text.hex()],['create',label+16,text.hex(),1000,11,1,0]]
        put(expected,label+16,word(handle))
        if selected==i and tick:
            expected_trace.append(['random',rng&0xFFFFFFFF]);remainder=signed(rng)>>3;remainder-=divide(remainder,20000)*20000
            if (remainder&0xFFFFFFFF)//(tick&0xFFFFFFFF)==0:
                expected_trace.append(['properties',handle,expected_properties[handle]])
                if expected_properties[handle]&2:
                    expected_trace.append(['properties',handle,expected_properties[handle]])
                    if not expected_properties[handle]&16:
                        expected_trace.append(['flags',handle,16,0]);expected_properties[handle]|=16
        if i in (3,6):
            suffix=CHOICE_TEXT[first if i==6 else second]
            expected_trace += [['decode',suffix.hex()],['convert',suffix.hex()],['suffix',handle,len(text)+1,suffix.hex()]]
        expected_trace += [['properties',handle,expected_properties[handle]],draw(handle,y,False,1 if expected_properties[handle]&2 else 24)]
        y+=37 if i in (0,1) else 28
    trace=[];state={};handle_count=[99]
    def string(address):
        value=bytearray()
        for i in range(64):
            byte=read(address+i,1)[0]
            if not byte:return value.hex()
            value.append(byte)
        raise AssertionError('Boundary string lacks bounded terminator')
    def stub(uc,address,size,user):
        args=[uc.reg_read(reg) for reg in (regs.UC_MIPS_REG_A0,regs.UC_MIPS_REG_A1,regs.UC_MIPS_REG_A2,regs.UC_MIPS_REG_A3)]
        sp=uc.reg_read(regs.UC_MIPS_REG_SP)
        if address==0x80000518:trace.append(['convert',string(args[0])]);finish_call(args[0])
        elif address==0x8003BCC4:trace.append(['decode',string(args[0])]);finish_call(args[0])
        elif address==0x800011AC:
            trace.append(['create',args[0],string(args[1]),signed(args[2]),signed(args[3]),int.from_bytes(read(sp+16,4),'big'),int.from_bytes(read(sp+20,4),'big')])
            assert args[0]==PAGE+4 or args[0] in [LABELS+i*40+16 for i in range(8)]
            handle_count[0]+=1;state[handle_count[0]]=properties;write(args[0],word(handle_count[0]));finish_call(handle_count[0])
        elif address==0x8000177C:
            values=args+[int.from_bytes(read(sp+16+i*4,4),'big') for i in range(11)]
            trace.append(['draw',[signed(x) for x in values]]);finish_call()
        elif address==0x80000E74:trace.append(['properties',args[0],state[args[0]]]);finish_call(state[args[0]])
        elif address==0x80000B7C:trace.append(['flags']+args[:3]);state[args[0]]=(state[args[0]]|args[1])&~args[2];finish_call()
        elif address==0x80001270:trace.append(['suffix',args[0],args[1],string(args[2])]);finish_call(0)
        else:assert address==0x8004CDE8;trace.append(['random',rng&0xFFFFFFFF]);finish_call(rng&0xFFFFFFFF)
    for address in STUBS:uc.hook_add(UC_HOOK_CODE,stub,begin=address,end=address)
    code_ranges=[(a&0x1FFFFFFF,(a&0x1FFFFFFF)+len(b)) for a,b in code]+[(CLOBBER&0x1FFFFFFF,(CLOBBER&0x1FFFFFFF)+92)]
    readable=[((a+16)&0x1FFFFFFF,(a+len(b)-16)&0x1FFFFFFF) for a,b in fixtures.items() if a!=STACK-0x300]+code_ranges
    readable.append(((STACK-0x200)&0x1FFFFFFF,(STACK+16)&0x1FFFFFFF))
    writable=([((STACK-0x200)&0x1FFFFFFF,(STACK+16)&0x1FFFFFFF),(PAGE+4&0x1FFFFFFF,PAGE+8&0x1FFFFFFF)]+
             [(LABELS+i*40+16&0x1FFFFFFF,LABELS+i*40+20&0x1FFFFFFF) for i in range(8)])
    def guard(uc,access,address,size,value,user):
        address&=0x1FFFFFFF;ranges=writable if access==UC_MEM_WRITE else readable
        assert any(a<=address and address+size<=b for a,b in ranges),('Memory escaped fixture',hex(address),size)
    def code_guard(uc,address,size,user):
        assert address in STUBS+(SENTINEL,) or any(a<=address&0x1FFFFFFF and (address&0x1FFFFFFF)+size<=b for a,b in code_ranges),hex(address)
    uc.hook_add(UC_HOOK_MEM_READ|UC_HOOK_MEM_WRITE,guard);uc.hook_add(UC_HOOK_CODE,code_guard)
    uc.reg_write(regs.UC_MIPS_REG_GP,0x8007F123);execute(ENTRY);assert uc.reg_read(regs.UC_MIPS_REG_GP)==0x8007F123
    assert trace==expected_trace,(case,trace,expected_trace)
    for address,data in expected.items():
        if address==STACK-0x300:
            assert read(address,0x100)==bytes(data[:0x100]);assert read(STACK+16,48)==bytes(data[0x310:])
        else:assert read(address,len(data))==bytes(data),(case,hex(address))
    return trace

def main():
    target=(r/'baseroms/us/baserom.z64').read_bytes();validate(target);layout=SymbolLayoutSnapshot();compiled=[];original=[];comparisons={}
    for name,source,first,last in MATCHING_BLOCKS:
        if name not in ('menu_display','game_memory'):continue
        start=first-0x80000000+0xC00;q=compare_block(name,source,first,start,start+last-first,target,'control-setup-execution',layout)
        assert q['matches'];comparisons[name]=q;compiled.append((first,(r/'build/control-setup-execution'/name/(name+'.bin')).read_bytes()));original.append((first,target[start:start+last-first]))
    image=[];data_comparisons={}
    for leaf in ('choices','labels','page','text','text_details'):
        source='src/game/save_menus/control_setup/'+leaf+'.c';records=source_sections(source)
        data_comparisons[source]=compare_unit(source,records,target,layout)
        sections,_=elf_sections_and_symbols(comparison_directory(source)/'compiled.elf')
        image += [(rec['vram'],sections[rec['section']]['bytes']) for rec in records]
    cases=list(itertools.product(range(4),range(4),range(-1,8),range(2),(0,), (0,), (0,2,18)))
    cases += [(1,2,selected,0,tick,rng,properties) for selected,tick,rng,properties in itertools.product(range(8),(1,-1),(-8,8,160000),(0,2,18))]
    digest=hashlib.sha256()
    for i,case in enumerate(cases):
        a=run(compiled,image,target,case);b=run(original,[],target,case);assert a==b;digest.update(json.dumps([case,a]).encode())
        if i and i%200==0:print('Checked complete eight-label display cases:',i,flush=True)
    mutations=[]
    for address,value in ((CHOICES,word(0)),(LABELS+7*40+24,word(0)),(0x80093440,b'X')):
        altered=[]
        for base,data in image:
            if base<=address and address+len(value)<=base+len(data):
                data=bytearray(data);data[address-base:address-base+len(value)]=value;data=bytes(data)
            altered.append((base,data))
        try:run(compiled,altered,target,(0,2,6,0,0,0,2))
        except (AssertionError,ValueError):mutations.append(hex(address))
        else:raise AssertionError(('Undetected data mutation',hex(address)))
    report=dict(matches=True,source_instruction_bytes_added=0,initialized_bytes_added=588,bss_bytes_added=0,unicorn_version=version('unicorn'),data_comparisons=data_comparisons,cases=len(cases),executions=len(cases)*2,mutations_detected=mutations,trace_sha256=digest.hexdigest(),checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),comparisons=comparisons,
                limits=['Text conversion, choice decoding, allocation, flags, RNG and draw submission use O32 boundary stubs.',
                        'Complete freshly matching display and string helper blocks execute on all eight real label records and all four choice entries.',
                        'The proof checks all fifteen draw arguments, label order, spacing, suffixes, whole fixture memory, bounded accesses, SP, GP and saved integer registers.',
                        'Menu activation, control callbacks and gameplay rendering are not executed. No new instruction ownership is granted.'])
    (r/'build/control-setup-execution/report.json').write_text(json.dumps(report,indent=2)+'\n');print('Complete control setup display:',len(cases),'cases,',len(cases)*2,'executions and',len(mutations),'detected mutations.',flush=True)

if __name__=='__main__':main()
