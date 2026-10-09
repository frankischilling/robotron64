"""Audit the excluded inverse camera matrix with real fixed-point callees.

Execution agreement does not replace complete instruction matching.
"""
import argparse
import hashlib
import itertools
import json
import math
import random
import struct
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from generate_short_sine_table import table_values
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


ENTRY, VIEW, MATRIX, STACK = 0x8003F480, 0x800C8BD8, 0x800CD250, 0x80300000
SUPPORT = ('fixed_math', 'short_sine', 'short_cosine')
FAMILY = 'inverse-camera-execution'


def signed(value):
    return ((value + 0x80000000) & 0xFFFFFFFF) - 0x80000000


def oracle(angles):
    """Compose quantized Y/Z axes, then rotate their two rows around X."""
    def sine(phase):
        phase &= 4095
        quadrant_index = phase & 1023
        if phase & 1024:
            quadrant_index = 1023 - quadrant_index
        magnitude = math.floor(32767 * math.sin(quadrant_index * math.pi / 2046))
        return -magnitude if phase & 2048 else magnitude

    def product(left, right):
        return signed(left * right) >> 15

    phase = [signed(-angle) & 4095 for angle in angles]
    sine_x, sine_y, sine_z = [sine(angle) for angle in phase]
    cosine_x, cosine_y, cosine_z = [sine(angle + 1024) for angle in phase]
    first = [product(cosine_y, cosine_z), product(-cosine_y, sine_z), sine_y]
    z_axis = [sine_z, cosine_z, 0]
    y_axis = [-product(sine_y, cosine_z), product(sine_y, sine_z), cosine_y]
    rows = [first]
    for coefficients in ((cosine_x, -sine_x), (sine_x, cosine_x)):
        rows.append([signed(product(coefficients[0], z_axis[column]) +
                            product(coefficients[1], y_axis[column]))
                     for column in range(3)])
    return b''.join(word(value) for row in rows for value in row)


def execute(code, helpers, angles, seed):
    assert int.from_bytes(code[:2], 'big') == 0x27BD, 'Expected declared stack frame'
    frame = -int.from_bytes(code[2:4], 'big', signed=True)
    assert 0 < frame <= 256
    # Fixed cosine and SDK cosine each reserve 24 bytes; SDK sine is a leaf.
    stack_floor = STACK - frame - 48
    uc, write, execute_body = machine([(ENTRY, code)], helpers)
    view = bytearray((i * 37 + seed * 13) & 255 for i in range(40))
    for i, angle in enumerate(angles):
        view[16 + i * 4:20 + i * 4] = word(angle)
    before_view = b'\xD7' * 16 + bytes(view) + b'\xE9' * 16
    before_matrix = b'\xA7' * 16 + b'\xB3' * 36 + b'\xC9' * 16
    write(VIEW - 16, before_view)
    write(MATRIX - 16, before_matrix)
    write(stack_floor - 16, b'\x97' * 16)
    write(STACK + 16, b'\x93' * 16)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA578ABCD)
    code_ranges = [(ENTRY, ENTRY + len(code)), (SENTINEL, SENTINEL + 4)]
    code_ranges += [(start, end) for name, source, start, end in MATCHING_BLOCKS if name in SUPPORT]
    data_ranges = [(address, address + len(data)) for address, data in helpers
                   if not any(start <= address < end for start, end in code_ranges)]
    stack = (stack_floor, STACK + 16)
    reads = [(VIEW, VIEW + 40), stack] + data_ranges
    writes = [(MATRIX, MATRIX + 36), stack]
    trace = []

    def inside(address, size, ranges):
        address = (address & 0x1FFFFFFF) | 0x80000000
        return any(start <= address and address + size <= end for start, end in ranges)

    def instruction(uc, address, size, user):
        assert not address & 3 and inside(address, 4, code_ranges), ('Code bounds', hex(address))
        if address in (0x8004DB60, 0x8004DB88):
            trace.append((address, uc.reg_read(regs.UC_MIPS_REG_A0)))

    def read(uc, access, address, size, value, user):
        assert inside(address, size, reads), ('Read bounds', hex(address), size)

    def store(uc, access, address, size, value, user):
        assert inside(address, size, writes), ('Write bounds', hex(address), size)

    hooks = [uc.hook_add(UC_HOOK_CODE, instruction), uc.hook_add(UC_HOOK_MEM_READ, read),
             uc.hook_add(UC_HOOK_MEM_WRITE, store)]
    try:
        execute_body(ENTRY)
    finally:
        for hook in hooks:
            uc.hook_del(hook)
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xA578ABCD
    assert bytes(uc.mem_read((VIEW - 16) & 0x1FFFFFFF, len(before_view))) == before_view
    observed = bytes(uc.mem_read((MATRIX - 16) & 0x1FFFFFFF, len(before_matrix)))
    assert observed == before_matrix[:16] + oracle(angles) + before_matrix[-16:], ('Matrix oracle', angles)
    assert bytes(uc.mem_read((stack_floor - 16) & 0x1FFFFFFF, 16)) == b'\x97' * 16
    assert bytes(uc.mem_read((STACK + 16) & 0x1FFFFFFF, 16)) == b'\x93' * 16
    expected_trace = [(address, (-angle) & 0xFFFFFFFF) for angle in angles
                      for address in (0x8004DB60, 0x8004DB88)]
    assert trace == expected_trace, ('Trig calls', angles, trace)
    return observed[16:52]


def cases():
    for axis, phase in itertools.product(range(3), range(4096)):
        angles = [37, 913, 2450]
        angles[axis] = phase
        yield tuple(angles)
    boundaries = (0, 1, 511, 512, 1023, 1024, 1025, 2047, 2048, 3071, 3072, 4095,
                  -1, 4096, -0x80000000, 0x7FFFFFFF)
    yield from itertools.product(boundaries, repeat=3)
    rng = random.Random(0x8003F480)
    for _ in range(256):
        yield tuple(rng.randrange(-0x80000000, 0x80000000) for _ in range(3))


def main(source='src/game/view_inverse_matrix.c'):
    checker_inputs = ('tools/check_inverse_camera.py', 'tools/check_actor_group_path.py',
                      'tools/generate_short_sine_table.py')
    checker_hashes = {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
                      for name in checker_inputs}
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    reports, helpers = {}, []
    report = compare_block('inverse_camera', source, ENTRY, 0x40080, 0x4022C,
                           target, FAMILY, layout)
    reports['inverse_camera'] = report
    candidate = (ROOT / 'build' / FAMILY / 'inverse_camera/inverse_camera.bin').read_bytes()
    for name in SUPPORT:
        _, support_source, start, end = next(row for row in MATCHING_BLOCKS if row[0] == name)
        q = compare_block(name, support_source, start, start - 0x80000000 + 0xC00,
                          end - 0x80000000 + 0xC00, target, FAMILY, layout)
        assert q['matches'], ('Support mismatch', name)
        reports[name] = q
        directory = ROOT / 'build' / FAMILY / name
        helpers.append((start, (directory / (name + '.bin')).read_bytes()))
        sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
        for owned in source_sections(support_source):
            if owned['rom'] is not None:
                data = sections[owned['section']]['bytes']
                if owned['vram'] == 0x8008DBB0:
                    assert data == struct.pack('>1024h', *table_values())
                    mathematical = [math.floor(32767 * math.sin(i * math.pi / 2046)) for i in range(1024)]
                    assert data == struct.pack('>1024h', *mathematical)
                helpers.append((owned['vram'], data))
    retail = target[0x40080:0x4022C]
    for address in (0x8004DB60, 0x8004DB88, 0x8005FC20):
        block = next(data for start, data in helpers if start <= address < start + len(data))
        start = next(start for start, data in helpers if start <= address < start + len(data))
        assert block[address - start:address - start + 4] == bytes.fromhex('27bdffe8')
    digest = hashlib.sha256()
    count = 0
    for count, angles in enumerate(cases(), 1):
        expected = execute(retail, helpers, angles, count)
        actual = execute(candidate, helpers, angles, count)
        assert actual == expected
        digest.update(json.dumps([angles, actual.hex()]).encode())
        if count % 1024 == 0:
            print('Compared', count, 'inverse camera cases.', flush=True)
    layout.verify()
    for name, expected_hash in checker_hashes.items():
        assert hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == expected_hash
    for comparison in reports.values():
        for name, expected_hash in comparison['inputs_sha256'].items():
            assert hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == expected_hash
    result = dict(matches=True, cases=count, paired_executions=count * 2,
                  source_owned=False, comparisons=reports, trace_sha256=digest.hexdigest(),
                  checker_inputs_sha256=checker_hashes,
                  candidate_sha256=hashlib.sha256(candidate).hexdigest(),
                  retail_sha256=hashlib.sha256(retail).hexdigest(),
                  target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['Three complete matching source units and their compiled initialized tables execute; no callee stubs or instruction patches.',
                          'The independent oracle composes quantized axes and checks all nine output words for both retail and candidate executions.',
                          'Every masked phase is exercised separately on each axis, with Cartesian boundary and deterministic full-width input cases.',
                          'Code/read/write bounds, call arguments, unchanged complete FrameView, matrix/stack canaries, SP, GP and saved GPRs are checked.',
                          'This is bounded CPU execution, without a complete game, graphics microcode or hardware proof.',
                          'The inverse camera candidate remains excluded from matching ownership.'])
    output = ROOT / 'build' / FAMILY / 'report.json'
    output.write_text(json.dumps(result, indent=2) + '\n')
    print('Passed inverse camera execution:', count, 'cases.', flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', default='src/game/view_inverse_matrix.c')
    main(parser.parse_args().source)
