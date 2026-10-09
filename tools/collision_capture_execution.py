"""Guarded collision capture execution with real helpers and a separate oracle."""
from pathlib import Path
import hashlib,itertools,json,math,random,struct,subprocess,sys
from elftools.elf.elffile import ELFFile
from unicorn import UC_HOOK_CODE,UC_HOOK_MEM_READ,UC_HOOK_MEM_WRITE,UC_MEM_WRITE
from unicorn import mips_const as reg
R=Path(__file__).resolve().parent.parent;D=R/'build/collision-capture-check'
sys.path.insert(0,str(R/'tools'))
from compare_startup import SymbolLayoutSnapshot,compare_block
from compare_runtime import MATCHING_BLOCKS
from compare_data import compare_unit
from owned_sections import source_sections,elf_sections_and_symbols
from check_actor_collision_followup import State
from check_actor_group_path import word,SENTINEL
from resource_literal_execution import literal_machine,verify_fpu,FP_INIT,FP_STUB,FP_RETURN,FP_SEED,FP_RESULT,CALLER_SAVED
from actor_path_model import tangent_bucket,divide
ENTRY,ANIMATE,ANGLE,ABS=0x8001737C,0x80027AB8,0x8003CD4C,0x8004CEF0
POSITION,COSINE,SINE,OBJECT=0x800290B0,0x8003CC88,0x8003CC58,0x80039514
LOOP,FRAME,ATTACH,INDEX=0x8003945C,0x80039DCC,0x80039C5C,0x80039D4C
ALLOC,FRAGMENT,SOUND=0x800283D4,0x80036B00,0x8003614C
CALLBACK,CHILD_CALLBACK=0x80000180,0x800001C0
FIRST,SECOND,CHILD=0x80201010,0x80202010,0x80203010
RESOURCE,OTHER_RESOURCE,ALT_RESOURCE,CHILD_RESOURCE=0x80204010,0x80205010,0x80206010,0x80207010
TRACKS,MODEL,FRAMES,TRANSFORMS=0x80208010,0x80209010,0x8020A010,0x8020B010
OBJECTS,CACHE,CLOCK,LOAD_FLAG,STACK=0x800BF918,0x80078274,0x8009EFA0,0x8007BB14,0x80300000
SAVED=[getattr(reg,'UC_MIPS_REG_'+n) for n in ['S'+str(i) for i in range(8)]+['FP','SP','GP']]
ARITY={ANIMATE:3,ANGLE:2,ABS:1,POSITION:2,COSINE:1,SINE:1,OBJECT:2,LOOP:2,FRAME:2,ATTACH:2,INDEX:2,ALLOC:3,FRAGMENT:3,SOUND:4,CALLBACK:1,CHILD_CALLBACK:2}
BOUNDARIES={ALLOC,FRAGMENT,SOUND,CALLBACK,CHILD_CALLBACK}
def signed(v):return ((v+0x80000000)&0xffffffff)-0x80000000
def signed16(v):return ((v+0x8000)&0xffff)-0x8000
def magnitude(v):return signed(-v) if v<0 else v
def f32(v):return struct.unpack('>f',struct.pack('>f',v))[0]
def heading(x,y):
    if x==0:return 2048 if y<0 else 0
    if y==0:return 3072 if x<0 else 1024
    quadrant=(x<0)+2*(y<0);x,y=magnitude(x),magnitude(y)
    n=tangent_bucket(divide(signed(x*32767),y)) if x<y else 128-tangent_bucket(divide(signed(y*32767),x))
    return (n,512-n,256-n,n+256)[quadrant]*8
def pattern(n,tag):return bytes((i*37+19+tag)&255 for i in range(n))
def fingerprint(images):return hashlib.sha256(b''.join(word(a)+bytes(b) for a,b in sorted(images.items()))).hexdigest()
def fixtures(case):
    sizes=[(FIRST,124),(SECOND,124),(CHILD,124),(RESOURCE,88),(OTHER_RESOURCE,88),(ALT_RESOURCE,88),(CHILD_RESOURCE,88),(TRACKS,8*16),(MODEL,56),(FRAMES,4*12),(TRANSFORMS,3*32),(OBJECTS,18*120),(CACHE,0x3860),(CLOCK,4),(LOAD_FLAG,4)]
    state=State({a-16:bytearray(b'\xa7'*16+pattern(n,i*11)+b'\xb9'*16) for i,(a,n) in enumerate(sizes)})
    other=FIRST if case.get('alias') else SECOND
    for a,res,kind,animation,angle,pos,index in [(FIRST,RESOURCE,case['kind'],case['first_animation'],case['angle'],case['first_position'],0),(other,OTHER_RESOURCE,case['other_kind'],case['second_animation'],case['other_angle'],case['second_position'],17),(CHILD,CHILD_RESOURCE,0,0,0,(11,-13,17),1)]:
        state.put(a+0x24,res);state.put(res+2,kind,1);state.put(a+0x1f,animation,1);state.put(a+8,angle,2);state.put(a+0xc,index,2)
        state.put(a+0x14,case['flags']);state.put(a+0x44,CALLBACK)
        for axis,v in enumerate(pos):state.put(a+0x60+4*axis,v)
    for res in [RESOURCE,OTHER_RESOURCE,ALT_RESOURCE,CHILD_RESOURCE]:
        for i in range(4):state.put(res+0x28+4*i,TRACKS+16*i)
    state.put(ALT_RESOURCE+2,1,1);state.put(CHILD_RESOURCE+0x54,CHILD_CALLBACK)
    for i in range(8):
        state.put(TRACKS+16*i,i%4,2);state.put(TRACKS+16*i+6,11+i,2);state.put(TRACKS+16*i+10,case['loop'],2)
        state.put(TRACKS+16*i+14,7 if case['sound'] else 255,1);state.put(TRACKS+16*i+15,0,1)
    if case['fallback']:
        state.put(RESOURCE+0x2c,0);state.put(OTHER_RESOURCE+0x2c,0)
    for i,index in enumerate((0,17,1)):
        state.put(OBJECTS+120*index+0x18,TRANSFORMS+32*i);state.put(OBJECTS+120*index+0x74,MODEL)
    for i,value in enumerate((0,90,108,255)):
        state.put(MODEL+0x28+4*i,FRAMES+12*i);state.put(FRAMES+12*i+10,value,2)
    for i in range(255):
        state.put(CACHE+0x1f58+16*i,case['limit']);state.put(CACHE+0x1f5c+16*i,1,1)
    state.put(CACHE+0x3854,1,1);state.put(CLOCK,case['clock']);state.put(LOAD_FLAG,0x1737c)
    return sizes,state,other
def oracle(case):
    sizes,state,other=fixtures(case);initial=State(state.images);events=[]
    def event(address,args):events.append([address,[x&0xffffffff for x in args],fingerprint(state.images)])
    def mutate(address,args):
        mutation=case['mutation'];actor=args[0] if address in [CALLBACK,CHILD_CALLBACK] else FIRST
        if address==CALLBACK:
            if mutation==1:state.put(actor+0x14,0x90000002)
            elif mutation==2:
                state.put(actor+8,-32768,2);state.put(FIRST+0x60,-219);state.put(other+0x64,313)
            elif mutation==3:state.put(actor+0x24,ALT_RESOURCE)
            elif mutation==4:state.put(actor+0xc,1,2)
            elif mutation==5:state.put(TRACKS+16+10,-1,2)
        elif address==ALLOC:
            if not case['fail']:
                for i in range(3):state.put(CHILD+0x60+4*i,state.get(args[2]+4*i))
            if mutation==6:
                state.put(FIRST+0x60,313);state.put(CHILD+0x48,-0x1737c)
        elif address==CHILD_CALLBACK and mutation==6:state.put(CHILD+0x4c,1234567)
        elif address==FRAGMENT and mutation==7:state.put(FIRST+8,4095,2)
        elif address==SOUND and mutation==8:state.put(FIRST+8,-1,2)
    def animate(actor,anim):
        res=state.get(actor+0x24,unsigned=True);track=state.get(res+0x28+4*anim,unsigned=True)
        if not track:anim=0;track=state.get(res+0x28,unsigned=True)
        state.put(actor+0x1f,anim,1);state.put(actor+0x18,0x100)
        idx=state.get(actor+0xc,2);obj=OBJECTS+idx*120
        frame=state.get(track,2);state.put(obj+0x15,state.get(track+6,2),1)
        state.put(obj+0xc,frame,1);state.put(obj+0xe,state.get(FRAMES+12*frame+10,2),1);state.put(obj+2,1,2)
        if state.get(track+14,1,unsigned=True)!=255 and state.get(track+15,1)==0:
            args=[state.get(track+14,1,unsigned=True),0,1,0];event(SOUND,args);mutate(SOUND,args)
    def call(address,args):
        event(address,args)
        if address in BOUNDARIES:
            mutate(address,args);return 0 if address!=ALLOC or case['fail'] else CHILD
        actor=args[0];obj=OBJECTS+signed(actor)*120
        if address==ANIMATE:animate(actor,args[1])
        elif address==ANGLE:return heading(signed(args[0]),signed(args[1]))
        elif address==ABS:return magnitude(signed(actor))
        elif address==POSITION:
            ix=state.get(args[1]);iy=state.get(args[1]+8);iz=state.get(args[1]+4)
            tr=state.get(obj+0x18,unsigned=True)
            for i,v in enumerate((ix,iy,iz)):
                f=f32(f32(f32(v)*f32(1400.0))/f32(60000.0));state.put(tr+0x10+4*i,int.from_bytes(struct.pack('>f',f),'big'))
                state.put(obj+0x54+4*i,math.trunc(f32(f*f32(12.0))))
        elif address==OBJECT:
            value=signed(args[1]);tr=state.get(obj+0x18,unsigned=True)
            f=f32(f32(f32(signed(value-1024))*f32(3.141592))/f32(2048))
            state.put(tr+8,int.from_bytes(struct.pack('>f',f),'big'));state.put(obj+0x4c,(1024-value)&0xffd)
        elif address==LOOP:state.put(obj+0xe,args[1],1)
        elif address==FRAME:state.put(obj+0x15,args[1],1)
        elif address==ATTACH:state.put(obj+0xa,args[1],2)
        elif address==INDEX:
            value=state.get(obj+0xe,1,unsigned=True)
            if value==255:limit=1
            else:state.put(LOAD_FLAG,1);limit=state.get(CACHE+0x1f58+16*value) or 1
            if signed(args[1])<limit:state.put(obj+2,args[1],2)
        return 0
    def install(actor,callback):
        if state.get(actor+0x14,unsigned=True)&0x40:
            state.put(actor+0x14,state.get(actor+0x14,unsigned=True)&~0x40);call(state.get(actor+0x44,unsigned=True),[actor])
        state.put(actor+0x14,state.get(actor+0x14,unsigned=True)|0x40);state.put(actor+0x44,callback);state.put(actor+0xe,999,2)
    def speed_zero(actor):
        state.put(actor+0x2c,0);call(COSINE,[state.get(actor+8,2)]);state.put(actor+0x6c,0)
        call(SINE,[state.get(actor+8,2)]);state.put(actor+0x70,0);call(OBJECT,[state.get(actor+0xc,2),state.get(actor+8,2)])
    def direction():return call(ANGLE,[signed(state.get(other+0x64)-state.get(FIRST+0x64)),signed(state.get(other+0x60)-state.get(FIRST+0x60))])
    if state.get(state.get(other+0x24,unsigned=True)+2,1,unsigned=True)<4 and state.get(other+0x1f,1,unsigned=True)==0:
        kind=state.get(state.get(FIRST+0x24,unsigned=True)+2,1,unsigned=True)
        if kind in [25,26,27,28] and state.get(FIRST+0x1f,1)!=3:
            install(other,0x80029e5c)
            for i in range(3):state.put(other+0x60+4*i,state.get(FIRST+0x60+4*i))
            call(ANIMATE,[other,3,1]);state.put(other+0x6c,0);state.put(other+0x70,0);state.put(FIRST+0x48,state.get(CLOCK))
            call(ANIMATE,[FIRST,3,1]);state.put(FIRST+0x6c,0);state.put(FIRST+0x70,0)
        elif kind==5 and state.get(FIRST+0x1f,1)!=3:
            if call(ABS,[signed(signed16(direction())-state.get(FIRST+8,2))])&2047>1000:
                state.put(other+8,state.get(FIRST+8,2)&4095,2);state.put(other+0x48,state.get(CLOCK));call(ANIMATE,[other,1,1]);install(other,0x80029154)
                for i in range(3):state.put(other+0x60+4*i,state.get(FIRST+0x60+4*i))
                call(POSITION,[state.get(other+0xc,2),other+0x60]);speed_zero(other);call(ANIMATE,[FIRST,3,1]);speed_zero(FIRST);install(FIRST,0x8002bf88);state.put(FIRST+0x4c,500)
                if call(ALLOC,[9,0x800b2740,FIRST+0x60]):call(CHILD_CALLBACK,[CHILD,1])
        elif kind==6 and state.get(FIRST+0x1f,1)!=3:
            if call(ABS,[signed(signed16(direction())-state.get(FIRST+8,2))])&2047>500:
                call(ANIMATE,[FIRST,3,1]);install(FIRST,0x80029210);state.put(FIRST+8,direction(),2);speed_zero(other);call(ANIMATE,[other,1,1])
                res=state.get(other+0x24,unsigned=True);track=state.get(res+0x2c,unsigned=True)
                call(LOOP,[state.get(other+0xc,2),state.get(track+10,2)]);call(FRAME,[state.get(other+0xc,2),108]);call(ATTACH,[state.get(other+0xc,2),state.get(FIRST+0xc,2)]);speed_zero(FIRST)
        elif kind in [7,8]:
            active=kind==7 or call(ABS,[signed(signed16(direction())-state.get(FIRST+8,2))])&2047>=601
            if active:
                state.put(FIRST+8,direction(),2);speed_zero(other);call(ANIMATE,[other,1,1])
                res=state.get(other+0x24,unsigned=True);track=state.get(res+0x28,unsigned=True);call(LOOP,[state.get(other+0xc,2),state.get(track+10,2)])
                if kind==7:
                    call(INDEX,[state.get(other+0xc,2),1]);call(FRAGMENT,[190,other,0]);call(ANIMATE,[FIRST,3,1]);speed_zero(FIRST);call(INDEX,[state.get(FIRST+0xc,2),1]);install(FIRST,0x80029210)
                    call(FRAME,[state.get(other+0xc,2),110]);call(ATTACH,[state.get(other+0xc,2),state.get(FIRST+0xc,2)])
                else:
                    call(FRAME,[state.get(other+0xc,2),109]);call(ATTACH,[state.get(other+0xc,2),state.get(FIRST+0xc,2)]);call(INDEX,[state.get(other+0xc,2),1])
    return sizes,initial,state,events,other,mutate
def run(body,support,entries,case,fpu_fault=None,input_fault=None):
    sizes,initial,wanted,events,other,unused=oracle(case)
    uc,write,execute,code=literal_machine([(ENTRY,body)]+support,ENTRY);uc.reg_write(reg.UC_MIPS_REG_GP,0xA5721737)
    if fpu_fault is not None:
        old=next(b for a,b in code if a==FP_STUB);changed=old[:-8]+word(0xC4003080|(fpu_fault<<16))+old[-8:]
        code=[(a,changed if a==FP_STUB else b) for a,b in code];write(FP_STUB,changed)
    for a,b in initial.images.items():write(a,bytes(b))
    data_ranges=[]
    for a,b in support:
        if not any(lo<=a<hi for lo,hi in entries['ranges']):data_ranges.append((a,a+len(b)))
    reads=[(a,a+n) for a,n in sizes]+data_ranges+[(STACK-2048,STACK+32),(FP_SEED,FP_SEED+132)]
    writes=[(a,a+n) for a,n in sizes if a not in [CLOCK,RESOURCE,OTHER_RESOURCE,ALT_RESOURCE,CHILD_RESOURCE,TRACKS,MODEL,FRAMES]]+[(STACK-2048,STACK+32),(FP_RESULT,FP_RESULT+48)]
    # Callback fixture mutations are checked host operations, not guest writes.
    write(STACK-2064,b'\xa7'*16);write(STACK-2048,b'\xc9'*2080);write(STACK+32,b'\xb9'*16)
    for n,v in [('A0',FIRST if input_fault is None else input_fault),('A1',other),('A2',case['formal']),('A3',case['formal']^0xffffffff)]:uc.reg_write(getattr(reg,'UC_MIPS_REG_'+n),v&0xffffffff)
    trace=[];pending=[];calls=0;retail_loader_calls=0
    def read(a,n):return bytes(uc.mem_read(a&0x1fffffff,n))
    def inside(a,n,bounds):return any(lo<=a and a+n<=hi for lo,hi in bounds)
    def access(uc,kind,a,n,value,user):
        a=a&0x1fffffff|0x80000000
        assert inside(a,n,writes if kind==UC_MEM_WRITE else reads),('access',kind,hex(a),n,hex(uc.reg_read(reg.UC_MIPS_REG_PC)))
    ranges=[(a,a+len(b)) for a,b in code]
    def hook(uc,address,size,user):
        nonlocal calls,retail_loader_calls
        if pending and address==pending[-1][0]:
            _,saved=pending.pop();assert all(uc.reg_read(k)==v for k,v in saved.items()),('support ABI',hex(address))
        direct=not pending
        if address in entries['symbols']:
            calls+=1;retail_loader_calls+=address==0x8004bd00;pending.append((uc.reg_read(reg.UC_MIPS_REG_RA),{k:uc.reg_read(k) for k in SAVED}))
        if address in ARITY and (direct or address in BOUNDARIES):
            args=[uc.reg_read(getattr(reg,'UC_MIPS_REG_A'+str(i))) for i in range(ARITY[address])]
            current=State({a:read(a,len(b)) for a,b in initial.images.items()});event=[address,args,fingerprint(current.images)]
            assert len(trace)<len(events) and event==events[len(trace)],('event',case,event,events[len(trace):len(trace)+1]);trace.append(event)
            if address in BOUNDARIES:
                # Apply the documented synthetic service/fixture mutation to the actual image.
                _,_,model,_,_,mutate=oracle(case)
                model.images=current.images;mutate(address,args)
                for a,b in current.images.items():write(a,bytes(b))
                result=0 if address!=ALLOC or case['fail'] else CHILD
                for i,k in enumerate(CALLER_SAVED):uc.reg_write(k,0xB2340000+i*257)
                uc.reg_write(reg.UC_MIPS_REG_V0,result);uc.reg_write(reg.UC_MIPS_REG_HI,0xAABBCCDD);uc.reg_write(reg.UC_MIPS_REG_LO,0x11223344);uc.reg_write(reg.UC_MIPS_REG_PC,FP_STUB);return
        assert address==SENTINEL or inside(address,size,ranges),('instruction',hex(address))
    uc.hook_add(UC_HOOK_MEM_READ,access);uc.hook_add(UC_HOOK_MEM_WRITE,access);uc.hook_add(UC_HOOK_CODE,hook)
    execute(FP_INIT);verify_fpu(uc)
    assert not pending and trace==events
    assert uc.reg_read(reg.UC_MIPS_REG_V0)==0 and uc.reg_read(reg.UC_MIPS_REG_GP)==0xA5721737 and uc.reg_read(reg.UC_MIPS_REG_RA)==FP_RETURN
    for a,b in wanted.images.items():
        actual=read(a,len(b));assert actual==bytes(b),('memory',case,hex(a),[(hex(a+i),x,y) for i,(x,y) in enumerate(zip(actual,b)) if x!=y][:8])
    for a,b in code:assert read(a,len(b))==b,('immutable code and support',hex(a))
    assert read(STACK-2064,16)==b'\xa7'*16 and read(STACK+32,16)==b'\xb9'*16
    return dict(events=trace,memory_sha256=fingerprint(wanted.images),support_calls=calls,unowned_retail_loader_calls=retail_loader_calls)
def build():
    D.mkdir(parents=True,exist_ok=True)
    rom=(R/'baseroms/us/baserom.z64').read_bytes();layout=SymbolLayoutSnapshot();support=[];symbols=set();ranges=[];proof={}
    from rom import validate
    validate(rom)
    names=['object_recovery_angle_scale','object_recovery_direction_angle','object_recovery_angle_table','fixed_geometry_setup','actor_animation','actor_position_submit','object_recovery_fixed_trig','short_sine','short_cosine','object_transforms','object_model_access','object_helpers_properties','object_helpers_index_set','object_helpers_index_limit']
    for name in names:
        _,source,start,end=next(x for x in MATCHING_BLOCKS if x[0]==name)
        report=compare_block(name,source,start,start-0x80000000+0xc00,end-0x80000000+0xc00,rom,family='collision-capture-support',layout=layout);assert report['matches'];proof[name]=report
        directory=R/'build/collision-capture-support'/name;support.append((start,(directory/(name+'.bin')).read_bytes()));ranges.append((start,end))
        with (directory/(name+'.elf')).open('rb') as f:
            e=ELFFile(f);symbols.update(s['st_value'] for s in e.get_section_by_name('.symtab').iter_symbols() if s['st_info']['type']=='STT_FUNC' and start<=s['st_value']<end)
        sections,_=elf_sections_and_symbols(directory/(name+'.elf'))
        for record in source_sections(source):
            if record['rom'] is not None:support.append((record['vram'],sections[record['section']]['bytes']))
    for source in ['src/game/object_angle_setter_constants.c','src/game/actor_groups/direction_table.c']:
        report=compare_unit(source,source_sections(source),rom,layout);assert report['matches'];proof[source]=report
        sections,_=elf_sections_and_symbols(R/'build/data-comparison'/Path(source).with_suffix('')/'compiled.elf')
        for record in source_sections(source):support.append((record['vram'],sections[record['section']]['bytes']))
    # This bounded path deliberately executes the unowned retail loader on cache hits.
    support.append((0x8004bd00,rom[0x4c900:0x4cc88]));ranges.append((0x8004bd00,0x8004c088));symbols.add(0x8004bd00)
    support.append((0x80090038,rom[0x90c38:0x90c98]));layout.verify()
    (D/'support-comparisons.json').write_text(json.dumps(proof,indent=2)+'\n')
    return rom,support,dict(symbols=symbols,ranges=ranges),proof
def cases():
    base=dict(kind=5,other_kind=0,first_animation=0,second_animation=0,angle=0,other_angle=-1,first_position=(17,-23,31),second_position=(17,117,71),flags=0x10000040,loop=90,limit=3,clock=0x7fffffff,fail=False,mutation=0,fallback=False,sound=False,formal=0xffffffff)
    for kind,other,anim in itertools.product(list(range(36))+[127,255],range(5),[0,3]):yield base|dict(kind=kind,other_kind=other,first_animation=anim)
    for kind,threshold in [(5,1000),(6,500),(8,600)]:
        for d in [threshold-1,threshold,threshold+1,threshold+2,-threshold-1]:
            for flags in [0,0x40,0xffffffff]:yield base|dict(kind=kind,angle=1024-d,second_position=(17,77,71),flags=flags)
    for kind,mutation,fail in itertools.product([5,6,7,8,25,28],range(1,9),[False,True]):yield base|dict(kind=kind,mutation=mutation,fail=fail)
    for kind,loop,limit,fallback,sound in itertools.product([6,7,8],[-1,0,90,255],[0,1,3],[False,True],[False,True]):
        if kind==6 and fallback:continue
        yield base|dict(kind=kind,loop=loop,limit=limit,fallback=fallback,sound=sound)
    for kind in [0,1,5,7,25]:yield base|dict(kind=kind,alias=True)
    rng=random.Random(0x1737c)
    for _ in range(192):
        yield base|dict(kind=rng.choice([5,6,7,8,25,26,27,28]),angle=rng.choice([-32768,-1,0,500,1000,2048,4095,32767]),other_angle=rng.choice([-32768,-1,0,4095,32767]),first_position=tuple(rng.randrange(-15000,15000) for _ in range(3)),second_position=tuple(rng.randrange(-15000,15000) for _ in range(3)),flags=rng.choice([0,0x40,0xffffffff]),loop=rng.choice([-1,0,90,255]),limit=rng.choice([0,1,3]),clock=rng.randrange(0x100000000),fail=bool(rng.randrange(2)),sound=bool(rng.randrange(2)),formal=rng.randrange(0x100000000))

def compile_one(name, source, rom, layout):
    """Link each complete body with its own generated switch table."""
    from compiler import compile_source, profile_for_source
    from trim_padding import trim
    from compare_startup import external_assignments, comparison_input_hashes
    from toolchain import installed_identity
    layout.verify()
    relative=source.relative_to(R).as_posix();inputs=comparison_input_hashes(relative)
    raw=D/(name+'.raw.o');obj=D/(name+'.o');elf=D/(name+'.elf');ld=D/(name+'.ld')
    compile_source(relative,raw)
    with raw.open('rb') as f:
        e=ELFFile(f);sym=e.get_section_by_name('.symtab').get_symbol_by_name('func_8001737C')[0]
        natural=sym['st_size'];code=e.get_section_by_name('.text').data();data=e.get_section_by_name('.rodata').data()
        assert sym['st_value']==0 and sym['st_info']['type']=='STT_FUNC' and not any(code[natural:])
        assert len(data)>=96 and not any(data[96:])
        assert not any(s['sh_size'] for s in e.iter_sections() if s.name in ('.data','.bss','.sdata','.sbss'))
        raw_size=len(code)
    obj.write_bytes(trim(trim(raw.read_bytes(),'.text',natural),'.rodata',96))
    undefined={line.split()[-1] for line in subprocess.check_output(['mips-linux-gnu-nm','-u',str(obj)],text=True).splitlines()}
    ld.write_text(external_assignments(undefined,layout.addresses)+'SECTIONS { .text 0x8001737C : SUBALIGN(4) { *(.text) } .rodata 0x80090038 : SUBALIGN(4) { *(.rodata) } /DISCARD/ : { *(.reginfo .MIPS.abiflags) } }\n')
    subprocess.run(['mips-linux-gnu-ld','-T',str(ld),'-e','func_8001737C','-o',str(elf),str(obj)],check=True,cwd=R)
    sections,_=elf_sections_and_symbols(elf);body=sections['.text']['bytes'];table=sections['.rodata']['bytes']
    assert len(body)==natural and len(table)==96
    assert all(ENTRY<=v<ENTRY+natural and v%4==0 for v in struct.unpack('>24I',table))
    layout.verify()
    for path,value in inputs.items():assert hashlib.sha256((R/path).read_bytes()).hexdigest()==value
    return body,table,dict(source=relative,source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),compiler_profile=profile_for_source(relative),toolchain_identity=installed_identity('5.3'),inputs_sha256=inputs,natural_size=natural,raw_text_bytes=raw_size,raw_table_bytes=len(data),actual_size=len(body),expected_size=1712,matches=body==rom[0x17f7c:0x1862c] and table==rom[0x90c38:0x90c98],generated_table_matches=table==rom[0x90c38:0x90c98],different_words=[dict(vram=hex(ENTRY+i),expected=rom[0x17f7c+i:0x17f7c+i+4].hex(),actual=body[i:i+4].hex()) for i in range(0,max(1712,len(body)),4) if body[i:i+4]!=rom[0x17f7c+i:0x17f7c+i+4]])

def prepare():
    rom,support,entries,proof=build();layout=SymbolLayoutSnapshot()
    body,table,comparison=compile_one('accepted',R/'src/game/collisions/capture.c',rom,layout)
    assert comparison['matches'] and comparison['natural_size']==1712 and comparison['raw_text_bytes']==1712
    support=[(a,table if a==0x80090038 else b) for a,b in support]
    return rom[0x17f7c:0x1862c],body,support,entries,comparison,proof,rom,layout
