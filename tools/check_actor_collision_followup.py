"""Check complete rebound and retirement code against guarded MIPS state oracles."""

import hashlib
import itertools
import json
import struct
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE
from unicorn import mips_const as regs
from check_actor_boundary_boss import environment, signed, divide
from check_actor_group_path import word
from check_boss_trigger import pattern, fingerprint
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


FIRST, SECOND = 0x80201010, 0x80202010
RESOURCE, OTHER_RESOURCE = 0x80203010, 0x80204010
FIRST_POSITION, SECOND_POSITION = 0x80205010, 0x80206010
OWNER, POOL, MODE = 0x80207010, 0x800AE300, 0x800BA74C
CALLBACK, REBOUND_CALLBACK, RETIRE_CALLBACK = 0x80000180, 0x800162F8, 0x8001B468
REBOUND, RETIRE = 0x8001631C, 0x8001B4F8
ANIMATE, COSINE, SINE, OBJECT = 0x80027AB8, 0x8003CC88, 0x8003CC58, 0x80039514
RESET, LABEL, SCATTER, FRAGMENT, FORWARD = 0x80009F90, 0x8001B3DC, 0x800366C8, 0x80036B00, 0x8001B448
SPAWN, EFFECT, DIAGNOSTIC = 0x8001A350, 0x80039EB8, 0x8001C0D0
DAMAGE, SCORE, TURN, MIDPOINT, SOUND, RANDOM = 0x80015130, 0x80037144, 0x8001A410, 0x80015184, 0x8003614C, 0x8004CDE8
ARG_COUNTS = {ANIMATE: 3, COSINE: 1, SINE: 1, OBJECT: 2, RESET: 2, LABEL: 1, SCATTER: 1,
    FRAGMENT: 3, FORWARD: 2, SPAWN: 2, EFFECT: 2, DIAGNOSTIC: 1, DAMAGE: 2, SCORE: 2,
    TURN: 2, MIDPOINT: 1, SOUND: 4, RANDOM: 0, CALLBACK: 1, RETIRE_CALLBACK: 1}


class State:
    def __init__(self, images):
        self.images = {address: bytearray(data) for address, data in images.items()}

    def put(self, address, value, size=4):
        data = (value & ((1 << (8*size))-1)).to_bytes(size, 'big')
        for start, image in self.images.items():
            if start <= address and address+size <= start+len(image):
                image[address-start:address-start+size] = data
                return
        raise AssertionError(('Outside guards', hex(address), size))

    def get(self, address, size=4, unsigned=False):
        for start, image in self.images.items():
            if start <= address and address+size <= start+len(image):
                return int.from_bytes(image[address-start:address-start+size], 'big', signed=not unsigned)
        raise AssertionError(('Outside guards', hex(address), size))

    def kind(self, actor):
        return self.get(self.get(actor+36, unsigned=True)+2, 1, True)


def run(code, case):
    uc, write, execute, read, finish_call = environment(code, [])
    ranges = ((FIRST,124), (SECOND,124), (RESOURCE,88), (OTHER_RESOURCE,88), (OWNER,32),
              (POOL,500), (MODE,4), (FIRST_POSITION,12), (SECOND_POSITION,12))
    state = State({address-16: pattern(size+32, case['id']+ordinal*19)
                   for ordinal,(address,size) in enumerate(ranges)})
    for actor, resource in ((FIRST,RESOURCE), (SECOND,OTHER_RESOURCE)):
        state.put(actor+36, resource)
        state.put(actor+68, CALLBACK)
        state.put(actor+20, case['flags'])
        state.put(actor+8, -17, 2)
        state.put(actor+12, -31, 2)
        state.put(actor+16, case['health'] if actor==FIRST else case['second_health'], 2)
        state.put(actor+60, OWNER)
        state.put(resource+2, case['kind'] if actor==FIRST else case['second_kind'], 1)
        state.put(resource+4, -12345, 2)
        state.put(resource+8, case['speed'])
    state.put(MODE, case['mode'])
    for index in range(36):
        state.put(POOL+80+index*2, 32767 if index==case['kind'] else -32768, 2)
    vectors = ((-11,4), (13,-8), (2147483647,1), (-2147483648,-1), (-2147483648,2147483647))
    for axis in range(3):
        first, second = vectors[(case['id']+axis)%len(vectors)]
        state.put(FIRST_POSITION+axis*4, first)
        state.put(SECOND_POSITION+axis*4, second)
    initial = State(state.images)
    events, vector_events = [], {}
    call_counts = {}

    def mutate(image, address, ordinal):
        mutation = case['mutation']
        if case['entry']==RETIRE:
            if mutation==1 and address in (SCATTER,RESET):
                image.put(image.get(FIRST+36, unsigned=True)+2, 5, 1)
            if mutation==2 and address==ANIMATE:
                image.put(image.get(FIRST+36, unsigned=True)+2, 17, 1)
            if mutation==3 and address in (CALLBACK,RETIRE_CALLBACK):
                image.put(FIRST+20, 0x400)
                image.put(image.get(FIRST+36, unsigned=True)+2, 35, 1)
            if mutation==4 and address==OBJECT:
                image.put(image.get(FIRST+36, unsigned=True)+2, 21, 1)
            if mutation==5 and address==SPAWN:
                image.put(FIRST+36, OTHER_RESOURCE)
            if mutation==6 and address==LABEL:
                image.put(FIRST+20, 0x240)
        else:
            if mutation==1 and address==DAMAGE:
                image.put(FIRST+16, 0, 2)
                image.put(MODE, 0)
            if mutation==2 and address in (SCORE,TURN,MIDPOINT):
                image.put(SECOND+16, 0, 2)
            if mutation==3 and address==COSINE:
                image.put(OTHER_RESOURCE+8, -1234567)
                image.put(SECOND+8, -32768, 2)
            if mutation==4 and address==SINE:
                image.put(SECOND+12, 17, 2)
            if mutation==5 and address==ANIMATE:
                image.put(FIRST+20, 0x400)
            if mutation==6 and address==CALLBACK:
                image.put(FIRST+20, 0x4400)
            if mutation==6 and address==SOUND:
                image.put(SECOND+20, 0x700)

    def event(address, args, vector=None):
        ordinal = call_counts.get(address,0)+1
        call_counts[address] = ordinal
        events.append([address,[value & 0xFFFFFFFF for value in args],fingerprint(state.images)])
        if vector is not None:
            vector_events[len(events)-1] = vector
        mutate(state,address,ordinal)

    def cancel(actor):
        flags = state.get(actor+20,unsigned=True)
        if flags & 0x40:
            state.put(actor+20,flags & ~0x40)
            event(state.get(actor+68,unsigned=True),[actor])

    def install(actor, callback, timer):
        state.put(actor+20,state.get(actor+20,unsigned=True)|0x40)
        state.put(actor+68,callback)
        state.put(actor+14,timer,2)

    collision = False
    result = 0
    if case['entry']==RETIRE:
        state.put(FIRST+16,0,2)
        kind = state.kind(FIRST)
        if case['mode'] != -1:
            state.put(POOL+80+kind*2,state.get(POOL+80+kind*2,2)+1,2)
        if kind==34:
            event(RESET,[FIRST,0])
        elif kind in (0,1,2,3,4,13,14,15,16,21,22,23,24,30,31,32,33,35):
            if kind==4:
                event(SPAWN,[0x8009F878,FIRST+96])
            event(RESET,[FIRST,0])
            event(LABEL,[FIRST])
        elif 9 <= kind <= 20:
            event(EFFECT,[10,5])
            event(SCATTER,[FIRST])
            if kind<=12:
                event(RESET,[FIRST,0])
            else:
                event(LABEL,[FIRST])
                cancel(FIRST)
                install(FIRST,RETIRE_CALLBACK,1)
        elif 25 <= kind <= 28:
            state.put(FIRST+20,state.get(FIRST+20,unsigned=True)&~0x40)
            event(FRAGMENT,[189,FIRST,SECOND+108 if case['other'] else 0])
            event(FORWARD,[FIRST,1])
        elif kind==29:
            event(SCATTER,[FIRST])
        elif kind not in (5,6,7,8):
            event(DIAGNOSTIC,[0x80090200])
        if state.kind(FIRST)!=5:
            event(ANIMATE,[FIRST,1,1])
            state.put(FIRST+44,0)
            event(COSINE,[state.get(FIRST+8,2)])
            state.put(FIRST+108,0)
            event(SINE,[state.get(FIRST+8,2)])
            state.put(FIRST+112,0)
            event(OBJECT,[state.get(FIRST+12,2),state.get(FIRST+8,2)])
            state.put(FIRST+52,-1)
        if not 17 <= state.kind(FIRST) <= 20:
            cancel(FIRST)
            install(FIRST,0x8001B324,999)
    else:
        kind = state.kind(FIRST)
        if kind in (14,15):
            event(ANIMATE,[FIRST,3,1])
            cancel(FIRST)
            install(FIRST,REBOUND_CALLBACK,999)
        elif kind==11:
            collision = state.kind(SECOND) in (1,2)
        elif kind==12:
            if not state.get(SECOND+20,unsigned=True)&0x100:
                event(SOUND,[84,0,1,0])
            state.put(SECOND+20,state.get(SECOND+20,unsigned=True)&~0x100)
            event(RANDOM,[])
            random = signed(case['random']) >> 3
            angle = random-divide(random,4096)*4096
            state.put(SECOND+8,angle,2)
            state.put(SECOND+44,divide(signed(state.get(OTHER_RESOURCE+8)*7),10))
            for address, field, value in ((COSINE,108,case['cosine']), (SINE,112,case['sine'])):
                event(address,[state.get(SECOND+8,2)])
                product = signed(signed(value*7)*state.get(OTHER_RESOURCE+8))
                state.put(SECOND+field,divide(divide(product,10),4096))
            event(OBJECT,[state.get(SECOND+12,2),state.get(SECOND+8,2)])
        elif kind not in (8,9,13):
            if state.get(SECOND+20,unsigned=True)&0x100:
                result = 32
            else:
                collision = True
        if collision:
            event(DAMAGE,[SECOND,FIRST])
            if state.get(FIRST+16,2)<=0:
                if state.get(MODE)!=-1:
                    event(SCORE,[state.get(state.get(FIRST+36,unsigned=True)+4,2),state.get(SECOND+60,unsigned=True)])
                event(TURN,[FIRST,SECOND])
            else:
                midpoint = [divide(signed(state.get(FIRST_POSITION+axis*4)+state.get(SECOND_POSITION+axis*4)),2)
                            for axis in range(2)]+[0]
                event(MIDPOINT,[19],midpoint)
            if state.get(SECOND+16,2)==0:
                result = 32

    for address,data in initial.images.items():
        write(address,bytes(data))
    home = bytes(pattern(32,case['id']+71))
    write(0x80300000,home)
    observed, actual_counts = [], {}
    def observe(uc,address,size,user):
        if address not in ARG_COUNTS:
            return
        args = [uc.reg_read(register) for register in
            (regs.UC_MIPS_REG_A0,regs.UC_MIPS_REG_A1,regs.UC_MIPS_REG_A2,regs.UC_MIPS_REG_A3)[:ARG_COUNTS[address]]]
        actual = State({start:read(start,len(data)) for start,data in initial.images.items()})
        record = [address,args,fingerprint(actual.images)]
        assert len(observed)<len(events) and record==events[len(observed)], (case,record,events[len(observed):len(observed)+1])
        if address==MIDPOINT:
            pointer = uc.reg_read(regs.UC_MIPS_REG_A1)
            vector = [int.from_bytes(read(pointer+axis*4,4),'big',signed=True) for axis in range(3)]
            assert vector==vector_events[len(observed)], (case,vector,vector_events)
        observed.append(record)
        ordinal = actual_counts.get(address,0)+1
        actual_counts[address] = ordinal
        mutate(actual,address,ordinal)
        for start,data in actual.images.items():
            write(start,bytes(data))
        returned = {RANDOM:case['random'],COSINE:case['cosine'],SINE:case['sine']}.get(address,0)
        finish_call(returned & 0xFFFFFFFF)
    uc.hook_add(UC_HOOK_CODE,observe)
    for register,value in zip((regs.UC_MIPS_REG_A0,regs.UC_MIPS_REG_A1,regs.UC_MIPS_REG_A2,regs.UC_MIPS_REG_A3),
        (FIRST,SECOND if case['other'] else 0,FIRST_POSITION,SECOND_POSITION)):
        uc.reg_write(register,value)
    execute(case['entry'])
    assert observed==events, (case,'Missing events')
    for start,data in state.images.items():
        assert read(start,len(data))==bytes(data), (case,'Final state',hex(start))
    expected_home = home
    if collision:
        expected_home = home[:8]+word(FIRST_POSITION)+word(SECOND_POSITION)+home[16:]
    assert read(0x80300000,32)==expected_home, (case,'Argument home slots')
    if case['entry']==REBOUND:
        assert uc.reg_read(regs.UC_MIPS_REG_V0)==result, (case,'Return byte')
    return dict(events=observed,final_sha256=fingerprint(state.images),result=result if case['entry']==REBOUND else None)


def cases():
    for kind,mode,flags,other in itertools.product(range(36),(-1,0,7),(0,0x40,0x400,0x4400),(False,True)):
        yield dict(group='retire',entry=RETIRE,kind=kind,mode=mode,flags=flags,other=other)
    for kind,mutation,other in itertools.product(range(36),range(1,7),(False,True)):
        yield dict(group='retire_mutation',entry=RETIRE,kind=kind,mutation=mutation,other=other,flags=0x40)
    for kind,flags in itertools.product((36,127,255),(0,0x40)):
        yield dict(group='retire_diagnostic',entry=RETIRE,kind=kind,flags=flags,mode=-1)
    for kind,second_kind,flags,health,second_health in itertools.product(tuple(range(16))+(17,255),(1,2,5),
            (0,0x100),(-1,0,1),(-1,0,1)):
        yield dict(group='rebound',entry=REBOUND,kind=kind,second_kind=second_kind,flags=flags,health=health,second_health=second_health)
    for random,speed,flags in itertools.product((-2147483648,-32769,-32768,-8,-1,0,32767,2147483647),
            (-2147483648,-1000,0,1000,2147483647),(0,0x100)):
        yield dict(group='rebound_arithmetic',entry=REBOUND,kind=12,random=random,speed=speed,flags=flags)
    for kind,mutation,flags in itertools.product(tuple(range(16))+(17,255),range(1,7),(0,0x40)):
        yield dict(group='rebound_mutation',entry=REBOUND,kind=kind,mutation=mutation,flags=flags)


def main():
    target = (ROOT/'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    compiled,retail,comparisons = [],[],{}
    layout = SymbolLayoutSnapshot()
    for name in ('actor_collision_rebound','actor_collision_retire'):
        _,source,start,end = next(record for record in MATCHING_BLOCKS if record[0]==name)
        block = compare_block(name,source,start,start-0x80000000+0xC00,end-0x80000000+0xC00,
            target,family='actor-collision-followup-execution',layout=layout)
        assert block['matches'], name
        comparisons[name] = block
        directory = ROOT/'build/actor-collision-followup-execution'/name
        compiled.append((start,(directory/(name+'.bin')).read_bytes()))
        retail.append((start,target[start-0x80000000+0xC00:end-0x80000000+0xC00]))
        sections,_ = elf_sections_and_symbols(directory/(name+'.elf'))
        for record in source_sections(source):
            compiled.append((record['vram'],sections[record['section']]['bytes']))
            retail.append((record['vram'],target[record['rom']:record['rom']+record['size']]))
    message_source = 'src/game/collisions/retirement_message.c'
    message = compare_unit(message_source,source_sections(message_source),target,layout)
    assert message['matches']
    counts,digest = {},hashlib.sha256()
    for index,parameters in enumerate(cases()):
        case = dict(id=index,entry=REBOUND,kind=0,second_kind=2,mode=0,flags=0,health=1,
            second_health=0,other=True,mutation=0,speed=1000,random=-32769,
            cosine=(-2147483648,-4096,0,4096,2147483647)[index%5],sine=(4096,-4096,0)[index%3])
        case.update(parameters)
        expected = run(retail,case)
        actual = run(compiled,case)
        assert actual==expected, case
        counts[case['group']] = counts.get(case['group'],0)+1
        digest.update(json.dumps([case,actual],sort_keys=True).encode())
        if (index+1)%500==0:
            print('Followup execution cases:',index+1,flush=True)
    report = dict(matches=True,cases=sum(counts.values()),counts=counts,trace_sha256=digest.hexdigest(),
        comparisons=comparisons,message_comparison=message,target_rom_sha256=hashlib.sha256(target).hexdigest(),
        checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        helpers_sha256={name:hashlib.sha256((ROOT/'tools'/name).read_bytes()).hexdigest()
            for name in ('check_actor_boundary_boss.py','check_actor_group_path.py','check_boss_trigger.py')},
        emulator=dict(package='unicorn',version=version('unicorn')),
        limits=['Complete callbacks, generated tables and diagnostic data are freshly compiled and independently byte compared.',
            'All called game services and callbacks use clobbering integer/FPU ABI stubs, including randomness and trigonometry.',
            'Independent arithmetic, guarded state before calls and after return, event order, vector bytes, return byte and argument home slots are checked.',
            'Synthetic mutations test fresh resource/global reads and callback replacement; they do not establish actual callee effects.',
            'Invalid retirement kinds are tested only with counter updates disabled; valid retail kind/counter bounds and full gameplay remain unproved.'])
    output = ROOT/'build/actor-collision-followup-execution/report.json'
    output.write_text(json.dumps(report,indent=2)+'\n')
    print('Passed followup:',report['cases'],counts,output,flush=True)


if __name__=='__main__':
    main()
