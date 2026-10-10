"""Check the complete fatal formatter and its nonreturning CPU path.

String and number helpers execute freshly matching C. The output boundary and
diagnostic report use returning ABI stubs; rendering and report internals are
outside this formatter check.
"""

import hashlib
import json
from pathlib import Path

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs

from check_actor_group_path import machine, word
from check_error_formatters import CALLER_SAVED
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS, CANDIDATE_BLOCKS
from compare_startup import SymbolLayoutSnapshot, compare_block
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate

ENTRY, WAIT, OUTPUT, REPORT = 0x800496E0, 0x80049898, 0x80048DC0, 0x8004C6E0
FORMAT, STRINGS, STACK = 0x80201010, 0x80210010, 0x80300000
FRAME, MESSAGE = 360, STACK-360+100
HELPER_STACK = 0x100
SOURCE = 'src/game/renderer_diagnostics/fatal_format.c'


def oracle(fmt, values):
    output = bytearray()
    i = arg = 0
    while i < len(fmt):
        c = fmt[i]
        i += 1
        if c != 37:
            output.append(c)
            continue
        assert i < len(fmt), 'Dangling percent is outside these cases'
        spec = fmt[i]
        i += 1
        value = values[arg]
        arg += 1
        if spec in b'Cc':
            output.append((value >> 24) & 255)
        elif spec == ord('s'):
            output.extend(value)
        elif spec == ord('d'):
            signed = value & 0xFFFFFFFF
            signed -= 0x100000000 if signed & 0x80000000 else 0
            assert signed != -0x80000000, 'INT_MIN decimal is outside this oracle'
            output.extend(str(signed).encode())
        elif spec == ord('x'):
            output.extend(format(value & 0xFFFFFFFF, 'X').encode())
    assert len(output) < 256
    return bytes(output)


def cases():
    yield b'', ()
    yield b'plain text', ()
    for size in (1, 254, 255):
        yield b'A'*size, ()
        yield b'%s', (b'B'*size,)
    yield b'%s/%d/%x/%C/%c', (b'name', -123, 0xFEDCBA98, 0x41112233, 0x7A987654)
    yield b'%C%c%d%x%s', (0x41000000, 0x42000000, -7, 0x10, b'end')
    yield b'%q%d%z%s', (0x12345678, -17, 0, b'next')
    yield b'%%/%d', (0x12345678, 42)
    for spec in b'Cc':
        for value in range(256):
            yield b'%' + bytes([spec]) + b'!', (value << 24 | 0x123456,)
    for value in (0, 1, -1, 9, 10, 99, 100, -999, 32767, -32768,
                  0x7FFFFFFF, -0x7FFFFFFF, 0x80000000, 0xFFFFFFFF):
        yield b'%x', (value,)
        if value & 0xFFFFFFFF != 0x80000000:
            yield b'%d', (value,)
    for spec in range(1, 256):
        if spec not in b'Ccdsx':
            yield b'%' + bytes([spec]) + b'%C/%d', (0xABCDEF01, 0x51000000, -37)
    for value in (1, 65, 127, 128, 255):
        yield b'[%s]', (bytes([value])*200,)


def run(code, support, case):
    fmt, values = case
    expected = oracle(fmt, values)
    uc, write, _ = machine([(ENTRY, code)], support)
    write(STACK-FRAME-HELPER_STACK-16, b'\xA7'*16 + b'\xA5'*(HELPER_STACK+FRAME+128))
    guarded_format = b'\xA9'*16 + fmt + b'\0' + b'\xB9'*16
    write(FORMAT-16, guarded_format)
    inputs, arguments = [], []
    for index, value in enumerate(values):
        if isinstance(value, bytes):
            address = STRINGS + index*0x400
            guarded = b'\xAA'*16 + value + b'\0' + b'\xBB'*16
            write(address-16, guarded)
            inputs.append((address-16, guarded))
            arguments.append(address)
        else:
            arguments.append(value & 0xFFFFFFFF)
    arguments += [0xDEADBEEF]*max(0, 3-len(arguments))
    for register, value in zip((regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3), arguments):
        uc.reg_write(register, value)
    stack_arguments = b''.join(word(x) for x in arguments[3:])
    write(STACK+16, stack_arguments)
    uc.reg_write(regs.UC_MIPS_REG_A0, FORMAT)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA1234000)
    saved = {name: uc.reg_read(getattr(regs, 'UC_MIPS_REG_'+name))
             for name in ('S0','S1','S2','S3','S4','S5','S6','S7','FP','RA')}
    trace, stopped = [], [0]
    code_ranges = [(ENTRY, ENTRY+512)] + [(address,address+len(data)) for address,data in support
                                        if address not in (0x8007BB1C, 0x8009542C)]
    read_ranges = [(STACK-FRAME-HELPER_STACK, STACK+16+len(stack_arguments)), (FORMAT, FORMAT+len(fmt)+1)]
    read_ranges += [(address+16,address+len(data)-16) for address,data in inputs]
    read_ranges += [(address,address+len(data)) for address,data in support]

    def read(address, size):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, size))

    def inside(address, size, bounds):
        address = (address & 0x1FFFFFFF) | 0x80000000
        return any(start <= address and address+size <= end for start,end in bounds)

    def guard_read(uc, access, address, size, value, user):
        assert inside(address,size,read_ranges), ('read bounds', hex(address), size)

    def guard_write(uc, access, address, size, value, user):
        assert inside(address,size,[(STACK-FRAME-HELPER_STACK,STACK+16)]), ('write bounds',hex(address),size)
        if size == 1:
            assert inside(address,size,[(STACK-FRAME-HELPER_STACK,STACK-FRAME),
                                        (MESSAGE,MESSAGE+256)]), 'Message write escaped its frame extent'

    def boundary(uc, address, size, user):
        if address == WAIT:
            stopped[0] += 1
            assert len(trace) == 2, 'Wait occurred before both calls'
            if stopped[0] == 3:
                uc.emu_stop()
            return
        if address == OUTPUT:
            a0, a1 = uc.reg_read(regs.UC_MIPS_REG_A0), uc.reg_read(regs.UC_MIPS_REG_A1)
            assert a0 == 0x8009542C and a1 == MESSAGE
            assert read(a0,7) == b'\n\n%s\n\n\0'
            assert read(a1,len(expected)+1) == expected+b'\0'
            trace.append(['output',expected.hex()])
        elif address == REPORT:
            assert trace == [['output',expected.hex()]], 'Report order changed'
            trace.append(['report'])
        else:
            assert inside(address,size,code_ranges), ('code bounds',hex(address))
            return
        resume = uc.reg_read(regs.UC_MIPS_REG_RA)
        for index, register in enumerate(CALLER_SAVED):
            uc.reg_write(register,0xB2340000+index*257)
        uc.reg_write(regs.UC_MIPS_REG_PC,resume)

    uc.hook_add(UC_HOOK_MEM_READ,guard_read)
    uc.hook_add(UC_HOOK_MEM_WRITE,guard_write)
    uc.hook_add(UC_HOOK_CODE,boundary)
    uc.emu_start(ENTRY,0,count=20000)
    assert stopped[0] == 3, 'Fatal formatter did not remain in its wait loop'
    assert uc.reg_read(regs.UC_MIPS_REG_SP) == STACK-FRAME
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xA1234000
    assert read(MESSAGE,len(expected)+1) == expected+b'\0'
    assert read(MESSAGE+256,4) == b'\xA5'*4
    assert read(STACK-FRAME-HELPER_STACK-16,16) == b'\xA7'*16
    assert read(STACK+64,16) == b'\xA5'*16
    assert read(FORMAT-16,len(guarded_format)) == guarded_format
    assert read(STACK+16,len(stack_arguments)) == stack_arguments
    for address,data in inputs:
        assert read(address,len(data)) == data
    for name, offset in [('S0',24),('S1',28),('S2',32),('S3',36),('S4',40),('S5',44),('S6',48),('S7',52),('FP',56),('RA',60)]:
        assert read(STACK-FRAME+offset,4) == word(saved[name]), ('Saved register',name)
    return trace


def main():
    target = (ROOT/'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    family = 'renderer-fatal-format-execution'
    comparison = compare_block('fatal',SOURCE,ENTRY,0x4A2E0,0x4A4E0,target,family,layout)
    assert comparison['matches'], 'Complete formatter instruction match required'
    binary = ROOT/'build'/family/'fatal/fatal.bin'
    compiled = binary.read_bytes()
    retail = target[0x4A2E0:0x4A4E0]
    support, comparisons = [], {}
    for name in ('game_memory','game_number_format','fixed_geometry_setup'):
        _,source,start,end = next(x for x in MATCHING_BLOCKS+CANDIDATE_BLOCKS if x[0]==name)
        q = compare_block(name,source,start,start-0x80000000+0xC00,end-0x80000000+0xC00,target,family,layout)
        assert q['matches']
        comparisons[name] = q
        support.append((start,(ROOT/'build'/family/name/(name+'.bin')).read_bytes()))
    data_reports = {}
    for source in ('src/game/formatting/digits.c','src/game/renderer_diagnostics/fatal_message.c'):
        owned = source_sections(source)
        q = compare_unit(source,owned,target,layout)
        assert q['matches']
        data_reports[source] = q
        sections,_ = elf_sections_and_symbols(ROOT/'build/data-comparison'/Path(source).with_suffix('')/'compiled.elf')
        support += [(x['vram'],sections[x['section']]['bytes']) for x in owned]
    digest, count = hashlib.sha256(),0
    all_cases = list(cases())
    for case in all_cases:
        expected, actual = run(retail,support,case),run(compiled,support,case)
        assert expected == actual
        digest.update(json.dumps([case[0].hex(),actual]).encode())
        count += 1
        if count % 200 == 0:
            print('Compared fatal formatter cases:',count,flush=True)
    # Each fault must be rejected by the behavior/memory oracle, not by byte equality.
    mutations = []
    for name, offset, replacement, case in [
        ('character_low_byte',0xC4,0x92220003,(b'%C',(0x41112233,))),
        ('missing_terminator',0x198,0,(b'plain',())),
        ('wrong_message_base',0x19C,0x27B00060,(b'plain',())),
        ('skipped_report',0x1B0,0,(b'plain',())),
        ('wait_returns',0x1B8,0x1000000D,(b'plain',())),
    ]:
        positive = run(retail,support,case)
        assert run(compiled,support,case) == positive
        modified = bytearray(compiled)
        modified[offset:offset+4] = word(replacement)
        try:
            run(bytes(modified),support,case)
        except (AssertionError,ValueError) as error:
            mutations.append(dict(name=name,rejected=True,reason=str(error)))
        else:
            raise AssertionError('Formatter mutation escaped: '+name)
        assert run(compiled,support,case) == positive
    report = dict(matches=True,cases=count,paired_executions=count*2,
                  trace_sha256=digest.hexdigest(),comparison=comparison,
                  support_comparisons=comparisons,data_comparisons=data_reports,
                  mutations=mutations,checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  positive_control_executions=len(mutations)*3,
                  limits=['Complete 512-byte function, including the unreachable epilogue, matches.',
                          'Output and report calls use ABI-clobbering returning stubs.',
                          'The nonreturning path checks the saved-register image and active stack frame.',
                          'Strings and messages up to 255 bytes are exercised; buffer overflow, dangling percent and INT_MIN decimal are omitted.',
                          'The original declared buffer capacity and translation-unit boundary remain unknown.',
                          'FPU register effects, report internals, rendering and complete gameplay are not exercised.'])
    (ROOT/'build'/family/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print('Fatal formatter checked:',count,'paired cases;',len(mutations),'rejected faults',flush=True)


if __name__ == '__main__':
    main()
