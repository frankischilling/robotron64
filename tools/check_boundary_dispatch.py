"""Check the complete actor boundary dispatcher with recorded callback ABIs.

Boundary response, retirement, sound and diagnostic callees are stubs. The
independent model checks dispatch, direct actor/player writes and preserved ABI.
"""
import hashlib
import itertools
import json
import struct
from pathlib import Path
from elftools.elf.elffile import ELFFile
from importlib.metadata import version
from unicorn import UC_HOOK_CODE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word
from compare_startup import compare_block, SymbolLayoutSnapshot
from rom import ROOT, validate

ENTRY, END = 0x800190F8, 0x800194DC
ACTORS, RESOURCES, PLAYERS = 0x80201010, 0x80202010, 0x8009B190
GLOBALS = (0x800AA708, 0x800BA784, 0x800AD168, 0x8009EFA0)
TABLE, MESSAGE = 0x800900AC, 0x8008FDE0
BOUNCE, CLAMP, REFLECT, RETIRE, SOUND, PRINT, ABS = 0x80017F9C, 0x80018480, 0x800186D8, 0x8000A074, 0x8003614C, 0x8001C0D0, 0x8004CEF0
COUNTS = {BOUNCE:1, CLAMP:1, REFLECT:1, RETIRE:1, SOUND:4, PRINT:1, ABS:1}
CALLER_SAVED = [getattr(regs,'UC_MIPS_REG_'+n) for n in ('V0','V1','A0','A1','A2','A3','T0','T1','T2','T3','T4','T5','T6','T7','T8','T9')]

def model(case):
    kind, resource, x, y, radius, diamond, blocked, flags, age, bounced, player = case
    images = {ACTORS:bytearray(b'\x93' * (3 * 124)), RESOURCES:bytearray(b'\xB5' * (3 * 92)),
              PLAYERS:bytearray(b'\xC7' * (2 * 3508))}
    images.update({a:bytearray(word(v)) for a,v in zip(GLOBALS,(0 if blocked == 2 else ACTORS,diamond,player,500))})
    for i in range(3):
        off=i*124
        actor=images[ACTORS]
        actor[off+6:off+8]=struct.pack('>h',radius)
        actor[off+0x14:off+0x18]=word(flags)
        actor[off+0x1C]=kind
        actor[off+0x24:off+0x28]=word(RESOURCES+i*92)
        actor[off+0x28:off+0x2C]=word(blocked if i==1 else 1)
        actor[off+0x48:off+0x4C]=word(500-age)
        actor[off+0x60:off+0x68]=word(x)+word(y)
        actor[off+0x6C:off+0x74]=word(1 if age&1 else 0)+word(1 if age&2 else 0)
        actor[off+0x78:off+0x7C]=word(ACTORS+(i+1)*124 if i<2 else 0)
        images[RESOURCES][i*92+2]=resource
    images[PLAYERS][player*3508+6]=0
    images[PLAYERS][player*3508+28:player*3508+32]=word(0xFFFFFFFF)
    expected={a:bytearray(b) for a,b in images.items()}
    trace=[]
    actor=ACTORS+124
    def call(address,*args): trace.append([address,[v&0xFFFFFFFF for v in args]])
    rectangular=x<radius-30000 or x>30000-radius or y<radius-30000 or y>30000-radius
    outside=rectangular
    if not blocked and not rectangular and diamond:
        call(ABS,x);call(ABS,y)
        outside=abs(x)+abs(y)>42000-radius
    if not blocked and outside:
        if kind==0:
            if resource in (5,6,7,8,21,22,23,24):call(REFLECT,actor)
            else:
                expected[ACTORS][124+20:124+24]=word(flags|2)
                call(BOUNCE,actor)
        elif kind in (2,6,7,8):call(CLAMP,actor)
        elif kind==1:
            if resource not in (10,13):call(BOUNCE,actor)
        elif kind==9:
            if resource==23:
                expected[ACTORS][124+0x21]=2
                expected[PLAYERS][player*3508+6]=255
                expected[PLAYERS][player*3508+28:player*3508+32]=word(0)
            elif resource!=188:call(BOUNCE,actor)
        elif kind==5:
            if resource in (5,7,8):
                call(REFLECT,actor)
                if bounced:call(SOUND,84,0,1,0)
            elif resource==4:call(BOUNCE,actor)
        elif kind==4:
            if resource!=2 or age&0xFFFFFFFF>200:
                moving=(x<radius-30000 or x>30000-radius) and age&1 or (y<radius-30000 or y>30000-radius) and age&2
                if not moving and diamond:
                    call(ABS,x);call(ABS,y)
                    moving=abs(x)+abs(y)>42000-radius
                if moving:
                    if flags&0x100:expected[ACTORS][124+0x21]=2
                    else:
                        call(RETIRE,actor)
                        expected[ACTORS][124+0x21]=1
        elif kind==3:call(REFLECT,actor)
        else:call(PRINT,MESSAGE)
    return images,expected,trace

def execute(code,data,case):
    images,expected,expected_trace=model(case)
    uc,write,run=machine([(ENTRY,code)],data)
    guard=bytes(range(16));trace=[]
    for address,blob in images.items():write(address-16,guard+bytes(blob)+guard)
    write(0x802FFF80,b'\x75'*16);write(0x80300010,b'\x57'*48)
    def read(a,n):return bytes(uc.mem_read(a&0x1FFFFFFF,n))
    def boundary(uc,address,size,user):
        args=[uc.reg_read(r) for r in (regs.UC_MIPS_REG_A0,regs.UC_MIPS_REG_A1,regs.UC_MIPS_REG_A2,regs.UC_MIPS_REG_A3)[:COUNTS[address]]]
        event=[address,args]
        assert len(trace)<len(expected_trace) and event==expected_trace[len(trace)],(case,event,expected_trace)
        trace.append(event)
        result=case[9] if address==REFLECT else 0
        if address==ABS:
            value=args[0] if args[0]<0x80000000 else args[0]-0x100000000
            result=abs(value)
        for i,r in enumerate(CALLER_SAVED):uc.reg_write(r,0xBA120000+i*257)
        uc.reg_write(regs.UC_MIPS_REG_V0,result)
        uc.reg_write(regs.UC_MIPS_REG_PC,uc.reg_read(regs.UC_MIPS_REG_RA))
    for address in COUNTS:uc.hook_add(UC_HOOK_CODE,boundary,begin=address,end=address)
    run(ENTRY)
    assert trace==expected_trace,(case,trace,expected_trace)
    digest=hashlib.sha256()
    for address,blob in expected.items():
        observed=read(address-16,len(blob)+32)
        assert observed==guard+bytes(blob)+guard,(case,hex(address))
        digest.update(word(address)+observed)
    assert read(0x802FFF80,16)==b'\x75'*16 and read(0x80300010,48)==b'\x57'*48
    return dict(trace=trace,state_sha256=digest.hexdigest())

def cases():
    yield 0, 5, 40000, 0, 0, 1, 2, 0, 201, 1, 0
    for kind,resource,position,diamond,bounced in itertools.product(range(11),(2,4,5,6,7,8,10,13,21,22,23,24,188),((0,0),(30001,0),(0,-30001),(22000,22000)),(0,1),(0,1)):
        yield kind,resource,*position,0,diamond,0,0,201,bounced,1
    for kind,position,radius,blocked,flags,age,player in itertools.product((0,4,9),((30000,0),(-30000,0),(0,30000),(0,-30000),(21000,21000)),(-32768,-1,0,1,32767),(0,1),(0,0x100),(0,1,2,3,200,201),(0,1)):
        yield kind,23 if kind==9 else 2,*position,radius,1,blocked,flags,age,1,player

def main():
    rom=(ROOT/'baseroms/us/baserom.z64').read_bytes();validate(rom)
    result=compare_block('boundary_dispatch','src/game/actor_groups/boundary_dispatch.c',ENTRY,0x19CF8,0x1A0DC,rom,family='boundary-dispatch-execution',layout=SymbolLayoutSnapshot())
    assert result['matches'],result['different_words'][:10]
    output=ROOT/'build/boundary-dispatch-execution'
    compiled=(output/'boundary_dispatch/boundary_dispatch.bin').read_bytes()
    support=[(TABLE,rom[0x90CAC:0x90D38]),(MESSAGE,rom[0x909E0:0x90A04])]
    directory=output/'boundary_dispatch'
    with (directory/'boundary_dispatch.elf').open('rb') as stream:
        elf=ELFFile(stream)
        compiled_support=[]
        for address,expected in support:
            section=next(section for section in elf.iter_sections() if section['sh_addr']==address)
            assert section.data()==expected,(section.name,address)
            compiled_support.append((address,section.data()))
    with (directory/'boundary_dispatch.raw.o').open('rb') as stream:
        elf=ELFFile(stream)
        tail_sizes={'.text':996,'.rodata':140,'.data':36}
        tails={name:elf.get_section_by_name(name).data()[size:] for name,size in tail_sizes.items()}
        assert all(not any(tail) for tail in tails.values())
        assert [(symbol.name,symbol['st_size']) for symbol in elf.get_section_by_name('.symtab').iter_symbols() if symbol['st_info']['type']=='STT_FUNC' and symbol['st_shndx']!='SHN_UNDEF']==[('func_800190F8',996)]
        relocations=list(elf.get_section_by_name('.rel.rodata').iter_relocations())
        assert len(relocations)==35 and all(reloc['r_info_type']==2 for reloc in relocations)
        assert [reloc['r_offset'] for reloc in relocations]==list(range(0,140,4))
        symbols=elf.get_section_by_name('.symtab')
        table_bytes=elf.get_section_by_name('.rodata').data()
        for reloc in relocations:
            assert symbols.get_symbol(reloc['r_info_sym']).name=='.text'
            offset=reloc['r_offset']
            target=int.from_bytes(table_bytes[offset:offset+4],'big')
            assert 0 <= target < 996 and target % 4 == 0
        assert all(section.name in ('.text','.rodata','.data','.reginfo') for section in elf.iter_sections() if section['sh_flags']&2)
    data_proof=dict(sections=[dict(vram=hex(a),size=len(b),sha256=hashlib.sha256(b).hexdigest()) for a,b in compiled_support],switch_relocations=35,relocation_type='R_MIPS_32',zero_tail_bytes={name:len(tail) for name,tail in tails.items()})
    digest=hashlib.sha256();count=0
    for case in cases():
        original=execute(rom[0x19CF8:0x1A0DC],support,case)
        rebuilt=execute(compiled,compiled_support,case)
        assert original==rebuilt,case
        digest.update(json.dumps([case,rebuilt],sort_keys=True).encode());count+=1
        if count%1000==0:print('Compared',count,'boundary cases',flush=True)
    report=dict(matches=True,cases=count,comparison=result,data=data_proof,emulator=version("unicorn"),target_rom_sha256=hashlib.sha256(rom).hexdigest(),machine_helper_sha256=hashlib.sha256((ROOT/"tools/check_actor_group_path.py").read_bytes()).hexdigest(),trace_sha256=digest.hexdigest(),checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),limits=['Boundary response, retirement, sound and diagnostics are recorded ABI stubs.','Direct actor/player writes, switch dispatch, guarded linked actor pools and saved registers are checked.','Whole-game collision behavior and callback implementations are outside this check.'])
    (output/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print('Passed boundary dispatcher',count,flush=True)
if __name__=='__main__':main()
