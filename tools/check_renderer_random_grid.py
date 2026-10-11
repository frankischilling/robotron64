"""Verify the complete random grid with real matched support and a memory oracle."""
from pathlib import Path
import hashlib,itertools,json,struct,sys
from unicorn import UC_HOOK_CODE,UC_HOOK_MEM_READ,UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine,word,SENTINEL
from check_object_projection import fpu_fixture,FPU_INIT,FPU_PROBE,FPU_RETURN,FPU_RESULT
from check_renderer_rotating_rings import locate,put
from compare_startup import compare_block,SymbolLayoutSnapshot
from rom import ROOT
import compiler
from compare_runtime import MATCHING_BLOCKS
from owned_sections import source_sections,elf_sections_and_symbols
ENTRY,STACK,DLIST,POOL=0x80040BA0,0x80300000,0x80200000,0x800CDBD0
CLOCK,CURSOR,ALLOCATOR,FRAME_BASE=0x800CD2B4,0x80123AE4,0x80126B84,0x80123B20
MODE,ALPHA,FLAG,RNG,DL_CURSOR=0x8007D5D8,0x80123AE8,0x800C85B8,0x8008F120,0x80138254
EXTENT_X,EXTENT_Y,COUNTER1,COUNTER2=0x8007CCA8,0x8007CCAC,0x80123B14,0x80123B18
SUPPORT=('graphics_mode_dispatch','graphics_modes','graphics_pool','fixed_math','short_sine','short_cosine','random_between','runtime_random','gu_random','renderer_quad_submit')
CALLS=(0x8004729C,0x80046800,0x80047048,0x80047094,0x8004DB88,0x8005FBB0,0x8000A21C,0x8004CDE8,0x800631F0,0x80045124)
FAMILY='renderer-random-grid-execution'
SOURCE='src/game/renderer_surfaces/random_grid.c'
out=ROOT/'build'/FAMILY;out.mkdir(parents=True,exist_ok=True)
def signed(v): return ((v+0x80000000)&0xFFFFFFFF)-0x80000000
def div(a,b): return abs(a)//abs(b)*(-1 if (a<0)!=(b<0) else 1)
def initial(case):
    h,v,time,seed,first,mode,extent_x,extent_y=case
    count=max(0,2*h+1)*max(0,2*v+1)
    ranges=[(CLOCK-16,CLOCK+276),(POOL+max(first,0)*16-16,POOL+(max(first,0)+max(count,1))*16+32),(DLIST-16,DLIST+10000),(EXTENT_X-16,EXTENT_Y+20)]
    ranges +=[(a-16,a+20) for a in (CURSOR,ALLOCATOR,FRAME_BASE,MODE,ALPHA,FLAG,RNG,DL_CURSOR,COUNTER1,COUNTER2)]
    merged=[]
    for a,b in sorted(ranges):
        if merged and a<=merged[-1][1]:merged[-1]=(merged[-1][0],max(merged[-1][1],b))
        else:merged.append((a,b))
    data={a:bytearray(((a+i)*37+seed*19+i//7)&255 for i in range(b-a)) for a,b in merged}
    for a,val in ((CLOCK,time),(CURSOR,137),(ALLOCATOR,first),(FRAME_BASE,max(first,0)),(MODE,mode),(ALPHA,89),(FLAG,37),(RNG,seed),(DL_CURSOR,DLIST),(EXTENT_X,extent_x),(EXTENT_Y,extent_y),(COUNTER1,0xFFFFFFF0),(COUNTER2,123)):
        put(data,a,word(val))
    return data
def oracle(data,case):
    h,v,time,seed,first,mode,extent_x,extent_y=case
    expected={a:bytearray(b) for a,b in data.items()};allowed=[];trace=[];packets=[]
    def store(a,val):put(expected,a,val);allowed.append((a,a+len(val)))
    def command(a,b):packets.append((a,b))
    trace.append((0x8004729C,2))
    if mode!=2:
        if mode==18:command(0xB9000002,0)
        store(MODE,word(2));command(0xE7000000,0);trace.append((0x80046800,None))
        for a,b in ((0xB6000000,0x60000),(0xB7000000,0x205),(0xFCFFFFFF,0xFFFE793C),(0xB900031D,0x00552078)):command(a,b)
        store(ALPHA,word(255));store(FLAG,word(0))
    for a,b in ((0xB7000000,4),(0xFCFFFFFF,0xFFFE793C),(0xB900031D,0x00552078)):command(a,b)
    trace.append((0x80047048,None));store(CURSOR,word(first))
    if first!=-1:
        index=0;columns=2*h+1
        for y in range(-v,v+1):
            for x in range(-h,h+1):
                for phase in (div(time,2),signed(time+512),div(time,3)):
                    trace.extend(((0x8004DB88,phase&0xFFFFFFFF),(0x8005FBB0,(phase<<4)&65535)))
                time=signed(time+40);colors=[]
                for _ in range(3):
                    trace.extend(((0x8000A21C,(0,64)),(0x8004CDE8,None),(0x800631F0,None)))
                    value=((seed<<2)+2)&0xFFFFFFFF;seed=((value*(value+1))&0xFFFFFFFF)>>2;colors.append(seed%64)
                a=POOL+(first+index)*16
                store(a,struct.pack('>3H',(div(extent_x,h)*x)&65535,(div(extent_y,v)*y)&65535,32000))
                store(a+12,bytes([colors[2],colors[0],colors[1],128]));index+=1
        store(CURSOR,word(first+index));store(ALLOCATOR,word(first+index))
        if index:store(RNG,word(seed))
        trace.append((0x80047094,index))
        count=0
        for y in range(-v,v):
            for x in range(-h,h):
                a=POOL+(first+(y+v)*columns+h+x)*16
                corners=(a,a+16,a+(columns+1)*16,a+columns*16)
                trace.append((0x80045124,corners))
                for header,address in zip((0x0400040F,0x0402040F,0x0404040F,0x0406040F),corners):command(header,address)
                command(0xBF000000,0x204);command(0xBF000000,0x60004);count+=1
        if count:
            store(COUNTER1,word(0xFFFFFFF0+count));store(COUNTER2,word(123+count))
        command(0xB900031D,0x00552078)
    packetbytes=b''.join(word(a)+word(b) for a,b in packets)
    store(DLIST,packetbytes);store(DL_CURSOR,word(DLIST+len(packetbytes)))
    return expected,allowed,trace
def execute(code,support,owned,case):
    data=initial(case);expected,allowed,expected_trace=oracle(data,case)
    initialize,probe,expected_fpu=fpu_fixture(case[3])
    uc,write,_=machine([(ENTRY,code),(FPU_INIT,initialize),(FPU_PROBE,probe)],support)
    for a,b in data.items():write(a,bytes(b))
    window=bytes((i*29+case[3])&255 for i in range(80));write(FPU_RESULT-16,window)
    uc.reg_write(regs.UC_MIPS_REG_RA,FPU_RETURN);uc.emu_start(FPU_INIT,FPU_RETURN,count=50)
    assert uc.reg_read(regs.UC_MIPS_REG_PC)==FPU_RETURN
    uc.emu_start(FPU_PROBE,FPU_RETURN,count=32)
    assert uc.reg_read(regs.UC_MIPS_REG_PC)==FPU_RETURN
    assert bytes(uc.mem_read(FPU_RESULT&0x1FFFFFFF,48))==expected_fpu
    write(FPU_RESULT-16,window);uc.reg_write(regs.UC_MIPS_REG_RA,SENTINEL)
    stack_start=STACK-0x200;stack=bytes((i*43+case[3])&255 for i in range(0x240));write(stack_start,stack)
    allowed.append((STACK-0x180,STACK+16))
    write_allowed={i for a,b in allowed for i in range(a,b)}
    reads=[(a,a+len(b)) for a,b in data.items()]+[(STACK-0x180,STACK+16)]+[(a,a+len(b)) for a,b in owned]
    executable=[(ENTRY,ENTRY+len(code))]+[(a,a+len(b)) for a,b in support if a not in {x[0] for x in owned}]
    saved={getattr(regs,'UC_MIPS_REG_'+n):uc.reg_read(getattr(regs,'UC_MIPS_REG_'+n)) for n in ('S0','S1','S2','S3','S4','S5','S6','S7','FP')}
    uc.reg_write(regs.UC_MIPS_REG_GP,0xABCD1234);trace=[];touched=set();observing=[False]
    def guard_write(uc,access,address,size,value,user):
        address|=0x80000000
        if observing[0]: assert FPU_RESULT<=address and address+size<=FPU_RESULT+48;return
        assert all(address+i in write_allowed for i in range(size)),('Write guard',hex(address),size,case)
        if stack_start<=address<STACK+16:touched.update(range(address,address+size))
    def guard_read(uc,access,address,size,value,user):
        address|=0x80000000
        assert any(a<=address and address+size<=b for a,b in reads),('Read guard',hex(address),size,case)
    def guard_code(uc,address,size,user):
        if observing[0]:assert FPU_PROBE<=address and address+size<=FPU_PROBE+len(probe);return
        assert address==SENTINEL or any(a<=address and address+size<=b for a,b in executable),('Escaped code',hex(address),case)
        if address in CALLS:
            arg=None
            if address==0x8000A21C:arg=tuple(uc.reg_read(getattr(regs,'UC_MIPS_REG_'+n)) for n in ('A0','A1'))
            elif address==0x80045124:arg=tuple(uc.reg_read(getattr(regs,'UC_MIPS_REG_'+n)) for n in ('A0','A1','A2','A3'))
            elif address in (0x8004729C,0x80047094,0x8004DB88,0x8005FBB0):arg=uc.reg_read(regs.UC_MIPS_REG_A0)
            trace.append((address,arg))
    uc.hook_add(UC_HOOK_MEM_WRITE,guard_write);uc.hook_add(UC_HOOK_MEM_READ,guard_read);uc.hook_add(UC_HOOK_CODE,guard_code)
    uc.reg_write(regs.UC_MIPS_REG_A0,case[0]&0xFFFFFFFF);uc.reg_write(regs.UC_MIPS_REG_A1,case[1]&0xFFFFFFFF)
    uc.emu_start(ENTRY,0,count=700000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC)==SENTINEL,'No return'
    assert uc.reg_read(regs.UC_MIPS_REG_SP)==STACK and uc.reg_read(regs.UC_MIPS_REG_GP)==0xABCD1234,'SP/GP'
    assert uc.reg_read(regs.UC_MIPS_REG_RA)==SENTINEL,'RA'
    assert all(uc.reg_read(a)==b for a,b in saved.items()),'Saved integer registers'
    assert trace==expected_trace,('Call trace',case,next(((i,a,b) for i,(a,b) in enumerate(itertools.zip_longest(trace,expected_trace)) if a!=b),None))
    digest=hashlib.sha256()
    for a,b in expected.items():
        actual=bytes(uc.mem_read(a&0x1FFFFFFF,len(b)));assert actual==bytes(b),('Independent memory oracle',hex(a),case);digest.update(actual)
    actual_stack=bytes(uc.mem_read(stack_start&0x1FFFFFFF,len(stack)))
    assert all(v==stack[i] for i,v in enumerate(actual_stack) if stack_start+i not in touched),'Stack canary'
    for a,b in owned:
        if a!=RNG:assert bytes(uc.mem_read(a&0x1FFFFFFF,len(b)))==b,('Support data changed',hex(a))
    assert bytes(uc.mem_read((FPU_RESULT-16)&0x1FFFFFFF,80))==window,'Observer touched'
    observing[0]=True;uc.reg_write(regs.UC_MIPS_REG_RA,FPU_RETURN);uc.emu_start(FPU_PROBE,FPU_RETURN,count=32)
    assert uc.reg_read(regs.UC_MIPS_REG_PC)==FPU_RETURN
    observed=bytes(uc.mem_read((FPU_RESULT-16)&0x1FFFFFFF,80))
    assert observed[:16]==window[:16] and observed[64:]==window[64:],'FPU canary'
    assert observed[16:64]==expected_fpu,'Saved floating registers'
    digest.update(json.dumps(trace).encode());return digest.hexdigest()
def main():
    target=(ROOT/'baseroms/us/baserom.z64').read_bytes();layout=SymbolLayoutSnapshot();reports={};support=[];owned=[]
    for name in SUPPORT:
        _,source,start,end=next(x for x in MATCHING_BLOCKS if x[0]==name)
        report=compare_block(name,source,start,start-0x80000000+0xC00,end-0x80000000+0xC00,target,FAMILY,layout)
        assert report['matches'],('Support mismatch',name);reports[name]=report
        d=out/name;support.append((start,(d/(name+'.bin')).read_bytes()))
        sections,_=elf_sections_and_symbols(d/(name+'.elf'))
        for section in source_sections(source):
            if section['rom'] is not None:
                a,b=section['vram'],sections[section['section']]['bytes'];owned.append((a,b));support.append((a,b))
    comparison=compare_block('grid',SOURCE,ENTRY,0x417A0,0x41B5C,target,FAMILY,layout)
    assert comparison['matches'],'Complete grid mismatch'
    compiled=(out/'grid/grid.bin').read_bytes();retail=target[0x417A0:0x41B5C]
    raw,symbols=elf_sections_and_symbols(out/'grid/grid.raw.o')
    assert symbols['func_80040BA0']['size']==956
    assert raw['.text']['size']==960 and raw['.text']['bytes'][956:]==bytes(4)
    assert all(k in ('.text','.reginfo') or not (v['flags']&2 and v['size']) for k,v in raw.items()),'Unexpected generated sections'
    cases=[]
    for (h,v),time,seed,mode in itertools.product(((1,1),(2,3),(5,5),(10,4),(-1,2),(2,-1)),(0,-1,0x7FFFFFFF,-0x80000000),(1,174823885),(2,18)):
        count=max(0,2*h+1)*max(0,2*v+1)
        for first in (-1,0,137,22000-count):
            cases.append((h,v,time,seed,first,mode,32000 if seed==1 else -32000,24000 if seed==1 else -24000))
    digest=hashlib.sha256()
    for i,case in enumerate(cases):
        a=execute(retail,support,owned,case);b=execute(compiled,support,owned,case);assert a==b;digest.update(json.dumps([case,b]).encode())
        if (i+1)%24==0:print('Grid oracle pairs',i+1,flush=True)
    controls=[];positive=next(c for c in cases if c[0:2]==(2,3) and c[4]==137 and c[5]==18)
    seed=(ROOT/SOURCE).read_text()
    for name,before,after in [('phase','time += 40;','time += 41;'),('corner','third = last + 16;','third = last + 32;'),('channel','vertex->color.color[1] = green;','vertex->color.color[1] = blue;'),('extent','dx = D_8007CCA8 / horizontal;','dx = D_8007CCA8 / vertical;')]:
        assert seed.count(before)==1
        path=out/('control-'+name+'.c');path.write_text(seed.replace(before,after).replace('../../../include/',str(ROOT/'include')+'/'))
        relative=path.relative_to(ROOT).as_posix();compiler.SOURCE_PROFILES[relative]='game'
        compare_block('control-'+name,relative,ENTRY,0x417A0,0x41B5C,target,FAMILY,layout)
        mutation=(out/('control-'+name)/('control-'+name+'.bin')).read_bytes()
        execute(compiled,support,owned,positive)
        try:execute(mutation,support,owned,positive)
        except (AssertionError,ValueError) as e:controls.append(dict(name=name,positive_passed=True,detected=str(e)[:250]))
        else:raise AssertionError(('Undetected source control',name))
    (out/'report.json').write_text(json.dumps(dict(cases=len(cases),principal_executions=2*len(cases),controls=controls,trace_sha256=digest.hexdigest(),saved_fpu_words=12,abi_stubs=0,comparison=comparison,natural_bytes=956,raw_bytes=960,compiler_alignment_bytes=4,retail_sha256=hashlib.sha256(retail).hexdigest(),compiled_sha256=hashlib.sha256(compiled).hexdigest(),real_support=reports,limits='CPU packets, memory and O32 preservation only. Diagnostic formatter branches, zero divisors, RSP and full gameplay excluded.'),indent=2)+'\n')
    layout.verify()
    print('Grid complete',len(cases),'pairs,',len(controls),'source controls',flush=True)
if __name__=='__main__':main()
