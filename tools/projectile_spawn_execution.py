"""Bounded projectile execution with real matching support and a separate oracle."""
from pathlib import Path
import sys,json,hashlib,math,struct,random,io
from elftools.elf.elffile import ELFFile
from unicorn import UC_HOOK_CODE,UC_HOOK_MEM_READ,UC_HOOK_MEM_WRITE,UcError
from unicorn import mips_const as reg
R=Path(__file__).resolve().parent.parent
D=R/'build/projectile-spawn-check'
sys.path.insert(0,str(R/'tools'))
from compare_startup import compare_block,SymbolLayoutSnapshot
from compare_runtime import MATCHING_BLOCKS
from compare_data import compare_unit
from owned_sections import source_sections,elf_sections_and_symbols
from rom import validate
from check_actor_group_path import word,SENTINEL
from resource_literal_execution import literal_machine,verify_fpu,FP_INIT,FP_STUB,FP_RETURN,FP_SEED,FP_RESULT,CALLER_SAVED
ENTRY,ALLOC=0x80038D8C,0x800283D4
INPUT,OWNER,PARENT=0x80201010,0x80202010,0x80204010
ACTORS=[0x80205010+i*0x100 for i in range(3)]
TRANSFORMS=[0x80206010+i*0x100 for i in range(3)]
OBJECTS,RESOURCES,STACK=0x800BF918,0x800AC998,0x80300000
SEED,DELTA,JITTER=0x8008F120,0x8009EF94,0x800AC98C
SAVED=[getattr(reg,'UC_MIPS_REG_'+n) for n in ['S'+str(i) for i in range(8)]+['FP','SP','GP']]
def s32(n):return ((n+0x80000000)&0xffffffff)-0x80000000
def trunc(n,d):return abs(n)//abs(d)*(-1 if (n<0)!=(d<0) else 1)
def f32(n):return struct.unpack('>f',struct.pack('>f',n))[0]
def sine(angle):
 phase=angle&4095;half=phase&2047;idx=min(half,2047-half)
 magnitude=math.floor(32767*math.sin(idx*math.pi/2046))
 return trunc(-magnitude if phase&2048 else magnitude,8)
def next_seed(seed):
 value=((seed<<2)+2)&0xffffffff
 return ((value*((value+1)&0xffffffff))&0xffffffff)>>2
def pattern(size,tag=0):return bytes((i*37+19+tag)&255 for i in range(size))
def setword(blob,offset,value):blob[offset:offset+4]=word(value)
def getword(blob,offset):return s32(int.from_bytes(blob[offset:offset+4],'big'))
def fixtures(case):
 kind,angle,mask,seed,speed,delta,jitter,px,py,stack_change=case
 angle=s32(angle)
 count=1 if kind in (1,2,3) else 3
 resources=bytearray(pattern(11*92))
 for i in range(11):setword(resources,i*92+8,s32(speed+i*31))
 parent=bytearray(pattern(124,2));setword(parent,0x6c,px);setword(parent,0x70,py)
 owner=bytearray(pattern(3508,3));setword(owner,8,PARENT)
 start=[12345,-6789,9012-350]
 actor_images=[];objects=bytearray(pattern(18*120,4));transforms=[]
 for i,index in enumerate((0,1,17)):
  actor=bytearray(pattern(124,10+i));actor[12:14]=struct.pack('>h',index)
  setword(actor,0x24,RESOURCES+((kind+5+i)%11)*92)
  actor_images.append(actor);setword(objects,index*120+0x18,TRANSFORMS[i])
  transforms.append(bytearray(pattern(28,20+i)))
 expected=[bytearray(x) for x in actor_images];object_end=bytearray(objects);transform_end=[bytearray(x) for x in transforms]
 calls=[];alloc_calls=[];last=0
 for i in range(count):
  alloc_calls.append(list(start));calls.append([ALLOC,[4,RESOURCES+kind*92,list(start)]])
  last=0 if mask&(1<<i) else ACTORS[i]
  if last:
   a=expected[i]
   for axis,v in enumerate(start):setword(a,0x60+4*axis,v)
   flags=int.from_bytes(a[0x14:0x18],'big')|0x1000
   setword(a,0x14,flags)
   if kind in (1,2):
    calls.append([0x80039C50,[(0,1,17)[i],4]])
    if kind==1:calls.append([0x80039BE4,[(0,1,17)[i],3]])
    movement=getword(resources,((kind+5+i)%11)*92+8)
    setword(a,0x54,movement);setword(a,0,0x80005560)
    if kind==1:setword(a,0x68,-2500)
   elif kind==3:
    movement=0;setword(a,0x54,0)
    calls.append([0x80039C50,[(0,1,17)[i],4]])
   else:
    if i:setword(a,0x14,flags|0x100)
    movement=trunc(s32(getword(resources,((kind+5+i)%11)*92+8)*(7-i)),7)
    setword(a,0x54,movement)
   a[8:10]=struct.pack('>H',angle&65535);setword(a,0x2c,movement)
   calls.append([0x8003CC88,[angle&0xffffffff]])
   vx=trunc(s32(sine(angle+1024)*movement),4096);setword(a,0x6c,vx)
   calls.append([0x8003CC58,[angle&0xffffffff]])
   vy=trunc(s32(sine(angle)*movement),4096);setword(a,0x70,vy)
   calls.append([0x80039514,[(0,1,17)[i],angle&0xffffffff]])
   for axis in range(2):
    calls.append([0x8004CDE8,[]]);seed=next_seed(seed)
    setword(a,0x60+axis*4,s32(getword(a,0x60+axis*4)+((seed>>3)%2)*jitter))
   setword(a,0x60,s32(getword(a,0x60)+s32(delta*px)))
   setword(a,0x64,s32(getword(a,0x64)+s32(delta*py)))
   if kind==1:
    setword(a,0x6c,s32(vx+px));setword(a,0x70,s32(vy+py))
   if angle>2048:setword(a,0x64,s32(getword(a,0x64)-100))
   if kind==0:
    setword(a,0x2c,1)
    calls.append([0x8003CC88,[angle&0xffffffff]]);setword(a,0x6c,trunc(sine(angle+1024),4096))
    calls.append([0x8003CC58,[angle&0xffffffff]]);setword(a,0x70,trunc(sine(angle),4096))
    calls.append([0x80039514,[(0,1,17)[i],angle&0xffffffff]])
   setword(a,0x3c,OWNER)
   setword(object_end,(0,1,17)[i]*120+0x4c,(1024-angle)&0xffd)
   value=f32(f32(f32(s32(angle-1024))*f32(3.141592))/2048.0)
   transform_end[i][8:12]=struct.pack('>f',value)
  if stack_change:
   start=[s32(v+(i+1)*[17,-29,43][axis]) for axis,v in enumerate(start)]
 panels=[(INPUT,word(12345)+word(-6789)+word(9012),None),(OWNER,owner,None),(PARENT,parent,None),(RESOURCES,resources,None),(OBJECTS,objects,object_end),(SEED,word(case[3]),word(seed)),(DELTA,word(delta),None),(JITTER,word(jitter),None)]
 panels += [(a,x,y) for a,x,y in zip(ACTORS,actor_images,expected)]
 panels += [(a,x,y) for a,x,y in zip(TRANSFORMS,transforms,transform_end)]
 return count,panels,calls,alloc_calls,last
def run(body,support,entries,case,fpu_fault=None,input_fault=None):
 count,panels,wanted,allocation_positions,last=fixtures(case)
 uc,write,execute,code=literal_machine([(ENTRY,body)]+support,ENTRY)
 if fpu_fault is not None:
  address,stub=next(x for x in code if x[0]==FP_STUB)
  changed=stub[:-8]+word(0xC4003080|(fpu_fault<<16))+stub[-8:]
  code=[(a,changed if a==FP_STUB else b) for a,b in code];write(FP_STUB,changed)
 uc.reg_write(reg.UC_MIPS_REG_GP,0xA5721938)
 guards=[];expected=[]
 reads=[];writes=[(STACK-1024,STACK+32),(FP_RESULT,FP_RESULT+48),(SEED,SEED+4)]
 for address,initial,final in panels:
  initial=bytes(initial);final=initial if final is None else bytes(final)
  reads.append((address,address+len(initial)))
  if final!=initial:writes.append((address,address+len(initial)))
 regions=[]
 for address,initial,final in sorted(panels):
  end=address+len(initial)
  if regions and address<=regions[-1][1]+32:regions[-1][1]=max(regions[-1][1],end)
  else:regions.append([address,end])
 for start,end in regions:
  initial=bytearray(b'\xc3'*(end-start));final=bytearray(initial)
  for address,before,after in panels:
   if start<=address and address+len(before)<=end:
    initial[address-start:address-start+len(before)]=before
    final[address-start:address-start+len(before)]=before if after is None else after
  write(start-16,b'\xa7'*16+initial+b'\xb9'*16)
  expected.append((start-16,b'\xa7'*16+final+b'\xb9'*16))
 for address,data in support:
  if address not in entries and not any(lo<=address<hi for lo,hi in [(x[0],x[0]+len(x[1])) for x in support if x[0] in entries]):
   reads.append((address,address+len(data)))
 reads.extend([(STACK-1024,STACK+32),(FP_SEED,FP_SEED+132)])
 write(STACK-1040,b'\xa7'*16);write(STACK-1024,b'\xc9'*1056);write(STACK+32,b'\xb9'*16)
 guards.extend([(STACK-1040,b'\xa7'*16),(STACK+32,b'\xb9'*16)])
 uc.reg_write(reg.UC_MIPS_REG_A0,INPUT if input_fault is None else input_fault)
 for n,value in [('A1',case[0]),('A2',OWNER),('A3',case[1])]:uc.reg_write(getattr(reg,'UC_MIPS_REG_'+n),value&0xffffffff)
 code_ranges=[(a,a+len(b)) for a,b in code]
 trace=[];pending=[];allocations=0;support_calls=0
 def read(address,size):return bytes(uc.mem_read(address&0x1fffffff,size))
 def inside(a,n,ranges):return any(lo<=a and a+n<=hi for lo,hi in ranges)
 def mem(uc,access,address,size,value,user):
  a=(address&0x1fffffff)|0x80000000
  assert not (size>1 and a&(min(size,4)-1)),('unaligned',hex(a),size)
  assert inside(a,size,writes if access==17 else reads),('access',access,hex(a),size,hex(uc.reg_read(reg.UC_MIPS_REG_PC)))
 uc.hook_add(UC_HOOK_MEM_READ,mem);uc.hook_add(UC_HOOK_MEM_WRITE,mem)
 def hook(uc,address,size,user):
  nonlocal allocations,support_calls
  if pending and address==pending[-1][0]:
   _,saved=pending.pop()
   assert all(uc.reg_read(k)==v for k,v in saved.items()),('support ABI',hex(address))
  if address==ALLOC:
   assert allocations<count
   args=[uc.reg_read(getattr(reg,'UC_MIPS_REG_'+n)) for n in ['A0','A1','A2']]
   assert args[:2]==[4,RESOURCES+case[0]*92] and inside(args[2],12,[(STACK-1024,STACK)])
   position=[s32(int.from_bytes(read(args[2]+i*4,4),'big')) for i in range(3)]
   assert position==allocation_positions[allocations],('copied position',position,allocation_positions[allocations])
   trace.append([ALLOC,[4,args[1],position]])
   ptr=0 if case[2]&(1<<allocations) else ACTORS[allocations]
   if ptr:write(ptr+0x60,b''.join(word(x) for x in position))
   if case[-1]:write(args[2],b''.join(word(s32(v+(allocations+1)*[17,-29,43][i])) for i,v in enumerate(position)))
   allocations+=1
   for i,k in enumerate(CALLER_SAVED):uc.reg_write(k,0xB2340000+i*257)
   uc.reg_write(reg.UC_MIPS_REG_V0,ptr)
   uc.reg_write(reg.UC_MIPS_REG_HI,0xAABBCCDD);uc.reg_write(reg.UC_MIPS_REG_LO,0x11223344)
   uc.reg_write(reg.UC_MIPS_REG_PC,FP_STUB);return
  if address in entries:
   support_calls+=1;pending.append((uc.reg_read(reg.UC_MIPS_REG_RA),{k:uc.reg_read(k) for k in SAVED}))
  if address in [0x80039C50,0x80039BE4,0x80039514]:
   trace.append([address,[uc.reg_read(reg.UC_MIPS_REG_A0),uc.reg_read(reg.UC_MIPS_REG_A1)]])
  elif address in [0x8003CC88,0x8003CC58]:
   trace.append([address,[uc.reg_read(reg.UC_MIPS_REG_A0)]])
  elif address==0x8004CDE8:trace.append([address,[]])
  assert address==SENTINEL or inside(address,size,code_ranges),('instruction',hex(address))
 uc.hook_add(UC_HOOK_CODE,hook)
 execute(FP_INIT);verify_fpu(uc)
 assert allocations==count and trace==wanted and not pending,('trace',trace,wanted)
 assert uc.reg_read(reg.UC_MIPS_REG_V0)==last and uc.reg_read(reg.UC_MIPS_REG_GP)==0xA5721938,('result',hex(uc.reg_read(reg.UC_MIPS_REG_V0)),hex(last))
 for address,blob in expected+guards:
  observed=read(address,len(blob))
  assert observed==blob,('memory',hex(address),[(hex(address+i),a,b) for i,(a,b) in enumerate(zip(observed,blob)) if a!=b][:12])
 return {'trace':trace,'result':last,'memory_digest':hashlib.sha256(b''.join(blob for _,blob in expected)).hexdigest(),'support_calls':support_calls}
def cases():
 for kind in range(11):
  count=1 if kind in (1,2,3) else 3
  for mask in range(1<<count):
   for angle in [0,1024,2048,2049,4095]:
    yield (kind,angle,mask,174823885,-731,2,-91,-117,293,0)
 rng=random.Random(0x38d8c)
 for i in range(256):
  yield (rng.randrange(11),rng.choice([-0x80000000,-65537,-32768,-1,0,1,2048,2049,0x7fffffff])+rng.randrange(-8,9),rng.randrange(8),rng.randrange(0x100000000),rng.choice([-0x80000000,-701,-1,0,1,791,0x7fffffff]),rng.choice([-0x80000000,-3,0,1,7,0x7fffffff]),rng.choice([-0x80000000,-351,0,5,0x7fffffff]),rng.randrange(-50000,50000),rng.randrange(-50000,50000),i%2)
def compile_one(name,path,rom,layout):
 q=compare_block(name,str(path.relative_to(R)),ENTRY,0x3998c,0x39d9c,rom,family='projectile-audit',layout=layout)
 directory=R/'build/projectile-audit'/name
 with (directory/(name+'.raw.o')).open('rb') as h:
  e=ELFFile(h);q['natural_size']=e.get_section_by_name('.symtab').get_symbol_by_name('func_80038D8C')[0]['st_size']
 return (directory/(name+'.bin')).read_bytes(),q
def prepare():
 rom=(R/'baseroms/us/baserom.z64').read_bytes();validate(rom);layout=SymbolLayoutSnapshot();support=[];entries=set();comparisons={}
 for name in ['object_transforms','object_recovery_fixed_trig','runtime_random','gu_random','short_sine','short_cosine']:
  _,source,start,end=next(x for x in MATCHING_BLOCKS if x[0]==name)
  q=compare_block(name,source,start,start-0x80000000+0xc00,end-0x80000000+0xc00,rom,family='projectile-support',layout=layout);assert q['matches'];comparisons[name]=q
  directory=R/'build/projectile-support'/name
  support.append((start,(directory/(name+'.bin')).read_bytes()))
  with (directory/(name+'.elf')).open('rb') as h:
   e=ELFFile(h);entries.update(s['st_value'] for s in e.get_section_by_name('.symtab').iter_symbols() if s['st_info']['type']=='STT_FUNC' and start<=s['st_value']<end)
  sections,_=elf_sections_and_symbols(directory/(name+'.elf'))
  for record in source_sections(source):
   if record['rom'] is not None:support.append((record['vram'],sections[record['section']]['bytes']))
 source='src/game/object_angle_setter_constants.c';q=compare_unit(source,source_sections(source),rom,layout);assert q['matches'];comparisons[source]=q
 sections,_=elf_sections_and_symbols(R/'build/data-comparison'/Path(source).with_suffix('')/'compiled.elf')
 for record in source_sections(source):support.append((record['vram'],sections[record['section']]['bytes']))
 body,comparison=compile_one('accepted',R/'src/game/actor_projectiles/spawn.c',rom,layout)
 assert comparison['matches'] and comparison['natural_size']==1040 and len(body)==1040
 return rom[0x3998c:0x39d9c],body,support,entries,comparison,comparisons,rom,layout
