"""Verify the complete projectile body, bounded execution and actual faults."""
from pathlib import Path
import json, hashlib
import projectile_spawn_execution as execution

ROOT=Path(__file__).resolve().parent.parent

def controls(retail,body,support,entries,rom,layout):
 D=ROOT/'build/projectile-spawn-check';C=D/'mutants';C.mkdir(parents=True,exist_ok=True)
 base=(ROOT/'src/game/actor_projectiles/spawn.c').read_text()
 def case(kind=4,angle=0):return (kind,angle,0,174823885,-731,2,-91,-117,293,1)
 mutations=[
  ('z_copy','start.value[2] -= 350;','start.value[2] -= 349;',case()),
  ('spawn_count','    count = 3;','    count = 1;',case()),
  ('secondary_flag','actor->flags14 |= 0x100;','actor->flags14 |= 0x200;',case()),
  ('wrong_resource_speed','((TextGlyphResource *) actor->resource24)->speed','((TextGlyphResource *) resource)->speed',case(1)),
  ('negative_division','(func_8003CC88(angle) * actor->field54) / 4096','(func_8003CC88(angle) * actor->field54) >> 12',case()),
  ('owner_velocity','actor->field6C += owner->actor08->field6C;','actor->field6C += 0;',case(1)),
  ('angle_threshold','if (angle > 2048)','if (angle >= 2048)',case(4,2048)),
  ('last_result','return actor;','return 0;',case(1))
 ]
 controls=[]
 for name,before,after,c in mutations:
  assert before in base and before!=after
  p=C/(name+'.c');p.write_text(base.replace(before,after))
  execution.run(retail,support,entries,c);execution.run(body,support,entries,c)
  changed,q=execution.compile_one('mutant_'+name,p,rom,layout)
  try:execution.run(changed,support,entries,c)
  except (AssertionError,ValueError,execution.UcError) as e:reason=str(e)[:600]
  else:raise AssertionError('Mutation survived '+name)
  execution.run(body,support,entries,c)
  controls.append({'kind':'source','name':name,'rejected':True,'reason':reason,'source_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'comparison':q})
  print('rejected',name,flush=True)
 for f in range(20,32):
  c=case(1);execution.run(retail,support,entries,c);execution.run(body,support,entries,c)
  try:execution.run(body,support,entries,c,fpu_fault=f)
  except (AssertionError,ValueError,execution.UcError) as e:reason=str(e)[:600]
  else:raise AssertionError('Saved FPU fault survived '+str(f))
  execution.run(body,support,entries,c);controls.append({'kind':'saved_fpu','register':f,'rejected':True,'reason':reason})
 for name,address in [('null',0),('misaligned',execution.INPUT+1),('past_position',execution.INPUT+4)]:
  c=case(1);execution.run(retail,support,entries,c);execution.run(body,support,entries,c)
  try:execution.run(body,support,entries,c,input_fault=address)
  except (AssertionError,ValueError,execution.UcError) as e:reason=str(e)[:600]
  else:raise AssertionError('Input fault survived '+name)
  execution.run(body,support,entries,c);controls.append({'kind':'access','name':name,'rejected':True,'reason':reason})
 return controls

def main():
 retail,body,support,entries,comparison,comparisons,rom,layout=execution.prepare()
 digest=hashlib.sha256();all_cases=list(execution.cases());calls=0
 for case in all_cases:
  a=execution.run(retail,support,entries,case);b=execution.run(body,support,entries,case)
  assert a==b;calls+=a['support_calls'];digest.update(json.dumps(a,sort_keys=True).encode()+b'\n')
 faults=controls(retail,body,support,entries,rom,layout)
 assert len(all_cases)==606 and len(faults)==23 and all(x['rejected'] for x in faults)
 report={'matches':True,'comparison':comparison,'support_comparisons':comparisons,'paired_cases':606,'principal_executions':1212,'support_calls_per_image':calls,'digest':digest.hexdigest(),'controls':faults,'source_mutants_rejected':8,'saved_fpu_faults_rejected':12,'guest_access_faults_rejected':3,'positive_retail_and_candidate_before_every_fault':True,'candidate_positive_after_every_fault':True,'complete_support_instruction_bytes':sum(len(b) for a,b in support if a in entries),'initialized_support_bytes':sum(len(b) for a,b in support if a not in entries),'checker_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'runner_sha256':hashlib.sha256((ROOT/'tools/projectile_spawn_execution.py').read_bytes()).hexdigest(),'limitations':['Allocation alone uses an argument-checked ABI boundary with synthetic actors; all six matching support units execute.','Allocation-time position mutations are adversarial fixtures, not asserted allocator behavior.','Finite valid resource kinds and mapped objects only; unsafe kinds, arbitrary aliasing and full gameplay remain unverified.','Stack interiors are bounded and preserved integer/FPU registers are checked; stack byte identity is not claimed.']}
 (ROOT/'build/projectile-spawn-check/report.json').write_text(json.dumps(report,indent=2)+'\n')
 print('Projectile: 1040 complete bytes, 606 paired cases, 23 actual rejected faults; all checks passed',flush=True)

if __name__=='__main__':main()
