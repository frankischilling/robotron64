"""Execute the complete interpreter and its real matched vertex-copy callees."""
from pathlib import Path
import contextlib, hashlib, io, itertools, json, struct
from importlib.metadata import version
from rom import ROOT as R, validate
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UC_MEM_WRITE
from unicorn import mips_const as regs
from capstone import Cs, CS_ARCH_MIPS, CS_MODE_MIPS32, CS_MODE_BIG_ENDIAN
from check_actor_boundary_boss import environment, signed
from check_actor_group_path import word, SENTINEL
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols

ENTRY,TABLE,STREAM,MESH,NORMALS,PACKETS,STACK=0x80045A08,0x800951DC,0x80201000,0x80202000,0x80203000,0x80204000,0x80300000
VERTICES,POSITIONS,PALETTE,STATE=0x800CDBD0,0x800CA5A0,0x8007BF34,0x80123AD0

def compile_candidate(source):
    layout=SymbolLayoutSnapshot(); rom=(R/'baseroms/us/baserom.z64').read_bytes(); validate(rom)
    name='renderer_mesh_commands'; family='mesh-command-execution'
    with contextlib.redirect_stdout(io.StringIO()):
        q=compare_block(name,source,ENTRY,0x46608,0x46B40,rom,family,layout)
    assert q['matches'], 'Complete public code/table comparison failed'
    directory=R/'build'/family/name
    raw,syms=elf_sections_and_symbols(directory/(name+'.raw.o'))
    linked,_=elf_sections_and_symbols(directory/(name+'.elf'))
    code=linked['.text']['bytes']; table=linked['.renderer_mesh_commands_switch']['bytes']
    assert syms['func_80045A08']['size']==len(code)==1336 and len(table)==68
    assert code==rom[0x46608:0x46B40] and table==rom[0x95DDC:0x95E20]
    assert raw['.text']['bytes'][1336:]==bytes(raw['.text']['size']-1336)
    assert raw['.rodata']['bytes'][68:]==bytes(raw['.rodata']['size']-68)
    item=dict(source=source,source_sha256=hashlib.sha256((R/source).read_bytes()).hexdigest(),source_owned=True,
        complete_code_different_words=0,complete_table_different_words=0,
        live_bytes=1336,raw_text_bytes=raw['.text']['size'],raw_table_bytes=raw['.rodata']['size'],
        checked_zero_text_padding_bytes=raw['.text']['size']-1336,
        checked_zero_table_padding_bytes=raw['.rodata']['size']-68,
        frame_bytes=-struct.unpack('>h',code[2:4])[0],comparison=q)
    assert item['frame_bytes']==104
    layout.verify(); return code,table,item

def streams():
    return [
      [0x7000],
      [-32768,0x6FFF,0x7005,0x700F,0x7011,32767,0x7000],
      [0x7002,-2,0x7002,0,0x7002,1,0x7002,31,0x7002,32,0x7000],
      [0x7002,33,0x7002,64,0x7002,65,0x7000],
      [0x7001,1,-2,0x7001,2,0,0x7001,3,1,0x7001,4,32,0x7002,31,0x7000],
      [0x7010,3,0x7001,37,33,0x7002,33,0x7010,3,0x7001,7,1,0x7002,1,0x7000],
      [0x7003,0,-32768,32767,0x7003,1,-1,128,0x7003,2,255,-129,0x7003,-1,3,4,0x7000],
      [0x7004,-32768,32767,-1,255,0x7004,0,1,2,3,0x7000],
      [0x7010,1,0x7010,186,0x7010,186,0x7010,-1,0x7010,0x101,0x7000],
      [0x7010,256,0x7001,3,2,0x7003,1,2,3,0x7002,2,0x7004,1,2,3,4,0x7010,511,0x7001,1,1,0x7002,33,0x7000]
    ]

def cases(): return list(itertools.product((0,1,-1),(8,97,199),(3,186),(0,1),range(10),(0,1,2)))

def run(code,table,support,case,entry=ENTRY,table_address=TABLE):
    lighting,destination,last_color,wrap,stream_index,fixture_kind=case
    commands=streams()[stream_index]
    uc,write,execute,read,_=environment([(entry,code)],support)
    regions={}
    allocations=((STREAM,128),(MESH,24),(NORMALS,128*8),(PACKETS,512),(VERTICES,512*16),
                 (POSITIONS,128*12),(PALETTE,1024),(STATE,0x1058),(0x800C85B8,4),(0x80138254,4),(table_address,len(table)))
    for salt,(address,length) in enumerate(allocations):
        regions[address-16]=bytearray(b'\xA5'*16+bytes((i*37+salt*23+7)&255 for i in range(length))+b'\xB6'*16)
    regions[STACK-0x1000]=bytearray(b'\xC7'*0x1040)
    def put(images,address,blob):
        for base,storage in images.items():
            if base<=address and address+len(blob)<=base+len(storage):
                storage[address-base:address-base+len(blob)]=blob; return
        raise AssertionError(('Fixture escaped',hex(address),len(blob)))
    def get(images,address,size):
        for base,storage in images.items():
            if base<=address and address+size<=base+len(storage): return bytes(storage[address-base:address-base+size])
        raise AssertionError(('Oracle read escaped',hex(address),size))
    set_word=lambda images,address,value:put(images,address,word(value))
    positions=[]; normals=[]
    for i in range(128):
        xyz=(i*317-999,777-i*193,-1000+i*511) if fixture_kind==0 else ((0x7FFFFFFF,-0x80000000,0x12345678) if fixture_kind==1 else (-65537,65536,-32769))
        normal=(i*211-16000,17000-i*197,i*149-8000)
        positions.append(xyz); normals.append(normal)
        put(regions,POSITIONS+i*12,b''.join(word(x) for x in xyz))
        put(regions,NORMALS+i*8,struct.pack('>hhhh',*normal,1234))
    palette=bytes(((i*73+19)&255) for i in range(1024)); put(regions,PALETTE,palette)
    put(regions,STREAM,struct.pack('>'+'h'*len(commands),*commands))
    put(regions,MESH,b''.join(word(x) for x in (0x12345678,128,NORMALS,0x87654321,0x81234560,7)))
    put(regions,table_address,table); set_word(regions,0x800C85B8,lighting); set_word(regions,0x80138254,PACKETS)
    set_word(regions,0x80123ADC,last_color)
    for address,value in ((0x80123AF0,511),(0x80123AF4,-129),(0x80123AF8,257),
                          (0x80123B10,0x7FFFFFFF if wrap else 11),(0x80123B14,-1 if wrap else 13),(0x80123B18,0xFFFFFFFF if wrap else 17)):
        set_word(regions,address,value)
    for address,blob in regions.items(): write(address,bytes(blob))
    expected={a:bytearray(b) for a,b in regions.items()}; cursor=PACKETS; copy_cursor=destination; load_cursor=destination; calls=[]
    def global_value(address): return int.from_bytes(get(expected,address,4),'big')
    def emit(a,b):
        nonlocal cursor
        put(expected,cursor,word(a)+word(b)); cursor+=8; set_word(expected,0x80138254,cursor)
    def triangle(a,b,c): return ((a*2&255)<<16)|((b*2&255)<<8)|(c*2&255)
    pc=0
    while True:
        command=commands[pc]; pc+=1
        if command==0x7000: break
        if command==0x7001:
            first,count=commands[pc:pc+2]; pc+=2
            calls.append([0x800460D8 if lighting else 0x80045F40,first&0xFFFFFFFF,count&0xFFFFFFFF,copy_cursor&0xFFFFFFFF]+([NORMALS] if lighting else []))
            for i in range(max(0,count)):
                out=VERTICES+(copy_cursor+i)*16
                put(expected,out,b''.join(struct.pack('>H',x&65535) for x in positions[first+i]))
                rgb=[x>>8 for x in normals[first+i]] if lighting else [global_value(x) for x in (0x80123AF0,0x80123AF4,0x80123AF8)]
                put(expected,out+12,bytes([*(x&255 for x in rgb),64]))
            copy_cursor=signed(copy_cursor+count)
        elif command==0x7002:
            count=commands[pc]; pc+=1
            if count<=32: emit(0x04000000|(((count<<10)|(count*16-1))&65535),VERTICES+load_cursor*16)
            else:
                remaining=count; start=0; vertices=VERTICES+load_cursor*16
                while remaining>0:
                    chunk=min(32,remaining)
                    emit(0x04000000|((start&255)<<16)|(((chunk<<10)|(chunk*16-1))&65535),vertices)
                    remaining-=32; start+=64; vertices+=512
            load_cursor=signed(load_cursor+count)
        elif command in (0x7003,0x7004):
            address=0x80123B10 if command==0x7003 else 0x80123B14
            set_word(expected,address,global_value(address)+1); set_word(expected,0x80123B18,global_value(0x80123B18)+1)
            if command==0x7003:
                a,b,c=commands[pc:pc+3]; pc+=3
                emit(0xBF000000,triangle(a,b,c) if a==0 else triangle(b,c,a) if a==1 else triangle(c,a,b))
            else:
                a,b,c,d=commands[pc:pc+4]; pc+=4; emit(0xB1000000|triangle(b,c,d),triangle(b,d,a))
        elif command==0x7010:
            color=commands[pc]&255; pc+=1
            if lighting and color==global_value(0x80123ADC): continue
            if lighting: set_word(expected,0x80123ADC,color)
            if lighting and color in (1,186): emit(0x03860010,0x80123B28+color*16); continue
            rgb=list(palette[color*4:color*4+3])
            for address,value in zip((0x80123AF0,0x80123AF4,0x80123AF8),rgb): set_word(expected,address,value)
            if lighting:
                packed=int.from_bytes(palette[color*4:color*4+4],'big')
                emit(0xBC00000A,packed); emit(0xBC00040A,packed)
                rgb=[x>>1 for x in rgb]
                for address,value in zip((0x80123AF0,0x80123AF4,0x80123AF8),rgb): set_word(expected,address,value)
                packed=(rgb[0]<<24)|(rgb[1]<<16)|(rgb[2]<<8)
                emit(0xBC00200A,packed); emit(0xBC00240A,packed)
    trace=[]
    def observe(uc,address,size,user):
        args=[uc.reg_read(x) for x in (regs.UC_MIPS_REG_A0,regs.UC_MIPS_REG_A1,regs.UC_MIPS_REG_A2,regs.UC_MIPS_REG_A3)]
        event=[address,*args[:(4 if address==0x800460D8 else 3)]]
        assert len(trace)<len(calls) and event==calls[len(trace)],(case,event,calls)
        trace.append(event)
    for address in (0x80045F40,0x800460D8): uc.hook_add(UC_HOOK_CODE,observe,begin=address,end=address)
    phys=lambda a:a&0x1FFFFFFF
    code_ranges=[(phys(a),phys(a)+len(b)) for a,b in [(entry,code),*support]]
    readable=[(phys(a),phys(a)+n) for a,n in allocations]+code_ranges+[(phys(STACK-0xE00),phys(STACK+32))]
    writable=[(phys(a),phys(a)+n) for a,n in ((PACKETS,512),(VERTICES,512*16),(0x80138254,4),(0x80123ADC,4),
         (0x80123AF0,12),(0x80123B10,12),(STACK-0xE00,0xE20))]
    def memory_guard(uc,access,address,size,value,user):
        address=phys(address)
        assert any(a<=address and address+size<=b for a,b in (writable if access==UC_MEM_WRITE else readable)),('Memory escaped',hex(address),size,hex(uc.reg_read(regs.UC_MIPS_REG_PC)))
    def code_guard(uc,address,size,user):
        assert address==SENTINEL or any(a<=phys(address) and phys(address)+size<=b for a,b in code_ranges),('Code escaped',hex(address))
    uc.hook_add(UC_HOOK_MEM_READ|UC_HOOK_MEM_WRITE,memory_guard); uc.hook_add(UC_HOOK_CODE,code_guard)
    for register,value in zip((regs.UC_MIPS_REG_A0,regs.UC_MIPS_REG_A1,regs.UC_MIPS_REG_A2),(STREAM,MESH,destination)): uc.reg_write(register,value)
    uc.reg_write(regs.UC_MIPS_REG_GP,0x8007F123); execute(entry)
    assert uc.reg_read(regs.UC_MIPS_REG_PC)==SENTINEL and uc.reg_read(regs.UC_MIPS_REG_GP)==0x8007F123
    assert uc.reg_read(regs.UC_MIPS_REG_V0)==(load_cursor&0xFFFFFFFF) and trace==calls,(case,trace,calls)
    for address,storage in expected.items():
        if address==STACK-0x1000:
            assert read(address,0x200)==bytes(storage[:0x200]) and read(STACK+32,32)==bytes(storage[0x1020:])
        else: assert read(address,len(storage))==bytes(storage),('Image mismatch',case,hex(address))
    return [trace,load_cursor,hashlib.sha256(read(PACKETS,512)+read(VERTICES,8192)+read(STATE,0x1058)).hexdigest()]

def main():
    source='src/game/renderer_primitives/mesh_commands.c'
    rom=(R/'baseroms/us/baserom.z64').read_bytes(); validate(rom); layout=SymbolLayoutSnapshot()
    name,path,first,last=next(x for x in MATCHING_BLOCKS if x[0]=='renderer_vertex_copy')
    with contextlib.redirect_stdout(io.StringIO()): q=compare_block(name,path,first,first-0x80000000+0xC00,last-0x80000000+0xC00,rom,'mesh-command-support',layout)
    assert q['matches']; support=[(first,(R/'build/mesh-command-support'/name/(name+'.bin')).read_bytes())]
    code,table,item=compile_candidate(source); retail=rom[0x46608:0x46B40]; retail_table=rom[0x95DDC:0x95E20]
    matrix=cases(); digest=hashlib.sha256()
    for index,case in enumerate(matrix):
        a=run(retail,retail_table,support,case); b=run(code,table,support,case)
        assert a==b; digest.update(json.dumps([case,a]).encode())
        if index%180==179: print('Mesh cases:',index+1,'of',len(matrix),flush=True)
    decoder=Cs(CS_ARCH_MIPS,CS_MODE_MIPS32|CS_MODE_BIG_ENDIAN)
    definitions=[('switch-bound',0x74,0x2DC10010),('copy-cursor-store',0xEC,0),('first-triangle-rotation',0x224,0),
                 ('lighting-half',0x448,0),('return-load-cursor',0x508,0)]
    mutations=[]
    for label,offset,encoding in definitions:
        changed=retail[:offset]+word(encoding)+retail[offset+4:]; failure=None
        for case in matrix:
            try: run(changed,retail_table,support,case)
            except Exception as error: failure=type(error).__name__+': '+str(error)[:240]; break
        assert failure is not None,label
        mutations.append(dict(name=label,detected=True,offset=hex(offset),failure=failure))
    changed_table=word(0x80045A70)+retail_table[4:]
    failure=None
    try: run(retail,changed_table,support,matrix[0])
    except Exception as error: failure=type(error).__name__+': '+str(error)[:240]
    assert failure is not None,'Table mutation survived'
    mutations.append(dict(name='stop-table-target',detected=True,failure=failure))
    base,helper=support[0]
    store=next(i for i in decoder.disasm(helper,base) if i.mnemonic=='sh')
    offset=store.address-base
    encoding=(int.from_bytes(store.bytes,'big')&0x03FFFFFF)|(0x28<<26)
    changed=helper[:offset]+word(encoding)+helper[offset+4:]; failure=None
    for case in matrix:
        try: run(retail,retail_table,[(base,changed)],case)
        except Exception as error: failure=type(error).__name__+': '+str(error)[:240]; break
    assert failure is not None,'Real vertex-copy mutation survived'
    mutations.append(dict(name='real-vertex-position-store',detected=True,address=hex(store.address),failure=failure))
    report=dict(**item,cases=len(matrix),executions=2*len(matrix),trace_sha256=digest.hexdigest(),mutations=mutations,
        checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),retail_bytes=1336,table_bytes=68,
        support_code_bytes=sum(len(b) for a,b in support),support_comparison=q,abi_stubs=0,
        unicorn_version=version('unicorn'),capstone_version=version('capstone'),
        limits='Finite bounded command streams cover unknown opcodes, stop, independent copy/load cursors, signed nonpositive counts, 31/32/33/64/65 batches, rotated triangles, quads, lighting on/off, special/repeated/masked colors, RGB halving, counter wrap and vertex truncation. Both real fresh matched copy/color/normal functions execute. Unterminated or invalid streams, arbitrary aliasing and actual rendering are unproved.')
    (R/'build/mesh-command-execution/report.json').write_text(json.dumps(report,indent=2)+'\n')
    layout.verify(); print('Mesh guard passed:',len(matrix),'cases;',len(mutations),'detected mutations; complete owned code and switch table.',flush=True)

if __name__=='__main__': main()
