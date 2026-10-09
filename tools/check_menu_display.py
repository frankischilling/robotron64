"""Guard complete menu display with real string helpers and recorded text ABI stubs.

Text conversion, decoding, handle creation, flags and drawing are boundaries.
This checks submission behavior, rather than rendering or page activation.
"""

import hashlib
import itertools
import json
from importlib.metadata import version

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UC_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_boundary_boss import environment, CLOBBER, signed, divide
from check_actor_group_path import word, SENTINEL
from compare_data import compare_unit, comparison_directory
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate

ENTRY, NAV, STACK = 0x8002741C, 0x800AEE98, 0x80300000
PAGE, LABEL, SELECTION, STRINGS, CHOICES = (0x80201000, 0x80202000, 0x80203000,
                                         0x80204000, 0x80205000)
SUPPORT = ('menu_display', 'game_memory', 'game_number_format', 'fixed_geometry_setup')
DATA = tuple('src/game/save_menus/display/' + leaf + '.c'
             for leaf in ('choices', 'text', 'never')) + ('src/game/formatting/digits.c',)
STUBS = (0x80000518, 0x800011AC, 0x8000177C, 0x80000E74,
         0x80000B7C, 0x80001270, 0x8003BCC4, 0x8004CDE8)


def run(code, image, target, case):
    flags, selected, alternate, selection, tick, rng, properties, page_mode, offset = case
    uc, write, execute, read, finish_call = environment(code, [])
    fixtures = {}
    def seed(address, data):
        fixtures[address] = bytearray(data)
    for address, size in ((NAV, 100), (PAGE, 48), (LABEL, 40),
                          (SELECTION, 4), (STRINGS, 64), (CHOICES, 16),
                          (0x800761F4, 20), (0x8009EF94, 4),
                          (0x80092C08, 8),
                          (0x800938C8, 8), (0x8007BB1C, 20)):
        seed(address - 16, b'\xA5' * 16 + bytes(size) + b'\xB6' * 16)
    seed(STACK - 0x300, b'\xC7' * 0x340)
    def put(address, data, destination=fixtures):
        for base, storage in destination.items():
            if base <= address and address + len(data) <= base + len(storage):
                storage[address-base:address-base+len(data)] = data
                return
        raise AssertionError(('Fixture write escapes extent', hex(address), len(data)))
    for address, size in ((0x800761F8, 16), (0x80092C08, 8),
                          (0x800938C8, 8), (0x8007BB1C, 20)):
        start = address - 0x80000000 + 0xC00
        put(address, target[start:start+size])
    put(STRINGS, b'Title\0'); put(STRINGS+16, b'Label\0')
    put(STRINGS+32, b'Alternate\0'); put(STRINGS+48, b'Choice\0')
    put(CHOICES, word(STRINGS+48)+word(68)+word(STRINGS+32)+word(68))
    put(PAGE, word(STRINGS)+word(-1)+word(-17)+word(offset))
    put(PAGE+32, word(LABEL if page_mode==2 else 0))
    put(LABEL, word(flags))
    put(LABEL+8, word(STRINGS+16)+word(CHOICES if flags&0x1000 else
                                     STRINGS+32 if alternate else 0)+word(-1))
    put(LABEL+20, word(SELECTION)); put(LABEL+28, word(28))
    put(SELECTION, word(selection))
    put(NAV+4, word(PAGE if page_mode else 0))
    put(NAV+0x44, word(123)+word(-234)+word(345))
    put(NAV+0x50, word(LABEL if selected else 0))
    put(0x800761F4, word(alternate)); put(0x8009EF94, word(tick))
    expected = {a:bytearray(b) for a,b in fixtures.items()}
    actual = {a:bytearray(b) for a,b in fixtures.items()}
    for address, data in image:
        put(address, data, actual)
    for address, data in actual.items():write(address, bytes(data))

    def draw(slot, y, limit, mode):
        return ['draw', [slot, 106, signed(-40234), signed(345+y*130-(45500 if limit==20 else 39000)),
                         2278, 0, 0, 2500, 0, 0, 0, 1, 1, limit, mode]]
    expected_trace = []
    expected_properties = properties
    if page_mode:
        expected_trace += [['convert', '5469746c65'], ['create', PAGE+4, '5469746c65', 1500, 11, 0, 0],
                           draw(100, offset-(60 if alternate else 0), 20, 180)]
        put(PAGE+4, word(100), expected)
        if page_mode==2:
            label_text = b'Alternate' if selected and alternate and not flags&0x1000 else b'Label'
            expected_trace += [['convert', label_text.hex()], ['create', LABEL+16, label_text.hex(), 1000, 11, 1, 0]]
            put(LABEL+16, word(101), expected)
            if selected and tick:
                expected_trace.append(['random', rng&0xFFFFFFFF])
                remainder = signed(rng) >> 3
                remainder -= divide(remainder, 20000)*20000
                if (remainder&0xFFFFFFFF)//(tick&0xFFFFFFFF)==0:
                    expected_trace.append(['properties', 101, expected_properties])
                    if expected_properties&2:
                        expected_trace.append(['properties', 101, expected_properties])
                        if not expected_properties&0x10:
                            expected_trace.append(['flags', 101, 16, 0])
                            expected_properties |= 16
            if flags&0x200:
                expected_trace.append(['suffix', 101, 6, (b'on' if selection&1 else b'off').hex()])
            if flags&0x400 and not flags&0x10000:
                if flags&0x1000:
                    suffix = b'Alternate' if selection else b'Choice'
                    expected_trace += [['decode', suffix.hex()], ['convert', suffix.hex()]]
                elif selection==105000:
                    suffix = b'never'
                else:
                    suffix = bytes((b+122)&255 for b in str(selection+1).encode())
                expected_trace.append(['suffix', 101, 6, suffix.hex()])
            expected_trace += [['properties', 101, expected_properties], draw(101, offset, 32767, 1 if expected_properties&2 else 24)]

    trace=[]; state=[properties]
    def string(address):
        result=bytearray()
        for i in range(100):
            byte=read(address+i,1)[0]
            if not byte:return result.hex()
            result.append(byte)
        raise AssertionError('Boundary string lacks bounded terminator')
    def stub(uc,address,size,user):
        args=[uc.reg_read(reg) for reg in (regs.UC_MIPS_REG_A0,regs.UC_MIPS_REG_A1,
                                          regs.UC_MIPS_REG_A2,regs.UC_MIPS_REG_A3)]
        sp=uc.reg_read(regs.UC_MIPS_REG_SP)
        if address==0x80000518:
            trace.append(['convert',string(args[0])]); finish_call(args[0])
        elif address==0x8003BCC4:
            trace.append(['decode',string(args[0])]); finish_call(args[0])
        elif address==0x800011AC:
            trace.append(['create',args[0],string(args[1]),signed(args[2]),signed(args[3]),
                          int.from_bytes(read(sp+16,4),'big'),int.from_bytes(read(sp+20,4),'big')])
            handle=100 if args[0]==PAGE+4 else 101
            assert args[0] in (PAGE+4,LABEL+16)
            write(args[0],word(handle)); finish_call(handle)
        elif address==0x8000177C:
            values=args+[int.from_bytes(read(sp+16+i*4,4),'big') for i in range(11)]
            trace.append(['draw',[signed(x) for x in values]]); finish_call()
        elif address==0x80000E74:
            assert args[0]==101; trace.append(['properties',101,state[0]]);finish_call(state[0])
        elif address==0x80000B7C:
            trace.append(['flags']+args[:3]);state[0]=(state[0]|args[1])&~args[2];finish_call()
        elif address==0x80001270:
            trace.append(['suffix',args[0],args[1],string(args[2])]);finish_call(0)
        else:
            assert address==0x8004CDE8;trace.append(['random',rng&0xFFFFFFFF]);finish_call(rng&0xFFFFFFFF)
    for address in STUBS:uc.hook_add(UC_HOOK_CODE,stub,begin=address,end=address)
    code_ranges=[(a&0x1FFFFFFF,(a&0x1FFFFFFF)+len(b)) for a,b in code]
    code_ranges.append((CLOBBER&0x1FFFFFFF,(CLOBBER&0x1FFFFFFF)+92))
    readable=[(a&0x1FFFFFFF,(a&0x1FFFFFFF)+len(b)) for a,b in fixtures.items()]+code_ranges
    writable=[(STACK-0x200,STACK+16),(PAGE+4,PAGE+8),(LABEL+16,LABEL+20)]
    writable=[(a&0x1FFFFFFF,b&0x1FFFFFFF) for a,b in writable]
    def guard(uc,access,address,size,value,user):
        address &= 0x1FFFFFFF
        ranges=writable if access==UC_MEM_WRITE else readable
        assert any(a<=address and address+size<=b for a,b in ranges),('Memory escaped extent',hex(address),size)
    uc.hook_add(UC_HOOK_MEM_READ|UC_HOOK_MEM_WRITE,guard)
    def code_guard(uc,address,size,user):
        assert address in STUBS+(SENTINEL,) or any(a<=(address&0x1FFFFFFF)<b for a,b in code_ranges),hex(address)
    uc.hook_add(UC_HOOK_CODE,code_guard)
    uc.reg_write(regs.UC_MIPS_REG_GP,0x8007F123)
    execute(ENTRY)
    assert uc.reg_read(regs.UC_MIPS_REG_GP)==0x8007F123
    assert trace==expected_trace,(case,trace,expected_trace)
    for address,data in expected.items():
        if address==STACK-0x300:
            assert read(address,0x100)==bytes(data[:0x100])
            assert read(STACK+16,48)==bytes(data[0x310:])
        else:assert read(address,len(data))==bytes(data),(case,hex(address))
    return trace


def main():
    target=(ROOT/'baseroms/us/baserom.z64').read_bytes();validate(target);layout=SymbolLayoutSnapshot()
    comparisons={};compiled=[];original=[]
    for name,source,first,last in MATCHING_BLOCKS:
        if name not in SUPPORT:continue
        start=first-0x80000000+0xC00
        q=compare_block(name,source,first,start,start+last-first,target,'menu-display-execution',layout)
        assert q['matches'],name;comparisons[name]=q
        compiled.append((first,(ROOT/'build/menu-display-execution'/name/(name+'.bin')).read_bytes()))
        original.append((first,target[start:start+last-first]))
    assert set(comparisons)==set(SUPPORT)
    data_comparisons={};image=[]
    for source in DATA:
        records=source_sections(source);data_comparisons[source]=compare_unit(source,records,target,layout)
        sections,_=elf_sections_and_symbols(comparison_directory(source)/'compiled.elf')
        image += [(item['vram'],sections[item['section']]['bytes']) for item in records]
    cases=[]
    for bits,selected,alternate,properties in itertools.product(range(16),range(2),range(2),(0,2,18)):
        flags=sum(value for i,value in enumerate((0x200,0x400,0x1000,0x10000)) if bits&(1<<i))
        selection=1 if flags&0x1000 else (105000 if bits&1 else 9)
        cases.append((flags,selected,alternate,selection,1,0,properties,2,390))
    for selection,tick,rng,offset in itertools.product((-1000000,-1,0,1,105000,2147483646),(0,1,17,-1),(-8,8,160000),(0,400)):
        cases.append((0x600,1,0,selection,tick,rng,2,2,offset))
    cases += [(0,0,0,0,0,0,0,page,0) for page in (0,1)]
    digest=hashlib.sha256()
    for case in cases:
        a=run(compiled,image,target,case);b=run(original,[],target,case);assert a==b
        digest.update(json.dumps([case,a],sort_keys=True).encode())
    # Each mutation must fail the independent trace/memory oracle.
    mutations=[]
    mutation_case=(0x200,1,0,1,1,0,2,2,390)
    for address,value in ((0x800761F8,word(0)),(0x80092C0C,b'xx\0\0'),(0x800938C8,b'always\0\0')):
        altered=list(image)
        for i,(base,data) in enumerate(altered):
            if base<=address and address+len(value)<=base+len(data):
                blob=bytearray(data);blob[address-base:address-base+len(value)]=value;altered[i]=(base,bytes(blob));break
        else:raise AssertionError('Mutation has no data owner')
        case=(0x400,0,0,105000,0,0,0,2,390) if address==0x800938C8 else mutation_case
        # The pointer mutation selects entry zero so the changed word is consumed.
        if address==0x800761F8:case=tuple(0 if i==3 else x for i,x in enumerate(mutation_case))
        try:run(compiled,altered,target,case)
        except (AssertionError,ValueError):mutations.append(hex(address))
        else:raise AssertionError(('Undetected data mutation',hex(address)))
    report=dict(matches=True,cases=len(cases),executions=len(cases)*2,trace_sha256=digest.hexdigest(),
                source_instruction_bytes_added=1168,initialized_bytes_added=32,bss_bytes_added=0,
                checker_sha256=hashlib.sha256((ROOT/'tools/check_menu_display.py').read_bytes()).hexdigest(),
                unicorn_version=version('unicorn'),comparisons=comparisons,data_comparisons=data_comparisons,
                mutations_detected=mutations,limits=[
                    'Text conversion, choice decoding, handle allocation, text flags and drawing use O32 boundary stubs.',
                    'String length, string copy, decimal formatting and integer absolute value execute complete freshly matching source blocks.',
                    'Dictionary selections stay inside the two-record fixture; numeric inputs avoid INT_MIN formatting.',
                    'The proof covers integer callee-saved registers, SP, GP, bounded memory and code access; it does not claim full-game rendering or page activation.'])
    (ROOT/'build/menu-display-execution/report.json').write_text(json.dumps(report,indent=2)+'\n')
    print('Guarded menu display:',len(cases),'cases,',len(cases)*2,'executions and',len(mutations),'detected mutations.')


if __name__=='__main__':main()
