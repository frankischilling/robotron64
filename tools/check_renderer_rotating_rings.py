"""Execute the complete rotating-ring renderer with real matched callees."""
import hashlib,itertools,json,math,struct
from unicorn import UC_HOOK_CODE,UC_HOOK_MEM_READ,UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine,word,SENTINEL
from compare_startup import compare_block,SymbolLayoutSnapshot
from compare_runtime import MATCHING_BLOCKS
from owned_sections import source_sections,elf_sections_and_symbols
from rom import ROOT as r, validate

ENTRY,STACK,DLIST,POOL=0x80040968,0x80300000,0x80200000,0x800CDBD0
CLOCK,CURSOR,ALLOCATOR,FRAME_BASE=0x800CD2B4,0x80123AE4,0x80126B84,0x80123B20
MODE,ALPHA,FLAG,RNG,DL_CURSOR=0x8007D5D8,0x80123AE8,0x800C85B8,0x8008F120,0x80138254
SUPPORT=('graphics_mode_dispatch','graphics_modes','graphics_pool','fixed_math','short_sine','short_cosine','random_between','runtime_random','gu_random')
CALLS=(0x8004729C,0x80046800,0x80047048,0x80047094,0x8004DB88,0x8004DB60,0x8005FBB0,0x8005FC20,0x8000A21C,0x8004CDE8,0x800631F0)

def locate(data,address,size):
    for a,b in data.items():
        if a<=address and address+size<=a+len(b):return b,address-a
    raise AssertionError(('Outside fixture',hex(address),size))

def put(data,address,value):
    block,offset=locate(data,address,len(value));block[offset:offset+len(value)]=value

def initial(case):
    time,seed,first,mode=case
    ranges=[(CLOCK-16,CLOCK+276),(POOL+max(first,0)*16-16,POOL+(max(first,0)+48)*16+64),(DLIST-16,DLIST+512)]
    ranges += [(a-16,a+20) for a in (CURSOR,ALLOCATOR,FRAME_BASE,MODE,ALPHA,FLAG,RNG,DL_CURSOR)]
    merged=[]
    for a,b in sorted(ranges):
        if merged and a<=merged[-1][1]:merged[-1]=(merged[-1][0],max(merged[-1][1],b))
        else:merged.append((a,b))
    data={a:bytearray(((a+i)*37+seed*19+i//7)&255 for i in range(b-a)) for a,b in merged}
    for a,v in ((CLOCK,time),(CURSOR,137),(ALLOCATOR,first),(FRAME_BASE,max(first,0)),(MODE,mode),(ALPHA,89),(FLAG,37),(RNG,seed),(DL_CURSOR,DLIST)):
        put(data,a,word(v))
    return data

def sine(phase):
    phase &=4095
    index=phase&1023
    if phase&1024:index=1023-index
    value=math.floor(32767*math.sin(index*math.pi/2046))
    return -value if phase&2048 else value

def oracle(data,case):
    time,seed,first,mode=case
    expected={a:bytearray(b) for a,b in data.items()};allowed=[];trace=[];packets=[]
    def store(a,v):put(expected,a,v);allowed.append((a,a+len(v)))
    def command(a,b):packets.append((a,b))
    trace.append((0x8004729C,2))
    if mode!=2:
        if mode==18:command(0xB9000002,0)
        store(MODE,word(2));command(0xE7000000,0)
        trace.append((0x80046800,None))
        for a,b in ((0xB6000000,0x60000),(0xB7000000,0x205),(0xFCFFFFFF,0xFFFE793C),(0xB900031D,0x00552078)):command(a,b)
        store(ALPHA,word(255));store(FLAG,word(0))
    for a,b in ((0xB7000000,4),(0xFCFFFFFF,0xFFFE793C),(0xB900031D,0x005049D8)):command(a,b)
    trace.append((0x80047048,None));store(CURSOR,word(first))
    if first!=-1:
        for group in range(12):
            radius=19210-group*1600;offset=24000-group*2000
            for corner in range(4):
                phase=(time+offset+corner*1024)&0xFFFFFFFF
                trace.extend(((0x8004DB88,phase),(0x8005FBB0,((phase<<4)&0xFFFF)),(0x8004DB60,phase),(0x8005FC20,((phase<<4)&0xFFFF)),(0x8005FBB0,(((phase<<4)+0x4000)&0xFFFF))))
                address=POOL+(first+group*4+corner)*16
                x=(sine(phase)*radius)>>15;y=(sine(phase+1024)*radius)>>15
                store(address,struct.pack('>3h',x,y,32000))
                colors=[]
                for _ in range(3):
                    trace.extend(((0x8000A21C,(0,128)),(0x8004CDE8,None),(0x800631F0,None)))
                    value=((seed<<2)+2)&0xFFFFFFFF
                    seed=((value*(value+1))&0xFFFFFFFF)>>2
                    colors.append(seed%128)
                store(address+12,bytes(colors+[255]))
            command(0x0400103F,POOL+(first+(group+1)*4)*16)
            command(0xBF000000,0x204);command(0xBF000000,0x60004)
        store(CURSOR,word(first+48));store(ALLOCATOR,word(first+48));store(RNG,word(seed))
        trace.append((0x80047094,48))
    packetbytes=b''.join(word(a)+word(b) for a,b in packets)
    store(DLIST,packetbytes);store(DL_CURSOR,word(DLIST+len(packetbytes)))
    return expected,allowed,trace

def execute(code,support,owned,case):
    data=initial(case);expected,allowed,expected_trace=oracle(data,case)
    uc,write,_=machine([(ENTRY,code)],support)
    for a,b in data.items():write(a,bytes(b))
    stack_start=STACK-0x180;stack=bytes((i*43+case[1])&255 for i in range(0x1C0));write(stack_start,stack)
    allowed.append((STACK-0x140,STACK))
    write_allowed={i for a,b in allowed for i in range(a,b)}
    reads=[(a,a+len(b)) for a,b in data.items()]+[(STACK-0x140,STACK)]+[(a,a+len(b)) for a,b in owned]
    executable=[(ENTRY,ENTRY+len(code))]+[(a,a+len(b)) for a,b in support if a not in {x[0] for x in owned}]
    saved={getattr(regs,'UC_MIPS_REG_'+n):uc.reg_read(getattr(regs,'UC_MIPS_REG_'+n)) for n in ('S0','S1','S2','S3','S4','S5','S6','S7','FP')}
    uc.reg_write(regs.UC_MIPS_REG_GP,0xABCD1234);trace=[];touched=set()
    def guard_write(uc,access,address,size,value,user):
        address|=0x80000000
        assert all(address+i in write_allowed for i in range(size)),('Write guard',hex(address),size,case)
        if stack_start<=address<STACK:touched.update(range(address,address+size))
    def guard_read(uc,access,address,size,value,user):
        address|=0x80000000
        assert any(a<=address and address+size<=b for a,b in reads),('Read guard',hex(address),size,case)
    def guard_code(uc,address,size,user):
        assert address==SENTINEL or any(a<=address and address+size<=b for a,b in executable),('Unmatched callee or escaped code',hex(address),case)
        if address in CALLS:
            if address==0x8000A21C:argument=(uc.reg_read(regs.UC_MIPS_REG_A0),uc.reg_read(regs.UC_MIPS_REG_A1))
            elif address in (0x8004729C,0x80047094,0x8004DB88,0x8004DB60,0x8005FBB0,0x8005FC20):argument=uc.reg_read(regs.UC_MIPS_REG_A0)
            else:argument=None
            trace.append((address,argument))
    uc.hook_add(UC_HOOK_MEM_WRITE,guard_write);uc.hook_add(UC_HOOK_MEM_READ,guard_read);uc.hook_add(UC_HOOK_CODE,guard_code)
    uc.emu_start(ENTRY,0,count=100000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC)==SENTINEL,'No return'
    assert uc.reg_read(regs.UC_MIPS_REG_SP)==STACK and uc.reg_read(regs.UC_MIPS_REG_GP)==0xABCD1234
    assert all(uc.reg_read(a)==b for a,b in saved.items()),'Callee-saved registers'
    assert trace==expected_trace,('Call trace',case,next(((i,a,b) for i,(a,b) in enumerate(itertools.zip_longest(trace,expected_trace)) if a!=b),None))
    digest=hashlib.sha256()
    for a,b in expected.items():
        actual=bytes(uc.mem_read(a&0x1FFFFFFF,len(b)));assert actual==bytes(b),('Independent memory oracle',hex(a),case);digest.update(actual)
    actual_stack=bytes(uc.mem_read(stack_start&0x1FFFFFFF,len(stack)))
    assert all(v==stack[i] for i,v in enumerate(actual_stack) if stack_start+i not in touched),'Stack canary'
    for a,b in owned:
        if a!=RNG:assert bytes(uc.mem_read(a&0x1FFFFFFF,len(b)))==b,('Support data changed',hex(a))
    digest.update(json.dumps(trace).encode());return digest.hexdigest()

def main():
    target=(r/'baseroms/us/baserom.z64').read_bytes();validate(target);layout=SymbolLayoutSnapshot();reports={};support=[];owned=[]
    family='renderer-rings-execution'
    for name in SUPPORT:
        _,source,start,end=next(x for x in MATCHING_BLOCKS if x[0]==name)
        report=compare_block(name,source,start,start-0x80000000+0xC00,end-0x80000000+0xC00,target,family,layout)
        assert report['matches'],('Real support mismatch',name);reports[name]=report
        directory=r/'build'/family/name
        support.append((start,(directory/(name+'.bin')).read_bytes()))
        sections,_=elf_sections_and_symbols(directory/(name+'.elf'))
        for section in source_sections(source):
            if section['rom'] is not None:
                a,b=section['vram'],sections[section['section']]['bytes'];owned.append((a,b));support.append((a,b))
                if name=='short_sine':assert b==struct.pack('>1024h',*(math.floor(32767*math.sin(i*math.pi/2046)) for i in range(1024)))
    source='src/game/renderer_surfaces/rotating_rings.c'
    reports['rings']=compare_block('rings',source,ENTRY,0x41568,0x417A0,target,family,layout)
    assert reports['rings']['matches'], 'Complete ring instruction comparison'
    compiled=(r/'build'/family/'rings/rings.bin').read_bytes();retail=target[0x41568:0x417A0]
    cases=list(itertools.product((0,1,-1,4095,4096,65535,0x7FFFFFFF,-0x80000000),(0,1,0xFFFFFFFF,174823885),(-1,0,137,10000,21952),(2,18,17,-1)))
    digest=hashlib.sha256()
    for index,case in enumerate(cases):
        a=execute(retail,support,owned,case);b=execute(compiled,support,owned,case);assert a==b,('Retail comparison',case);digest.update(json.dumps([case,b]).encode())
        if (index+1)%80==0:print('Rotating rings guarded cases',index+1,flush=True)
    mutations=[]
    # Change radius, advance two vertices at once, and change the ring decrement.
    # Resolve mutation sites by exact instruction encodings rather than assumptions.
    encodings=((bytes.fromhex('24134b0a'),bytes.fromhex('24134b0b')),(bytes.fromhex('26100010'),bytes.fromhex('26100020')),(bytes.fromhex('252af830'),bytes.fromhex('252af831')))
    for old,new in encodings:
        assert compiled.count(old)==1,(old.hex(),compiled.count(old))
        mutated=compiled.replace(old,new)
        try:execute(mutated,support,owned,(1,174823885,137,18))
        except (AssertionError,ValueError) as e:mutations.append(dict(original=old.hex(),replacement=new.hex(),detected=str(e)[:160]))
        else:raise AssertionError(('Undetected mutation',old.hex()))
    raw,symbols=elf_sections_and_symbols(r/'build'/family/'rings/rings.raw.o')
    assert symbols['func_80040968']['size']==568
    assert raw['.text']['size']==576 and raw['.text']['bytes'][568:]==bytes(8), 'Only compiler alignment is trimmed'
    assert all(name in ('.text','.reginfo') or not (s['flags']&2 and s['size']) for name,s in raw.items()), 'Unexpected generated data'
    layout.verify()
    report=dict(status='Complete 568-byte source instruction match and guarded CPU execution',cases=len(cases),mutations=mutations,trace_sha256=digest.hexdigest(),compiled_sha256=hashlib.sha256(compiled).hexdigest(),retail_sha256=hashlib.sha256(retail).hexdigest(),raw_text_bytes=raw['.text']['size'],comparison=reports['rings'],real_support=reports,limits='CPU-side packet and memory proof; RSP rendering is not executed. Valid allocator indices and direct -1 return exercised; diagnostic formatter branches are excluded and escaped calls fail.')
    (r/'build'/family/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:report[k] for k in ('cases','mutations','trace_sha256','raw_text_bytes','status')}),flush=True)

if __name__=='__main__':main()
