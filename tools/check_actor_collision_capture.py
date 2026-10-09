"""Verify the full collision body/table, bounded execution and actual faults."""
from pathlib import Path
import hashlib,json
from unicorn import UcError
import collision_capture_execution as h

ROOT=Path(__file__).resolve().parent.parent

def controls(retail,body,support,entries,rom,layout):
    d=h.D;base=(ROOT/'src/game/collisions/capture.c').read_text();cases=list(h.cases())
    changes={
     'other_kind_guard':('second->resource24->actorKind < 4','second->resource24->actorKind < 5'),
     'threshold_edge':('1000 < (angleDifference & 0x7ff)','999 < (angleDifference & 0x7ff)'),
     'callback_flag_clear':('second->flags14 &= ~0x40;','second->flags14 |= 0x40;'),
     'callback_installation':('second->callback44 = func_80029E5C','second->callback44 = func_80029154'),
     'timer_value':('second->timer0E = 999','second->timer0E = 998'),
     'copied_height':('*(TextValue3 *)second->position = *(TextValue3 *)first->position;','second->position[0] = first->position[0]; second->position[1] = first->position[1]; second->position[2] = first->position[1];'),
     'sine_call_removed':('func_8003CC58(second->angle08);',''),
     'attachment_target':('func_80039C5C(second->objectIndex, first->objectIndex);','func_80039C5C(second->objectIndex, second->objectIndex);'),
     'spawn_initializer_argument':('(spawned, 1);','(spawned, 0);'),
     'return_value':('  return 0;','  return 1;'),
    }

    out=d/'fault-controls';out.mkdir(exist_ok=True);controls=[]
    for name,(old,new) in changes.items():
        assert old in base,(name,old)
        path=out/(name+'.c');path.write_text(base.replace(old,new,1))
        code,data,q=h.compile_one('fault_'+name,path,rom,layout);assert code!=body
        adjusted=[(a,data if a==0x80090038 else b) for a,b in support]
        for i,case in enumerate(cases):
            try:h.run(code,adjusted,entries,case)
            except (AssertionError,UcError) as error:
                reason=str(error)[:600]
                assert h.run(body,support,entries,case)==h.run(retail,support,entries,case)
                try:h.run(code,adjusted,entries,case)
                except (AssertionError,UcError):pass
                else:raise AssertionError(('Fault stopped reproducing',name))
                h.run(body,support,entries,case)
                controls.append(dict(kind='source',name=name,case_index=i,rejected=True,reason=reason,comparison=q));break
        else:raise AssertionError(('Undetected semantic fault',name))
        print('Rejected source fault',name,controls[-1]['case_index'],flush=True)
    case=next(x for x in cases if x['kind']==25 and x['other_kind']==0 and x['first_animation']==0)
    for index in range(20,32):
        assert h.run(body,support,entries,case)==h.run(retail,support,entries,case)
        try:h.run(body,support,entries,case,fpu_fault=index)
        except AssertionError as error:controls.append(dict(kind='saved_fpu',register=index,rejected=True,reason=str(error)[:200]))
        else:raise AssertionError(('Undetected saved FPU corruption',index))
        h.run(body,support,entries,case)
    for address in [0,h.FIRST-4,0x80400100]:
        assert h.run(body,support,entries,case)==h.run(retail,support,entries,case)
        try:h.run(body,support,entries,case,input_fault=address)
        except (AssertionError,UcError) as error:controls.append(dict(kind='access',input=hex(address),rejected=True,reason=str(error)[:200]))
        else:raise AssertionError(('Undetected guest input fault',hex(address)))
        h.run(body,support,entries,case)
    layout.verify();return controls

def main():
    retail,body,support,entries,comparison,proof,rom,layout=h.prepare()
    digest=hashlib.sha256();calls=loader_calls=0;cases=list(h.cases())
    for i,case in enumerate(cases):
        a=h.run(retail,support,entries,case);b=h.run(body,support,entries,case);assert a==b
        calls+=a['support_calls'];loader_calls+=a['unowned_retail_loader_calls'];digest.update(json.dumps([case,a],sort_keys=True).encode()+b'\n')
        if i%100==0:print('Collision capture pairs',i+1,flush=True)
    faults=controls(retail,body,support,entries,rom,layout)
    assert len(cases)==838 and len(faults)==25 and all(x['rejected'] for x in faults)
    report=dict(matches=True,comparison=comparison,support_comparisons=proof,paired_cases=len(cases),principal_executions=2*len(cases),support_calls_per_image=calls,matching_support_calls_per_image=calls-loader_calls,unowned_retail_loader_calls_per_image=loader_calls,digest=digest.hexdigest(),controls=faults,source_mutants_rejected=10,saved_fpu_faults_rejected=12,guest_access_faults_rejected=3,positive_retail_and_candidate_for_every_fault=True,candidate_positive_after_every_fault=True,complete_matching_support_instruction_bytes=sum(len(b) for a,b in support if a in entries['symbols'] and a!=0x8004bd00),unowned_retail_loader_instruction_bytes=904,initialized_support_bytes=sum(len(b) for a,b in support if not any(lo<=a<hi for lo,hi in entries['ranges'])),checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),runner_sha256=hashlib.sha256((ROOT/'tools/collision_capture_execution.py').read_bytes()).hexdigest(),limitations=['Allocation, original actor callback, spawned initializer, fragment creation and sound playback use explicit synthetic caller-clobbering ABI boundaries.','Fourteen complete matching support units execute; an additional 904 unowned retail loader bytes execute only on valid cache hits.','Finite valid tracks/models/object indices and explicit callback mutations only; asset misses, unsafe indices, audio hardware, fragment effects and full gameplay are excluded.','Stack interiors are bounded and ABI checked, not claimed byte-identical.'])
    (h.D/'report.json').write_text(json.dumps(report,indent=2)+'\n');print('Collision: 1712 complete code bytes, 96 generated table bytes, 838 paired cases, 25 rejected faults',flush=True)

if __name__=='__main__':main()
