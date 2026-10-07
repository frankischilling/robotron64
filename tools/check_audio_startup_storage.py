"""Execute complete audio startup/thread consumers with guarded owned BSS."""

import argparse
from collections import Counter
import hashlib
from importlib.metadata import version
import itertools
import json
from pathlib import Path
import shutil
import struct
import subprocess
import sys
import tempfile

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs

from check_actor_group_path import SENTINEL, machine, word
from check_boss_trigger import fpu_code, FPU_OUT, FPU_BITS, SEED_FPU, READ_FPU
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import source_sections
from rom import ROOT, validate


BASE, END, HEAP, HEAP_SIZE = 0x8014BE50, 0x8019016C, 0x8014C080, 270000
DESCRIPTOR, STACK = 0x80190158, 0x80300000
GAME, GAME_SIZE, MESSAGES, RSP = 0x80210010, 131072, 0x80240010, 0x80241010
QUEUE, CONTEXT = 0x80243010, 0x80244010
FLOAT_CLOBBER = 0x80000100
SUPPORT = ('audio_startup', 'audio_thread', 'audio_generation', 'heap',
           'audio_heap_init', 'audio_heap_allocate', 'message_queue')
STORAGE = (
    ('temporary_allocation', BASE, 8), ('task_records', 0x8014BE58, 288),
    ('scheduler_records', 0x8014BF78, 264), ('synthesis_heap', HEAP, HEAP_SIZE),
    ('thread_stack', 0x8018DF30, 8192), ('message_queues', 0x8018FF30, 112),
    ('thread_state', 0x8018FFA0, 432), ('bank_cursor', 0x80190150, 4),
    ('heap_state', DESCRIPTOR, 16), ('generation_mode', 0x80190168, 4),
)
BOUNDARIES = {0x80058890: 1, 0x800588C8: 1, 0x80052948: 1,
              0x80052780: 1, 0x80051A0C: 1, 0x80052D70: 1,
              0x8005303C: 3, 0x80052A74: 0, 0x8005D220: 2,
              0x8005D2E4: 5, 0x8005D830: 2, 0x8005D8AC: 3,
              0x8005FF40: 6, 0x80060090: 1, 0x800507F0: 3,
              0x80062240: 3, 0x8004F850: 0, 0x80061450: 0,
              0x8005211C: 0, 0x80050620: 1, 0x800635A0: 3,
              0x800526D0: 0}
REAL_CALLS = {0x8004DD6C: 1, 0x8004DC70: 1, 0x800656F0: 3,
              0x80065730: 5, 0x80060450: 3}
CALLER_SAVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                    ('V0', 'V1', 'A0', 'A1', 'A2', 'A3', 'T0', 'T1', 'T2',
                     'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'HI', 'LO'))
PRESERVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                  ('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'FP', 'GP', 'SP', 'RA'))


def pattern(size, seed):
    # Build repeated chunks without a Python loop over the whole heap per case.
    block = bytes((i * 37 + seed) & 255 for i in range(256))
    return bytearray((block * ((size + 255) // 256))[:size])


def run(code, ranges, kind, seed, television=1, priority=20,
        sizes=(32, 48, 64), messages=(1, 1, 1, 1, 10), nulls=(), failures=(),
        clock=0x12345678FFFFFFF0, value=1, mode=1, offset=0, length=32,
        used=0, count=1, size=16):
    clobber = word(0x3C013F80)
    clobber += b''.join(word(0x44810000 | (i << 11)) for i in range(20))
    clobber += word(0x03E00008) + word(0)
    helpers = fpu_code() + [(FLOAT_CLOBBER, clobber)]
    uc, write, _ = machine(code, helpers)
    helper_ranges = tuple((a, a + len(b)) for a, b in helpers)
    uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS,
                 uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | (1 << 29))
    uc.emu_start(SEED_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, 'FPU initialization return'
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA57281D9)
    preserved = {r: uc.reg_read(r) for r in PRESERVED}
    panels = {'audio': (BASE - 16, pattern(END - BASE + 32, seed)),
              'game': (GAME - 16, pattern(GAME_SIZE + 40, seed + 1)),
              'heap_pointer': (0x8013EBF0 - 16, pattern(36, seed + 2)),
              'heap_ready': (0x8008D480 - 16, pattern(36, seed + 3)),
              'bank_count': (0x800AF1E0 - 16, pattern(36, seed + 4)),
              'clock': (0x8008D764 - 16, pattern(52, seed + 5)),
              'messages': (MESSAGES - 16, pattern(2 * len(messages) + 32, seed + 7)),
              'rsp': (RSP - 16, pattern(16 * 80 + 32, seed + 8)),
              'fpu': (FPU_OUT - 16, pattern(80, seed + 9))}
    panels['game'][1][16:20] = word(GAME_SIZE + 1)
    panels['game'][1][16 + GAME_SIZE + 4:20 + GAME_SIZE + 4] = word(0)
    panels['heap_pointer'][1][16:20] = word(GAME)
    panels['heap_ready'][1][16:20] = word(1)
    panels['bank_count'][1][16:20] = word(11)
    requested = (max(value - 1, 0) % 11) + 0x88
    panels['clock'][1][24:28] = word(requested)
    for i, message in enumerate(messages):
        panels['messages'][1][16 + i * 2:18 + i * 2] = (message & 0xFFFF).to_bytes(2, 'big')
    if kind in ('heap_init', 'heap_allocate'):
        start = HEAP + offset
        panels['audio'][1][16 + DESCRIPTOR - BASE:32 + DESCRIPTOR - BASE] = (
            word(start) + word(start + used) + word(length) + word(0x17))
    expected = {name: bytearray(data) for name, (_, data) in panels.items()}
    expected['fpu'][16:64] = b''.join(word(bits) for bits in FPU_BITS)
    wanted, trace, effects, cpu_stores = [], [], [], Counter()

    def put(name, address, data, cpu=True):
        base, panel = panels[name]
        at = address - base
        assert 16 <= at and at + len(data) <= len(panel) - 16
        expected[name][at:at + len(data)] = data
        if cpu:
            assert len(data) in (2, 4)
            cpu_stores[address, len(data)] += 1

    def call(address, *args, response=0, effect=None):
        wanted.append([address, list(args)])
        effects.append((response, effect))

    def game_allocation(request):
        remainder = GAME_SIZE + 1 - request - 4
        header = GAME + (remainder >> 2) * 4 + 4
        allocation = header + 4
        call(0x8004DD6C, request)
        put('game', GAME, word(remainder))
        put('game', header, word(request))
        put('audio', BASE, word(allocation))
        return allocation, header

    def release(allocation, header, request):
        call(0x8004DC70, allocation)
        put('game', header, word(request | 1))

    if kind == 'startup':
        entry = 0x8005109C
        uc.reg_write(regs.UC_MIPS_REG_A0, priority & 0xFFFFFFFF)
        uc.reg_write(regs.UC_MIPS_REG_A1, television & 0xFFFFFFFF)
        put('bank_count', 0x800AF1E0, word(11))
        put('audio', BASE + 4, word(120000))
        allocation, header = game_allocation(120000)
        defaults = [seed * 3 + i * 17 + 9 for i in range(14)]
        configuration = word(0xD3) + b''.join(word(v) for v in defaults)
        changed = defaults[:]
        changed[0] += 8
        changed[1] += 32
        changed[6] += 24
        changed[3], changed[8], changed[12] = 160, 48, 32
        changed_config = word(0x115F) + b''.join(word(v) for v in changed)
        call(0x80058890, 0x80051034)
        call(0x800588C8, 0x80051044)
        call(0x80052948, 'configuration', effect=('stack', configuration))
        call(0x80052780, changed_config.hex())
        call(0x800656F0, DESCRIPTOR, HEAP, HEAP_SIZE)
        for at, number in enumerate((HEAP, HEAP, HEAP_SIZE, 0)):
            put('audio', DESCRIPTOR + 4 * at, word(number))
        settings = b''.join(word(v) for v in
            (0x41F00000 if television == 2 else 0x42700000, 0x5622, 0xC00,
             DESCRIPTOR, 0x0066BEE0, 2, 0))
        call(0x80051A0C, settings.hex())
        cursor = HEAP

        def allocate(request):
            nonlocal cursor
            result = cursor
            cursor += (request + 15) & ~15
            assert cursor <= HEAP + HEAP_SIZE
            call(0x80065730, 0, 0, DESCRIPTOR, 1, request)
            put('audio', DESCRIPTOR + 4, word(cursor))
            return result

        call(0x80052D70, 0x0077B780, response=sizes[0])
        bank = allocate(sizes[0])
        bank_bytes = bytes(pattern(sizes[0], seed + 10))
        call(0x8005303C, 0x0077B780, bank, sizes[0], effect=('audio', bank, bank_bytes))
        put('audio', bank, bank_bytes, cpu=False)
        call(0x80052A74, response=CONTEXT)
        call(0x8005D220, CONTEXT, 0x00783380, response=sizes[1])
        sequence = allocate(sizes[1])
        call(0x80052A74, response=CONTEXT)
        sequence_bytes = bytes(pattern(sizes[1], seed + 11))
        call(0x8005D2E4, CONTEXT, 0x00783380, 0, sequence, sizes[1],
             effect=('audio', sequence, sequence_bytes))
        put('audio', sequence, sequence_bytes, cpu=False)
        call(0x8005D830, 0, 136, response=sizes[2])
        cache = allocate(sizes[2])
        cache_bytes = bytes(pattern(sizes[2], seed + 12))
        call(0x8005D8AC, 0, 136, cache, effect=('audio', cache, cache_bytes))
        put('audio', cache, cache_bytes, cpu=False)
        bank_cursor = allocate(4) + 16
        put('audio', 0x80190150, word(bank_cursor))
        # The retail stores the raw pointer and then its advanced value.
        cpu_stores[0x80190150, 4] += 1
        for i in range(3):
            record = 0x8014BE58 + i * 96
            put('audio', record + 92, word(record))
            put('audio', record + 88, b'\x00\x02')
        for queue, messages_at in ((0x8018FF68, 0x8018FF80), (0x8018FF30, 0x8018FF48)):
            call(0x80060450, queue, messages_at, 8)
            for i, number in enumerate((0x8008F1A0, 0x8008F1A0, 0, 0, 8, messages_at)):
                put('audio', queue + 4 * i, word(number))
        call(0x8005FF40, 0x8018FFA0, priority & 0xFFFFFFFF, 0x80051380, 0,
             0x8018FF30, priority & 0xFFFFFFFF)
        call(0x80060090, 0x8018FFA0)
        release(allocation, header, 120000)
    elif kind == 'generation':
        entry = 0x80051680
        uc.reg_write(regs.UC_MIPS_REG_A0, value & 0xFFFFFFFF)
        uc.reg_write(regs.UC_MIPS_REG_A1, mode & 0xFFFFFFFF)
        put('audio', 0x80190168, word(mode))
        put('audio', BASE + 4, word(90000))
        allocation, header = game_allocation(90000)
        release(allocation, header, 90000)
    elif kind == 'heap_init':
        entry = 0x800656F0
        start = HEAP + offset
        uc.reg_write(regs.UC_MIPS_REG_A0, DESCRIPTOR)
        uc.reg_write(regs.UC_MIPS_REG_A1, start)
        uc.reg_write(regs.UC_MIPS_REG_A2, length)
        aligned = (start + 15) & ~15
        for at, number in enumerate((aligned, aligned, length, 0)):
            put('audio', DESCRIPTOR + 4 * at, word(number))
    elif kind == 'heap_allocate':
        entry = 0x80065730
        uc.reg_write(regs.UC_MIPS_REG_A0, 0)
        uc.reg_write(regs.UC_MIPS_REG_A1, 0)
        uc.reg_write(regs.UC_MIPS_REG_A2, DESCRIPTOR)
        uc.reg_write(regs.UC_MIPS_REG_A3, count)
        rounded = (count * size + 15) & ~15
        result = 0
        if used + rounded <= length:
            result = HEAP + offset + used
            put('audio', DESCRIPTOR + 4, word(result + rounded))
    elif kind == 'thread':
        entry = 0x80051380
        uc.reg_write(regs.UC_MIPS_REG_A0, 0x71)
        assert messages and messages[-1] == 10 and messages.count(10) == 1
        call(0x800507F0, 0x801378D0, 'client', 0x8018FF30,
             effect=('client', word(0) + word(0x8018FF30)))
        outstanding, next_task, generation = 0, 0, 0
        for i, message in enumerate(messages):
            call(0x80062240, 0x8018FF30, 'message', 1,
                 effect=('message', MESSAGES + i * 2))
            if message == 1:
                call(0x8004F850)
                if outstanding < 3:
                    first = (clock + generation * 97) & 0xFFFFFFFFFFFFFFFF
                    call(0x80061450, response=first)
                    put('clock', 0x8008D764, word(first))
                    null = generation in nulls
                    rsp = RSP + generation * 80
                    call(0x8005211C, response=0 if null else rsp)
                    generation += 1
                    if null:
                        continue
                    second = (first + 31 + i) & 0xFFFFFFFFFFFFFFFF
                    call(0x80061450, response=second)
                    put('clock', 0x8008D768, word(second - (first & 0xFFFFFFFF)))
                    task = 0x8014BF78 + (next_task % 3) * 88
                    next_task += 1
                    put('audio', task, word(0))
                    put('audio', task + 84, word(0))
                    put('audio', task + 80, word(0x8018FF68))
                    payload = panels['rsp'][1][16 + rsp - RSP:80 + rsp - RSP]
                    for at in range(0, 64, 4):
                        put('audio', task + 16 + at, payload[at:at + 4])
                    call(0x80050620, 0x801378D0, response=QUEUE)
                    call(0x800635A0, QUEUE, task, 1)
                    outstanding += 1
                failed = i in failures
                call(0x80062240, 0x8018FF68, 'message', 1,
                     response=-1 if failed else 0,
                     effect=None if failed else ('message', MESSAGES + i * 2))
                if not failed:
                    outstanding -= 1
            elif message == 3:
                outstanding = 6
            elif message == 10:
                call(0x800526D0)
    else:
        raise ValueError(kind)

    for address, data in panels.values():
        write(address, bytes(data))
    lower, upper = bytes(range(0xA0, 0xB0)), bytes(range(0xB0, 0xC0))
    write(STACK - 0x210, lower)
    write(STACK, bytes(pattern(32, seed + 20)))
    write(STACK + 32, upper)
    if kind == 'heap_allocate':
        write(STACK + 16, word(size))
    read_ranges = tuple((address + 16, address + len(data) - 16) for address, data in panels.values())
    stack_range = (STACK - 0x200, STACK + 32)
    writes = Counter()

    def inside(address, length, bounds):
        return any(a <= address and address + length <= b for a, b in bounds)

    def guard_code(uc, address, instruction_size, user):
        assert any(a <= address < b for a, b in ranges + helper_ranges) or address in BOUNDARIES or address == SENTINEL, ('Code bounds', hex(address))
        if address not in BOUNDARIES and (address not in REAL_CALLS or address == entry):
            return
        assert len(trace) < len(wanted), ('Extra service call', hex(address))
        argc = (BOUNDARIES if address in BOUNDARIES else REAL_CALLS)[address]
        sp = uc.reg_read(regs.UC_MIPS_REG_SP)
        args = [uc.reg_read(getattr(regs, 'UC_MIPS_REG_A' + str(i))) if i < 4 else
                int.from_bytes(uc.mem_read((sp + 16 + (i - 4) * 4) & 0x1FFFFFFF, 4), 'big') for i in range(argc)]
        original_args = args[:]
        if address in (0x80052948, 0x80052780, 0x80051A0C):
            n = 28 if address == 0x80051A0C else 60
            assert inside(args[0], n, (stack_range,)), 'Configuration pointer bounds'
            args[0] = 'configuration' if address == 0x80052948 else bytes(uc.mem_read(args[0] & 0x1FFFFFFF, n)).hex()
        elif address == 0x800507F0:
            assert inside(args[1], 8, (stack_range,)), 'Client pointer bounds'
            args[1] = 'client'
        elif address == 0x80062240:
            assert inside(args[1], 4, (stack_range,)), 'Message pointer bounds'
            args[1] = 'message'
        event = [address, args]
        assert event == wanted[len(trace)], ('Service arguments and order', event, wanted[len(trace)])
        response, effect = effects[len(trace)]
        trace.append(event)
        if address not in BOUNDARIES:
            return
        if effect:
            if effect[0] == 'stack':
                write(original_args[0], effect[1])
            elif effect[0] == 'client':
                write(original_args[1], effect[1])
            elif effect[0] == 'message':
                write(original_args[1], word(effect[1]))
            else:
                _, effect_address, data = effect
                assert inside(effect_address, len(data), ((HEAP, HEAP + HEAP_SIZE),)), 'Loader write bounds'
                write(effect_address, data)
        return_address = uc.reg_read(regs.UC_MIPS_REG_RA)
        for i, r in enumerate(CALLER_SAVED):
            uc.reg_write(r, 0xABCD0000 + i * 0x111)
        uc.reg_write(regs.UC_MIPS_REG_V0, (response >> 32 if address == 0x80061450 else response) & 0xFFFFFFFF)
        uc.reg_write(regs.UC_MIPS_REG_V1, response & 0xFFFFFFFF)
        # Unicorn's direct MIPS FPU register API is unavailable. The short
        # mtc1 stub poisons F0..F19, then returns through the real call's RA.
        assert return_address == uc.reg_read(regs.UC_MIPS_REG_RA)
        uc.reg_write(regs.UC_MIPS_REG_PC, FLOAT_CLOBBER)

    def guard_read(uc, access, address, n, v, user):
        address = (address & 0x1FFFFFFF) | 0x80000000
        assert inside(address, n, read_ranges + (stack_range,)), ('Read bounds', hex(address), n)

    def guard_write(uc, access, address, n, v, user):
        address = (address & 0x1FFFFFFF) | 0x80000000
        assert inside(address, n, read_ranges + (stack_range,)), ('Write bounds', hex(address), n)
        if not inside(address, n, (stack_range,)):
            writes[address, n] += 1

    uc.hook_add(UC_HOOK_CODE, guard_code)
    uc.hook_add(UC_HOOK_MEM_READ, guard_read)
    uc.hook_add(UC_HOOK_MEM_WRITE, guard_write)
    uc.emu_start(entry, 0, count=200000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, 'Instruction bound or missing return'
    assert all(uc.reg_read(r) == v for r, v in preserved.items()), 'O32 preservation'
    assert trace == wanted, 'Complete service trace'
    assert writes == cpu_stores, ('Exact CPU store coverage', writes - cpu_stores, cpu_stores - writes)
    uc.emu_start(READ_FPU, 0, count=1000)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL, 'FPU observer return'
    fp_stores = Counter({(FPU_OUT + i * 4, 4): 1 for i in range(12)})
    assert writes == cpu_stores + fp_stores, 'Complete CPU and observer stores'
    for name, (address, data) in panels.items():
        assert bytes(uc.mem_read(address & 0x1FFFFFFF, len(data))) == expected[name], ('Complete guarded object', kind, name)
    assert bytes(uc.mem_read((STACK - 0x210) & 0x1FFFFFFF, 16)) == lower, 'Lower stack guard'
    assert bytes(uc.mem_read((STACK + 32) & 0x1FFFFFFF, 16)) == upper, 'Upper stack guard'
    if kind == 'heap_allocate':
        assert uc.reg_read(regs.UC_MIPS_REG_V0) == result & 0xFFFFFFFF, 'Allocator return'
    return {'case': {'kind': kind, 'seed': seed, 'television': television, 'priority': priority,
                     'sizes': list(sizes), 'messages': list(messages), 'nulls': list(nulls),
                     'failures': list(failures), 'clock': clock, 'value': value, 'mode': mode,
                     'offset': offset, 'length': length, 'used': used, 'count': count, 'size': size},
            'trace': trace, 'cpu_stores': sum(writes.values()),
            'objects_sha256': {name: hashlib.sha256(data).hexdigest() for name, data in expected.items()}}


def prepare_images():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    data = {}
    for name, address, size in STORAGE:
        source = f'src/game/audio/startup/{name}.c'
        records = source_sections(source)
        assert len(records) == 1 and records[0]['rom'] is None
        assert (records[0]['vram'], records[0]['size']) == (address, size)
        data[source] = compare_unit(source, records, target, layout)
    comparisons, original, compiled = {}, [], []
    for name, source, start, end in MATCHING_BLOCKS:
        if name not in SUPPORT:
            continue
        report = compare_block(name, source, start, start - 0x7FFFF400, end - 0x7FFFF400,
                               target, family='audio-startup-storage-check', layout=layout)
        assert report['matches'], (name, report['different_words'])
        comparisons[name] = report
        original.append((start, target[start - 0x7FFFF400:end - 0x7FFFF400]))
        compiled.append((start, (ROOT / 'build/audio-startup-storage-check' / name / (name + '.bin')).read_bytes()))
    assert set(comparisons) == set(SUPPORT)
    return target, layout, data, comparisons, original, compiled, tuple((a, a + len(b)) for a, b in original)


MUTATIONS = {
    'short_task_ring': ('src/game/audio_startup.c', 'index < 3', 'index < 2', dict(kind='startup')),
    'short_heap': ('src/game/audio_startup.c', 'D_8014C080, 0x41EB0', 'D_8014C080, 0x41EA0', dict(kind='startup')),
    'stack_top': ('src/game/audio_startup.c', 'D_8018DF30 + 0x2000', 'D_8018DF30 + 0x1FF0', dict(kind='startup')),
    'short_queue': ('src/game/audio_startup.c', 'D_8018FF80, 8', 'D_8018FF80, 7', dict(kind='startup')),
    'cursor_advance': ('src/game/audio_startup.c', 'D_80190150 += 0x10', 'D_80190150 += 0x0C', dict(kind='startup')),
    'two_scheduler_slots': ('src/game/audio_thread.c', 'next % 3', 'next % 2', dict(kind='thread')),
    'completion_queue': ('src/game/audio_thread.c', 'task->completionQueue = &D_8018FF68', 'task->completionQueue = &D_8018FF30', dict(kind='thread')),
    'generation_mode': ('src/game/audio_generation.c', 'D_80190168 = mode;', 'D_80190168 = 0;', dict(kind='generation')),
}


def mutation_check(name):
    if ROOT.parent.name != '.local' or not ROOT.name.startswith('audio-startup-storage-' + name + '-'):
        raise ValueError('Source mutations require an isolated audit directory')
    target, layout, _, _, original, compiled, ranges = prepare_images()
    relative, old, new, case = MUTATIONS[name]
    assert run(original, ranges, seed=173, **case) == run(compiled, ranges, seed=173, **case), 'Mutation positive control'
    path = ROOT / relative
    content = path.read_text()
    assert content.count(old) == 1, ('Mutation anchor', name)
    path.write_text(content.replace(old, new))
    _, _, start, end = next(row for row in MATCHING_BLOCKS if row[1] == relative)
    # Isolate a changed-size image at its own retail base. Exclude the adjacent
    # consumer so a rejection cannot be caused by overwriting its instructions.
    report = compare_block('mutated', relative, start, start - 0x7FFFF400, end - 0x7FFFF400,
                           target, family='audio-startup-storage-mutations', layout=layout)
    assert not report['matches'], 'Unchanged mutation'
    blob = (ROOT / 'build/audio-startup-storage-mutations/mutated/mutated.bin').read_bytes()
    excluded = {0x8005109C, 0x80051380, 0x800515B0}
    candidate = [(a, b) for a, b in compiled if a not in excluded] + [(start, blob)]
    bounds = tuple((a, a + len(b)) for a, b in candidate)
    try:
        run(candidate, bounds, seed=173, **case)
    except AssertionError as error:
        print(json.dumps({'name': name, 'control_passed': True, 'mutation_rejected': True,
                          'different_words': len(report['different_words']), 'actual_size': report['actual_size'],
                          'reason': str(error)}))
        return
    raise ValueError('Audio startup checker missed mutation: ' + name)


def check_mutations():
    results = []
    for name in MUTATIONS:
        with tempfile.TemporaryDirectory(prefix='audio-startup-storage-' + name + '-', dir=ROOT / '.local') as temporary:
            root = Path(temporary)
            assert root.resolve().parent == (ROOT / '.local').resolve()
            for folder in ('src', 'include', 'config', 'tools', 'docs'):
                shutil.copytree(ROOT / folder, root / folder)
            shutil.copy2(ROOT / 'Makefile', root / 'Makefile')
            (root / '.local').mkdir()
            (root / '.local/toolchain').symlink_to(ROOT / '.local/toolchain', target_is_directory=True)
            (root / 'baseroms/us').mkdir(parents=True)
            (root / 'baseroms/us/baserom.z64').symlink_to(ROOT / 'baseroms/us/baserom.z64')
            result = subprocess.run([sys.executable, str(root / 'tools/check_audio_startup_storage.py'), '--mutation', name], capture_output=True, text=True)
            if result.returncode:
                raise ValueError(f'Audio startup mutation {name} failed:\n{result.stdout}\n{result.stderr}')
            record = json.loads(result.stdout.splitlines()[-1])
            assert record['control_passed'] and record['mutation_rejected']
            results.append(record)
    return results


def main(mutations=False):
    target, layout, data, comparisons, original, compiled, ranges = prepare_images()
    cases = []
    sequences = ((10,), (1, 1, 1, 1, 1, 1, 1, 10), (3, 1, 1, 1, 1, 1, 1, 1, 10),
                 (-1, 0, 2, 32767, -32768, 1, 10), (1, 3, 1, 1, 1, 1, 1, 10))
    for seed in (0, 173, 255):
        for television, priority, sizes in itertools.product((-1, 0, 1, 2, 3), (1, 20, 127),
                ((1, 15, 17), (32, 48, 64), (269952, 16, 16))):
            cases.append(dict(kind='startup', seed=seed, television=television, priority=priority, sizes=sizes))
        for messages, nulls, failures, clock in itertools.product(sequences, ((), (0,), (0, 1, 3)),
                ((), (0, 1, 2, 3, 4, 5, 6)), (0, 0x12345678FFFFFFF0, 0xFFFFFFFFFFFFFFF0)):
            cases.append(dict(kind='thread', seed=seed, messages=messages, nulls=nulls, failures=failures, clock=clock))
        for value, mode in itertools.product((-11, 0, 1, 2, 11, 12, 99), (-1, 0, 1, 7)):
            cases.append(dict(kind='generation', seed=seed, value=value, mode=mode))
        for offset, length in itertools.product(range(16), (0, 32)):
            cases.append(dict(kind='heap_init', seed=seed, offset=offset, length=length))
        for used, count, size in itertools.product((0, 16, 32), (0, 1, 3), (0, 1, 4, 15, 16, 17, 32)):
            cases.append(dict(kind='heap_allocate', seed=seed, used=used, count=count, size=size))
        for used, size in ((0, HEAP_SIZE), (HEAP_SIZE - 16, 4), (HEAP_SIZE, 1), (HEAP_SIZE, 0)):
            cases.append(dict(kind='heap_allocate', seed=seed, length=HEAP_SIZE, used=used, size=size))
    results = []
    for case in cases:
        retail = run(original, ranges, **case)
        recovered = run(compiled, ranges, **case)
        assert retail == recovered, case
        results.append(recovered)
    mutation_results = check_mutations() if mutations else []
    layout.verify()
    report = {'matches': True, 'paired_cases': len(cases), 'target_executions': len(cases) * 2,
              'bss_bytes': 279320, 'unowned_gap': [0x80190154, 0x80190158],
              'storage': data, 'comparisons': comparisons, 'cases': results, 'mutations': mutation_results,
              'versions': {name: version(name) for name in ('unicorn', 'capstone', 'pyelftools')},
              'boundaries': {hex(address): count for address, count in BOUNDARIES.items()},
              'limitations': ['SDK heap initialization/allocation, queue initialization and initialized game heap allocation/free execute real matching instructions.',
                              'Audio engine, loader, OS thread, scheduler, queue transport and clock calls use recorded O32 boundaries with caller-saved integer, F0..F19 and HI/LO clobbering. Normal returns check F20..F31.',
                              'Loader bytes are synthetic bounded fixtures. OS creation does not write the thread record or execute its stack.',
                              'Generation cases cover selection of the already-current sequence, including requested-index wrapping and mode storage; sequence replacement is not executed.',
                              'The game heap is preinitialized; its excluded initializer is not called. Heap requests are nonnegative and avoid signed multiplication overflow.',
                              'Every byte of all ten objects, the unowned gap and neighboring guards is compared; no audio playback, RSP hardware or complete gameplay claim is made.']}
    path = ROOT / 'build/audio-startup-storage-check/report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: report[key] for key in ('matches', 'paired_cases', 'target_executions', 'bss_bytes')}))
    print(f'Rejected {len(mutation_results)} source mutations; report: {path.relative_to(ROOT)}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mutation', choices=MUTATIONS)
    parser.add_argument('--mutations', action='store_true')
    args = parser.parse_args()
    mutation_check(args.mutation) if args.mutation else main(args.mutations)
