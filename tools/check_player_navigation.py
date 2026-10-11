"""Compare the full navigation helper and audit finite real-callee execution.

The actor-kind contradiction and original five-argument search contract remain
part of the source. The angle lookup table is read from retail memory; the source
sine table and all ten executing helpers are independently compared in full.
"""
from pathlib import Path
import hashlib,itertools,json,os,random,struct,subprocess,sys
from unicorn import Uc,UC_ARCH_MIPS,UC_MODE_MIPS32,UC_MODE_BIG_ENDIAN,UC_HOOK_CODE,UC_HOOK_MEM_READ,UC_HOOK_MEM_WRITE
from unicorn import mips_const as mc
from rom import ROOT
n=ROOT;os.chdir(n)
from compiler import compile_source
from compare_startup import SymbolLayoutSnapshot,external_assignments,compare_block,comparison_input_hashes
from owned_sections import elf_sections_and_symbols
from rom import validate
rom=(n/'baseroms/us/baserom.z64').read_bytes();validate(rom);layout=SymbolLayoutSnapshot()
out=n/'build/player-navigation-audit';out.mkdir(parents=True,exist_ok=True)
manifest=json.loads((n/'config/functions.json').read_text())
names=['func_8000DF14','func_80027D8C','func_8003CC58','func_8003CC88','func_8003CD4C','func_8003CD70','func_8003CEF4','func_8004CEF0','func_8005FBB0','func_8005FC20']
helpers={};receipts=[];compiled={};input_hashes={}
for name in names:
    row=next(r for r in manifest if r['name']==name);source=row['source']
    for filename,digest in comparison_input_hashes(source).items():
        assert filename not in input_hashes or input_hashes[filename]==digest,('Input changed during audit',filename)
        input_hashes[filename]=digest
    if source not in compiled:
        raw=out/(Path(source).stem+'.o');compile_source(source,raw)
        undefined={line.split()[-1] for line in subprocess.check_output(['mips-linux-gnu-nm','-u',str(raw)],text=True).splitlines() if line.strip()}
        ld=raw.with_suffix('.ld');ld.write_text(external_assignments(undefined,layout.addresses)+'SECTIONS { .text 0x%X : SUBALIGN(4) { *(.text) } .data 0x8008DBB0 : SUBALIGN(4) { *(.data) } /DISCARD/ : { *(.reginfo .MIPS.abiflags) } }\n'%row['section_vram'])
        elf=raw.with_suffix('.elf');subprocess.run(['mips-linux-gnu-ld','-EB','-T',str(ld),'-e',name,'-o',str(elf),str(raw)],check=True,capture_output=True)
        compiled[source]=elf_sections_and_symbols(elf)
    sections,symbols=compiled[source];symbol=symbols[name];offset=symbol['value']-sections['.text']['address'];code=sections['.text']['bytes'][offset:offset+symbol['size']]
    assert symbol['value']==row['vram'] and symbol['size']==row['size'] and code==rom[row['rom']:row['rom']+row['size']],name
    helpers[row['vram']]=code;receipts.append(dict(name=name,source=source,instruction_bytes=len(code),sha256=hashlib.sha256(code).hexdigest()))
    if name=='func_8005FBB0':assert sections['.data']['bytes']==rom[0x8E7B0:0x8EFB0],'Whole 2048-byte sine table'
(out/'helpers.json').write_text(json.dumps(receipts,indent=2)+'\n')
START=0x800330F8;SP=0x807F0000;STOP=0x807FFF00
ACTOR=0x80500000;NODES=0x80501000;RESOURCES=0x80502000;PLAYER=0x80504000;OUTPUT=0x80506000
def reg(i):return getattr(mc,'UC_MIPS_REG_'+str(i))
def word(value):return struct.pack('>I',value&0xFFFFFFFF)
def run(fixture,candidate=None):
    uc=Uc(UC_ARCH_MIPS,UC_MODE_MIPS32|UC_MODE_BIG_ENDIAN);uc.mem_map(0,0x800000)
    read,write=uc.mem_read,uc.mem_write
    uc.mem_read=lambda a,s:read(a&0x1FFFFFFF,s)
    uc.mem_write=lambda a,b:write(a&0x1FFFFFFF,b)
    uc.mem_write(0x80000000,rom[0xC00:0x9BC00])
    for address,code in helpers.items():uc.mem_write(address,code)
    code=rom[0x33CF8:0x344CC] if candidate is None else elf_sections_and_symbols(candidate)[0]['.text']['bytes']
    uc.mem_write(START,code)
    actor=bytearray(0x7C);struct.pack_into('>iii',actor,0x60,*fixture['position'],0);uc.mem_write(ACTOR,bytes(actor))
    uc.mem_write(PLAYER,bytes(0xDB4));uc.mem_write(PLAYER+0x6C,word(fixture['weapon']))
    uc.mem_write(OUTPUT,word(123456)+word(-654321))
    nodes=fixture['nodes']
    for i,node in enumerate(nodes):
        a=bytearray(0x7C);a[0x1C]=node['kind'];a[0x1F]=node['animation'];struct.pack_into('>I',a,0x24,RESOURCES+i*0x58);struct.pack_into('>iii',a,0x60,node['x'],node['y'],0);struct.pack_into('>I',a,0x78,NODES+(i+1)*0x7C if i+1<len(nodes) else 0)
        resource=bytearray(0x58);resource[2]=node['limit'];uc.mem_write(RESOURCES+i*0x58,bytes(resource));uc.mem_write(NODES+i*0x7C,bytes(a))
    for address,value in [(0x800AA708,NODES if nodes else 0),(0x800BA74C,fixture['mode']),(0x8009EFA4,fixture['phase'])]:uc.mem_write(address,word(value))
    uc.mem_write(SP-1024,bytes((i*29+71)&255 for i in range(1060)))
    uc.mem_write(SP+0x10,word(fixture['speed']))
    preserved={i:0x22330000+i*0x101 for i in (*range(16,24),28,30)}
    for i,v in preserved.items():uc.reg_write(reg(i),v)
    for i,v in enumerate([PLAYER,ACTOR,OUTPUT,OUTPUT+4],4):uc.reg_write(reg(i),v)
    uc.reg_write(reg(29),SP);uc.reg_write(reg(31),STOP)
    readable=[(ACTOR,ACTOR+0x7C),(NODES,NODES+len(nodes)*0x7C),(RESOURCES,RESOURCES+len(nodes)*0x58),(PLAYER,PLAYER+0xDB4),(OUTPUT,OUTPUT+8),(SP-1024,SP+36),(0x800AA708,0x800AA70C),(0x800BA74C,0x800BA750),(0x8009EFA4,0x8009EFA8),(0x8007C338,0x8007C438),(0x8008DBB0,0x8008E3B0)]
    writable=[(OUTPUT,OUTPUT+8),(SP-1024,SP+36)]
    seen=set();trace=[];dirty=set();steps=0;active=[]
    def inside(address,size,ranges):return any(a<=address and address+size<=b for a,b in ranges)
    def rh(u,access,address,size,value,user):
        address=address|0x80000000;assert inside(address,size,readable),('Read outside fixture',hex(u.reg_read(mc.UC_MIPS_REG_PC)),hex(address),size)
    def wh(u,access,address,size,value,user):
        address=address|0x80000000;assert inside(address,size,writable),('Write outside output/stack',hex(address),size)
        if OUTPUT<=address<OUTPUT+8:dirty.update(range(address,address+size))
    def ch(u,address,size,user):
        nonlocal steps
        steps+=1
        if address==STOP:u.emu_stop();return
        if active and address==active[-1][0]:
            return_address,saved=active.pop();assert all(u.reg_read(reg(i))==v for i,v in saved.items()),'Callee violated preserved registers'
        assert START<=address<START+len(code) or any(a<=address<a+len(c) for a,c in helpers.items()),('Unexpected instruction',hex(address))
        if address in helpers:
            seen.add(address)
            count=5 if address==0x80027D8C else 2 if address in (0x8003CD4C,0x8003CD70) else 1
            args=tuple(u.reg_read(reg(4+i)) for i in range(min(count,4)))
            if count==5:args+=(int.from_bytes(uc.mem_read(u.reg_read(reg(29))+0x10,4),'big'),)
            trace.append((address,args))
            active.append((u.reg_read(reg(31)),{i:u.reg_read(reg(i)) for i in (*range(16,24),28,29,30)}))
    uc.hook_add(UC_HOOK_MEM_READ,rh);uc.hook_add(UC_HOOK_MEM_WRITE,wh);uc.hook_add(UC_HOOK_CODE,ch)
    uc.emu_start(START,STOP,count=100000)
    assert uc.reg_read(mc.UC_MIPS_REG_PC)==STOP and uc.reg_read(reg(29))==SP and not active,'Did not return naturally'
    assert all(uc.reg_read(reg(i))==v for i,v in preserved.items()),'Preserved register changed'
    assert uc.mem_read(SP-1024,16)==bytes((i*29+71)&255 for i in range(16)),'Lower stack canary changed'
    return dict(output=uc.mem_read(OUTPUT,8).hex(),result=uc.reg_read(reg(2)),trace=trace,dirty=sorted(dirty)),seen,steps
randomizer=random.Random(0x330F82026);fixtures=[]
for mask in range(32):
    for mode,weapon in itertools.product([-1,0],[-1,1]):
        pos=randomizer.choice([(0,0),(1000,-1000),(3000,0),(-3000,700)])
        nodes=[]
        for i,kind in enumerate([0,5,1,7,3]):
            if mask&(1<<i):
                distance=randomizer.choice([-10000,-3000,-2976,-2975,-32,-1,0,1,31,32,2975,2976,3000,10000]);nodes.append(dict(kind=kind,animation=0 if kind==3 else 3,limit=randomizer.choice([0,3,5,9,10,11,16,35,36]),x=pos[0]+distance,y=pos[1]+randomizer.choice([-3000,-32,-1,0,1,32,3000])))
        fixtures.append(dict(position=pos,nodes=nodes,mode=mode,weapon=weapon,phase=randomizer.choice([-8193,-1,0,1,8193]),speed=randomizer.choice([-4096,-1,0,1,4096,65536])))
for i in range(384):
    pos=(randomizer.randint(-10000,10000),randomizer.randint(-10000,10000));nodes=[]
    for j in range(randomizer.randrange(9)):
        nodes.append(dict(kind=randomizer.choice([0,1,3,5,7,9]),animation=randomizer.choice([0,1,3,9]),limit=randomizer.randrange(40),x=pos[0]+randomizer.randint(-10000,10000),y=pos[1]+randomizer.randint(-10000,10000)))
    fixtures.append(dict(position=pos,nodes=nodes,mode=randomizer.choice([-1,0,1]),weapon=randomizer.choice([-1,0,1]),phase=randomizer.randint(-8193,8193),speed=randomizer.choice([-4096,-1,0,1,4096,65536])))
(out/'fixtures.json').write_text(json.dumps(fixtures,indent=2)+'\n')
source='src/game/player/navigation.c'
report=compare_block('player_navigation',source,START,0x33CF8,0x344CC,rom,family='player-navigation-audit/baseline',layout=layout)
assert report['matches'] and report['actual_size']==2004
(out/'comparison.json').write_text(json.dumps(report,indent=2)+'\n')
candidate=n/'build/player-navigation-audit/baseline/player_navigation/player_navigation.elf'
sections,symbols=elf_sections_and_symbols(candidate)
assert symbols['func_800330F8']['size']==2004 and symbols['func_800330F8']['value']==START
assert len(sections['.text']['bytes'])==2004
candidates=[candidate]
rows=[];covered=set();steps=0
for candidate in candidates:
    for i,fixture in enumerate(fixtures):
        expected,seen,count=run(fixture);actual,seen2,count2=run(fixture,candidate)
        assert expected==actual,(candidate.name,i,expected,actual)
        covered|=seen|seen2;steps+=count+count2
    row=dict(candidate=candidate.relative_to(n).as_posix(),pairs=len(fixtures),passed=True);rows.append(row);print(json.dumps(row),flush=True)
# Changes must affect this audit's measured behavior, with passing baseline
# execution on the same fixture before and after each detected difference.
control_dir=out/'controls';control_dir.mkdir(exist_ok=True)
baseline_source=(n/source).read_text()
changes=[('distance-cutoff','< 0x21C9','< 0x21CA'),
 ('ability-slot','player->saved.field6C','player->saved.field70'),
 ('nearest-kind','position, 5, 0, 0xB','position, 6, 0, 0xB'),
 ('nearest-animation','0x24, 0xDEAD','0x24, 0'),
 ('output-scale',' / 4096',' / 2048'),
 ('avoidance-offset','+ 0x900','+ 0x800'),
 ('orbit-mode','D_800BA74C == -1','D_800BA74C == 0'),
 ('output-axis','*x = func_8003CC88','*x = func_8003CC58')]
control_fixtures=list(fixtures)
for distance in (-2976,-2975,0,2975,2976):
 control_fixtures.insert(0,dict(position=[0,0],nodes=[dict(kind=0,animation=3,limit=1,x=distance,y=0)],mode=0,weapon=-1,phase=0,speed=4096))
control_fixtures.insert(0,dict(position=[2976,0],nodes=[],mode=0,weapon=-1,phase=0,speed=4096))
controls=[]
for name,before,after in changes:
 assert before in baseline_source
 mutant_source=control_dir/(name+'.c');mutant_source.write_text(baseline_source.replace(before,after))
 comparison=compare_block(name,mutant_source.relative_to(n).as_posix(),START,0x33CF8,0x344CC,rom,family='player-navigation-audit/control-comparison',layout=layout)
 assert not comparison['matches']
 mutant=n/'build/player-navigation-audit/control-comparison'/name/(name+'.elf')
 detected=None
 for i,fixture in enumerate(control_fixtures):
  expected,_,_=run(fixture);actual_baseline,_,_=run(fixture,candidate)
  assert actual_baseline==expected
  actual,_,_=run(fixture,mutant)
  if actual!=expected:
   assert run(fixture,candidate)[0]==expected
   detected=i;break
 assert detected is not None,('Undetected mutation',name)
 controls.append(dict(name=name,fixture=detected,baseline_bracket_passed=True))
 print(json.dumps(controls[-1]),flush=True)
layout.verify()
assert covered==set(helpers)
for filename,digest in input_hashes.items():
 assert hashlib.sha256((n/filename).read_bytes()).hexdigest()==digest,('Helper input changed',filename)
receipt=dict(real_matching_helpers=len(helpers),helper_bytes=sum(map(len,helpers.values())),
 fixtures=len(fixtures),candidates=rows,steps=steps,controls=controls,inputs_sha256=input_hashes,
 covered_helpers=[hex(a) for a in sorted(covered)],matching_instruction_bytes=2004,
 limit='Finite paired fixtures, integer ABI and bounded memory; does not prove complete gameplay')
(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps({k:v for k,v in receipt.items() if k!='inputs_sha256'}),flush=True)
