"""Execute the complete startup projection with freshly matched real SDK callees."""
from pathlib import Path
import hashlib,itertools,json,math,struct,sys,shutil
from importlib.metadata import version
from unicorn import UC_HOOK_CODE,UC_HOOK_MEM_READ,UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL
from actor_path_model import heading as angle_heading, signed32 as signed
from compare_startup import SymbolLayoutSnapshot, compare_block
from compare_runtime import MATCHING_BLOCKS
from compare_data import compare_unit, comparison_directory
from compare_assembly import compare_unit as compare_assembly_unit
from owned_sections import source_sections, elf_sections_and_symbols
from manifest import load_manifest
from rom import ROOT, validate

r = ROOT
d = r / 'build/startup-projection-execution'
FP_INIT, FP_PROBE, FP_RESULT = 0x80000100, 0x80000200, 0x80204000

def f32(value):
    return struct.unpack('>f', struct.pack('>f', value))[0]

def float_bytes(value):
    return struct.pack('>f', value)

ENTRY,COMMANDS=0x80048ddc,0x80203010
WIDTH,ANGLE,INDEX,CURSOR,NORMALIZATION,LIGHT_X,LIGHT_Y=0x800c8bd8,0x80138268,0x8007d914,0x80138254,0x8013d950,0x8007d904,0x8007d908
ROTATION_DEGREES=0x80194d10
SUPPORT=('runtime_angle','object_recovery_angle_scale','object_recovery_direction_angle','object_recovery_angle_table','fixed_geometry_setup','runtime_sine','camera_perspective','camera_highlights','matrix_translate','matrix_rotation','matrix_convert','sine_float','cosine_float')
def bits(value):return int.from_bytes(struct.pack('>f',value),'big')
def fp(value):return f32(value)
def add(a,b):return fp(a+b)
def sub(a,b):return fp(a-b)
def mul(a,b):return fp(a*b)
def div(a,b):return fp(a/b)

def trig(angle,cosine,target):
    """Independent binary32 input/reduction and binary64 polynomial model."""
    origin=0x96980 if cosine else 0x96930
    values=struct.unpack('>8d',target[origin:origin+64])
    coefficients,reciprocal,high_pi,low_pi=values[:5],values[5],values[6],values[7]
    exponent=(bits(angle)>>22)&511
    assert exponent<0x136,('Finite trig fixture exceeds the verified model',angle)
    if not cosine and exponent<0xff:
        if exponent<0xe6:return angle
        reduced=float(angle);whole=0
    else:
        reduced=abs(float(angle)) if cosine else float(angle)
        periods=reduced*reciprocal+(0.5 if cosine else 0.0)
        whole=int(periods+(0.5 if periods>=0 else -0.5))
        periods=float(whole)-(0.5 if cosine else 0.0)
        reduced=(reduced-periods*high_pi)-periods*low_pi
    square=reduced*reduced
    polynomial=((coefficients[4]*square+coefficients[3])*square+coefficients[2])*square+coefficients[1]
    result=fp(reduced+(reduced*square)*polynomial)
    return -result if whole&1 else result

def packed_matrix(values):
    words=[int(mul(value,65536.0))&0xffffffff for value in values]
    integer=[];fraction=[]
    for a,b in zip(words[::2],words[1::2]):
        integer.append((a&0xffff0000)|(b>>16));fraction.append(((a<<16)&0xffff0000)|(b&65535))
    return b''.join(word(x) for x in integer+fraction)

def oracle(case,target,initial):
    width,angle,index,base=case
    buffer=bytearray(initial)
    heading=angle_heading(480,width)
    field=fp((float(heading)*360.0)*0.000244140625)
    multiplier=struct.unpack('>f',target[0x96040:0x96044])[0]
    radians=mul(fp(angle),multiplier)
    light_x=fp(float(trig(radians,False,target))*75.0)
    light_y=fp(float(trig(radians,True,target))*75.0)
    half=div(fp(float(field)*(3.1415926/180.0)),2.0)
    cotangent=div(trig(half,True,target),trig(half,False,target))
    perspective=[0.0]*16
    perspective[0]=div(cotangent,fp(1.3333333730697632));perspective[5]=cotangent
    perspective[10]=div(add(100.0,50000.0),sub(100.0,50000.0));perspective[11]=-1.0
    perspective[14]=div(mul(mul(2.0,100.0),50000.0),sub(100.0,50000.0))
    offset=index*64;buffer[offset:offset+64]=packed_matrix(perspective)
    view=[0.0]*16
    for i,value in zip((0,5,10,15),(-1.0,1.0,-1.0,1.0)):view[i]=value
    buffer[offset+128:offset+192]=packed_matrix(view)
    identity=[float(i//4==i%4) for i in range(16)]
    buffer[0x260:0x2a0]=packed_matrix(identity);buffer[0x2a0:0x2e0]=packed_matrix(identity)
    look=bytearray(buffer[0x1c0:0x1e0])
    look[:8]=bytes(8);look[8:11]=bytes((128,0,0));look[16:24]=bytes((0,128,0,0,0,128,0,0));look[24:27]=bytes((0,127,0))
    buffer[0x1c0:0x1e0]=look
    def highlight(x,y,z):
        length=fp(math.sqrt(add(add(mul(x,x),mul(y,y)),mul(z,z))))
        inverse=fp(1.0/float(length));x,y,z=mul(x,inverse),mul(y,inverse),mul(z,inverse)
        z=sub(z,1.0)
        length=fp(math.sqrt(add(add(mul(x,x),mul(y,y)),mul(z,z))))
        if length<=fp(0.1):return (64,64)
        inverse=fp(1.0/float(length));x,y=mul(x,inverse),mul(y,inverse)
        return int(add(128.0,mul(-x,64.0))),int(add(128.0,mul(y,64.0)))
    hilite=highlight(light_x,light_y,-70.0)+highlight(100.0,0.0,0.0)
    buffer[0x200:0x210]=b''.join(word(x) for x in hilite)
    commands=[(0x03840010,base+0x1c0),(0x03820010,base+0x1d0),(0xbc00000e,2),
              (0x01030040,(base+offset+0x80000000)&0xffffffff),(0x01010040,(base+offset+0x80000080)&0xffffffff),
              (0x01020040,(base+0x800002a0)&0xffffffff),(0x01000040,(base+0x80000260)&0xffffffff)]
    calls=[['perspective',[base+offset,NORMALIZATION,bits(field),bits(fp(1.3333333730697632)),bits(100.0),bits(50000.0),bits(1.0)]],
           ['highlight',[base+offset+128,base+0x1c0,base+0x200]+[bits(x) for x in (0.0,0.0,0.0,0.0,0.0,400.0,0.0,1.0,0.0,light_x,light_y,-70.0,100.0,0.0,0.0)]+[32,32]],
           ['translation',[base+0x2a0,0,0,0]],['rotation',[base+0x260,0,0,0]]]
    return dict(buffer=bytes(buffer),commands=b''.join(word(a)+word(b) for a,b in commands),
                angle=signed(angle+8),light_x=float_bytes(light_x),light_y=float_bytes(light_y),calls=calls)

def run(code,support,code_ranges,data_ranges,case,target):
    width,angle,index,base=case
    initial=bytes((i*31+7)&255 for i in range(0x2e0));expected=oracle(case,target,initial)
    saved_fp=[0x3f800101+i*257 for i in range(12)]
    init=b''.join(word(0x3c010000|(value>>16))+word(0x34210000|(value&65535))+
                  word(0x44810000|((i+20)<<11)) for i,value in enumerate(saved_fp))+word(0x03e00008)+word(0)
    probe=word(0x3c018020)+word(0x34214000)+b''.join(word(0xe4200000|(i<<16)|((i-20)*4)) for i in range(20,32))+word(0x03e00008)+word(0)
    uc,write,execute=machine([(ENTRY,code),(FP_INIT,init),(FP_PROBE,probe)],support)
    uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS,uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS)|(1<<29))
    uc.emu_start(FP_INIT,0,count=50);assert uc.reg_read(regs.UC_MIPS_REG_PC)==SENTINEL
    def read(address,size):return bytes(uc.mem_read(address&0x1fffffff,size))
    state=[(base,base+0x2e0),(COMMANDS,COMMANDS+56)];stack=(0x802ff000,0x80300010);canaries=[]
    for start,end in state+[stack,(ROTATION_DEGREES,ROTATION_DEGREES+4)]:
        for address,data in [(start-16,b'\xd7'*16),(end,b'\xe9'*16)]:write(address,data);canaries.append((address,data))
    write(base,initial);write(COMMANDS,b'\x9b'*56);write(FP_RESULT,b'\xa7'*48)
    globals_={WIDTH:width,ANGLE:angle,INDEX:index,CURSOR:COMMANDS,LIGHT_X:0x7fc12345,LIGHT_Y:0x80000000,ROTATION_DEGREES:0x7fc54321}
    for address,value in globals_.items():write(address,word(value))
    write(NORMALIZATION,b'\xa7\xa7')
    trace=[];entries={0x80060980:('perspective',7),0x8006114c:('highlight',20),0x80061258:('translation',4),0x800613fc:('rotation',4)}
    def observe(uc,address,size,user):
        name,count=entries[address];arguments=[uc.reg_read(reg) for reg in (regs.UC_MIPS_REG_A0,regs.UC_MIPS_REG_A1,regs.UC_MIPS_REG_A2,regs.UC_MIPS_REG_A3)]
        sp=uc.reg_read(regs.UC_MIPS_REG_SP)
        arguments += [int.from_bytes(read(sp+i*4,4),'big') for i in range(4,count)]
        event=[name,arguments[:count]]
        assert len(trace)<4 and event==expected['calls'][len(trace)],('Projection call oracle',case,event,expected['calls'])
        trace.append(event)
    for address in entries:uc.hook_add(UC_HOOK_CODE,observe,begin=address,end=address)
    def inside(address,size,ranges):
        address=(address&0x1fffffff)|0x80000000
        return any(start<=address and address+size<=end for start,end in ranges)
    globals_ranges=[(address,address+4) for address in globals_]+[(NORMALIZATION,NORMALIZATION+2)]
    writable=[(base+index*64,base+index*64+64),(base+index*64+128,base+index*64+192),
              (base+0x1c0,base+0x1cb),(base+0x1d0,base+0x1db),(base+0x200,base+0x210),
              (base+0x260,base+0x2e0),(COMMANDS,COMMANDS+56),stack,(NORMALIZATION,NORMALIZATION+2)]+[(address,address+4) for address in (ANGLE,CURSOR,LIGHT_X,LIGHT_Y,ROTATION_DEGREES)]
    def instruction(uc,address,size,user):
        assert not address&3 and inside(address,4,code_ranges+[(ENTRY,ENTRY+len(code)),(SENTINEL,SENTINEL+4)]),('Projection instruction bounds',hex(address))
    def load(uc,access,address,size,value,user):
        assert inside(address,size,state+[stack]+globals_ranges+data_ranges),('Projection read bounds',hex(address),size)
    def store(uc,access,address,size,value,user):
        assert inside(address,size,writable),('Projection write bounds',hex(address),size,hex(uc.reg_read(regs.UC_MIPS_REG_PC)),hex(value))
    uc.reg_write(regs.UC_MIPS_REG_GP,0xa578abcd);uc.reg_write(regs.UC_MIPS_REG_RA,SENTINEL);uc.reg_write(regs.UC_MIPS_REG_A0,base)
    handles=[uc.hook_add(UC_HOOK_CODE,instruction),uc.hook_add(UC_HOOK_MEM_READ,load),uc.hook_add(UC_HOOK_MEM_WRITE,store)]
    try:execute(ENTRY)
    finally:
        for handle in handles:uc.hook_del(handle)
    assert uc.reg_read(regs.UC_MIPS_REG_PC)==SENTINEL and uc.reg_read(regs.UC_MIPS_REG_GP)==0xa578abcd
    actual=read(base,0x2e0)
    differences=[(hex(i),a,b) for i,(a,b) in enumerate(zip(actual,expected['buffer'])) if a!=b]
    assert not differences,('Projection buffer oracle',case,differences[:12])
    assert read(COMMANDS,56)==expected['commands'],('Projection command oracle',case)
    assert trace==expected['calls']
    for address,value in [(WIDTH,width),(ANGLE,expected['angle']),(INDEX,index),(CURSOR,COMMANDS+56)]:assert read(address,4)==word(value),('Projection global oracle',hex(address),case)
    assert read(LIGHT_X,4)==expected['light_x'] and read(LIGHT_Y,4)==expected['light_y']
    assert read(NORMALIZATION,2)==b'\0\2'
    # IDO materializes the SDK function-local static initializer in its owned BSS.
    # Retail SWC1 at 800612F4 stores the freshly compared scalar from ROM 96920.
    assert read(ROTATION_DEGREES,4)==target[0x96920:0x96924]
    for address,data in canaries:assert read(address,len(data))==data,('Projection canary',hex(address))
    uc.reg_write(regs.UC_MIPS_REG_RA,SENTINEL);uc.emu_start(FP_PROBE,0,count=50)
    assert uc.reg_read(regs.UC_MIPS_REG_PC)==SENTINEL and read(FP_RESULT,48)==b''.join(word(value) for value in saved_fp)
    return dict(buffer=actual.hex(),commands=expected['commands'].hex(),calls=trace,angle=expected['angle'],light_x=expected['light_x'].hex(),light_y=expected['light_y'].hex())

def build_support(layout,target):
    support=[];code_ranges=[];data_ranges=[];reports={};family='startup-projection-execution'
    bss=source_sections('src/sdk/matrix_rotation.c')
    assert any(x['input_section']=='.bss' and x['vram']==ROTATION_DEGREES and x['size']==4 and x['static_symbols']=={'degreesToRadians':0} for x in bss)
    for name in SUPPORT:
        name,source,start,end=next(row for row in MATCHING_BLOCKS if row[0]==name)
        report=compare_block(name,source,start,start-0x80000000+0xc00,end-0x80000000+0xc00,target,family=family,layout=layout);assert report['matches'];reports[name]=report
        directory=r/'build'/family/name;support.append((start,(directory/(name+'.bin')).read_bytes()));code_ranges.append((start,end))
        sections,_=elf_sections_and_symbols(directory/(name+'.elf'))
        for record in source_sections(source):
            data=sections[record['section']]['bytes']
            if data is not None:
                support.append((record['vram'],data));data_ranges.append((record['vram'],record['vram']+len(data)))
    for source in ['src/game/object_math_tables.c','src/game/renderer_projection/constants.c','src/game/renderer_projection/state.c']:
        if not (r/source).exists():
            if source=='src/game/object_math_tables.c':
                records=json.loads((r/'config/owned_sections.json').read_text());source=next(x['source'] for x in records if x['vram']==0x8007c338)
            else:raise AssertionError(source)
        records=source_sections(source);report=compare_unit(source,records,target,layout);assert report['matches'];reports[source]=report
        sections,_=elf_sections_and_symbols(comparison_directory(source)/'compiled.elf')
        for record in records:
            data=sections[record['section']]['bytes']
            if data is not None:
                support.append((record['vram'],data));data_ranges.append((record['vram'],record['vram']+len(data)))
    source='src/sdk/square_root.s';records=[x for x in load_manifest() if x['source']==source]
    report=compare_assembly_unit(source,records,target,shutil.which('mips-linux-gnu-as'));assert report['matches'];reports['square_root']=report
    data=(r/'build/assembly-comparison/square_root/compiled.bin').read_bytes();assert records[0]['size']==8
    support.append((records[0]['vram'],data[:8]));code_ranges.append((records[0]['vram'],records[0]['vram']+8))
    return support,code_ranges,data_ranges,reports

def run_controls(code, support, code_ranges, data_ranges, target, path, layout, baseline):
    """Reject independent source faults and actual guest invalid accesses."""
    import compiler
    out = d / 'controls'
    out.mkdir(parents=True, exist_ok=True)
    base = path.read_text().replace('../../../include/', str(r/'include')+'/')
    case = (240, 512, 1, 0x80222000)
    mutations = [
        ('angle_step', 'D_80138268 += 8;', 'D_80138268 += 7;'),
        ('light_scaling', '* D_DBL_80095448', '/ D_DBL_80095448'),
        ('near_plane', 'fieldOfView, 1.3333333730697632f, 100.0f,',
                       'fieldOfView, 1.3333333730697632f, 101.0f,'),
        ('matrix_stride', 'D_8007D914 << 6', 'D_8007D914 << 5'),
        ('look_at_address', 'base + 0x1C0', 'base + 0x1C4'),
        ('look_at_packet', '0x03840010', '0x03840011'),
        ('translation', 'base + 0x2A0), eyeX, eyeY, eyeZ',
                        'base + 0x2A0), upY, eyeY, eyeZ'),
    ]
    results = []
    for name, before, after in mutations:
        assert before in base, (name, 'Mutation must apply')
        reference = run(target[0x499dc:0x49d3c], support, code_ranges, data_ranges, case, target)
        assert run(code, support, code_ranges, data_ranges, case, target) == reference
        source = out / (name+'.c')
        source.write_text(base.replace(before, after))
        relative = source.relative_to(r).as_posix()
        compiler.SOURCE_PROFILES[relative] = 'game-r4300-mul'
        family = 'startup-projection-controls'
        comparison = compare_block(name, relative, ENTRY, 0x499dc, 0x49d3c,
                                   target, family=family, layout=layout)
        mutant = (r/'build'/family/name/(name+'.bin')).read_bytes()
        try:
            run(mutant, support, code_ranges, data_ranges, case, target)
        except AssertionError as error:
            reason = str(error)
            assert ' bounds' not in reason, (name, 'Unexpected failure mechanism', reason)
            results.append(dict(name=name, rejected=True, positive_pair_passed=True,
                                reason=reason, source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
                                before=before, after=after, comparison=comparison))
        else:
            raise AssertionError(('Semantic mutant accepted', name))
    guards = []
    for name, instruction_word, expected in [
        ('instruction', 0x08000010, 'Projection instruction bounds'),
        ('read', 0x8c0202f0, 'Projection read bounds'),
        ('write', 0xac0202f0, 'Projection write bounds'),
    ]:
        reference = run(target[0x499dc:0x49d3c], support, code_ranges, data_ranges, case, target)
        assert run(code, support, code_ranges, data_ranges, case, target) == reference
        modified = word(instruction_word)+word(0)+code[8:]
        try:
            run(modified, support, code_ranges, data_ranges, case, target)
        except AssertionError as error:
            reason = str(error)
            assert expected in reason, (name, reason)
            guards.append(dict(name=name, rejected=True, positive_pair_passed=True,
                               reason=reason, injected_words=[hex(instruction_word), '0x0']))
        else:
            raise AssertionError(('Guard probe accepted', name))
    layout.verify()
    receipt = dict(mutations=results, guard_controls=guards, baseline_comparison=baseline,
                   positive_control_pairs=len(results)+len(guards),
                   source_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                   code_sha256=hashlib.sha256(code).hexdigest(),
                   checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    (d/'controls.json').write_text(json.dumps(receipt, indent=2)+'\n')
    print('Projection source faults and actual guest access probes rejected:', len(results), len(guards), flush=True)

def main():
    target=(r/'baseroms/us/baserom.z64').read_bytes();validate(target);layout=SymbolLayoutSnapshot()
    support,code_ranges,data_ranges,reports=build_support(layout,target)
    d.mkdir(parents=True, exist_ok=True)
    path=r/'src/game/renderer_projection/setup.c'
    candidate=compare_block('projection',str(path.relative_to(r)),ENTRY,0x499dc,0x49d3c,target,family='startup-projection-execution',layout=layout)
    assert candidate['matches'] and candidate['actual_size']==candidate['expected_size']==864
    code=(r/'build/startup-projection-execution/projection/projection.bin').read_bytes()
    if '--controls' in sys.argv:
        run_controls(code,support,code_ranges,data_ranges,target,path,layout,candidate)
        return
    cases=list(itertools.product((-1024,-1,0,1,160,240,320,480,640,1024,4096),(-4096,-1,0,1,512,1024,2048,4096,8192),(0,1),(0x80211000,0x80222000)))
    if '--quick' in sys.argv:cases=[(320,0,0,0x80211000),(240,-1,1,0x80222000)]
    checksum=hashlib.sha256()
    for count,case in enumerate(cases,1):
        expected=run(target[0x499dc:0x49d3c],support,code_ranges,data_ranges,case,target)
        actual=run(code,support,code_ranges,data_ranges,case,target);assert actual==expected
        checksum.update(json.dumps([case,actual],sort_keys=True).encode())
        if count%100==0:print('Projection paired cases:',count,flush=True)
    layout.verify()
    receipt=dict(behavior_matches=True,instruction_matches=candidate['matches'],cases=len(cases),principal_executions=2*len(cases),
                 candidate_comparison=candidate,support_comparisons=reports,support_code_bytes=sum(end-start for start,end in code_ranges),initialized_data_bytes=sum(end-start for start,end in data_ranges),
                 source_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),code_sha256=hashlib.sha256(code).hexdigest(),trace_sha256=checksum.hexdigest(),
                 checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                 machine_helper_sha256=hashlib.sha256((r/'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
                 arithmetic_model_sha256=hashlib.sha256((r/'tools/actor_path_model.py').read_bytes()).hexdigest(),emulator_version=version('unicorn'),
                 limits=['Thirteen complete matching C support units, the 8-byte SDK square-root assembly function, and all supplied initialized sections are freshly compared before execution.',
                         'No ABI stubs execute. Complete matrix/look-at/hilite/unused-gap/command/global state and O32 SDK call arguments are checked against a separate rounded-float, fixed-pack and command oracle.',
                         'Guest code/read/write bounds, canaries, GP/SP, integer saved registers and F20-F31 are checked.',
                         'Finite widths/angles and matrix indices0/1 only. Nonfinite floating-point exceptions, arbitrary aliasing with globals, RSP/RDP results and gameplay are not verified.',
                         'This complete function matches 864 instruction bytes; whole-ROM acceptance remains a separate check.'])
    output=d/('execution-quick.json' if '--quick' in sys.argv else 'execution.json');output.write_text(json.dumps(receipt,indent=2)+'\n')
    print('Startup projection execution passed:',len(cases),'cases,',receipt['support_code_bytes'],'support instruction bytes,',receipt['initialized_data_bytes'],'initialized bytes',flush=True)

if __name__=='__main__':main()
