"""Compare and execute the complete excluded actor ring callback against retail.

Ten support units and their owned initialized sections are freshly compiled,
linked and matched. Passing this guard adds no ROM or function ownership.
"""

from pathlib import Path
import hashlib
import itertools
import json
import struct
from importlib.metadata import version
from capstone import Cs, CS_ARCH_MIPS, CS_MODE_MIPS32, CS_MODE_BIG_ENDIAN
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UcError
from unicorn import mips_const as regs

from rom import ROOT, validate
from check_actor_group_path import machine, word, SENTINEL
from compare_startup import compare_block, SymbolLayoutSnapshot
from compare_runtime import MATCHING_BLOCKS, CANDIDATE_BLOCKS, validate_candidate_ranges
from manifest import load_manifest
from owned_sections import source_sections, elf_sections_and_symbols
from actor_ring_model import (ACTOR, BOOT, ENTRY, FP_INPUT, FP_OUTPUT, RETURN,
                              STACK, initial, oracle)

SOURCE = 'src/game/actor_effects/ring.c'
FAMILY = 'actor-ring-execution'
OUTPUT = ROOT / 'build' / FAMILY
SUPPORT=('graphics_mode_dispatch','graphics_modes','graphics_pool','debug_noop','palette',
         'object_recovery_fixed_trig','short_sine','short_cosine','frame_transform','renderer_matrix_submit')
CALLS=(0x8004729C,0x80046774,0x80047048,0x80048DC0,0x8003C14C,0x8004D4B4,0x80047D88,
       0x8003CC88,0x8003CC58,0x8005FC20,0x8005FBB0,0x80047094)

def execute(code,support,owned,case,actor_override=None):
    data,info=initial(case);expected,allowed,expected_trace,result=oracle(data,case,info)
    fpu=[0x3F800101+i*257 for i in range(12)]
    boot=b''.join(word(x) for x in [0x3C08802A,0x35080000]+[0xC5000000|((i+20)<<16)|(i*4) for i in range(12)]+[0x3C088000,0x35086240,0x01000008,0])
    finish=b''.join(word(x) for x in [0x3C08802A,0x35080100]+[0xE5000000|((i+20)<<16)|(i*4) for i in range(12)]+[0x3C088000,0x35080080,0x01000008,0])
    uc,write,_=machine([(ENTRY,code),(BOOT,boot),(RETURN,finish)],support)
    for a,b in data.items():write(a,bytes(b))
    write(FP_INPUT,b''.join(word(v) for v in fpu));write(FP_OUTPUT,b'\x6D'*48)
    stack_start=STACK-0x420;stack=bytes((i*29+case[5])&255 for i in range(0x460));write(stack_start,stack)
    allowed += [(STACK-0x400,STACK),(FP_OUTPUT,FP_OUTPUT+48)]
    reads=[(a,a+len(b)) for a,b in data.items()]+[(STACK-0x400,STACK),(FP_INPUT,FP_INPUT+48)]
    reads += [(a,a+len(b)) for a,b in owned]
    executable=[(ENTRY,ENTRY+len(code)),(BOOT,BOOT+len(boot)),(RETURN,RETURN+len(finish))]
    executable += [(a,a+len(b)) for a,b in support if a not in {x[0] for x in owned}]
    saved={getattr(regs,'UC_MIPS_REG_'+name):uc.reg_read(getattr(regs,'UC_MIPS_REG_'+name)) for name in ('S0','S1','S2','S3','S4','S5','S6','S7','FP')}
    uc.reg_write(regs.UC_MIPS_REG_GP,0xABCD1234);uc.reg_write(regs.UC_MIPS_REG_RA,RETURN)
    uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS, uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | (1 << 29))
    uc.reg_write(regs.UC_MIPS_REG_A0,ACTOR if actor_override is None else actor_override)
    trace=[];touched=set();instruction_count=[0]
    def memory_write(uc,access,address,size,value,user):
        address|=0x80000000
        assert any(a<=address and address+size<=b for a,b in allowed),('Write guard',hex(address),size,case)
        if stack_start<=address<STACK:touched.update(range(address,address+size))
    def memory_read(uc,access,address,size,value,user):
        address|=0x80000000
        assert any(a<=address and address+size<=b for a,b in reads),('Read guard',hex(address),size,case)
    def code_hook(uc,address,size,user):
        instruction_count[0]+=1
        assert address==SENTINEL or any(a<=address and address+size<=b for a,b in executable),('Escaped code',hex(address),case)
        if address in CALLS:
            args=[uc.reg_read(regs.UC_MIPS_REG_A0+i) for i in range(3)]
            if address in (0x8004729C,0x8003CC88,0x8003CC58,0x8005FC20,0x8005FBB0,0x80047094):argument=args[0]
            elif address==0x8003C14C:
                assert STACK-0x400<=args[0]<=STACK-3,('Color pointer outside frame',hex(args[0]))
                argument=('color',args[1])
            elif address==0x8004D4B4:
                assert STACK-0x400<=args[2]<=STACK-12,('Relative pointer outside frame',hex(args[2]))
                raw=bytes(uc.mem_read(args[2]&0x1FFFFFFF,12));argument=(args[0],args[1],struct.unpack('>3i',raw))
            elif address==0x80047D88:argument=(args[0],args[1])
            elif address==0x80048DC0:
                assert args[0]==0x80095280,('Unexpected warning pointer',hex(args[0]))
                argument='warning'
            else:argument=None
            trace.append((address,argument))
    uc.hook_add(UC_HOOK_MEM_WRITE,memory_write);uc.hook_add(UC_HOOK_MEM_READ,memory_read);uc.hook_add(UC_HOOK_CODE,code_hook)
    uc.emu_start(BOOT,0,count=100000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC)==SENTINEL,'No return'
    assert uc.reg_read(regs.UC_MIPS_REG_V0)==result,('Return value',case)
    assert uc.reg_read(regs.UC_MIPS_REG_SP)==STACK and uc.reg_read(regs.UC_MIPS_REG_GP)==0xABCD1234,'SP/GP'
    assert all(uc.reg_read(k)==v for k,v in saved.items()),'Integer saved registers'
    assert bytes(uc.mem_read(FP_OUTPUT&0x1FFFFFFF,48))==b''.join(word(v) for v in fpu),'Saved FPU words'
    assert trace==expected_trace,('Call trace',case,next(((i,a,b) for i,(a,b) in enumerate(itertools.zip_longest(trace,expected_trace)) if a!=b),None))
    digest=hashlib.sha256()
    for a,b in expected.items():
        actual=bytes(uc.mem_read(a&0x1FFFFFFF,len(b)))
        assert actual==bytes(b),('Independent memory oracle',hex(a),case)
        digest.update(actual)
    actual=bytes(uc.mem_read(stack_start&0x1FFFFFFF,len(stack)))
    assert all(v==stack[i] for i,v in enumerate(actual) if stack_start+i not in touched),'Stack canary'
    digest.update(json.dumps(trace).encode());digest.update(word(result))
    return digest.hexdigest(),instruction_count[0]

def check_controls(candidate, retail, support, owned, target, layout):
    """Require actual guest faults to fail for their intended observable reason."""
    selected = (1, 137, 18, 3, 1, 1)
    results = []

    def reject(name, code, reason, case=selected, **kwargs):
        try:
            execute(code, support, owned, case, **kwargs)
        except (AssertionError, UcError) as error:
            message = str(error)
            assert reason in message, (name, reason, message)
            results.append({'name': name, 'rejected_by': message})
        else:
            raise AssertionError(('Control escaped the guard', name))

    source = (ROOT / SOURCE).read_text()
    variants = {
        'radius_bias': ('state * 150 + 150', 'state * 150 + 151', 'Independent memory oracle'),
        'alpha_bias': ('208 - state * 10', '207 - state * 10', 'Independent memory oracle'),
        'upper_height': ('color.position[1] = 300', 'color.position[1] = 301', 'Independent memory oracle'),
        'triangle_opcode': ('0xB1000000', '0xB2000000', 'Independent memory oracle'),
        'allocation_count': ('func_80047094(32)', 'func_80047094(33)', 'Call trace'),
    }
    for name, (old, new, reason) in variants.items():
        assert old in source, ('Mutation anchor changed', name)
        path = OUTPUT / 'control-sources' / (name + '.c')
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(source.replace(old, new))
        compare_block(name, path.relative_to(ROOT).as_posix(), ENTRY, 0x6E40, 0x7254,
                      target, FAMILY + '-controls', layout)
        code = (ROOT / 'build' / (FAMILY + '-controls') / name / (name + '.bin')).read_bytes()
        reject(name, code, reason)

    decoder = Cs(CS_ARCH_MIPS, CS_MODE_MIPS32 | CS_MODE_BIG_ENDIAN)
    instructions = list(decoder.disasm(candidate, ENTRY))
    slot = next(i.address - ENTRY for i in instructions[:35] if i.mnemonic == 'nop')
    assert candidate[slot:slot + 4] == b'\0' * 4
    for register in range(20, 32):
        bad = bytearray(candidate)
        bad[slot:slot + 4] = word(0x44880000 | (register << 11))
        reject('saved_fpu_f' + str(register), bytes(bad), 'Saved FPU words')

    for register, number in [('s' + str(i), 16 + i) for i in range(8)] + [('fp', 30)]:
        restore = next(i.address - ENTRY for i in reversed(instructions)
                       if i.mnemonic == 'lw' and i.op_str.startswith('$' + register + ','))
        bad = bytearray(candidate)
        bad[restore:restore + 4] = word((number << 11) | 0x25)
        reject('saved_' + register + '_epilogue', bytes(bad), 'Integer saved registers')
    for name, opcode, reason in (('saved_gp', 0x0000E025, 'SP/GP'),
                                 ('out_of_fixture_read', 0x8C000000, 'Read guard'),
                                 ('out_of_fixture_write', 0xAC000000, 'Write guard')):
        bad = bytearray(candidate); bad[slot:slot + 4] = word(opcode)
        reject(name, bytes(bad), reason)

    for label, code in (('retail', retail), ('candidate', candidate)):
        reject('null_actor_' + label, code, 'Read guard', actor_override=0)
        for first in (-1, 9801):
            execute(code, support, owned, (1, first, 18, 3, 1, 1), actor_override=0)
        results.append({'name': 'allocation_failure_invalid_actor_' + label, 'positive_cases': 2})
    jal = next(i.address - ENTRY for i in instructions if i.mnemonic == 'jal')
    bad = bytearray(candidate); bad[jal:jal + 4] = word(0x0C0AC000)
    reject('escaped_executable_range', bytes(bad), 'Escaped code')
    return results


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes(); validate(target)
    validate_candidate_ranges(CANDIDATE_BLOCKS, load_manifest())
    assert ("actor_ring", SOURCE, ENTRY, 0x80006654) in CANDIDATE_BLOCKS
    layout = SymbolLayoutSnapshot(); support = []; owned = []; reports = {}
    guard_inputs = {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest()
                    for path in (SOURCE, 'tools/check_actor_ring.py', 'tools/actor_ring_model.py',
                                 'tools/check_actor_group_path.py')}
    for name in SUPPORT:
        _, source, start, end = next(x for x in MATCHING_BLOCKS if x[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target, FAMILY, layout)
        assert report['matches'], ('Full support mismatch', name)
        reports[name] = report
        directory = OUTPUT / name
        support.append((start, (directory / (name + '.bin')).read_bytes()))
        sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
        for section in source_sections(source):
            if section['rom'] is not None:
                address, payload = section['vram'], sections[section['section']]['bytes']
                support.append((address, payload)); owned.append((address, payload))
                if name == 'short_sine':
                    import math, struct
                    assert payload == struct.pack('>1024h', *(math.floor(32767 * math.sin(i * math.pi / 2046)) for i in range(1024)))
        print('Fresh matched support', name, flush=True)
    comparison = compare_block('candidate', SOURCE, ENTRY, 0x6E40, 0x7254, target, FAMILY, layout)
    candidate = (OUTPUT / 'candidate/candidate.bin').read_bytes(); retail = target[0x6E40:0x7254]
    sections, symbols = elf_sections_and_symbols(OUTPUT / 'candidate/candidate.raw.o')
    natural_size = symbols['func_80006240']['size']
    assert not any(sections['.text']['bytes'][natural_size:]), 'Nonzero compiler alignment tail'
    cases = list(itertools.product((-0x80000000, -1000, -1, 0, 1, 19, 20, 21, 1000, 0x7FFFFFFF),
                                 (-1, 0, 137, 9800, 9801), (1, 18), (0, 3), (0, 1, 2), (0, 1, 2)))
    digest = hashlib.sha256(); max_instructions = 0
    for index, case in enumerate(cases):
        a, n = execute(retail, support, owned, case)
        b, m = execute(candidate, support, owned, case)
        assert a == b, ('Retail/candidate execution', case)
        digest.update(a.encode()); max_instructions = max(max_instructions, n, m)
        if (index + 1) % 300 == 0:
            print('Guarded actor ring pairs', index + 1, '/', len(cases), flush=True)
    controls = check_controls(candidate, retail, support, owned, target, layout)
    layout.verify()
    for report in list(reports.values()) + [comparison]:
        for path, expected in report['inputs_sha256'].items():
            assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == expected, ('Changed comparison input', path)
    for path, expected in guard_inputs.items():
        assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == expected, ('Changed guard input', path)
    receipt = dict(paired_cases=len(cases), principal_executions=len(cases) * 2,
        max_instructions=max_instructions, trace_sha256=digest.hexdigest(), controls=controls,
        retail_sha256=hashlib.sha256(retail).hexdigest(), candidate_sha256=hashlib.sha256(candidate).hexdigest(),
        natural_bytes=natural_size, candidate_frame=-int.from_bytes(candidate[2:4], 'big', signed=True),
        comparison=comparison, real_support=reports, guard_inputs_sha256=guard_inputs,
        emulator={'package': 'unicorn', 'version': version('unicorn')}, source_ownership_added=0,
        limits=['Candidate remains excluded until its complete instructions, size, layout and relocations match.',
                'Finite synthetic CPU, integer, vertex, matrix and display-word cases.',
                'Old graphics modes 1 and 18; frame vertex base 0; matrix cursor 7 and buffer 1.',
                'Real matched callees execute; no external ABI stubs are used.',
                'RSP/RDP execution, fatal formatting and full gameplay are not verified.',
                'Stack interiors are bounded and ABI-checked, not compared byte-for-byte.'])
    (OUTPUT / 'report.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('Actor ring guard:', len(cases), 'paired cases;', len(controls) - 2,
          'rejected mutations;', comparison['actual_size'], '/', comparison['expected_size'],
          'compiled bytes;', len(comparison['different_words']), 'differing words; no new ownership', flush=True)


if __name__ == '__main__':
    main()
