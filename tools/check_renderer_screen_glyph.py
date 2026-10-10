"""Audit the excluded screen-glyph candidate with real support code and independent oracles.

The complete function remains nonmatching. Only its separately verified four-byte
clock has source ownership. Optional analysis dependencies and a baserom are needed.
"""

from pathlib import Path
import hashlib
import itertools
import json
from importlib.metadata import version
from unicorn import UC_MEM_WRITE, UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UcError
from unicorn import mips_const as regs

from check_actor_group_path import machine, word, SENTINEL
from check_renderer_image_setup import half, packets, signed
from check_renderer_object_glyph import packed_matrix, glyph_index
from check_boss_trigger import fpu_code, FPU_OUT, FPU_BITS, SEED_FPU, READ_FPU
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate
from compare_data import compare_unit


def main():
    r = ROOT
    d = r / 'build/renderer-screen-glyph-execution'
    d.mkdir(parents=True, exist_ok=True)
    rom = (r / 'baseroms/us/baserom.z64').read_bytes()
    validate(rom)
    layout = SymbolLayoutSnapshot()
    assert layout.addresses['D_800CD2B0'] == 0x800CD2B0
    clock_source = 'src/game/renderer_text/clock_storage.c'
    clock_comparison = compare_unit(clock_source, source_sections(clock_source), rom, layout)
    ENTRY, END = 0x80049E3C, 0x8004A2B4
    VERTICES, ARENA, FONT, COMMANDS = 0x800CDBD0, 0x80126B90, 0x8007DB20, 0x80220010
    CURSOR, BUFFER, DISPLAY = 0x8007D6A8, 0x8007D910, 0x80138254
    SUPPORT = ('renderer_glyph_map', 'fixed_math', 'renderer_matrix_transform', 'short_sine', 'short_cosine',
               'object_recovery_fixed_trig', 'graphics_pool', 'debug_noop')
    support, support_code, comparisons = [], [], {}
    for name in SUPPORT:
        _, source, start, end = next(x for x in MATCHING_BLOCKS if x[0] == name)
        q = compare_block(name, source, start, start-0x80000000+0xC00, end-0x80000000+0xC00,
                          rom, 'renderer-screen-glyph-support', layout)
        assert q['matches'], name
        directory = r / 'build/renderer-screen-glyph-support' / name
        code = (directory / (name + '.bin')).read_bytes()
        support.append((start, code))
        support_code.append((start, start + len(code)))
        sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
        for owned in source_sections(source):
            if owned['rom'] is not None:
                support.append((owned['vram'], sections[owned['section']]['bytes']))
        comparisons[name] = q
    print('Eight real support units freshly matched', flush=True)

    PROFILES = (
        (16, (0, 1, -1), (4, 17, 63), 0),
        (32, (64001, -64001, 12345), (0x1234, -1, 0xABCDEF00), 65535),
        (-16, (-17, 1024, 0x7FFFFFFF), (257, -257, 300), -17),
        (65537, (0x7FFFFFFF, -0x80000000, -32001), (255, 0, 128), 0x7FFFFFFA),
    )

    class GuardFault(Exception):
        pass

    def run(code, case, fault=None):
        character, allocation, profile, cursor, buffer = case
        scale, position, color, clock = PROFILES[profile]
        vertex = (0, 21996, 9801)[allocation]
        frame_vertex = vertex if allocation == 1 else 0
        rejected = allocation == 2
        if fault == 'negative_vertex':
            vertex = -17
        elif fault == 'matrix_cursor':
            cursor = 250
        command_base = COMMANDS + int(fault == 'unaligned_commands')
        floating = fpu_code()
        uc, write, execute = machine([(ENTRY, code)], support + floating)
        uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS, uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | (1 << 29))
        uc.emu_start(SEED_FPU, 0, count=1000)
        assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
        write(0x802FEF00-16, b'\xE1' * 16)
        write(0x80300020, b'\xE2' * 16)
        write(0x802FEF00, b'\xA9' * 0x1120)
        matrix_arena = bytearray(b'\xA7' * 32000)
        vertex_arena = bytearray(b'\xA8' * 352000)
        command_arena = bytearray(b'\xAC' * 256)
        font = b'\xC1' * (58 * 1024 + 32)
        write(ARENA-16, b'\xC7' * 16 + matrix_arena + b'\xC7' * 16)
        write(VERTICES-16, b'\xC8' * 16 + vertex_arena + b'\xC8' * 16)
        write(COMMANDS-16, b'\xCC' * 16 + command_arena + b'\xCC' * 16)
        write(FONT-16, font)
        globals_ = {CURSOR: cursor, BUFFER: buffer, DISPLAY: command_base, 0x80126B84: vertex,
            0x80123B20: frame_vertex, 0x80123AE4: 0x12345678, 0x80123B00: 0xDEAD1234,
            0x8008CB20: -99, 0x8008CB34: scale, 0x800CD2B0: clock,
            **{0x8008CB24+i*4: v for i,v in enumerate(color)},
            **{0x8013D9A0+i*4: v for i,v in enumerate(position)}}
        for address, value in globals_.items():
            write(address, word(value))
        write(FPU_OUT-16, b'\xE3' * 16 + b'\xA4' * 48 + b'\xE4' * 16)
        uc.reg_write(regs.UC_MIPS_REG_GP, 0xA578ABCD)
        normalize = lambda address: address & 0x1FFFFFFF
        code_ranges = [(normalize(a),normalize(b)) for a,b in support_code] + [(normalize(ENTRY),normalize(ENTRY+len(code))), (normalize(SENTINEL),normalize(SENTINEL)+4)]
        code_ranges += [(normalize(a),normalize(a)+len(data)) for a,data in floating]
        state_ranges = [(normalize(ARENA),normalize(ARENA)+32000), (normalize(VERTICES),normalize(VERTICES)+352000),
                        (normalize(COMMANDS),normalize(COMMANDS)+256), (0x2FEF00,0x300020), (normalize(FPU_OUT),normalize(FPU_OUT)+48)]
        global_ranges = [(normalize(a),normalize(a)+4) for a in globals_]
        data_ranges = [(normalize(a),normalize(a)+len(data)) for a,data in support
                       if not any(start <= normalize(a) < end for start,end in code_ranges)]
        read_ranges = state_ranges + global_ranges + data_ranges + code_ranges + [(normalize(FONT-16),normalize(FONT-16)+len(font))]
        write_ranges = state_ranges + global_ranges
        trace = []

        def access(uc, kind, address, size, value, user):
            start = normalize(address)
            ranges = write_ranges if kind == UC_MEM_WRITE else read_ranges
            if not any(a <= start and start+size <= b for a,b in ranges):
                raise GuardFault((hex(uc.reg_read(regs.UC_MIPS_REG_PC)), hex(address), size, kind))

        def instructions(uc, address, size, user):
            start = normalize(address)
            if not any(a <= start and start+size <= b for a,b in code_ranges):
                raise GuardFault(('unexpected code', hex(address)))

        def boundary(uc, address, size, user):
            trace.append(hex(address))
            a0 = uc.reg_read(regs.UC_MIPS_REG_A0)
            if address == 0x80047570:
                assert bytes(uc.mem_read(normalize(a0+4),24)) == b''.join(word(n) for n in ((scale,)*3 + (0,)*3))
                assert bytes(uc.mem_read(normalize(a0+40),12)) == b''.join(word(n) for n in position)
            elif address == 0x800498F0:
                assert a0 == (character & 255)
            elif address == 0x8003CC58:
                assert a0 == ((clock+10) & 0xFFFFFFFF)
            elif address == 0x80047094:
                assert a0 == 4

        uc.hook_add(UC_HOOK_MEM_READ | UC_HOOK_MEM_WRITE, access)
        uc.hook_add(UC_HOOK_CODE, instructions)
        for address in (0x8004DB34, 0x80047570, 0x800498F0, 0x80047048, 0x8003CC58, 0x80047094, 0x80048DC0):
            uc.hook_add(UC_HOOK_CODE, boundary, begin=address, end=address)
        uc.reg_write(regs.UC_MIPS_REG_A0, character & 0xFFFFFFFF)
        execute(ENTRY)
        assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
        assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xA578ABCD
        uc.emu_start(READ_FPU,0,count=1000)
        assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
        assert bytes(uc.mem_read(normalize(FPU_OUT-16),80)) == b'\xE3'*16 + b''.join(word(n) for n in FPU_BITS) + b'\xE4'*16
        clamped = tuple(max(-32000,min(32000,n)) for n in position)
        matrix = packed_matrix((scale,)*3, (0,)*3, clamped)
        offset = cursor*128 + buffer*64
        matrix_arena[offset:offset+64] = matrix
        texture = (FONT + glyph_index(character)*1024) & ~7
        values = [(0x01020040, ARENA+offset-0x80000000), (0xE7000000,0), (0xFD900000,texture),
                  (0xF5900000,0x07080200), (0xE6000000,0), (0xF3000000,0x071FF200),
                  (0xE7000000,0), (0xF5880800,0x00080200), (0xF2000000,0x0007C07C)]
        if not rejected:
            ch = character & 255
            special = (0,0,255) if ch == 14 else (0,255,0) if ch == 15 else (255,0,0) if ch == ord('[') else None
            for i, (x,y,u,v) in enumerate(((20,20,0,0),(-20,20,3072,0),(-20,-20,3072,3072),(20,-20,0,3072))):
                start = (vertex+i)*16
                vertex_arena[start:start+6] = half(x)+half(y)+half(0)
                vertex_arena[start+8:start+12] = half(u)+half(v)
                rgb = special if special is not None else ((255,)*3 if i < 2 else tuple(n & 255 for n in color))
                vertex_arena[start+12:start+16] = bytes((*rgb,255))
            values += [(0x0400103F, VERTICES+vertex*16), (0xB1020406,0x00020600), (0xB1040200,0x00040006)]
        emitted = packets(values)
        command_arena[:len(emitted)] = emitted
        expected_globals = {**globals_, CURSOR: cursor+1, DISPLAY: COMMANDS+len(emitted), 0x80126B84: vertex+(0 if rejected else 4),
            0x80123AE4: -1 if rejected else vertex, 0x80123B00: texture, 0x8008CB20: 20,
            0x800CD2B0: clock+(0 if rejected else 10), 0x8013D9A0: position[0]-(0 if rejected else 40)}
        for address, value in expected_globals.items():
            assert bytes(uc.mem_read(normalize(address),4)) == word(value), ('state',case,hex(address))
        pool_prefix = b'\xC7'*4 + word(vertex+(0 if rejected else 4)) + b'\xC7'*8
        for address, expected in ((ARENA-16,pool_prefix+matrix_arena+b'\xC7'*16),
            (VERTICES-16,b'\xC8'*16+vertex_arena+b'\xC8'*16), (COMMANDS-16,b'\xCC'*16+command_arena+b'\xCC'*16),
            (FONT-16,font), (0x802FEF00-16,b'\xE1'*16), (0x80300020,b'\xE2'*16)):
            assert bytes(uc.mem_read(normalize(address),len(expected))) == expected, ('bytes',case,hex(address))
        expected_trace = ['0x8004db34','0x80047570','0x800498f0','0x80047048'] + (['0x80048dc0'] if rejected else ['0x8003cc58','0x80047094'])
        assert trace == expected_trace, (case,trace)
        return dict(commands=emitted.hex(), matrix=matrix.hex(), trace=trace, vertex_sha256=hashlib.sha256(vertex_arena).hexdigest())

    sources = {'public': 'src/game/renderer_text/text_glyph.c'}
    original_candidate = (r / sources['public']).read_text()
    original_candidate = original_candidate.replace('../../../include/', str(r / 'include') + '/')
    mutants = {
        'alpha_254': original_candidate.replace('alpha = 255;', 'alpha = 254;'),
        'commit_three': original_candidate.replace('func_80047094(4);', 'func_80047094(3);'),
        'wrong_font_alignment': original_candidate.replace('& ~7)', '& ~2047)'),
        'extent_21': original_candidate.replace('D_8008CB20 = 20;', 'D_8008CB20 = 21;'),
        'lower_red_zero': original_candidate.replace('vertices[2].color.color[0] = D_8008CB24;',
                                                    'vertices[2].color.color[0] = 0;'),
    }
    for name, code in mutants.items():
        assert code != original_candidate, name
        p = d / (name + '.c')
        p.write_text(code)
        sources[name] = p.relative_to(r).as_posix()
    compiled = {}
    for name, source in sources.items():
        q = compare_block(name, source, ENTRY, 0x4AA3C, 0x4AEB4, rom, 'renderer-screen-glyph-candidates', layout)
        directory = r / 'build/renderer-screen-glyph-candidates' / name
        _, symbols = elf_sections_and_symbols(directory / (name + '.raw.o'))
        compiled[name] = (directory / (name + '.bin')).read_bytes()[:symbols['func_80049E3C']['size']]
        comparisons[name] = q
    retail = rom[0x4AA3C:0x4AEB4]
    cases = [(c,a,c//64,73 if c & 1 else 0,(c>>1)&1) for c,a in itertools.product(range(256), range(3))]
    cases += [(c,a,p,0,0) for c,a,p in itertools.product((-1,256,0x1234,0xFFFFFFFE), range(3), range(4))]
    counts, hashes = {}, {}
    for name in ('public',):
        digest = hashlib.sha256()
        for index,case in enumerate(cases):
            expected = run(retail,case)
            observed = run(compiled[name],case)
            assert observed == expected, (name,case)
            digest.update(json.dumps([case,observed],sort_keys=True).encode())
            if (index+1)%200 == 0:
                print(name,index+1,'paired cases',flush=True)
        counts[name] = len(cases)
        hashes[name] = digest.hexdigest()
        print(name,'passed',len(cases),'paired cases',flush=True)

    controls = []
    for name,ch in [(name,65) for name in mutants]:
        try:
            run(compiled[name],(ch,0,0,0,0))
        except (AssertionError,GuardFault,UcError) as error:
            controls.append(dict(name=name,character=ch,rejected=True,error=str(error)))
        else:
            raise AssertionError(('Invalid source suggestion was not detected',name,ch))
    for fault in ('negative_vertex','matrix_cursor','unaligned_commands'):
        try:
            run(retail,(65,0,0,0,0),fault=fault)
        except (GuardFault,UcError) as error:
            controls.append(dict(name=fault,rejected=True,error=str(error)))
        else:
            raise AssertionError(('Invalid guest storage was not rejected',fault))

    layout.verify()
    proof = dict(paired_cases=counts,trace_sha256=hashes,clock_comparison=clock_comparison,
        real_support_units=SUPPORT,stubbed_callees=[],positive_controls=controls,comparisons=comparisons,
        retail_code_sha256=hashlib.sha256(retail).hexdigest(),matching_instruction_bytes_added=0,source_owned_bss_bytes=4,
        checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),unicorn_version=version('unicorn'),
        limits=['All source candidates remain nonmatching over the complete natural retail range.',
                'Diagnostic matrix exhaustion and vertex commit exhaustion are excluded; tested cursors are 0 and 73.',
                'The current public draw-state type is retained; private transform views are not part of this audit.',
                'This checks bounded CPU state and ABI behavior; RSP/RDP rendering and full-game behavior remain unverified.'])
    (d / 'proof.json').write_text(json.dumps(proof,indent=2)+'\n')
    print('Screen oracle complete',counts,'controls',len(controls),flush=True)

if __name__ == '__main__':
    main()
