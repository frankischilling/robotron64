"""Check the framebuffer-strip renderer and its complete compiled CPU callees.

Compares vertex bytes, display-list commands, pool counters, and preserved ABI
registers with retail execution. RSP/RDP rendering is outside this CPU check.
"""
import hashlib
import itertools
import json
import struct
from pathlib import Path

from unicorn import Uc, UC_ARCH_MIPS, UC_MODE_MIPS32, UC_MODE_BIG_ENDIAN, UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn.mips_const import *
from compare_startup import compare_block, SymbolLayoutSnapshot
from compare_runtime import MATCHING_BLOCKS
from rom import ROOT, validate

ENTRY = 0x80040724
END = 0x80040874
SUPPORT = ('renderer_vertex_attributes', 'model_framebuffer_texture', 'renderer_opaque_quad')


def run(blocks, x, y, depth, selector, base):
    uc = Uc(UC_ARCH_MIPS, UC_MODE_MIPS32 | UC_MODE_BIG_ENDIAN)
    uc.mem_map(0, 0x400000)
    uc.mem_map(0x80000000, 0x400000)

    def write(address, data):
        address &= 0x1fffffff
        uc.mem_write(address, data)
        uc.mem_write(address | 0x80000000, data)

    def word(address, value):
        write(address, struct.pack('>I', value & 0xffffffff))

    def read(address, length):
        return bytes(uc.mem_read(address & 0x1fffffff, length))

    def load(address):
        return int.from_bytes(read(address, 4), 'big')

    def mirror(uc, access, address, size, value, user):
        other = address ^ 0x80000000
        if other < 0x400000 or 0x80000000 <= other < 0x80400000:
            uc.mem_write(other, (value & ((1 << (size * 8)) - 1)).to_bytes(size, 'big'))

    uc.hook_add(UC_HOOK_MEM_WRITE, mirror)
    for address, data in blocks:
        write(address, data)
    word(0x800CD3B8, depth)
    word(0x8007D914, selector)
    word(0x80138260, 0x80240000)
    word(0x80138264, 0x80280000)
    word(0x80138254, 0x80200000)
    word(0x80123AE4, base)
    word(0x80123B20, base)
    word(0x80123B14, 7)
    word(0x80123B18, 11)
    vertices = 0x800CDBD0 + base * 16
    write(vertices - 16, b'\xa5' * 96)
    guards = (read(vertices - 16, 16), read(vertices + 64, 16))
    trace = []
    finished = [False]

    def hook(uc, address, size, user):
        address |= 0x80000000
        if address == 0x80000080:
            finished[0] = True
            uc.emu_stop()
        elif address == 0x800496E0:
            raise AssertionError('Unexpected fatal renderer diagnostic')
        elif address in (0x80043CB4, 0x80040874, 0x80044F60):
            args = [uc.reg_read(r) & 0xffffffff for r in (UC_MIPS_REG_A0, UC_MIPS_REG_A1, UC_MIPS_REG_A2, UC_MIPS_REG_A3)]
            if address == 0x80044F60:
                trace.append((address, [read(a, 12).hex() for a in args]))
            else:
                trace.append((address, args[:4 if address == 0x80043CB4 else 1]))

    uc.hook_add(UC_HOOK_CODE, hook)
    preserved = [UC_MIPS_REG_S0, UC_MIPS_REG_S1, UC_MIPS_REG_S2, UC_MIPS_REG_S3, UC_MIPS_REG_S4, UC_MIPS_REG_S5, UC_MIPS_REG_S6, UC_MIPS_REG_S7, UC_MIPS_REG_FP, UC_MIPS_REG_GP]
    sentinels = [0x13570000 + i * 0x101 for i in range(len(preserved))]
    for r, v in zip(preserved, sentinels):
        uc.reg_write(r, v)
    uc.reg_write(UC_MIPS_REG_SP, 0x803F0000)
    uc.reg_write(UC_MIPS_REG_RA, 0x80000080)
    uc.reg_write(UC_MIPS_REG_A0, x & 0xffffffff)
    uc.reg_write(UC_MIPS_REG_A1, y & 0xffffffff)
    uc.emu_start(ENTRY, 0, count=20000)
    assert finished[0]
    assert uc.reg_read(UC_MIPS_REG_SP) == 0x803F0000
    assert [uc.reg_read(r) for r in preserved] == sentinels
    assert guards == (read(vertices - 16, 16), read(vertices + 64, 16))
    assert load(0x80123AE4) == base + 4
    assert load(0x80123B14) == 8 and load(0x80123B18) == 12
    command_end = load(0x80138254)
    assert command_end == 0x80200000 + 88
    expected_corners = [(100 * (x - 160), 100 * (y - 120), depth),
                        (100 * x, 100 * (y - 120), depth),
                        (100 * x, 100 * (y - 114), depth),
                        (100 * (x - 160), 100 * (y - 114), depth)]
    actual = read(vertices, 64)
    for i, corner in enumerate(expected_corners):
        assert actual[i * 16:i * 16 + 6] == struct.pack('>3H', *(c & 0xffff for c in corner))
        assert actual[i * 16 + 15] == 255
    expected_image = ((0x80240000, 0x80280000)[selector ^ 1] + 2 * (x - 160) + 2 * (74880 - y * 320)) & 0xffffffff
    assert trace[4] == (0x80040874, [expected_image])
    return dict(trace=trace, vertices=actual.hex(), commands=read(0x80200000, 88).hex())


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    blocks = [('model_framebuffer_strip', 'src/game/model_framebuffer_strip.c', ENTRY, END)]
    blocks += [next(b for b in MATCHING_BLOCKS if b[0] == n) for n in SUPPORT]
    retail, compiled, proofs = [], [], []
    for name, source, start, end in blocks:
        proof = compare_block(name, source, start, start - 0x80000000 + 0xc00, end - 0x80000000 + 0xc00, target, family='framebuffer-strip-execution', layout=layout)
        assert proof['matches'], name
        code = (ROOT / 'build/framebuffer-strip-execution' / name / (name + '.bin')).read_bytes()
        retail.append((start, target[start - 0x80000000 + 0xc00:end - 0x80000000 + 0xc00]))
        compiled.append((start, code))
        proofs.append(proof)
    cases = [(x, y, depth, selector, 0) for x, y, depth, selector in itertools.product((0, 160), range(0, 240, 6), (31000, 1000), (0, 1))]
    cases += [(x, y, depth, selector, base) for x, y, depth, selector, base in itertools.product((-1, 159, 319, 320), (-1, 239, 240), (-32769, 32768), (0, 1), (1, 9997))]
    digest = hashlib.sha256()
    for case in cases:
        expected = run(retail, *case)
        actual = run(compiled, *case)
        assert actual == expected, case
        digest.update(json.dumps(actual, sort_keys=True).encode())
    report = {'cases': len(cases), 'matches': True, 'trace_sha256': digest.hexdigest(), 'comparisons': proofs, 'scope': 'Complete CPU renderer and three compiled support blocks, call arguments, four vertices, eleven display-list commands, counters, guards, and preserved ABI registers. No RSP/RDP rendering.'}
    out = ROOT / 'build/framebuffer-strip-execution/report.json'
    out.write_text(json.dumps(report, indent=2) + '\n')
    print(f'{len(cases)} framebuffer-strip CPU cases passed; report: {out}')


if __name__ == '__main__':
    main()
