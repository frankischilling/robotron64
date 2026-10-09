"""Check the complete empty-platform block and its caller-visible V0 word.

Caller slices start after playback and stop on entry to the future-sound queue.
They establish the O32 fifth argument, without claiming menu/gameplay recovery.
"""

import hashlib
import itertools
import json
from importlib.metadata import version
from pathlib import Path

from capstone import Cs, CS_ARCH_MIPS, CS_MODE_MIPS32, CS_MODE_BIG_ENDIAN
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UC_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL
from compare_startup import compare_block, SymbolLayoutSnapshot
from compiler import compile_source
from owned_sections import elf_sections_and_symbols
from rom import ROOT, validate


LEAF, QUEUE, STACK = 0x8003BF84, 0x80036288, 0x80300000
LABEL, VALUE, CHOICES = 0x80201010, 0x80202010, 0x80203010
SITES = ((0x80027000, 0x80027030), (0x80027130, 0x8002715C),
         (0x80027260, 0x8002728C))
WORDS = (0, 1, 2, 17, 24, 31, 68, 0x7FFFFFFF, 0x80000000,
         0x80000001, 0xB4560000, 0xC0000010, 0xFEDCBA98, 0xFFFFFFFF)
NAMES = ('AT', 'V0', 'V1', 'A0', 'A1', 'A2', 'A3', 'T0', 'T1', 'T2',
         'T3', 'T4', 'T5', 'T6', 'T7', 'S0', 'S1', 'S2', 'S3', 'S4',
         'S5', 'S6', 'S7', 'T8', 'T9', 'K0', 'K1', 'GP', 'SP', 'FP',
         'RA', 'HI', 'LO')
REGISTERS = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in NAMES)


def leaf_run(body, incoming, argument, salt):
    uc, write, _ = machine([(LEAF, body)], [])
    for index, register in enumerate(REGISTERS):
        uc.reg_write(register, (0x76540000 + salt * 513 + index * 257) & 0xFFFFFFFF)
    uc.reg_write(regs.UC_MIPS_REG_V0, incoming)
    uc.reg_write(regs.UC_MIPS_REG_A0, argument)
    uc.reg_write(regs.UC_MIPS_REG_SP, STACK)
    uc.reg_write(regs.UC_MIPS_REG_RA, SENTINEL)
    before = [uc.reg_read(register) for register in REGISTERS]
    trace = []

    def code_guard(uc, address, size, data):
        trace.append(address)
        assert address in (LEAF, LEAF + 4, SENTINEL)

    def memory_guard(*args):
        raise AssertionError('Empty leaf accessed data memory')

    uc.hook_add(UC_HOOK_CODE, code_guard)
    uc.hook_add(UC_HOOK_MEM_READ | UC_HOOK_MEM_WRITE, memory_guard)
    uc.emu_start(LEAF, 0, count=5)
    # machine() stops before later code hooks run at the return sentinel.
    assert trace == [LEAF, LEAF + 4]
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    assert [uc.reg_read(register) for register in REGISTERS] == before
    return before


def caller_run(rom, body, site, queue_call, incoming, argument, selection):
    first, last = site - 4, queue_call + 8
    offset = first - 0x80000000 + 0xC00
    code = rom[offset:offset + last - first]
    uc, write, _ = machine([(first, code), (LEAF, body)], [])
    label = bytearray(40)
    label[12:16] = word(CHOICES)
    label[20:24] = word(VALUE)
    label[36:40] = word(argument)
    images = {LABEL - 16: b'\xA5' * 16 + label + b'\xB6' * 16,
              VALUE - 16: b'\xA5' * 16 + word(selection) + b'\xB6' * 16,
              CHOICES - 16: b'\xA5' * 16 + b''.join(word(0) + word(71 + i)
                                                     for i in range(3)) + b'\xB6' * 16,
              STACK - 16: b'\xC7' * 48,
              0x800761F8: word(0) + word(81) + word(0) + word(82)}
    for address, data in images.items():
        write(address, bytes(data))
    uc.reg_write(regs.UC_MIPS_REG_S0, LABEL)
    uc.reg_write(regs.UC_MIPS_REG_V0, incoming)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0x8007F123)
    saved = {register: uc.reg_read(register) for register in REGISTERS
             if register in tuple(getattr(regs, 'UC_MIPS_REG_' + name)
                                  for name in ('S0', 'S1', 'S2', 'S3', 'S4',
                                               'S5', 'S6', 'S7', 'SP', 'FP', 'GP'))}
    trace = []
    stopped = [False]
    readable = [(LABEL, LABEL + 40), (VALUE, VALUE + 4), (CHOICES, CHOICES + 24),
                (0x800761F8, 0x80076208)]

    def memory_guard(uc, access, address, size, value, data):
        address |= 0x80000000
        if access == UC_MEM_WRITE:
            assert address == STACK + 16 and size == 4
        else:
            assert any(start <= address and address + size <= end
                       for start, end in readable)

    def code_guard(uc, address, size, data):
        assert address == QUEUE or address in (LEAF, LEAF + 4) or first <= address < last
        trace.append(address)
        if address == LEAF:
            assert uc.reg_read(regs.UC_MIPS_REG_A0) == argument
            assert uc.reg_read(regs.UC_MIPS_REG_V0) == incoming
            assert uc.reg_read(regs.UC_MIPS_REG_RA) == site + 8
        elif address == site + 8:
            assert uc.reg_read(regs.UC_MIPS_REG_V0) == incoming
        elif address == QUEUE:
            expected_sound = 81 + (selection & 1) if site == SITES[0][0] else 71 + selection
            assert [uc.reg_read(register) for register in
                    (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                     regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)] == [expected_sound, 0, 1, 0]
            assert bytes(uc.mem_read((STACK + 16) & 0x1FFFFFFF, 4)) == word(incoming)
            stopped[0] = True
            uc.emu_stop()

    uc.hook_add(UC_HOOK_CODE, code_guard)
    uc.hook_add(UC_HOOK_MEM_READ | UC_HOOK_MEM_WRITE, memory_guard)
    uc.emu_start(first, 0, count=40)
    assert stopped[0] and uc.reg_read(regs.UC_MIPS_REG_PC) == QUEUE
    assert all(uc.reg_read(register) == value for register, value in saved.items())
    for address, data in images.items():
        expected = bytearray(data)
        if address == STACK - 16:
            expected[32:36] = word(incoming)
        assert bytes(uc.mem_read(address & 0x1FFFFFFF, len(data))) == bytes(expected)
    return trace


def main():
    rom = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(rom)
    directory = ROOT / 'build/platform-empty-execution'
    directory.mkdir(parents=True, exist_ok=True)
    comparison = compare_block('platform_empty', 'src/game/platform_empty.c',
                               0x8003BF5C, 0x3CB5C, 0x3CBEC, rom,
                               'platform-empty-execution', SymbolLayoutSnapshot())
    assert comparison['matches'] and comparison['actual_size'] == 144
    compiled = directory / 'platform_empty'
    sections, symbols = elf_sections_and_symbols(compiled / 'platform_empty.raw.o')
    assert sections['.text']['size'] == 144 and symbols['func_8003BF84']['size'] == 8
    actual = (compiled / 'platform_empty.bin').read_bytes()[40:48]
    original = rom[0x3CB84:0x3CB8C]
    assert actual == original
    probe = directory / 'interface.c'
    probe.write_text('#include "../../include/platform_services.h"\nint platform_delay_interface(int sound) { return func_8003BF84(sound); }\n')
    compile_source(str(probe.relative_to(ROOT)), directory / 'interface.o')
    disassembler = Cs(CS_ARCH_MIPS, CS_MODE_MIPS32 | CS_MODE_BIG_ENDIAN)
    instructions = list(disassembler.disasm(rom[0x2770C:0x2801C], 0x80026B0C))
    assert len(instructions) == 580
    callers = [instruction.address for instruction in instructions
               if instruction.mnemonic == 'jal' and instruction.op_str == hex(LEAF)]
    assert callers == [site for site, _ in SITES]
    digest = hashlib.sha256()
    for salt, (incoming, argument) in enumerate(itertools.product(WORDS, WORDS)):
        for body in (original, actual):
            digest.update(json.dumps(leaf_run(body, incoming, argument, salt)).encode())
    caller_cases = list(itertools.product(SITES, WORDS,
                                        (0, 24, 68, 0x80000000, 0xFFFFFFFF), range(3)))
    for (site, queue_call), incoming, argument, selection in caller_cases:
        for body in (original, actual):
            digest.update(json.dumps(caller_run(rom, body, site, queue_call,
                                              incoming, argument, selection)).encode())
    mutations = []
    for name, instruction in (('constant-return', 0x34021234),
                              ('argument-return', 0x00801021),
                              ('parameter-stack-spill', 0xAFA40000)):
        try:
            leaf_run(original[:4] + word(instruction), 0xCAFEBABE, 31, 3)
        except AssertionError:
            mutations.append(name)
        else:
            raise AssertionError('Undetected mutation: ' + name)
    inputs = dict(comparison['inputs_sha256'])
    for name in ('tools/check_platform_empty.py', 'tools/check_actor_group_path.py', 'tools/rom.py'):
        inputs[name] = hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
    report = dict(matches=True, comparison=comparison, inputs_sha256=inputs,
                  source_instruction_bytes_added=0, initialized_bytes_added=0, bss_bytes_added=0,
                  complete_platform_bytes=144, leaf_bytes=8, leaf_cases=len(WORDS)**2,
                  cases=len(WORDS)**2 + len(caller_cases),
                  executions=(len(WORDS)**2 + len(caller_cases))*2,
                  leaf_executions=len(WORDS)**2 * 2, caller_slice_cases=len(caller_cases),
                  caller_slice_executions=len(caller_cases)*2,
                  caller_sites=[hex(site) for site, _ in SITES],
                  trace_sha256=digest.hexdigest(), mutations_detected=mutations,
                  versions={name: version(name) for name in ('unicorn', 'capstone', 'pyelftools')},
                  retail_menu_instruction_bytes=2320, retail_menu_source_owned=False,
                  retail_menu_sha256=hashlib.sha256(rom[0x2770C:0x2801C]).hexdigest(),
                  interface_probe_sha256=hashlib.sha256((directory / 'interface.o').read_bytes()).hexdigest(),
                  scope=['All seeded GPR/HI/LO words, SP and GP survive the empty leaf; it reads/writes no data.',
                         'All three retail call slices pass the unchanged incoming V0 as the O32 fifth argument.',
                         'Caller slices start after playback and stop before the queue body; playback, full menu control and gameplay are outside this checker.',
                         'The int-return empty function falls off without return and accepts unspecified arguments. Its observed register behavior is specific to pinned IDO, without a portable ISO C return guarantee.'])
    (directory / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Complete platform block: 144 bytes match; %d leaf and %d caller-slice executions; three detected mutants; no new ownership.' %
          (report['leaf_executions'], report['caller_slice_executions']))


if __name__ == '__main__':
    main()
