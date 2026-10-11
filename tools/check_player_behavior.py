"""Audit complete excluded player behavior under a finite paired corpus.

Four independently compiled matching helpers execute. Other callee effects
are explicit returning O32 observers. This does not prove full gameplay,
independent game-state semantics, or matching source ownership.
"""
from pathlib import Path
import hashlib,itertools,json,math,random,struct,sys
from unicorn import Uc,UC_ARCH_MIPS,UC_MODE_MIPS32,UC_MODE_BIG_ENDIAN,UC_HOOK_CODE,UC_HOOK_MEM_WRITE,UC_HOOK_MEM_READ
from unicorn import mips_const as mc
from rom import ROOT,validate
from compare_startup import SymbolLayoutSnapshot
from player_behavior_compare import compare_candidate_block,verify_helpers,SOURCE
n=ROOT
from owned_sections import elf_sections_and_symbols
rom=(n/'baseroms/us/baserom.z64').read_bytes()
START=0x80033974;END=0x80035190;SP=0x807F0000;STOP=0x807FFF00
ACTOR=0x80500000;SECOND=ACTOR+0x7C;CHILD=SECOND+0x7C;ENEMY=CHILD+0x7C
RESOURCE=0x80501000;TRACK=0x80502000;BORN=0x80503000
SEED=0x80510000;READ=0x80510100;CLOBBER=0x80510200;FPU_OUT=0x80510300
HELPERS={0x80017F9C:1,0x8001C49C:3,0x80027AB8:3,0x800290B0:2,0x80029194:1,0x80032F70:0,
 0x800330F8:5,0x800338CC:2,0x800338F0:2,0x80035E3C:3,0x80036064:2,0x8003614C:4,
 0x80038D8C:4,0x800393FC:1,0x8003945C:2,0x80039514:2,0x8003978C:2,0x800397E0:2,
 0x80039CD0:1,0x80039E5C:2,0x8003B520:3,0x8003CC58:1,0x8003CC88:1,0x8003CD4C:2,
 0x8004CDE8:0,0x8004CEF0:1}
def s32(x):return (x&0x7FFFFFFF)-(x&0x80000000)
def u32(x):return x&0xFFFFFFFF
def trunc(a,b):return abs(a)//abs(b)*(-1 if (a<0)!=(b<0) else 1)
def reg(i):return getattr(mc,'UC_MIPS_REG_'+str(i))
def w(uc,address,value,size=4):uc.mem_write(address,(value&((1<<(size*8))-1)).to_bytes(size,'big'))
def r(uc,address,size=4):return int.from_bytes(uc.mem_read(address,size),'big')
def execute(fixture,elf=None,fault=None):
 uc=Uc(UC_ARCH_MIPS,UC_MODE_MIPS32|UC_MODE_BIG_ENDIAN);uc.mem_map(0,0x800000)
 raw_read,raw_write=uc.mem_read,uc.mem_write
 uc.mem_read=lambda address,size:raw_read(address&0x1FFFFFFF,size)
 uc.mem_write=lambda address,data:raw_write(address&0x1FFFFFFF,data)
 uc.mem_write(0x80000000,rom[0xC00:0xC00+0x9B000])
 # BSS and synthetic caller-owned buffers are initialized independently per run.
 uc.mem_write(0x8009B000,bytes(0x60000))
 if elf:
  sections,_=elf_sections_and_symbols(elf);code=sections['.text']['bytes'];tables=sections.get('.rodata',{}).get('bytes',b'')
  uc.mem_write(START,code);uc.mem_write(0x80094254,tables)
  bound=START+len(code)
 else:bound=END
 if fault=='dispatch':uc.mem_write(0x80094254,struct.pack('>16I',*[STOP]*16))
 player=0x8009B190+fixture['player']*0xDB4
 actor=bytearray(0x7C);struct.pack_into('>hh',actor,8,fixture['angle'],0)
 struct.pack_into('>hh',actor,0xC,3,0);struct.pack_into('>I',actor,0x14,fixture['flags']);struct.pack_into('>i',actor,0x18,fixture['frame'])
 actor[0x1F]=fixture['animation'];struct.pack_into('>I',actor,0x24,RESOURCE)
 struct.pack_into('>II',actor,0x3C,player,0);struct.pack_into('>I',actor,0x44,0x80029194)
 struct.pack_into('>II',actor,0x48,u32(fixture['now']-fixture['elapsed']),0)
 struct.pack_into('>i',actor,0x54,fixture['count']);struct.pack_into('>iii',actor,0x60,fixture['x'],fixture['y'],11)
 uc.mem_write(ACTOR,bytes(actor));uc.mem_write(SECOND,bytes(actor));uc.mem_write(CHILD,bytes(actor));uc.mem_write(ENEMY,bytes(actor))
 w(uc,SECOND+0xC,4,2);w(uc,ENEMY+0x60,fixture['x']+fixture['aim_x']);w(uc,ENEMY+0x64,fixture['y']+fixture['aim_y'])
 w(uc,RESOURCE+8,fixture['speed']);w(uc,RESOURCE+0xC,4096);w(uc,RESOURCE+0x18,fixture['range'],2)
 w(uc,RESOURCE+0x48,TRACK);w(uc,TRACK+0xA,9,2)
 w(uc,player+8,ACTOR);w(uc,player+0xC,SECOND if fixture['display'] else 0)
 w(uc,player+0x1C,fixture['lives']);w(uc,player+0x6C,fixture['weapon']);w(uc,player+0x70,fixture['ability']);w(uc,player+0x74,fixture['ability'])
 w(uc,player+0x78,fixture['shots']);w(uc,player+0x7C,2);w(uc,player+0x80,fixture['blend'])
 w(uc,player+0x84,fixture['old_direction']);w(uc,player+0x88,4);w(uc,player+0x8C,u32(fixture['now']-fixture['elapsed']))
 w(uc,player+0x94,u32(fixture['now']-fixture['elapsed']));w(uc,player+0x98,u32(fixture['now']-fixture['elapsed']));w(uc,player+0x9C,fixture['charge'])
 w(uc,player+4,fixture['idle'],1)
 for index in range(2):w(uc,0x8009B190+index*0xDB4+0x1C,fixture['lives'] if index==fixture['player'] else fixture['other_lives'])
 for input_address in (0x800AD138,player+0x34):
  w(uc,input_address,fixture['input_flags']);w(uc,input_address+0x1C,fixture['held']);w(uc,input_address+0x20,fixture['pressed'])
 w(uc,0x800AD168,2);w(uc,0x800AD16C,fixture['player']);w(uc,0x800AD170,0)
 w(uc,0x800AD174,0);w(uc,0x800AD178,1);w(uc,0x800AD180,fixture['session_mode'])
 for address,value in ((0x8007394C,fixture['relative']), (0x80073A40,fixture['pause']), (0x8007BB18,1),
  (0x8007C334,fixture['controllers']),(0x80097644,u32(fixture['now']-fixture['elapsed'])),(0x8009EF94,fixture['delta']),
  (0x8009EFA0,fixture['now']),(0x800AD280,fixture['game_state']),(0x800AD288,fixture['game_mode']),
  (0x800AD300,fixture['option']),(0x800B6FD0,8),(0x800BA74C,fixture['death_ready']),(0x800BA784,fixture['diamond'])):w(uc,address,value)
 for index,(x,y) in enumerate(zip(fixture['stick_x'],fixture['stick_y'])):
  w(uc,0x8013DBB8+index*4,x);w(uc,0x8013DBC8+index*4,y)
 for index in range(16):w(uc,0x8009AA00+index*0x5C+0x58,fixture['limit'])
 for index in range(11):w(uc,0x800AC998+index*0x5C+0x10,fixture['interval'],2)
 uc.mem_write(0x800A4538,bytes(range(32)))
 w(uc,CHILD+0x1C,0,1);w(uc,CHILD+0x1F,3,1);w(uc,RESOURCE+2,0x21,1);w(uc,CHILD+0x3C,ACTOR)
 w(uc,CHILD+0x78,0);w(uc,0x800AA708,CHILD if fixture['child'] else 0)
 w(uc,BORN+0x6C,fixture['born_x']);w(uc,BORN+0x70,fixture['born_y'])
 preserved={i:0x22330000+i*0x101 for i in (*range(16,24),28,30)}
 for index,value in preserved.items():uc.reg_write(reg(index),value)
 fps={i:0x3F010000+i*0x100 for i in range(20,32)}
 word=lambda value:struct.pack('>I',value)
 jump=word(0x03E00008)+word(0)
 seed=b''.join(word(0x3C080000|(value>>16))+word(0x35080000|(value&65535))+word(0x44880000|(index<<11)) for index,value in fps.items())+jump
 reader=word(0x3C080000|(FPU_OUT>>16))+word(0x35080000|(FPU_OUT&65535))+b''.join(word(0xE5000000|(index<<16)|((index-20)*4)) for index in fps)+jump
 clobber=word(0x3C013F80)+b''.join(word(0x44810000|(index<<11)) for index in range(20))+jump
 if fault=='read':clobber=word(0x8E024000)+clobber
 elif fault=='write':clobber=word(0xAE004000)+clobber
 elif fault=='stack':clobber=word(0xAFA0F000)+clobber
 elif fault=='saved_integer':clobber=word(0x24100000)+clobber
 elif fault=='saved_fpu':clobber=word(0x4480A000)+clobber
 elif fault=='code':clobber=word(0x08000000|((0x80660000&0x0FFFFFFF)>>2))+word(0)+clobber
 uc.mem_write(SEED,seed);uc.mem_write(READ,reader);uc.mem_write(CLOBBER,clobber)
 uc.reg_write(mc.UC_MIPS_REG_CP0_STATUS,uc.reg_read(mc.UC_MIPS_REG_CP0_STATUS)|(1<<29))
 uc.reg_write(reg(31),STOP);uc.emu_start(SEED,STOP,count=1000)
 uc.reg_write(reg(4),ACTOR);uc.reg_write(reg(5),0x55667788);uc.reg_write(reg(29),SP);uc.reg_write(reg(31),STOP)
 trace=[];dirty=set();steps=0;seen=set();observer_saved={}

 frame=-int.from_bytes(uc.mem_read(START+2,2),'big',signed=True)
 assert frame>0 and frame<0x1000
 stack_low=SP-frame
 stack_pattern=bytes((i*29+71)&255 for i in range(frame+16))
 uc.mem_write(stack_low,stack_pattern)
 uc.mem_write(stack_low-16,b'\xa7'*16);uc.mem_write(SP+16,b'\xb9'*16)
 # Exact allocations already initialized above, with original array strides.
 allocations=[(ACTOR,ACTOR+4*0x7C),(RESOURCE,RESOURCE+0x58),
  (TRACK,TRACK+0x10),(BORN,BORN+0x7C),
  (0x8009B190,0x8009B190+2*0xDB4),(0x800AD138,0x800AD138+0x148)]
 globals_=[0x8007394C,0x80073A40,0x8007BB18,0x8007C334,0x80097644,
  0x8009EF94,0x8009EFA0,0x800AD280,0x800AD288,0x800AD300,
  0x800B6FD0,0x800BA74C,0x800BA784,0x800AA708,0x800BEF60,
  0x800BEF64,0x800BEF6C]
 readable=allocations+[(a,a+4) for a in globals_]+[
  (0x8013DBB8,0x8013DBD8),(0x8009AA00,0x8009AA00+16*0x5C),
  (0x800AC998,0x800AC998+11*0x5C),(0x800A4538,0x800A4558),
  (0x80094254,0x80094294),(0x80094294,0x8009429C),
  (stack_low,SP+16),(FPU_OUT,FPU_OUT+48)]
 writable=allocations+[(a,a+4) for a in
  (0x80073A40,0x8007BB18,0x800BEF60,0x800BEF64,0x800BEF6C)]+[
  (stack_low,SP+16),(FPU_OUT,FPU_OUT+48)]
 def inside(address,size,ranges):
  address=(address&0x1FFFFFFF)|0x80000000
  assert size in (1,2,4,8),('invalid access width',size)
  return any(left<=address and address+size<=right for left,right in ranges)
 def read_hook(machine,access,address,size,value,user):
  assert inside(address,size,readable),('read bounds',hex(machine.reg_read(mc.UC_MIPS_REG_PC)),hex(address),size)
 def write_hook(machine,access,address,size,value,user):
  address=(address&0x1FFFFFFF)|0x80000000
  assert inside(address,size,writable),('write bounds',hex(machine.reg_read(mc.UC_MIPS_REG_PC)),hex(address),size)
  if FPU_OUT<=address<FPU_OUT+48:return
  if stack_low<=address<SP+16:return
  dirty.update(range(address,address+size))

 real_helpers={2147694796: 2147694832, 2147798768: 2147798792, 2147726624: 2147726740, 2147704932: 2147704992}
 pending_return=None
 def code_hook(machine,address,size,user):
  nonlocal steps,observer_saved,pending_return
  steps+=1
  if address==STOP:machine.emu_stop();return
  if CLOBBER<=address<CLOBBER+len(clobber):
   if address==CLOBBER+len(clobber)-8:
    assert all(machine.reg_read(reg(index))==value for index,value in observer_saved.items()),'Observer saved integer registers'
   return
  if READ<=address<READ+len(reader):return

  if pending_return==address:
   pending_return=None
   assert all(machine.reg_read(reg(index))==value for index,value in observer_saved.items()),'Real helper saved registers'
   result=machine.reg_read(reg(2))
   for index in (2,3,4,5,6,7,8,9,10,11,12,13,14,15,24,25):machine.reg_write(reg(index),0x13570000+index*0x107)
   machine.reg_write(reg(2),result);machine.reg_write(mc.UC_MIPS_REG_PC,CLOBBER)
   return
  if any(start<address<end for start,end in real_helpers.items()):return
  if START<=address<bound:return
  assert address in HELPERS,('unobserved callee',hex(address))
  seen.add(address);args=[r(machine,machine.reg_read(reg(29))+0x10) if i==4 else machine.reg_read(reg(4+i))&0xFFFFFFFF for i in range(HELPERS[address])]
  observer_saved={index:machine.reg_read(reg(index)) for index in (*range(16,24),28,29,30,31)}
  observed=list(args);result=0
  def host_read(pointer,count):
   pointer=(pointer&0x1FFFFFFF)|0x80000000
   assert count>0 and any(left<=pointer and pointer+count<=right for left,right in readable),('observer read',hex(pointer),count)
   return machine.mem_read(pointer,count)
  def host_write(pointer,data):
   pointer=(pointer&0x1FFFFFFF)|0x80000000
   assert data and any(left<=pointer and pointer+len(data)<=right for left,right in writable),('observer write',hex(pointer),len(data))
   machine.mem_write(pointer,data)
   if not stack_low<=pointer<SP+16:dirty.update(range(pointer,pointer+len(data)))
  if address==0x800330F8:
   observed=[args[0],args[1],s32(r(machine,args[2])),s32(r(machine,args[3])),s32(args[4])]
   host_write(args[2],struct.pack('>I',u32(fixture['ai_x'])));host_write(args[3],struct.pack('>I',u32(fixture['ai_y'])));result=ENEMY if fixture['ai_target'] else 0
  elif address==0x80038D8C:
   observed=[list(struct.unpack('>iii',host_read(args[0],12))),*args[1:]];result=BORN
  elif address==0x8003B520:
   data=bytes(host_read(args[1],args[2]));observed=[args[0],data.hex(),args[2]];
   if address not in real_helpers:
    host_write(args[0],data)
  elif address==0x800338F0:observed=[args[0],args[1],s32(r(machine,args[0]))];host_write(args[0],bytes(4))
  elif address==0x80035E3C:observed=[args[0],args[1],bytes(host_read(args[2],36)).hex()]
  elif address==0x800290B0:observed=[args[0],list(struct.unpack('>iii',host_read(args[1],12)))]
  elif address==0x80017F9C:observed=[args[0],list(struct.unpack('>iii',host_read(args[0]+0x60,12)))]
  elif address==0x800338CC:result=trunc(s32(args[0]),1<<(args[1]&31))
  elif address==0x8004CEF0:result=abs(s32(args[0]))
  elif address in (0x8003CC58,0x8003CC88):
   angle=(args[0]&0xFFF)*2*math.pi/4096;result=int(round(4096*(math.sin(angle) if address==0x8003CC58 else math.cos(angle))))
  elif address==0x8003CD4C:result=int(round(math.atan2(s32(args[0]),s32(args[1]))*4096/(2*math.pi)))&0xFFF
  elif address==0x800393FC:result=fixture['animation_id']
  elif address==0x80039CD0:result=fixture['frame_count']
  elif address==0x8004CDE8:result=fixture['random']
  elif address==0x80036064:result=(s32(r(machine,args[0]+8,2))+args[1]+1024)&0xFFF if fixture['relative'] else args[1]
  elif address==0x80039E5C:result=args[1]

  trace.append([hex(address),observed])
  if address in real_helpers:
   pending_return=machine.reg_read(reg(31))
   return
  return_address=machine.reg_read(reg(31))
  for index in (2,3,4,5,6,7,8,9,10,11,12,13,14,15,24,25):machine.reg_write(reg(index),0x13570000+index*0x107)
  machine.reg_write(reg(2),u32(result));machine.reg_write(mc.UC_MIPS_REG_PC,CLOBBER)
 uc.hook_add(UC_HOOK_MEM_READ,read_hook);uc.hook_add(UC_HOOK_MEM_WRITE,write_hook);uc.hook_add(UC_HOOK_CODE,code_hook)
 uc.emu_start(START,STOP+4,count=40000)
 assert uc.reg_read(mc.UC_MIPS_REG_PC)==STOP,('did not return',steps,hex(uc.reg_read(mc.UC_MIPS_REG_PC)))
 assert bytes(uc.mem_read(stack_low-16,16))==b'\xa7'*16,'stack low canary'
 assert bytes(uc.mem_read(SP+16,16))==b'\xb9'*16,'stack high canary'
 assert uc.reg_read(reg(29))==SP,'Stack pointer not restored'
 assert all(uc.reg_read(reg(index))&0xFFFFFFFF==value for index,value in preserved.items()),'Saved integer registers'
 uc.reg_write(reg(31),STOP);uc.emu_start(READ,STOP,count=1000)
 assert bytes(uc.mem_read(FPU_OUT,48))==b''.join(word(value) for value in fps.values()),'Saved FPU registers'
 return uc,trace,dirty,steps,seen
def fixtures():
 rng=random.Random(0x339742026)
 for i in range(1536):
  yield {'player':i%2,'animation':(0,0,8,8,1,1,1,2,3,4,5,6,7,9)[i%14],'angle':rng.choice((-2048,-1,0,2048,4095)),
   'flags':rng.choice((0,1,0x40,0x400,0x4000,0x4401)), 'frame':rng.choice((0,1000,4000,8000)),
   'now':rng.choice((30000,0xFFFFFFF0,0x30)), 'elapsed':rng.choice((99,100,1000,1001,2000,2001,10000,10001)),
   'x':rng.choice((-31000,-29000,0,29000,31000)),'y':rng.choice((-31000,0,31000)),
   'count':rng.choice((0,1,7)), 'speed':rng.choice((100,500,1000)), 'range':rng.choice((100,500)),
   'display':i%4!=0,'lives':rng.choice((0,1,2)),'other_lives':rng.choice((0,1,2)), 'weapon':rng.choice((-1,0,1,2,3,4)),
   'ability':rng.choice((0,8,9,10)), 'shots':rng.choice((0,10,11)), 'blend':rng.choice((1,128,256)),
   'old_direction':rng.choice((0,4,8)), 'charge':rng.choice((-1,0,999,1000,1001,2000)), 'idle':i%2,
   'input_flags':i%2,'held':rng.choice((0,1,2,4,8,0xF,0x10,0x20,0x40,0x80,0xF0)),
   'pressed':rng.choice((0,1,0xF,0x800,0x1000,0x180F)), 'session_mode':rng.choice((0,3)),
   'relative':i%2,'pause':i%3==0,'controllers':rng.choice((0,2,4,6,8,12)),
   'delta':rng.choice((1,8,16,32)), 'game_state':rng.choice((0,6,9)), 'game_mode':rng.choice((0,3,7)),
   'option':i%2,'death_ready':rng.choice((-1,0)), 'diamond':i%2,
   'stick_x':[rng.choice((-256,-16,-15,-14,-10,0,10,14,15,16,256)) for _ in range(4)],
   'stick_y':[rng.choice((-256,-16,-15,-14,-10,0,10,14,15,16,256)) for _ in range(4)],
   'limit':rng.choice((0,10)),'interval':rng.choice((0,100,1000)), 'child':i%3!=0,
   'born_x':rng.choice((-100,0,100)), 'born_y':rng.choice((-100,0,100)),
   'ai_x':rng.choice((-100,0,100)), 'ai_y':rng.choice((-100,0,100)), 'ai_target':i%2,
   'aim_x':rng.choice((0,10000,60000)), 'aim_y':rng.choice((0,10000,60000)),
   'animation_id':rng.choice((0,110)), 'frame_count':20,'random':rng.choice((-32,-8,0,8,32))}
def main():
 out=n/'build/player-behavior-audit';out.mkdir(exist_ok=True)
 validate(rom);layout=SymbolLayoutSnapshot()
 report=compare_candidate_block('player_behavior',SOURCE,rom,layout,'player-behavior-audit')
 helpers=verify_helpers(rom,layout)
 candidate=n/report['elf'];seen=set();steps=0
 family='player-behavior'
 for index,fixture in enumerate(fixtures()):
  try:
   original=execute(fixture);current=execute(fixture,candidate)
   assert original[1]==current[1],('trace',original[1],current[1])
   changed=original[2]|current[2]
   differences=[hex(address) for address in sorted(changed) if original[0].mem_read(address,1)!=current[0].mem_read(address,1)]
   assert not differences,('memory',differences)
   seen|=original[4]|current[4];steps+=original[3]+current[3]
  except Exception as error:
   (out/(family+'-failure.json')).write_text(json.dumps({'index':index,'fixture':fixture,'error':str(error)},indent=2)+'\n')
   print('FAILED fixture',index,str(error)[:2500],flush=True);raise
  if index%64==63:print('Passed',index+1,'pairs',flush=True)
 assert seen==set(HELPERS),('uncovered callees',set(HELPERS)-seen)
 controls=run_controls(candidate,list(fixtures()),layout)
 record={'pairs':index+1,'executions':2*(index+1),'guest_steps':steps,'observed_callees':[hex(x) for x in sorted(seen)],
  'checker_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
  'fixtures_sha256':hashlib.sha256(json.dumps(list(fixtures()),sort_keys=True).encode()).hexdigest(),
  'candidate_sha256':hashlib.sha256(candidate.read_bytes()).hexdigest(),'comparison':report,'verified_helpers':helpers,'controls':controls,'source_ownership_added':0,
  'limits':['Four independently compared matching helpers execute their real instructions. Other callees use explicit returning O32 observers.','Caller effects and traces under 1536 finite fixtures do not prove gameplay or matching source.','Guest accesses checked against fixture allocations, natural stack frame and original tables. Host observer effects remain explicit synthetic models.']}
 (out/(family+'-receipt.json')).write_text(json.dumps(record,indent=2)+'\n')
 layout.verify()
 for path,digest in report['inputs_sha256'].items():assert hashlib.sha256((n/path).read_bytes()).hexdigest()==digest,path
 print(json.dumps(dict(pairs=index+1,guest_steps=steps,controls=len(controls),matches=report['matches'],natural_bytes=report['actual_size'],frame=report['frame'],different_words=len(report['different_words']),different_dispatch_words=len(report['dispatch']['differing_words']),source_ownership_added=0)),flush=True)

def equivalent(first,second):
 if first[1]!=second[1]:return False
 return all(first[0].mem_read(address,1)==second[0].mem_read(address,1) for address in first[2]|second[2])

def run_controls(candidate,corpus,layout):
 out=n/'build/player-behavior-audit/controls';out.mkdir(exist_ok=True)
 source=(n/SOURCE).read_text();controls=[]
 for name,before,after in (
  ('height','actor->position[2] = 500;','actor->position[2] = 501;'),
  ('aim_default','D_800BEF6C = -1;','D_800BEF6C = 0;'),
  ('ability','func_800338F0(&player->selection70, (ScenePlayerRuntime *)player);','func_800338F0(&player->selection74, (ScenePlayerRuntime *)player);'),
  ('ability_player','func_800338F0(&player->selection70, (ScenePlayerRuntime *)player);','func_800338F0(&player->selection70, (ScenePlayerRuntime *)actor);'),
  ('other_ability_player','func_800338F0(&player->selection74, (ScenePlayerRuntime *)player);','func_800338F0(&player->selection74, (ScenePlayerRuntime *)actor);'),
  ('clamp_restore','restorePosition = 1;','restorePosition = 0;'),
  ('stick_y','D_8013DBC8[controller]','D_8013DBB8[controller]')):
  assert before in source,name
  mutant_source=out/(name+'.c');mutant_source.write_text(source.replace(before,after,1))
  result=compare_candidate_block(name,mutant_source.relative_to(n).as_posix(),rom,layout,'player-behavior-audit/controls')
  mutant=n/result['elf'];rejected=None
  for index,fixture in enumerate(corpus):
   baseline=execute(fixture)
   assert equivalent(baseline,execute(fixture,candidate)),('control baseline',name,index)
   try:different=not equivalent(baseline,execute(fixture,mutant))
   except (AssertionError,ValueError):different=True
   if different:
    assert equivalent(execute(fixture),execute(fixture,candidate)),('control final bracket',name,index)
    rejected=index;break
  assert rejected is not None,('mutation survived',name)
  controls.append(dict(name=name,rejected_fixture=rejected,baseline_brackets_passed=True,mutant_sha256=hashlib.sha256(mutant.read_bytes()).hexdigest()))
  print('Rejected source control',name,'at fixture',rejected,flush=True)
 fixture=next(case for case in corpus if case['animation']==0 and case['game_mode']==3)
 for fault in ('saved_integer','saved_fpu','code','read','write','stack','dispatch'):
  assert equivalent(execute(fixture),execute(fixture,candidate))
  error=None
  try:execute(fixture,candidate,fault=fault)
  except Exception as exception:error=str(exception)
  assert error,('guest fault survived',fault)
  assert equivalent(execute(fixture),execute(fixture,candidate))
  controls.append(dict(name=fault,rejected=True,reason=error,baseline_brackets_passed=True))
  print('Rejected guest control',fault,error[:160],flush=True)
 return controls
if __name__=='__main__':main()
