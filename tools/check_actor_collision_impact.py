"""Execute complete impact code against retail and independent state oracles."""

import hashlib
import itertools
import json
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE
from unicorn import mips_const as regs
from check_actor_boundary_boss import environment, signed, divide
from check_actor_collision_followup import State
from check_actor_group_path import word
from check_boss_trigger import pattern, fingerprint
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


ENTRY = 0x80016C1C
FIRST, SECOND, EXTRA = 0x80201010, 0x80202010, 0x80203010
RESOURCE, OTHER_RESOURCE, EXTRA_RESOURCE, ALT_RESOURCE = 0x80204010, 0x80205010, 0x80206010, 0x80207010
FIRST_POSITION, SECOND_POSITION, OWNER = 0x80208010, 0x80209010, 0x8020A010
SESSION, PALETTE, CLOCK, DURATION, DELAY = 0x800AD138, 0x80073950, 0x8009EFA0, 0x800AC988, 0x800B6FD4
WIDTH, MODE, BONUS_RESOURCE = 0x800B8F60, 0x800BA74C, 0x800B1F58
STACK_POSITION, CALLBACK, CHILD_CALLBACK, RECOVERY_CALLBACK = 0x802FFFE8, 0x80000180, 0x800001C0, 0x8002937C
COLOR, DAMAGE, SCORE, CREATE = 0x80039C1C, 0x80015130, 0x80037144, 0x800283D4
RESET, EFFECT, SOUND, RETIRE, GROUP = 0x80009F90, 0x80015184, 0x8003614C, 0x8001B4F8, 0x8000EAF8
ANIMATE, COSINE, SINE, OBJECT, FRAME_COUNT = 0x80027AB8, 0x8003CC88, 0x8003CC58, 0x80039514, 0x80039CD0
ARG_COUNTS = {COLOR:4, DAMAGE:2, SCORE:2, CREATE:3, RESET:2, EFFECT:2, SOUND:4,
    RETIRE:2, GROUP:2, ANIMATE:3, COSINE:1, SINE:1, OBJECT:2, FRAME_COUNT:1, CALLBACK:1, CHILD_CALLBACK:2}
BOUNDARIES = (-2147483648, -32769, -32768, -1, 0, 1, 32767, 2147483647)


def run(code, palette, case):
    uc, write, execute, read, finish_call = environment(code, [])
    ranges = ((FIRST,124),(SECOND,124),(EXTRA,124),(RESOURCE,88),(OTHER_RESOURCE,92),
        (EXTRA_RESOURCE,88),(ALT_RESOURCE,92),(FIRST_POSITION,12),(SECOND_POSITION,12),(OWNER,32),
        (SESSION,328),(PALETTE,108),(CLOCK,4),(DURATION,4),(DELAY,4),(WIDTH,4),(MODE,4))
    state = State({address-16:pattern(size+32,case['id']+index*19) for index,(address,size) in enumerate(ranges)})
    for actor, resource in ((FIRST,RESOURCE),(SECOND,OTHER_RESOURCE),(EXTRA,EXTRA_RESOURCE)):
        state.put(actor+36,resource)
        state.put(actor+68,CALLBACK)
        state.put(actor+60,OWNER)
        state.put(actor+20,case['flags'] if actor==FIRST else case['second_flags'])
        state.put(actor+8,case['first_angle'] if actor==FIRST else case['second_angle'],2)
        state.put(actor+12,-31,2)
        state.put(actor+16,case['health'] if actor==FIRST else case['second_health'],2)
        state.put(actor+31,case['animation'],1)
        state.put(actor+24,case['frame'])
        state.put(actor+72,case['clock'])
        state.put(actor+96,case['height'] if actor==FIRST else 19)
        state.put(actor+100,23)
        state.put(actor+104,case['height'])
        state.put(actor+108,case['velocity_x'])
        state.put(actor+112,case['velocity_y'])
        state.put(resource+2,case['kind'] if actor==FIRST else case['second_kind'],1)
        state.put(resource+4,-12345,2)
        state.put(resource+8,case['speed'])
    state.put(EXTRA_RESOURCE+84,CHILD_CALLBACK)
    state.put(OTHER_RESOURCE+88,case['resource_duration'])
    state.put(ALT_RESOURCE+2,2,1)
    state.put(ALT_RESOURCE+8,-1234567)
    state.put(ALT_RESOURCE+88,2147483647)
    state.put(SESSION+76,case['session_enabled'])
    state.put(SESSION+88,case['bonus_count'])
    for address,value in ((CLOCK,case['clock']),(DURATION,case['duration']),
                          (DELAY,case['delay']),(WIDTH,case['width']),(MODE,case['mode'])):
        state.put(address,value)
    for index,value in enumerate(palette):
        state.put(PALETTE+index,value,1)
    vectors = ((-11,4),(13,-8),(2147483647,1),(-2147483648,-1),(-2147483648,2147483647))
    for axis in range(3):
        first,second = vectors[(case['id']+axis)%len(vectors)]
        state.put(FIRST_POSITION+axis*4,first)
        state.put(SECOND_POSITION+axis*4,second)
    initial = State(state.images)
    events, vector_events, call_counts = [],{},{}

    def mutate(image,address,ordinal):
        mutation = case['mutation']
        if mutation==1 and address==DAMAGE:
            image.put(FIRST+16,0,2)
            image.put(SESSION+76,1)
            image.put(SESSION+88,2)
        if mutation==2 and address==SCORE:
            image.put(MODE,0)
            image.put(SECOND+60,OWNER+4)
        if mutation==3 and address==COSINE:
            image.put(SECOND+36,ALT_RESOURCE)
            image.put(SECOND+8,-32768,2)
        if mutation==4 and address==SINE:
            image.put(CLOCK,-2147483648)
            image.put(DURATION,2147483647)
            image.put(SECOND+12,17,2)
            image.put(image.get(SECOND+36,unsigned=True)+88,-2147483648)
        if mutation==5 and address==CALLBACK:
            image.put(FIRST+20,0x4400)
            image.put(FIRST+14,-17,2)
        if mutation==6 and address==COLOR:
            image.put(image.get(FIRST+36,unsigned=True)+2,26,1)
        if mutation==7 and address==CHILD_CALLBACK:
            image.put(EXTRA+72,-2147483648)
            image.put(DELAY,2147483647)
        if mutation==8 and address==RESET:
            image.put(SECOND+16,1,2)
            image.put(OTHER_RESOURCE+2,2,1)
        if mutation==9 and address==EFFECT:
            image.put(MODE,-1)
            image.put(FIRST+31,3,1)
        if mutation==10 and address in (RETIRE,GROUP):
            image.put(SECOND+16,0,2)

    def event(address,args,vector=None):
        ordinal = call_counts.get(address,0)+1
        call_counts[address] = ordinal
        events.append([address,[value & 0xFFFFFFFF for value in args],fingerprint(state.images)])
        if vector is not None:
            vector_events[len(events)-1] = vector
        mutate(state,address,ordinal)

    counter = state.get(SECOND+60,unsigned=True)
    result = 0
    if state.get(SECOND+20,unsigned=True) & 0x100:
        result = 32
    else:
        position = [divide(signed(state.get(FIRST_POSITION+axis*4)+state.get(SECOND_POSITION+axis*4)),2) for axis in range(2)]+[0]
        kind = state.kind(FIRST)
        handled = False
        permitted = True
        if 5 <= kind <= 8:
            rgb = [state.get(PALETTE+kind*3+axis,1,True) for axis in range(3)]
            event(COLOR,[state.get(FIRST+12,2)]+rgb)
            event(DAMAGE,[FIRST,SECOND])
            if state.get(FIRST+16,2) <= 0:
                state.put(FIRST+16,3072,2)
                if state.get(SESSION+76) != 0:
                    state.put(SESSION+88,state.get(SESSION+88)-1)
                    if state.get(SESSION+88) > 0:
                        event(SCORE,[1000,counter])
                        event(CREATE,[9,BONUS_RESOURCE,STACK_POSITION],position)
                        if case['create']:
                            event(state.get(EXTRA_RESOURCE+84,unsigned=True),[EXTRA,1])
                            state.put(EXTRA+72,state.get(EXTRA+72)-divide(state.get(DELAY),5))
            if state.kind(SECOND)==3:
                event(RESET,[SECOND,0])
                result = 32
            event(EFFECT,[143,STACK_POSITION],position)
            if state.get(MODE)==-1:
                event(SCORE,[state.get(state.get(FIRST+36,unsigned=True)+4,2),counter])
            if state.get(FIRST+31,1,True)!=3:
                state.put(FIRST+84,state.get(SECOND+108))
                state.put(FIRST+88,state.get(SECOND+112))
                state.put(FIRST+108,state.get(FIRST+108)+divide(state.get(FIRST+84),30))
                state.put(FIRST+112,state.get(FIRST+112)+divide(state.get(FIRST+88),30))
            state.put(SECOND+108,divide(state.get(SECOND+108),2))
            state.put(SECOND+112,divide(state.get(SECOND+112),2))
            state.put(FIRST+72,state.get(CLOCK))
            state.put(FIRST+20,state.get(FIRST+20,unsigned=True)|0x10)
            first_angle,second_angle = state.get(FIRST+8,2),state.get(SECOND+8,2)
            state.put(SECOND+8,(second_angle+divide(first_angle-second_angle,2)+2048)&4095,2)
            state.put(SECOND+44,divide(state.get(state.get(SECOND+36,unsigned=True)+8),2))
            event(COSINE,[state.get(SECOND+8,2)])
            speed = divide(state.get(state.get(SECOND+36,unsigned=True)+8),2)
            state.put(SECOND+108,divide(signed(case['cosine']*speed),4096))
            event(SINE,[state.get(SECOND+8,2)])
            speed = divide(state.get(state.get(SECOND+36,unsigned=True)+8),2)
            state.put(SECOND+112,divide(signed(case['sine']*speed),4096))
            event(OBJECT,[state.get(SECOND+12,2),state.get(SECOND+8,2)])
            state.put(SECOND+72,state.get(CLOCK))
            duration = signed(state.get(state.get(SECOND+36,unsigned=True)+88)-state.get(DURATION))
            state.put(SECOND+72,state.get(SECOND+72)-duration)
            state.put(SECOND+20,state.get(SECOND+20,unsigned=True)|0x100)
            handled = True
        elif 17 <= kind <= 20 and state.get(FIRST+31,1,True)==8:
            event(SOUND,[62,0,1,0])
            event(EFFECT,[19,SECOND_POSITION],[state.get(SECOND_POSITION+axis*4) for axis in range(3)])
            handled = True
        elif kind in (15,16):
            permitted = not 1280 <= state.get(FIRST+24) <= 1792
        elif kind in (11,12):
            permitted = not 2048 <= state.get(FIRST+24) <= 2560
        elif kind in (33,34):
            permitted = state.kind(SECOND) in (1,2,3)
        elif kind==1:
            height = state.get(FIRST+104)
            half_width = divide(state.get(WIDTH),2)
            absolute_height = signed(-height) if height<0 else height
            absolute_width = signed(-half_width) if half_width<0 else half_width
            permitted = absolute_height <= absolute_width or state.kind(SECOND) in (1,2)
        elif kind==35:
            permitted = state.get(FIRST+31,1,True)==6
        if not handled and permitted:
            event(DAMAGE,[FIRST,SECOND])
            if state.get(MODE)!=-1:
                event(GROUP,[FIRST,counter])
            if state.get(FIRST+16,2)<=0:
                if state.get(MODE)==-1:
                    event(SCORE,[state.get(state.get(FIRST+36,unsigned=True)+4,2),counter])
                event(RETIRE,[FIRST,SECOND])
            else:
                kind = state.kind(FIRST)
                assert 0 <= kind < 36, ('Palette bounds',case,kind)
                rgb = [state.get(PALETTE+kind*3+axis,1,True) for axis in range(3)]
                event(COLOR,[state.get(FIRST+12,2)]+rgb)
                event(EFFECT,[19,STACK_POSITION],position)
                kind = state.kind(FIRST)
                if kind==2 or 26 <= kind < 29:
                    event(ANIMATE,[FIRST,8,1])
                    state.put(FIRST+44,0)
                    event(COSINE,[state.get(FIRST+8,2)])
                    state.put(FIRST+108,0)
                    event(SINE,[state.get(FIRST+8,2)])
                    state.put(FIRST+112,0)
                    event(OBJECT,[state.get(FIRST+12,2),state.get(FIRST+8,2)])
                    flags = state.get(FIRST+20,unsigned=True)
                    if flags & 0x40:
                        state.put(FIRST+20,flags & ~0x40)
                        event(state.get(FIRST+68,unsigned=True),[FIRST])
                    state.put(FIRST+20,state.get(FIRST+20,unsigned=True)|0x40)
                    state.put(FIRST+68,RECOVERY_CALLBACK)
                    state.put(FIRST+14,999,2)
                else:
                    event(FRAME_COUNT,[state.get(FIRST+12,2)])
                    state.put(FIRST+24,divide(case['frame_count'],3)<<9)
            if state.get(SECOND+16,2)<=0:
                result = 32

    for start,data in initial.images.items():
        write(start,bytes(data))
    home = bytes(pattern(32,case['id']+7))
    write(0x80300000,home)
    observed,actual_counts = [],{}
    def observe(uc,address,size,user):
        if address not in ARG_COUNTS:
            return
        actual = State({start:read(start,len(data)) for start,data in initial.images.items()})
        arguments = [uc.reg_read(register) for register in (regs.UC_MIPS_REG_A0,regs.UC_MIPS_REG_A1,regs.UC_MIPS_REG_A2,regs.UC_MIPS_REG_A3)[:ARG_COUNTS[address]]]
        record = [address,arguments,fingerprint(actual.images)]
        assert len(observed)<len(events) and record==events[len(observed)], (case,record,events[len(observed):len(observed)+1])
        if address in (CREATE,EFFECT):
            pointer = arguments[2] if address==CREATE else arguments[1]
            vector = [int.from_bytes(read(pointer+axis*4,4),'big',signed=True) for axis in range(3)]
            assert vector==vector_events[len(observed)], (case,vector,vector_events)
        observed.append(record)
        ordinal = actual_counts.get(address,0)+1
        actual_counts[address] = ordinal
        mutate(actual,address,ordinal)
        for start,data in actual.images.items():
            write(start,bytes(data))
        returned = {CREATE:EXTRA if case['create'] else 0,COSINE:case['cosine'],SINE:case['sine'],FRAME_COUNT:case['frame_count']}.get(address,0)
        finish_call(returned & 0xFFFFFFFF)
    uc.hook_add(UC_HOOK_CODE,observe)
    for register,value in zip((regs.UC_MIPS_REG_A0,regs.UC_MIPS_REG_A1,regs.UC_MIPS_REG_A2,regs.UC_MIPS_REG_A3),
                              (FIRST,SECOND,FIRST_POSITION,SECOND_POSITION)):
        uc.reg_write(register,value)
    execute(ENTRY)
    assert observed==events, (case,'Missing events')
    assert uc.reg_read(regs.UC_MIPS_REG_V0)==result, (case,'Return byte')
    for start,data in state.images.items():
        assert read(start,len(data))==bytes(data), (case,'Final guarded state',hex(start))
    assert read(0x80300000,32)==home[:12]+word(SECOND_POSITION)+home[16:], (case,'Argument home slots')
    return dict(events=observed,result=result,final_sha256=fingerprint(state.images))


def cases():
    for kind,mode,flags,health,second_health in itertools.product(range(36),(-1,0),(0,0x40,0x100,0x4400),(-1,0,1),(-1,0,1)):
        yield dict(group='dispatch',kind=kind,mode=mode,flags=flags,health=health,second_health=second_health,
                   second_flags=flags & 0x100)
    for kind,second_kind,frame,animation in itertools.product((1,11,12,15,16,17,18,19,20,33,34,35),(0,1,2,3,35),
            (1279,1280,1792,1793,2047,2048,2560,2561),(3,6,8)):
        yield dict(group='gates',kind=kind,second_kind=second_kind,frame=frame,animation=animation)
    for kind,health,enabled,count,create in itertools.product(range(5,9),(-1,0,1),(0,1),(-2147483648,0,1,2,2147483647),(False,True)):
        yield dict(group='bonus',kind=kind,health=health,session_enabled=enabled,bonus_count=count,create=create,second_kind=3)
    for speed,clock,first_angle,second_angle in itertools.product(BOUNDARIES,BOUNDARIES,(-32768,0,32767),(-32768,0,32767)):
        yield dict(group='arithmetic',kind=5,speed=speed,clock=clock,first_angle=first_angle,second_angle=second_angle,
            resource_duration=clock,duration=speed,delay=speed,velocity_x=clock,velocity_y=speed,
            cosine=clock,sine=speed,health=0,session_enabled=1,bonus_count=2)
    for kind,mutation in itertools.product(range(36),range(1,11)):
        yield dict(group='mutation',kind=kind,mutation=mutation,flags=0x40,second_kind=3,health=0 if 5<=kind<=8 else 1,
                   session_enabled=1,bonus_count=2,animation=6)
    for kind,mode in itertools.product((36,127,255),(-1,0)):
        yield dict(group='outside_switch',kind=kind,mode=mode,health=0)


def main():
    target = (ROOT/'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    name,source,start,end = next(record for record in MATCHING_BLOCKS if record[0]=='actor_collision_impact')
    block = compare_block(name,source,start,start-0x80000000+0xC00,end-0x80000000+0xC00,target,
                          family='actor-collision-impact-execution',layout=layout)
    assert block['matches'], block
    directory = ROOT/'build/actor-collision-impact-execution'/name
    compiled = [(start,(directory/(name+'.bin')).read_bytes())]
    retail = [(start,target[0x1781C:0x17F64])]
    sections,_ = elf_sections_and_symbols(directory/(name+'.elf'))
    for record in source_sections(source):
        compiled.append((record['vram'],sections[record['section']]['bytes']))
        retail.append((record['vram'],target[record['rom']:record['rom']+record['size']]))
    palette_source = 'src/game/collisions/palette.c'
    palette_comparison = compare_unit(palette_source,source_sections(palette_source),target,layout)
    assert palette_comparison['matches'], palette_comparison
    palette = target[0x74550:0x745BC]
    counts,digest = {},hashlib.sha256()
    for index,parameters in enumerate(cases()):
        case = dict(id=index,kind=0,second_kind=(1,2,3,35)[index%4],mode=-1,flags=0,second_flags=0,health=1,second_health=1,
            animation=0,frame=0,first_angle=-17,second_angle=19,height=(0,1001,-1001,-2147483648)[index%4],
            width=(2000,-2000,2147483647,-2147483648)[index%4],clock=999999,duration=1000,resource_duration=2000,
            delay=-12345,speed=1000,velocity_x=-2147483648,velocity_y=2147483647,
            cosine=(4096,-4096,2147483647,-2147483648)[index%4],sine=(-4096,4096,1,0)[index%4],
            frame_count=BOUNDARIES[index%len(BOUNDARIES)],session_enabled=0,bonus_count=0,create=True,mutation=0)
        case.update(parameters)
        expected = run(retail,palette,case)
        actual = run(compiled,palette,case)
        assert actual==expected, case
        counts[case['group']] = counts.get(case['group'],0)+1
        digest.update(json.dumps([case,actual],sort_keys=True).encode())
        if (index+1)%500==0:
            print('Impact execution cases:',index+1,flush=True)
    report = dict(matches=True,cases=sum(counts.values()),counts=counts,trace_sha256=digest.hexdigest(),
        comparison=block,palette_comparison=palette_comparison,target_rom_sha256=hashlib.sha256(target).hexdigest(),
        checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        helper_sha256={name:hashlib.sha256((ROOT/'tools'/name).read_bytes()).hexdigest() for name in
            ('check_actor_boundary_boss.py','check_actor_collision_followup.py','check_actor_group_path.py','check_boss_trigger.py')},
        emulator=dict(package='unicorn',version=version('unicorn')),
        limits=['Complete text, generated switch and RGB palette are freshly compiled and independently byte compared.',
            'Called game services and callbacks use clobbering integer/FPU ABI stubs, including trigonometry and allocation.',
            'Independent wrapped arithmetic, guarded state before calls and on return, call order, vectors, return byte and argument home slots are checked.',
            'Mutations check fresh resource/global reads and callback replacement; actual callee effects and gameplay remain unproved.',
            'Resources are guarded through the observed 88/92-byte layouts. Invalid palette indices and complete caller bounds are not established.'])
    output = ROOT/'build/actor-collision-impact-execution/report.json'
    output.write_text(json.dumps(report,indent=2)+'\n')
    print('Passed impact:',report['cases'],counts,output,flush=True)


if __name__=='__main__':
    main()
