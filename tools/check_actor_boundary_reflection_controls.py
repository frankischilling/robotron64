"""Verify reflection semantic faults and executed saved-FPU corruptions are rejected."""
from pathlib import Path
import hashlib
import json
import struct
import check_actor_boundary_reflection as k


def main():
    r,d=k.R,k.D;target=(r/'baseroms/us/baserom.z64').read_bytes();k.validate(target)
    layout=k.SymbolLayoutSnapshot();support=[];code_ranges=[];data_ranges=[];comparisons={}
    for name in k.SUPPORT:
        _,source,start,end=next(row for row in k.MATCHING_BLOCKS if row[0]==name)
        report=k.compare_block(name,source,start,start-0x80000000+0xc00,end-0x80000000+0xc00,target,family='boundary-reflection-controls-support',layout=layout)
        assert report['matches'];comparisons[name]=report
        directory=r/'build/boundary-reflection-controls-support'/name
        support.append((start,(directory/(name+'.bin')).read_bytes()));code_ranges.append((start,end))
        sections,_=k.elf_sections_and_symbols(directory/(name+'.elf'))
        for owned in k.source_sections(source):
            if owned['rom'] is not None:
                data=sections[owned['section']]['bytes'];support.append((owned['vram'],data));data_ranges.append((owned['vram'],owned['vram']+len(data)))
    data_comparisons={}
    for source in ['src/game/actor_groups/direction_table.c','src/game/object_angle_setter_constants.c']:
        owned=k.source_sections(source);report=k.compare_unit(source,owned,target,layout);assert report['matches'];data_comparisons[source]=report
        sections,_=k.elf_sections_and_symbols(r/'build/data-comparison'/Path(source).with_suffix('')/'compiled.elf')
        for record in owned:
            data=sections[record['section']]['bytes'];support.append((record['vram'],data));data_ranges.append((record['vram'],record['vram']+len(data)))
    pi=struct.unpack('>f',next(data for address,data in support if address==0x80094c20)[:4])[0]
    base_path=r/'src/game/actor_contacts/reflection.c';base=base_path.read_text()
    baseline=k.compare_block('baseline',str(base_path.relative_to(r)),k.ENTRY,0x192d8,0x198c8,target,family='boundary-reflection-controls',layout=layout)
    assert baseline['matches']
    baseline_bytes=(r/'build/boundary-reflection-controls/baseline/baseline.bin').read_bytes()
    out=d/'source-mutations';out.mkdir(parents=True,exist_ok=True)
    mutations=[
     ('lower_y_sign','actor->field70 = BOUNCE_ABS(actor->field70);','actor->field70 = -BOUNCE_ABS(actor->field70);',(0,0,-30000,17,-29,0,17,65000)),
     ('upper_inclusive','actor->position[1] >= (30000 - actor->unknown00[3])','actor->position[1] > (30000 - actor->unknown00[3])',(0,0,30000,17,29,0,17,65000)),
     ('diagonal_second_margin','limit -= actor->unknown00[3];','limit -= 0;',(1,25000,25000,-17,29,1,17,65000)),
     ('diagonal_cutoff','angle < 3096','angle < 3072',(0,25000,25000,-17,29,1,17,65000,(0,1000,-30000))),
     ('final_heading_arguments','actor->angle08 = func_8003CD4C(actor->field70, actor->field6C);','actor->angle08 = func_8003CD4C(actor->field6C, actor->field70);',(0,30000,0,17,29,0,17,65000)),
    ]
    results=[]
    for name,old,new,case in mutations:
        assert base.count(old)==1,(name,base.count(old))
        text=base.replace(old,new);path=out/(name+'.c');path.write_text(text)
        reference=k.run(target[0x192d8:0x198c8],support,code_ranges,data_ranges,case,pi)
        positive=k.run(baseline_bytes,support,code_ranges,data_ranges,case,pi);assert positive==reference
        comparison=k.compare_block(name,str(path.relative_to(r)),k.ENTRY,0x192d8,0x198c8,target,family='boundary-reflection-controls',layout=layout)
        code=(r/'build/boundary-reflection-controls'/name/(name+'.bin')).read_bytes()
        try:k.run(code,support,code_ranges,data_ranges,case,pi)
        except AssertionError as error:
            reason=str(error)
            assert ' bounds' not in reason,('Mutation rejected by access guard instead of semantic oracle',name,reason)
            results.append(dict(name=name,rejected=True,positive_pair_passed=True,case=case,reason=reason,source_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),comparison=comparison))
        else:raise AssertionError(('Independent oracle failed to reject mutation',name))
    layout.verify()
    receipt=dict(mutations=results,support_comparisons=comparisons,data_comparisons=data_comparisons,
                 baseline_comparison=baseline,source_ownership_added=0,checker_sha256=hashlib.sha256(Path(k.__file__).read_bytes()).hexdigest())
    (d/'mutation-controls.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print('Source mutations rejected:',[x['name'] for x in results],flush=True)

    # Change an executed retail NOP, leaving the full prologue and state behavior intact.
    probe_case=(0, -30000, -30000, 17, -29, 1, 17, 65000)
    nop_offset=0x800187C0-k.ENTRY
    assert baseline_bytes[nop_offset:nop_offset+4]==k.word(0)
    fpu_controls=[]
    original_machine=k.machine
    probe_hits=[]
    def machine_with_probe(code,support):
        uc,write,execute=original_machine(code,support)
        from unicorn import UC_HOOK_CODE
        uc.hook_add(UC_HOOK_CODE,lambda uc,address,size,user:probe_hits.append(address),
                    begin=0x800187C0,end=0x800187C0)
        return uc,write,execute
    k.machine=machine_with_probe
    for target_register in range(20,32):
        source_register=20+(target_register-19)%12
        probe_hits.clear()
        positive=k.run(baseline_bytes,support,code_ranges,data_ranges,probe_case,pi)
        assert probe_hits==[0x800187C0],('Positive probe instruction did not execute',probe_hits)
        instruction=0x46000006|(source_register<<11)|(target_register<<6)
        mutated=baseline_bytes[:nop_offset]+k.word(instruction)+baseline_bytes[nop_offset+4:]
        probe_hits.clear()
        try:
            k.run(mutated,support,code_ranges,data_ranges,probe_case,pi)
        except AssertionError as error:
            assert error.args[0][0]=='Reflection saved FPU registers',error
            assert probe_hits==[0x800187C0],('Corruption probe instruction did not execute',probe_hits)
            fpu_controls.append(dict(target_register=target_register,source_register=source_register,
                                     rejected=True,positive_result=positive['result'],reason=str(error),
                                     positive_probe_executions=1,negative_probe_executions=len(probe_hits),
                                     executed_probe_vram='0x800187C0',instruction_hex=f'{instruction:08x}'))
        else:
            raise AssertionError(('FPU register copy escaped readback',target_register,source_register))
    k.machine=original_machine
    layout.verify()
    (d/'fpu-corruption-controls.json').write_text(json.dumps(dict(
        controls=fpu_controls, distinct_saved_fpu_seeds=[hex(0x3f800101+i*257) for i in range(12)],
        source_ownership_added=0, checker_sha256=hashlib.sha256(Path(k.__file__).read_bytes()).hexdigest()),indent=2)+'\n')
    print('Saved FPU corruption probes rejected:',len(fpu_controls),flush=True)


if __name__ == "__main__":
    main()
