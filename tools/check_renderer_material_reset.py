"""Execute the complete material reset with real cache/resource reset callees."""
import hashlib
import json
import random
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs

from rom import ROOT as root, validate
from compare_startup import compare_block, SymbolLayoutSnapshot
from compare_runtime import MATCHING_BLOCKS
from check_actor_group_path import machine, word, SENTINEL
from owned_sections import elf_sections_and_symbols

ENTRY, MODEL, STACK = 0x800420B0, 0x80078274, 0x80300000
resources = ((0x800B1BE8,244,88,6), (0x800AF1F0,36,104,6),
             (0x800ACE58,8,88,6), (0x800AC998,11,92,6),
             (0x8009AA00,16,92,6), (0x8009B138,1,88,6),
             (0x8009AFD8,4,88,6), (0x8009EA18,5,96,10))
OPERATIONS = (
    (0x800B2741, 0x4000, False),
    (0x800B1F59, 0x4000, False),
    (0x800B1FB1, 0x4000, False),
    (0x800B2009, 0x4000, False),
    (0x800B2061, 0x4000, False),
    (0x800B20B9, 0x4000, False),
    (0x8009F561, 0x2000, False),
    (0x8009F5B9, 0x2000, False),
    (0x8009F611, 0x2000, False),
    (0x8009F669, 0x2000, False),
    (0x8009F6C1, 0x2000, False),
    (0x8009F719, 0x2000, False),
    (0x8009F771, 0x2000, False),
    (0x8009F7C9, 0x2000, False),
    (0x8009F879, 0x4000, False),
    (0x8009F929, 0x800, False),
    (0x8009F981, 0x44, False),
    (0x8009F9D9, 0x2000, False),
    (0x8009FA31, 0x2000, False),
    (0x8009FA89, 0x2000, False),
    (0x800AF2C1, 0x44, False),
    (0x800AF329, 0x4000, False),
    (0x800AF391, 0x4000, False),
    (0x800B1DA1, 0x44, False),
    (0x800B1F01, 0x800, False),
    (0x800B2219, 0x840, False),
    (0x800B2691, 0x42, False),
    (0x800B2849, 0x4040, False),
    (0x800B48F1, 0x2000, False),
    (0x800B2589, 0x40, False),
    (0x800B4949, 0x800, False),
    (0x800B4B01, 0x4040, False),
    (0x800B49F9, 0x800, False),
    (0x800B26E9, 0x4040, False),
    (0x800B5E41, 0x800, False),
    (0x800B5E99, 0x840, False),
    (0x800B5FF9, 0x840, False),
    (0x800B6051, 0x840, False),
    (0x800B60A9, 0x840, False),
    (0x800B6101, 0x840, False),
    (0x800B6999, 0x44, False),
    (0x800B69F1, 0x42, False),
    (0x800B6A49, 0x4000, False),
    (0x800B6AA1, 0x42, False),
    (0x800B6471, 0x42, False),
    (0x800B6419, 0x2000, False),
    (0x800B6AF9, 0x4000, False),
    (0x800B6B51, 0x4000, False),
    (0x800B6BA9, 0x4000, False),
    (0x800B6C01, 0x4000, False),
    (0x800B6C59, 0x4000, False),
    (0x800B6CB1, 0x4000, False),
    (0x800B2379, 0x1000, True),
    (0x800B5A21, 0x1000, True),
    (0x800B5A79, 0x1000, True),
    (0x800B5AD1, 0x1000, True),
    (0x800B5B29, 0x1000, True),
    (0x800AC999, 0x2000, False),
    (0x800ACAAD, 0x2000, False),
    (0x8009AFD9, 0x2000, False),
    (0x8009B031, 0x2000, False),
    (0x8009B089, 0x2000, False),
    (0x8009B0E1, 0x2000, False),
    (0x800AD011, 0x10, True),
    (0x800ACFB9, 0x10, True),
    (0x800AD069, 0x10, True),
    (0x800AD0C1, 0x10, True),
    (0x800B4F79, 0x800, False),
)
operations = OPERATIONS
kind_addresses = sorted({a for a, _, _ in operations})

def initial_state(seed, kinds):
    ranges = [(MODEL-16, MODEL+0x3880), (0x8009F550, 0x8009F560+16*88+16)]
    ranges += [(a-16, a+n*stride+16) for a,n,stride,_ in resources]
    ranges += [(a-16,a+20) for a in (0x800BF2C0,0x800BEF60,0x80126B74,0x8013D9C0)]
    merged = []
    for a,b in sorted(ranges):
        if merged and a <= merged[-1][1]:
            merged[-1] = (merged[-1][0], max(b, merged[-1][1]))
        else:
            merged.append((a,b))
    result = {a:bytearray(((i*37+seed*19)^((i//7)*13))&255 for i in range(b-a)) for a,b in merged}
    for address,value in zip(kind_addresses,kinds):
        block,offset = locate(result,address,1)
        block[offset] = value
    return result

def locate(data,address,size):
    for base, block in data.items():
        if base <= address and address+size <= base+len(block):
            return block,address-base
    raise AssertionError(('Outside initialized data',hex(address),size))

def put(data,address,value):
    block,offset=locate(data,address,len(value))
    block[offset:offset+len(value)]=value

def get(data,address,size):
    block,offset=locate(data,address,size)
    return bytes(block[offset:offset+size])

def oracle(initial):
    expected={a:bytearray(b) for a,b in initial.items()}
    allowed=[]
    for base,count,stride,offset in resources:
        for index in range(count):
            address=base+index*stride+offset
            put(expected,address,bytes([get(expected,address,1)[0]&127]))
            allowed.append((address,address+1))
    for index in range(400):
        for address in (MODEL+20+index*20,MODEL+0x1F5C+index*16):
            put(expected,address,b'\0')
            allowed.append((address,address+1))
        address=MODEL+24+index*20
        put(expected,address,word(128))
        allowed.append((address,address+4))
    for address in (0x800BF2C0,0x800BEF60,0x80126B80):
        put(expected,address,word(0))
        allowed.append((address,address+4))
    for destination,source in ((0x80126B74,0x80126B78),(0x8013D9C0,0x8013D9C4)):
        put(expected,destination,get(expected,source,4))
        allowed.append((destination,destination+4))
    for source,value,combine in operations:
        index=get(expected,source,1)[0]
        address=MODEL+24+index*20
        previous=int.from_bytes(get(expected,address,4),'big')
        put(expected,address,word(previous|value if combine else value))
    return expected,allowed

def execute(code,support,seed,kinds):
    initial=initial_state(seed,kinds)
    expected,allowed=oracle(initial)
    uc,write,_=machine([(ENTRY,code)],support)
    for address,data in initial.items():
        write(address,bytes(data))
    stack_start=STACK-0x80
    stack=bytes((i*41+seed)&255 for i in range(0xC0))
    write(stack_start,stack)
    allowed.append((STACK-0x60,STACK))
    write_allowed={address for a,b in allowed for address in range(a,b)}
    reads=[(a,a+len(b)) for a,b in initial.items()]+[(STACK-0x60,STACK)]
    saved={getattr(regs,'UC_MIPS_REG_'+name):uc.reg_read(getattr(regs,'UC_MIPS_REG_'+name))
           for name in ('S0','S1','S2','S3','S4','S5','S6','S7','FP')}
    uc.reg_write(regs.UC_MIPS_REG_GP,0xABCD1234)
    touched=set()
    calls=[]
    def guard_write(uc,access,address,size,value,user):
        address|=0x80000000
        assert all(address+i in write_allowed for i in range(size)),('Write guard',hex(address),size)
        if stack_start<=address<STACK:
            touched.update(range(address,address+size))
    def guard_read(uc,access,address,size,value,user):
        address|=0x80000000
        assert any(a<=address and address+size<=b for a,b in reads),('Read guard',hex(address),size)
    def call(uc,address,size,user):
        calls.append(address)
    uc.hook_add(UC_HOOK_MEM_WRITE,guard_write)
    uc.hook_add(UC_HOOK_MEM_READ,guard_read)
    for address in (0x8004BC8C,0x8001D260):
        uc.hook_add(UC_HOOK_CODE,call,begin=address,end=address)
    uc.emu_start(ENTRY,0,count=100000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC)==SENTINEL,'Function did not return'
    assert uc.reg_read(regs.UC_MIPS_REG_SP)==STACK
    assert uc.reg_read(regs.UC_MIPS_REG_GP)==0xABCD1234
    assert all(uc.reg_read(r)==v for r,v in saved.items())
    assert calls==[0x8004BC8C,0x8001D260],calls
    digest=hashlib.sha256()
    for address,block in expected.items():
        actual=bytes(uc.mem_read(address&0x1FFFFFFF,len(block)))
        assert actual==block,('Independent state oracle',hex(address),seed)
        digest.update(actual)
    actual_stack=bytes(uc.mem_read(stack_start&0x1FFFFFFF,len(stack)))
    assert all(v==stack[i] for i,v in enumerate(actual_stack) if stack_start+i not in touched)
    return digest.hexdigest(),calls

def main():
    target=(root/'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout=SymbolLayoutSnapshot()
    reports={}
    support=[]
    for name in ('renderer_cache_flags_clear','actor_resource_reset'):
        _,source,start,end=next(x for x in MATCHING_BLOCKS if x[0]==name)
        report=compare_block(name,source,start,start-0x80000000+0xC00,end-0x80000000+0xC00,
                             target,'renderer-reset-execution',layout)
        assert report['matches'],name
        reports[name]=report
        support.append((start,(root/f'build/renderer-reset-execution/{name}/{name}.bin').read_bytes()))
    reports['reset']=compare_block('reset','src/game/renderer_resources/material_reset.c',ENTRY,
                                   0x42CB0,0x43430,target,'renderer-reset-execution',layout)
    sections,symbols=elf_sections_and_symbols(root/'build/renderer-reset-execution/reset/reset.raw.o')
    assert sections['.text']['size']==1920
    assert symbols['func_800420B0']['size']==1912
    assert sections['.text']['bytes'][1912:]==bytes(8), 'Complete zero alignment'
    assert all(name in ('.text','.reginfo') or not (section['flags']&2 and section['size'])
               for name,section in sections.items()), 'Unexpected generated data'
    original=target[0x42CB0:0x43430]
    compiled=(root/'build/renderer-reset-execution/reset/reset.bin').read_bytes()
    assert reports['reset']['matches'], 'Complete function and alignment comparison'
    count=len(kind_addresses)
    cases=[(index,[index]*count) for index in range(256)]
    for step in (0,1,3,17,127,255):
        for start in (0,1,127,254,255):
            cases.append((step+start,[(start+n*step)&255 for n in range(count)]))
    rng=random.Random(0x420B0)
    for seed in range(64):
        cases.append((seed,[rng.randrange(256) for _ in range(count)]))
    digest=hashlib.sha256()
    for index,(seed,kinds) in enumerate(cases):
        retail=execute(original,support,seed,kinds)
        candidate=execute(compiled,support,seed,kinds)
        assert candidate==retail,(seed,kinds)
        digest.update(json.dumps((seed,kinds,retail),separators=(',',':')).encode())
        if (index+1)%64==0:
            print('Reset guarded cases',index+1,flush=True)
    mutants=[]
    for label,offset,xor in (('default flag value',0x44,1),('loop destination shift',0x40,20),
                             ('resource flag value',0x7C,1)):
        changed=bytearray(original)
        value=int.from_bytes(changed[offset:offset+4],'big')^xor
        changed[offset:offset+4]=word(value)
        try:
            execute(bytes(changed),support,0,list(range(count)))
        except AssertionError as error:
            mutants.append(dict(name=label,detected=True,reason=str(error)))
        else:
            raise AssertionError(('Mutation not detected',label))
    result=dict(instruction_matches=reports['reset']['matches'],execution_cases=len(cases),
                distinct_kind_addresses=count,trace_sha256=digest.hexdigest(),mutants=mutants,
                comparisons=reports,limits=['All 1912 instruction bytes match; eight verified alignment bytes are excluded from recovered instruction totals.',
                'Deterministic initialized records are not an end-to-end gameplay snapshot.',
                'Complete freshly matched cache and resource reset callees execute without stubs.'])
    layout.verify()
    (root/'build/renderer-reset-execution/report.json').write_text(json.dumps(result,indent=2)+'\n')
    print('All reset cases passed',len(cases),'instruction match',result['instruction_matches'],flush=True)

if __name__=='__main__':
    main()
