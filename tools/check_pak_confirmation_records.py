"""Guard complete Pak confirmation records and observed title/adjacent-string writes."""
from pathlib import Path
import hashlib,itertools,json,sys
from importlib.metadata import version
from unicorn import UC_HOOK_CODE,UC_HOOK_MEM_READ,UC_HOOK_MEM_WRITE,UC_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_boundary_boss import environment,CLOBBER,signed,divide
from check_actor_group_path import word,SENTINEL
from compare_startup import compare_block,SymbolLayoutSnapshot
from compare_runtime import MATCHING_BLOCKS
from owned_sections import elf_sections_and_symbols
from rom import ROOT as R,validate
from compare_data import compare_unit,comparison_directory
from owned_sections import source_sections
NAV,STACK=0x800AEE98,0x80300000
ACTOR,PREVIEW,CAPTURE=0x80203000,0x80204000,0x80201000
PAGE,LABELS=0x8007726C,0x8007721C
PAGES=((PAGE,LABELS,2),)
TITLE,SELECTION=0x80093460,0x80201010
LABEL_TEXT=(b'\\delete',b'\\cancel')
STUBS=(0x80000518,0x800011AC,0x8000177C,0x80000E74,0x80000B7C,0x80001270,0x8003BCC4,0x8004CDE8)

def run_cleanup(code, image, retail, case):
    page_index, transition, restore, release, preview, actor, mask = case
    page, labels, count = PAGES[page_index]
    uc, write, execute, read, finish_call = environment(code, [])
    fixtures = {}
    def seed(address, value):
        fixtures[address] = bytearray(value)
    for base, size in ((0x8007721C, 132), (0x80093450, 60), (0x80093828, 16)):
        offset = base - 0x80000000 + 0xC00
        seed(base - 16, b'\xA5' * 16 + retail[offset:offset + size] + b'\xB6' * 16)
    seed(NAV - 16, b'\xC7' * 132)
    seed(ACTOR - 16, b'\xD8' * 112)
    seed(PREVIEW - 16, b'\xE9' * 112)
    seed(CAPTURE - 16, b'\xFA' * 44)
    seed(STACK - 0x300, b'\x8B' * 0x340)

    def put(address, value, destination=fixtures):
        for base, data in destination.items():
            if base <= address and address + len(value) <= base + len(data):
                data[address - base:address - base + len(value)] = value
                return
        raise AssertionError(('Write outside fixture', hex(address), len(value)))

    put(NAV + 4, word(page))
    put(NAV + 0x1C, word(PREVIEW if preview else 0))
    put(NAV + 0x20, word(ACTOR if actor else 0))
    put(NAV + 0x60, word(0x80208000))
    camera = (0x3F800000, 0xC0000000, 0x40800000)
    angles = (0x81234567, 0, 0x7FFFFFFF)
    for i, value in enumerate(camera):
        put(NAV + 0x2C + i * 4, word(value))
    for i, value in enumerate(angles):
        put(NAV + 0x38 + i * 4, word(value))
    slots = [(page + 4, 137 if mask & 1 else -1)]
    slots += [(labels + i * 40 + 16, 200 + i if mask & (1 << (i % 3)) else -1)
              for i in reversed(range(count))]
    for address, value in slots:
        put(address, word(value))
    expected = {a: bytearray(b) for a, b in fixtures.items()}
    expected_trace = []
    for address, value in slots:
        if value != -1:
            expected_trace.append(['text_release', address])
            put(address, word(-1), expected)
    if transition:
        put(NAV + 0x60, word(0), expected)
    if preview and release:
        put(PREVIEW + 0x21, b'\x02', expected)
        put(NAV + 0x1C, word(0), expected)
    if restore:
        expected_trace += [['camera_position', list(camera)], ['camera_angles', list(angles)]]
        put(CAPTURE, b''.join(word(x) for x in camera), expected)
    if actor:
        put(ACTOR + 0x21, b'\x02', expected)
    put(NAV + 4, word(0), expected)
    # Overlay independently compiled initialized storage; fixture expectations
    # continue to come from retail, including fields that cleanup never touches.
    actual = {a: bytearray(b) for a, b in fixtures.items()}
    for address, data in image:
        put(address, data, actual)
    for address, value in slots:
        put(address, word(value), actual)
    for base, data in actual.items():
        write(base, bytes(data))

    trace = []
    def stub(uc, address, size, user):
        if address == 0x80000ACC:
            argument = uc.reg_read(regs.UC_MIPS_REG_A0)
            trace.append(['text_release', argument])
            write(argument, word(-1))
        elif address == 0x80039F20:
            trace.append(['camera_position', [int.from_bytes(read(CAPTURE + i * 4, 4), 'big')
                                               for i in range(3)]])
        else:
            assert address == 0x80039FCC
            trace.append(['camera_angles', [uc.reg_read(r) for r in
                         (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2)]])
        finish_call()
    for address in (0x80000ACC, 0x80039F20, 0x80039FCC):
        uc.hook_add(UC_HOOK_CODE, stub, begin=address, end=address)

    code_ranges = [(a & 0x1FFFFFFF, (a & 0x1FFFFFFF) + len(b)) for a, b in code]
    code_ranges += [(CLOBBER & 0x1FFFFFFF, (CLOBBER & 0x1FFFFFFF) + 92)]
    stub_addresses = {0x80000ACC, 0x80039F20, 0x80039FCC, SENTINEL}
    reads = [(a & 0x1FFFFFFF, (a & 0x1FFFFFFF) + len(b)) for a, b in fixtures.items()] + code_ranges
    writes = [(STACK - 0x200, STACK + 16), (NAV + 4, NAV + 8),
              (NAV + 0x1C, NAV + 0x24), (NAV + 0x60, NAV + 0x64),
              (ACTOR + 0x21, ACTOR + 0x22), (PREVIEW + 0x21, PREVIEW + 0x22),
              (CAPTURE, CAPTURE + 12)]
    writes += [(a, a + 4) for a, _ in slots]
    writes = [(a & 0x1FFFFFFF, b & 0x1FFFFFFF) for a, b in writes]
    def memory_guard(uc, access, address, size, value, user):
        address &= 0x1FFFFFFF
        ranges = writes if access == UC_MEM_WRITE else reads
        assert any(a <= address and address + size <= b for a, b in ranges), (
            'Out-of-bounds memory access', access, hex(address), size)
    uc.hook_add(UC_HOOK_MEM_READ | UC_HOOK_MEM_WRITE, memory_guard)
    def execution_guard(uc, address, size, user):
        assert address in stub_addresses or any(a <= (address & 0x1FFFFFFF) < b
                                               for a, b in code_ranges), hex(address)
    uc.hook_add(UC_HOOK_CODE, execution_guard)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0x8007F123)
    uc.reg_write(regs.UC_MIPS_REG_A0, restore)
    uc.reg_write(regs.UC_MIPS_REG_A1, release)
    if transition:
        uc.reg_write(regs.UC_MIPS_REG_A2, 0)
    execute(0x800278AC if transition else 0x8002606C)
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0x8007F123
    assert trace == expected_trace, (case, trace, expected_trace)
    for base, data in expected.items():
        if base == STACK - 0x300:
            assert read(base, 0x100) == bytes(data[:0x100])
            assert read(STACK + 16, 48) == bytes(data[0x310:])
        else:
            assert read(base, len(data)) == bytes(data), (case, hex(base))
    return trace

def run_display(code,image,target,case):
    selected,alternate,tick,rng,properties=case
    uc,write,execute,read,finish_call=environment(code,[]);fixtures={}
    def seed(address,data):fixtures[address]=bytearray(data)
    for address,size in (((0x8007721C,132),(0x80093450,60),(0x80093828,16),(NAV,100),(0x800761F4,4),(0x8009EF94,4))):
        seed(address-16,b'\xA5'*16+bytes(size)+b'\xB6'*16)
    seed(STACK-0x300,b'\xC7'*0x340)
    def put(state,address,data):
        for base,storage in state.items():
            if base<=address and address+len(data)<=base+len(storage):storage[address-base:address-base+len(data)]=data;return
        raise AssertionError(('Fixture write escaped extent',hex(address),len(data)))
    for address,size in ((0x8007721C,132),(0x80093450,60),(0x80093828,16)):
        start=address-0x80000000+0xC00;put(fixtures,address,target[start:start+size])
    put(fixtures,NAV+4,word(PAGE));put(fixtures,NAV+0x44,word(123)+word(-234)+word(345))
    put(fixtures,NAV+0x50,word(LABELS+selected*40 if selected>=0 else 0))
    put(fixtures,0x800761F4,word(alternate));put(fixtures,0x8009EF94,word(tick))
    expected={a:bytearray(b) for a,b in fixtures.items()};actual={a:bytearray(b) for a,b in fixtures.items()}
    for address,data in image:put(actual,address,data)
    for address,data in actual.items():write(address,bytes(data))
    expected_trace=[];expected_properties={};handle=100
    def draw(slot,y,title,mode):
        return ['draw',[slot,123,-40234,345+y*130-(45500 if title else 39000),2278,0,0,2500,0,0,0,1,1,20 if title else 32767,mode]]
    expected_trace += [['convert',b'012345678901234456789012345'.hex()],['create',PAGE+4,b'012345678901234456789012345'.hex(),1500,11,0,0],draw(100,400-(60 if alternate else 0),True,180)]
    put(expected,PAGE+4,word(handle));y=400
    for i in range(1,-1,-1):
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
        expected_trace += [['properties',handle,expected_properties[handle]],draw(handle,y,False,1 if expected_properties[handle]&2 else 24)]
        y+=28
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
            assert args[0]==PAGE+4 or args[0] in [LABELS+i*40+16 for i in range(2)]
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
             [(LABELS+i*40+16&0x1FFFFFFF,LABELS+i*40+20&0x1FFFFFFF) for i in range(2)])
    def guard(uc,access,address,size,value,user):
        address&=0x1FFFFFFF;ranges=writable if access==UC_MEM_WRITE else readable
        assert any(a<=address and address+size<=b for a,b in ranges),('Memory escaped fixture',hex(address),size)
    def code_guard(uc,address,size,user):
        assert address in STUBS+(SENTINEL,) or any(a<=address&0x1FFFFFFF and (address&0x1FFFFFFF)+size<=b for a,b in code_ranges),hex(address)
    uc.hook_add(UC_HOOK_MEM_READ|UC_HOOK_MEM_WRITE,guard);uc.hook_add(UC_HOOK_CODE,code_guard)
    uc.reg_write(regs.UC_MIPS_REG_GP,0x8007F123);execute(0x8002741C);assert uc.reg_read(regs.UC_MIPS_REG_GP)==0x8007F123
    assert trace==expected_trace,(case,trace,expected_trace)
    for address,data in expected.items():
        if address==STACK-0x300:
            assert read(address,0x100)==bytes(data[:0x100]);assert read(STACK+16,48)==bytes(data[0x310:])
        else:assert read(address,len(data))==bytes(data),(case,hex(address))
    return trace

def run_formatting(code, data, target, length, image):
    uc,write,execute,read,finish=environment(code,data)
    fixtures={}
    def seed(address,payload):
        fixtures[address-16]=bytearray(b'\xA5'*16+payload+b'\xB6'*16)
    seed(SELECTION,word(0))
    seed(0x800BB0E8,word(0x800BAF08))
    seed(0x800BB128,word(0x1234))
    seed(0x800761F4,word(1))
    seed(0x8007721C,target[0x77E1C:0x77EA0])
    seed(0x80093450,target[0x94050:0x9408C])
    state=bytearray(512)
    state[:4]=word(512)
    state[10]=26  # extension A in the retail 51-byte decode table
    state[14:14+length]=bytes([26])*length
    seed(0x80143450,state+bytes(64)+b'\xD8'*256)
    seed(0x8008D520,target[0x8E120:0x8E153])
    seed(0x80095BE0,target[0x967E0:0x967E8])
    seed(0x80093828,target[0x94428:0x94438])
    seed(STACK-0x600,b'\xC7'*0x620)
    expected={address:bytearray(payload) for address,payload in fixtures.items()}
    def put(address,payload):
        for start,storage in expected.items():
            if start<=address and address+len(payload)<=start+len(storage):
                storage[address-start:address-start+len(payload)]=payload
                return
        raise AssertionError(('Expected write outside fixture',hex(address),len(payload)))
    decoded=b'A'*length+b' '
    name=decoded+b'.A'
    title=b'delete\\ '+name+b' ?\0'
    put(TITLE,title)
    put(0x80143690,decoded+bytes(256-len(decoded)))
    put(0x800BB128,word(0))
    put(0x800761F4,word(0))
    actual={address:bytearray(payload) for address,payload in fixtures.items()}
    for address,payload in image:
        for base,storage in actual.items():
            if base<=address and address+len(payload)<=base+len(storage):
                storage[address-base:address-base+len(payload)]=payload
                break
        else:raise AssertionError(('Compiled data outside fixture',hex(address),len(payload)))
    for address,payload in actual.items():write(address,bytes(payload))
    uc.reg_write(regs.UC_MIPS_REG_A0,SELECTION)
    uc.reg_write(regs.UC_MIPS_REG_GP,0xA7654321)
    code_spans=[(address,address+len(payload)) for address,payload in code]+[(CLOBBER,CLOBBER+92)]
    read_spans=[(address+16,address+len(payload)-16) for address,payload in fixtures.items()]
    read_spans += [(address,address+len(payload)) for address,payload in data]
    writes=[(0x80143690,0x80143790),(TITLE,TITLE+40),(0x800BB128,0x800BB12C),
            (0x800761F4,0x800761F8),(STACK-0x600,STACK+16)]
    touched=set()
    overrun=[]
    lookups=[]
    activation=[]
    def code_guard(uc,address,size,user):
        if address==0x8000060C:
            character=uc.reg_read(regs.UC_MIPS_REG_A0)
            assert character in (ord('A'),ord(' '))
            lookups.append(character)
            finish(0)
        elif address==0x80026178:
            activation.append([uc.reg_read(regs.UC_MIPS_REG_A0),uc.reg_read(regs.UC_MIPS_REG_A1)])
            assert activation==[[0x8007726C,0]]
            finish()
        else:
            assert address==SENTINEL or any(a<=address and address+size<=b for a,b in code_spans),('Code outside complete blocks',hex(address))
    def memory_guard(uc,access,address,size,value,user):
        address|=0x80000000
        if access==UC_MEM_WRITE:
            assert any(a<=address and address+size<=b for a,b in writes),('Write outside bounded scope',hex(address),size)
            if STACK-0x600<=address<STACK+16:touched.update(range(address,address+size))
            if TITLE+28<=address<TITLE+40:overrun.append(dict(address=hex(address),size=size,value=value))
        else:
            assert any(a<=address and address+size<=b for a,b in read_spans),('Read outside bounded scope',hex(address),size)
    uc.hook_add(UC_HOOK_CODE,code_guard)
    uc.hook_add(UC_HOOK_MEM_READ|UC_HOOK_MEM_WRITE,memory_guard)
    execute(0x800266BC)
    assert uc.reg_read(regs.UC_MIPS_REG_GP)==0xA7654321
    assert lookups==list(decoded) and activation==[[0x8007726C,0]]
    for address,payload in expected.items():
        actual=read(address,len(payload))
        if address==STACK-0x610:
            assert all(actual[i]==byte for i,byte in enumerate(payload) if address+i not in touched)
        else:assert actual==bytes(payload),('Full fixture mismatch',hex(address),length)
    assert bool(overrun)==(len(title)>28)
    return dict(encoded_name_bytes=length,decoded_name_bytes=len(decoded),entry_name_bytes=len(name),
                title_bytes_including_nul=len(title),title_initialized_span=28,
                writes_into_following_string=overrun,following_string_after=read(TITLE+28,4).hex(),
                title_hex=title.hex(),glyph_boundary_calls=len(lookups),activation_boundary_calls=len(activation))

def run_callback(code,image,target,case):
    record,slot,refresh=case
    uc,write,execute,read,finish=environment(code,[])
    offset=LABELS-0x80000000+0xC00
    labels=bytearray(target[offset:offset+80])
    for address,payload in image:
        if address==LABELS:labels[:]=payload
    address=LABELS+record*40
    callback=int.from_bytes(labels[record*40+4:record*40+8],'big')
    argument=int.from_bytes(labels[record*40+20:record*40+24],'big')
    assert callback==0x80026674 and argument==(1 if record==0 else 0)
    assert labels==target[offset:offset+80]
    fixtures={LABELS-16:b'\xA5'*16+labels+b'\xB6'*16,
              0x800BB118:b'\xD8'*16+word(slot)+b'\xE9'*16,
              STACK-0x100:b'\xC7'*0x130}
    for base,payload in fixtures.items():write(base,bytes(payload))
    events=[]
    def boundary(uc,address,size,user):
        if address==0x8004FA14:
            assert argument==1
            events.append(['delete',uc.reg_read(regs.UC_MIPS_REG_A0)])
            finish(-1)
        elif address==0x800267BC:events.append(['refresh']);finish(refresh&0xFFFFFFFF)
        elif address==0x8002674C:events.append(['fallback']);finish()
        else:assert address==SENTINEL or address==CLOBBER or any(base<=address and address+size<=base+len(payload) for base,payload in code) or CLOBBER<=address<CLOBBER+92
    touched=set()
    def guard(uc,access,address,size,value,user):
        address|=0x80000000
        if access==UC_MEM_WRITE:
            assert STACK-0x100<=address and address+size<=STACK+16
            touched.update(range(address,address+size))
        else:
            assert any(base<=address and address+size<=base+len(payload) for base,payload in fixtures.items())
    uc.hook_add(UC_HOOK_CODE,boundary)
    uc.hook_add(UC_HOOK_MEM_READ|UC_HOOK_MEM_WRITE,guard)
    uc.reg_write(regs.UC_MIPS_REG_A0,argument)
    uc.reg_write(regs.UC_MIPS_REG_GP,0xA7654321)
    execute(callback)
    expected=([['delete',slot&0xFFFFFFFF]] if argument else [])+[['refresh']]+([['fallback']] if refresh!=1 else [])
    assert events==expected and uc.reg_read(regs.UC_MIPS_REG_GP)==0xA7654321
    for base,payload in fixtures.items():
        actual=read(base,len(payload))
        assert all(actual[i]==byte for i,byte in enumerate(payload) if base+i not in touched)
    return events

def main():
    target=(R/'baseroms/us/baserom.z64').read_bytes();validate(target)
    layout=SymbolLayoutSnapshot();code=[];retail=[];support_data=[];comparisons={}
    support=('menu_display','game_memory','game_number_format','fixed_geometry_setup',
             'save_menu_nav_cleanup','save_menu_nav_preview_release','menu_transition_start',
             'save_menu_pak_refresh','save_menu_pak_name_select','controller_pak_name','controller_pak_entry','destination_format')
    from owned_sections import source_sections
    for name,source,start,end in MATCHING_BLOCKS:
        if name not in support:continue
        offset=start-0x80000000+0xC00
        q=compare_block(name,source,start,offset,offset+end-start,target,'pak-confirmation-execution',layout)
        assert q['matches'];comparisons[name]=q
        directory=R/'build/pak-confirmation-execution'/name
        code.append((start,(directory/(name+'.bin')).read_bytes()));retail.append((start,target[offset:offset+end-start]))
        sections,_=elf_sections_and_symbols(directory/(name+'.elf'))
        for record in source_sections(source):
            payload=sections[record['section']]['bytes']
            if payload is not None:support_data.append((record['vram'],payload))
    assert set(comparisons)==set(support)
    shim=b''.join(word(x) for x in (0x3C018020,0xE42C1000,0xE42E1004,0xAC261008,0))
    code.append((0x80039F10,shim));retail.append((0x80039F10,shim))
    image=[];data_comparisons={}
    for leaf in ('labels','page','text','title','format'):
        source='src/game/save_menus/pak_confirmation/'+leaf+'.c';records=source_sections(source)
        data_comparisons[source]=compare_unit(source,records,target,layout)
        sections,_=elf_sections_and_symbols(comparison_directory(source)/'compiled.elf')
        image += [(record['vram'],sections[record['section']]['bytes']) for record in records]
    assert sum(len(payload) for _,payload in image)==192
    digest=hashlib.sha256();counts={};results=[]
    suites=(('display',run_display,itertools.product((-1,0,1),range(2),(0,1,59),(0,-1,160000,0x7FFFFFFF),(0,2,0x12))),
            ('cleanup',run_cleanup,((0,)+case for case in itertools.product(range(2),range(2),range(2),range(2),range(2),range(8)))),
            ('callback',run_callback,itertools.product(range(2),(-1,0,15),(-1,0,1))))
    for name,run,matrix in suites:
        count=0
        for case in matrix:
            first=run(retail,[],target,case);second=run(code,image,target,case)
            assert first==second;digest.update(json.dumps([name,case,second],sort_keys=True).encode());count+=1
        counts[name]=count
    for length in range(17):
        first=run_formatting(retail,support_data,target,length,[])
        second=run_formatting(code,support_data,target,length,image)
        assert first==second;results.append(second);digest.update(json.dumps(['formatting',length,second],sort_keys=True).encode())
    counts['formatting']=17
    mutations=[]
    for name,address,payload,kind,case in (
        ('scalar_argument',LABELS+20,word(0),'callback',(0,15,1)),
        ('callback_address',LABELS+4,word(0),'callback',(0,15,1)),
        ('label_chain',LABELS+40+24,word(0),'display',(1,0,0,0,2)),
        ('page_title',PAGE,word(0),'display',(1,0,0,0,2)),
        ('mutable_title',TITLE,b'X','display',(1,0,0,0,2)),
        ('format_prefix',0x80093828,b'X','formatting',15)):
        changed=[]
        for base,data in image:
            if base<=address and address+len(payload)<=base+len(data):
                data=bytearray(data);data[address-base:address-base+len(payload)]=payload;data=bytes(data)
            changed.append((base,data))
        assert changed!=image
        try:
            if kind=='formatting':run_formatting(code,support_data,target,case,changed)
            else:{'callback':run_callback,'display':run_display}[kind](code,changed,target,case)
        except (AssertionError,ValueError):mutations.append(name)
        else:raise AssertionError('Undetected mutation '+name)
    report=dict(matches=True,initialized_bytes_added=192,source_instruction_bytes_added=0,bss_bytes_added=0,
                cases=sum(counts.values()),executions=sum(counts.values())*2,suites=counts,
                comparisons=comparisons,data_comparisons=data_comparisons,formatting_results=results,
                mutations_detected=mutations,trace_sha256=digest.hexdigest(),unicorn=version('unicorn'),
                checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                limits=['Complete matched display, cleanup/transition, callback, filename and formatting blocks execute with retail and compiled confirmation data.',
                        'Text services, drawing, RNG, Pak deletion/directory refresh, glyph lookup and page activation are explicit O32 boundary stubs.',
                        'Callback addresses and scalar argument words are read by the harness from real records; the full menu-control caller is outside this guard.',
                        'Synthetic successful slot zero and encoded A/extension A names; a full 16-byte name reads zero-filled record padding.',
                        'Formatting preserves the observed writes into the adjacent yes string for 15/16-character names. Original title capacity and portable C overflow behavior are not established.',
                        'Protected fixture bytes, bounded reads/writes/code, stack canaries, SP, GP and saved registers are checked; gameplay and RSP rendering remain unverified.'])
    blob=(json.dumps(report,indent=2)+'\n').encode()
    (R/'build/pak-confirmation-execution/report.json').write_bytes(blob)
    print('Complete Pak confirmation records:',report['cases'],'cases,',report['executions'],'executions,',len(mutations),'mutations;',counts,flush=True)

if __name__=='__main__':main()
