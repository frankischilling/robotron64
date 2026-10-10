"""Verify natural movie arrays and bounded retail consumer behavior."""
import hashlib,itertools,json
from pathlib import Path
from unicorn import UcError
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block,SymbolLayoutSnapshot
from compare_data import compare_unit,comparison_directory
from owned_sections import elf_sections_and_symbols,load_owned_sections,source_sections
from compiler import compile_source
from movie_literal_execution import EXPECTED,LIMITS,run
from check_actor_group_path import word
from rom import ROOT,validate

FAMILY='movie-literals'
BLOCKS=('movie_commands','movie_files','movie_callback','movie_update','game_memory','game_string_append')


def prepare():
    rom=(ROOT/'baseroms/us/baserom.z64').read_bytes();validate(rom);layout=SymbolLayoutSnapshot()
    records=[r for r in load_owned_sections() if r['evidence']=='docs/movie-literals.md']
    assert len(records)==14 and sum(r['size'] for r in records)==210
    original,compiled,proof=[],[],{}
    for name in BLOCKS:
        _,source,start,end=next(r for r in MATCHING_BLOCKS if r[0]==name)
        report=compare_block(name,source,start,start-0x7FFFF400,end-0x7FFFF400,rom,FAMILY,layout)
        assert report['matches'],name;proof[name]=report
        original.append((start,rom[start-0x7FFFF400:end-0x7FFFF400]))
        compiled.append((start,(ROOT/'build'/FAMILY/name/(name+'.bin')).read_bytes()))
    originals,arrays=[],[]
    for r in records:
        report=compare_unit(r['source'],source_sections(r['source']),rom,layout);assert report['matches'];proof[r['source']]=report
        d=comparison_directory(r['source']);sections,symbols=elf_sections_and_symbols(d/'compiled.elf');raw,raw_symbols=elf_sections_and_symbols(d/'raw.o')
        a=r['vram'];data=sections[r['section']]['bytes'];retail=rom[r['rom']:r['rom']+r['size']]
        assert data==retail==dict(EXPECTED)[a]
        assert symbols[f'D_{a:08X}']['value']==a and raw_symbols[f'D_{a:08X}']['value']==0
        assert not any(raw['.data']['bytes'][r['size']:])
        originals.append((a,retail));arrays.append((a,data))
    probe=ROOT/'build'/FAMILY/'extent-probe.c'
    probe.write_text(''.join('#include "'+str(ROOT/r['source'])+'"\n' for r in records)+'unsigned int movie_probe_sizes[] = {'+','.join(f'sizeof(D_{a:08X})' for a,data in EXPECTED)+'};\n')
    obj=probe.with_suffix('.o');compile_source(probe,obj);sections,symbols=elf_sections_and_symbols(obj)
    at=symbols['movie_probe_sizes']['value'];assert sections['.data']['bytes'][at:at+56]==b''.join(word(len(data)) for a,data in EXPECTED)
    layout.verify();return original,compiled,originals,arrays,proof


def cases():
    out=[]
    for kind,(entry,offset,limit,address) in LIMITS.items():
        counts=list(range(limit))+[limit]
        if kind in ('prop','cycle'):counts += [limit+1]
        props=(0,9) if kind=='primary' else (0,1) if kind=='callback' else (-32769,32768) if kind=='prop' else (0,17)
        for count,prop,value in itertools.product(counts,props,(-65537,0,65539)):
            out.append((kind,count,prop,value,len(out)+1))
    names=(b'',b'INTRO',b'intro.mov',b'INTRO.SRC',b'a.b.c',b'.MOV',b'PATH\\track.mov',b'abcdefghijklmnopqrstuvwx',b'Movie_Name')
    for name,slot,channels in itertools.product(names,(0,24),((0,0),(1,0),(0,1),(2,-3))):
        out.append(('file',name,slot,False,*channels,len(out)+1))
    for slot in (0,12,24):out.append(('file',b'cached.name',slot,True,1,1,len(out)+1))
    for name in (b'INTRO',b'a.b.c'):out.append(('file',name,None,False,0,0,len(out)+1))
    for erase in (0,1,-1,2):out.append(('update',erase,len(out)+1))
    return out


def main():
    retail,compiled,originals,arrays,proof=prepare();fixtures=cases();digest=hashlib.sha256()
    for case in fixtures:
        expected=run(retail,originals,case);actual=run(compiled,arrays,case)
        assert expected==actual,case;digest.update(json.dumps(actual,sort_keys=True).encode())
    controls=[]
    for a,data in EXPECTED:
        if a in {v[3] for v in LIMITS.values()}:
            kind=next(k for k,v in LIMITS.items() if v[3]==a);case=(kind,LIMITS[kind][2],0,17,777)
        elif a==0x8008F8C8:case=('file',b'INTRO',None,False,0,0,777)
        elif a in (0x8008F914,0x8008F920):case=('update',1,777)
        else:case=('file',b'INTRO' if a==0x8008F8C0 else b'a.b.c',0,False,1,1,777)
        for off in (0,len(data)-1):
            changed=bytearray(data);changed[off]^=1
            fault=[(address,bytes(changed) if address==a else b) for address,b in arrays]
            assert run(retail,originals,case)==run(compiled,arrays,case)
            try:run(compiled,fault,case)
            except (AssertionError,UcError,ValueError):controls.append(dict(address=a,offset=off,rejected=True))
            else:raise AssertionError(('Missed character/terminator control',hex(a),off))
            assert run(compiled,arrays,case)==run(retail,originals,case)
    guest_faults=[]
    case=('file',b'INTRO',0,False,1,1,999)
    for fault in [('saved_fpu',i) for i in range(20,32)]+[(kind,0) for kind in ('read_guard','write_guard','code_guard')]:
        assert run(retail,originals,case)==run(compiled,arrays,case)
        try:run(compiled,arrays,case,fault=fault)
        except (AssertionError,UcError,ValueError):guest_faults.append(dict(kind=fault[0],item=fault[1],rejected=True))
        else:raise AssertionError(('Missed guest fault',fault))
        assert run(compiled,arrays,case)==run(retail,originals,case)
    receipt=dict(matches=True,pairs=len(fixtures),executions=2*len(fixtures),initialized_bytes=210,new_instruction_bytes=0,consumer_instruction_bytes=4712,support_comparisons=proof,controls=controls,guest_faults=guest_faults,digest=digest.hexdigest(),checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),runner_sha256=hashlib.sha256((ROOT/'tools/movie_literal_execution.py').read_bytes()).hexdigest(),limitations=['Finite valid movie objects and signed argument boundaries only.','Allocation, release, fatal calls, labels and early update query use explicit caller-clobbering service boundaries.','Full playback, filesystem/cartridge I/O, arbitrary aliases and unsafe indices remain unproved.'])
    (ROOT/'build'/FAMILY/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print('Movie arrays:210 bytes;',len(fixtures),'guarded pairs;',len(controls),'character/terminator controls;',len(guest_faults),'guest faults rejected; all passed')


if __name__=='__main__':main()
