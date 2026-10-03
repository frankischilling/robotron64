"""Execute the complete matching scene action handler and its menu caller."""

import hashlib
import itertools
import json
import struct
from importlib.metadata import version
from pathlib import Path

from unicorn import UC_HOOK_CODE
from unicorn import mips_const as regs
from check_actor_group_path import SENTINEL, machine, word
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


ENTRY, CALLER = 0x8001B8D8, 0x800338F0
FLOAT_CLOBBER = 0x80000100
PLAYER, ACTOR, CHILD, SELECTION = 0x80201010, 0x80203010, 0x80204010, 0x80205010
SOURCE = 'src/game/scene_actions/dispatch.c'
NAMES = ('scene_action_dispatch', 'resource_selection_clear', 'early_signature_gate')
CALLER_SAVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                     ('V0', 'V1', 'A0', 'A1', 'A2', 'A3',
                      'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9'))


def run(code, tables, case):
    entry, selection, gate, counter, allocation, profile, alias = case
    # Unicorn's MIPS register API cannot write FPU state; execute mtc1 instead.
    clobber = word(0x3C013F80)
    clobber += b''.join(word(0x44810000 | (i << 11)) for i in range(20))
    clobber += word(0x03E00008) + word(0)
    uc, write, execute = machine(code + [(FLOAT_CLOBBER, clobber)], tables)
    uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS,
                 uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | (1 << 29))
    initial, expected = {}, {}

    def region(address, size, salt):
        initial[address] = bytearray((i * 37 + salt * 19 + profile * 43) & 255
                                     for i in range(size))

    for address, size, salt in ((PLAYER - 16, 0xDB4 + 32, 1),
                                (ACTOR - 16, 124 + 32, 2),
                                (CHILD - 16, 124 + 32, 3),
                                (SELECTION - 16, 36, 4),
                                (0x80073A30, 36, 5), (0x8007BB08, 36, 6),
                                (0x80097630, 40, 7), (0x8009EF90, 36, 8),
                                (0x800AD270, 0xAC, 9), (0x8009E564, 44, 10),
                                (0x80076FE4, 36, 11), (0x800BAE7C, 36, 12),
                                (0x8009D108, 36, 13), (0x8009AFC8, 64, 14),
                                (0x80076E34, 64, 15), (0x80076FA4, 64, 16)):
        region(address, size, salt)

    def put(images, address, value):
        for start, data in images.items():
            if start <= address and address + len(value) <= start + len(data):
                data[address - start:address - start + len(value)] = value
                return
        raise AssertionError(('Oracle write outside guarded regions', hex(address)))

    phase, mode, paused = gate
    delta = (-129, -1, 1, 129)[profile]
    angle = (-32768, -1, 0, 32767)[profile]
    lives = (-1, 0, 7, 0x7FFFFFFE)[profile]
    timestamp = (0, 0x12345678, 0x7FFFFFFF, 0x80000000)[profile]
    difficulty = (-1, 0, 1, 0x7FFFFFFF)[profile]
    for address, value in ((PLAYER + 8, ACTOR),
                           (PLAYER + 12, CHILD if allocation == 'existing' else 0),
                           (PLAYER + 0x6C, 19), (PLAYER + 0x78, 27),
                           (PLAYER + 0x7C, lives),
                           (0x800AD280, phase), (0x800AD288, mode),
                           (0x800AD284, paused), (0x800BAE8C, counter),
                           (0x8009D118, delta), (0x8009EFA0, timestamp),
                           (0x80097640, difficulty)):
        put(initial, address, word(value))
    put(initial, ACTOR + 0x10, struct.pack('>h', angle))
    position = (-300 + profile * 100, 1000 - profile * 7, -500 + profile * 11)
    put(initial, ACTOR + 0x60, b''.join(word(value) for value in position))
    selected = PLAYER + alias if alias else SELECTION
    put(initial, selected, word(selection))
    expected = {address: bytearray(data) for address, data in initial.items()}
    for address, data in initial.items():
        write(address, bytes(data))

    calls = []
    action_code = {5: 0, 6: 1, 7: 2, 8: 3, 9: 4, 10: 6, 11: 7}
    action = {8: 12, 9: 13, 10: 0}.get(selection) if entry == CALLER else selection
    if action == 0:
        put(expected, 0x80073A40, word(1))
        put(expected, 0x8007BB18, word(1))
        put(expected, 0x80097644, word(timestamp))
    elif action == 1 and phase == 5:
        put(expected, 0x8009E57C, word(1))
        calls.append([0x80022528, [0, 0, 0]])
    elif action in (2, 3) and phase == 5:
        if action == 2:
            put(expected, 0x800AD30C, word(50))
        else:
            put(expected, 0x8009E574, word(1))
            put(expected, 0x80076FF4, word(0x80076FB4))
        calls.extend([[0x800278AC, [0, 0, 0]], [0x8003614C, [0, 0, 1, 0]],
                      [0x80026178, [0x80076E44, 1]]])
    elif action == 4 and phase == 5:
        put(expected, 0x80097640, word((difficulty & 1) + 1))
    eligible = action in action_code and gate == (9, 3, 0)
    if eligible:
        put(expected, 0x800BAE8C, word(counter + 1))
        if counter < 5:
            calls.append([0x8003614C, [0, 0, 1, 0]])
            pickup = action_code[action]
            if pickup == 7:
                original = int.from_bytes(initial[PLAYER - 16][0x8C:0x90], 'big')
                put(expected, PLAYER + 0x7C, word(original + 1))
            elif pickup == 6:
                if allocation != 'existing':
                    calls.append([0x800283D4, [6, 0x8009AFD8, ACTOR + 0x60]])
                    put(expected, PLAYER + 12, word(CHILD if allocation == 'success' else 0))
                if allocation != 'failure':
                    put(expected, CHILD + 0x3C, word(PLAYER))
                    put(expected, ACTOR + 0x10, ((angle + delta * 256) & 0xFFFF).to_bytes(2, 'big'))
            else:
                put(expected, PLAYER + 0x6C, word(pickup))
                put(expected, PLAYER + 0x78, word(0))
    if entry == CALLER or selection != -1:
        put(expected, selected, word(0 if entry == CALLER else -1))

    trace = []

    def read(address, size):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, size))

    def stub(uc, address, instruction_size, user):
        count = {0x80022528: 3, 0x800278AC: 3, 0x8003614C: 4,
                 0x80026178: 2, 0x800283D4: 3}[address]
        args = [uc.reg_read(register) for register in
                (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1,
                 regs.UC_MIPS_REG_A2, regs.UC_MIPS_REG_A3)][:count]
        event = [address, args]
        assert len(trace) < len(calls) and event == calls[len(trace)], (case, event, calls)
        if address == 0x8003614C and eligible:
            assert read(0x800BAE8C, 4) == word(counter + 1)
            assert read(PLAYER - 16, 0xDB4 + 32) == bytes(initial[PLAYER - 16])
        if address == 0x800283D4:
            assert read(ACTOR + 0x60, 12) == b''.join(word(value) for value in position)
            assert read(PLAYER + 12, 4) == word(0)
        trace.append(event)
        for i, register in enumerate(CALLER_SAVED):
            uc.reg_write(register, 0xB3450000 + i * 257)
        if address == 0x800283D4:
            uc.reg_write(regs.UC_MIPS_REG_V0, CHILD if allocation == 'success' else 0)
        uc.reg_write(regs.UC_MIPS_REG_PC, FLOAT_CLOBBER)

    for address in (0x80022528, 0x800278AC, 0x8003614C, 0x80026178, 0x800283D4):
        uc.hook_add(UC_HOOK_CODE, stub, begin=address, end=address)
    uc.reg_write(regs.UC_MIPS_REG_A0, selected)
    # Retail's menu caller supplies only A0; the executed cases never inspect A1.
    needs_player = eligible and counter < 5
    uc.reg_write(regs.UC_MIPS_REG_A1, PLAYER if needs_player else 0x81234000)
    execute(entry)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, ('Function did not return', case)
    assert trace == calls
    digest = hashlib.sha256()
    for address, data in expected.items():
        actual = read(address, len(data))
        assert actual == bytes(data), (case, hex(address), actual.hex(), data.hex())
        digest.update(word(address) + actual)
    for address, data in tables:
        assert read(address, len(data)) == data
    return dict(storage_sha256=digest.hexdigest(), calls=trace,
                eligible=eligible, applied=eligible and counter < 5)


def main():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    compiled, retail, comparisons = [], [], {}
    family = 'scene-actions-execution'
    for name in NAMES:
        _, source, start, end = next(item for item in MATCHING_BLOCKS if item[0] == name)
        report = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target, family=family, layout=layout)
        assert report['matches'], name
        comparisons[name] = report
        if name != 'early_signature_gate':
            binary = (ROOT / 'build' / family / name / (name + '.bin')).read_bytes()
            compiled.append((start, binary))
            retail.append((start, target[start - 0x80000000 + 0xC00:end - 0x80000000 + 0xC00]))
    sections, _ = elf_sections_and_symbols(ROOT / 'build' / family / NAMES[0] / (NAMES[0] + '.elf'))
    table = sections['.scene_action_table']['bytes']
    assert table == target[0x90FE8:0x91020] and len(table) == 56
    tables = [(0x800903E8, table)]
    data_source = 'src/game/scene_actions/pickup_count.c'
    data = compare_unit(data_source, source_sections(data_source), target, layout)
    assert data['matches'], data_source
    gates = ((9, 3, 0), (5, 3, 0), (9, 2, 0), (9, 3, 1), (0, 3, 0), (9, 3, -1))
    direct = ((ENTRY, selection, gate, count, allocation, profile, 0)
              for selection, gate, count, allocation, profile in
              itertools.product(range(5, 12), gates, (-3, 0, 4, 5, 6, 0x7FFFFFFE),
                                ('existing', 'success', 'failure'), range(4)))
    menus = ((ENTRY, selection, (phase, 3, 0), 4, 'success', profile, 0)
             for selection, phase, profile in
             itertools.product((-0x80000000, -2, -1, 0, 1, 2, 3, 4, 12, 13, 14, 0x7FFFFFFF),
                               (0, 5, 9), range(4)))
    callers = ((CALLER, selection, (phase, 3, 0), 4, 'success', profile, 0)
               for selection, phase, profile in
               itertools.product((-1, 0, 7, 8, 9, 10, 11, 13), (0, 5, 9), range(4)))
    aliases = ((ENTRY, selection, (9, 3, 0), 4, allocation, profile, alias)
               for selection, allocation, profile, alias in
               itertools.product(range(5, 12), ('existing', 'success', 'failure'),
                                 range(4), (0x6C, 0x78, 0x7C)))
    counts = dict(cases=0, direct=0, callers=0, aliases=0, gated_counter=0, applied=0)
    digest = hashlib.sha256()
    for case in itertools.chain(direct, menus, callers, aliases):
        expected = run(retail, [(0x800903E8, target[0x90FE8:0x91020])], case)
        actual = run(compiled, tables, case)
        assert actual == expected, case
        counts['cases'] += 1
        counts['direct' if case[0] == ENTRY else 'callers'] += 1
        counts['aliases'] += int(bool(case[6]))
        counts['gated_counter'] += int(actual['eligible'])
        counts['applied'] += int(actual['applied'])
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
    report = dict(matches=True, counts=counts, comparisons=comparisons,
                  data_comparisons={data_source: data}, table_sha256=hashlib.sha256(table).hexdigest(),
                  trace_sha256=digest.hexdigest(), target_rom_sha256=hashlib.sha256(target).hexdigest(),
                  checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  machine_helper_sha256=hashlib.sha256((ROOT / 'tools/check_actor_group_path.py').read_bytes()).hexdigest(),
                  emulator=dict(package='unicorn', version=version('unicorn')),
                  limits=['The complete matching handler, generated table and menu caller execute retail and freshly compiled instructions.',
                          'The signature-gated caller is independently recompiled and matched; it is not executed here.',
                          'The pickup counter definition is independently compiled with its complete size and placement verified.',
                          'Independent byte oracles check all player/actor fields, state globals, guards, call order and the unchanged switch table.',
                          'Cases cover state gates, counter boundaries, reused/successful/failed allocations, signed halfword narrowing and selection/player aliasing.',
                          'Non-player paths run with an unmapped player argument, including the retail caller which supplies only A0.',
                          'Level setup, input reset, sound, menu activation and actor allocation use ABI stubs which clobber caller-saved integer and floating-point registers.',
                          'Saved registers, stack restoration and return to the sentinel are verified.',
                          'Actual allocation, rendering, audio, menu activation, invalid required pointers and full-game execution are outside this proof.'])
    output = ROOT / 'build' / family / 'report.json'
    output.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed scene action execution:', counts, output, flush=True)


if __name__ == '__main__':
    main()
