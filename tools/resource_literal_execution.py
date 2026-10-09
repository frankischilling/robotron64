"""Bounded literal consumers and independent call/memory oracles.

Fatal fixtures stop at the checked call. Returning service boundaries clobber
caller-saved integer and floating-point registers. Real matching C constructs
all paths; file I/O and script interpretation remain outside this audit.
"""
import hashlib
import struct
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from check_actor_group_path import machine, word, SENTINEL

STACK, RESOURCE, INPUT, POOL, TABLE = 0x80300000, 0x80210010, 0x80211010, 0x8009FC50, 0x800A3AD8
ANIMATION, BASE, LOAD, FATAL, ENTRY = 0x80211010, 0x800906D0, 0x8003CB10, 0x8001C0D0, 0x8001CE70
FP_INIT, FP_STUB, FP_RETURN = 0x80001800, 0x80001000, 0x80002000
FP_SEED, FP_RESULT = 0x80003000, 0x80003100
CALLER_SAVED = tuple(getattr(regs, 'UC_MIPS_REG_' + name) for name in
                    ('V0', 'V1', 'A0', 'A1', 'A2', 'A3', 'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9'))
FP_VALUES = b''.join(word(0x3F000000 + index * 0x10000) for index in range(32))

def literal_machine(code, entry):
    """Use guest loads/stores because this Unicorn MIPS API cannot read FPRs."""
    initializer = b''.join(word(0xC4003000 | index << 16 | index * 4) for index in range(32))
    initializer += word(0x8000000 | ((entry >> 2) & 0x3FFFFFF)) + word(0)
    clobber = b''.join(word(0xC4003080 | index << 16) for index in range(20))
    clobber += word(0x3E00008) + word(0)
    observer = b''.join(word(0xE4003100 | index << 16 | (index - 20) * 4) for index in range(20, 32))
    observer += word(0x8000000 | ((SENTINEL >> 2) & 0x3FFFFFF)) + word(0)
    code = code + [(FP_INIT, initializer), (FP_STUB, clobber), (FP_RETURN, observer)]
    uc, write, execute = machine(code, [])
    uc.reg_write(regs.UC_MIPS_REG_CP0_STATUS, uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | (1 << 29))
    write(FP_SEED - 16, b'\xA7' * 16 + FP_VALUES + word(0x42E00000) + b'\xB9' * 16)
    write(FP_RESULT - 16, b'\xA7' * 16 + b'\x89' * 48 + b'\xB9' * 16)
    uc.reg_write(regs.UC_MIPS_REG_RA, FP_RETURN)
    return uc, write, execute, code

def verify_fpu(uc):
    seed = bytes(uc.mem_read((FP_SEED - 16) & 0x1FFFFFFF, 164))
    result = bytes(uc.mem_read((FP_RESULT - 16) & 0x1FFFFFFF, 80))
    assert seed == b'\xA7' * 16 + FP_VALUES + word(0x42E00000) + b'\xB9' * 16
    assert result == b'\xA7' * 16 + FP_VALUES[80:] + b'\xB9' * 16, 'Twelve distinct saved FPU words and guards'

def half(value):
    return struct.pack('>H', value & 65535)

def pattern(size):
    return bytes((i * 37 + 19 & 255 for i in range(size)))

def run_consumers(code, literals, case):
    kind = case[0]
    entry_address = {'scene': 0x8001CBE8, 'level': 0x8001CC5C, 'setup': 0x8001CD1C, 'resource': 0x8001CF68}[kind]
    uc, write, execute, code = literal_machine(code, entry_address)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA5728193)
    panels = list(literals)
    writable = []
    wanted = []
    expected = {}
    fatal = False
    result = None

    def panel(address, data, change=None):
        panels.append((address, bytes(data)))
        expected[address] = bytes(data if change is None else change)
        if change is not None:
            writable.append((address, address + len(data)))

    def event(address, args, return_value=0, terminate=False):
        wanted.append((address, args, return_value, terminate))
    if kind in ('scene', 'level'):
        _, count, name, level = case
        panel(INPUT, word(113) + word(name))
        uc.reg_write(regs.UC_MIPS_REG_A0, INPUT)
        if kind == 'scene':
            data = pattern(640)
            change = bytearray(data)
            fatal = count == 80
            if not fatal:
                change[count * 8:count * 8 + 8] = word(level) + word(name)
            panel(0x800A42B0, data, change)
            panel(0x800A4530, word(count), word(count + (not fatal)))
            panel(0x800BA7A0, word(level))
            if fatal:
                event(0x8001C0D0, [0x80090690, b'too many BFFs'], terminate=True)
        else:
            data = pattern(880)
            change = bytearray(data)
            fatal = count >= 220
            if not fatal:
                change[count * 4:count * 4 + 4] = word(name)
            panel(0x800BAB18, data, change)
            panel(0x800BA7A0, word(count), word(count + (not fatal)))
            if fatal:
                event(0x8001C0D0, [0x800906A0, b'Too many Levels defined\n'], terminate=True)
    elif kind == 'setup':
        _, filename = case
        panel(INPUT, filename + b'\x00')
        uc.reg_write(regs.UC_MIPS_REG_A0, INPUT)
        event(0x80038498, [0x800906BC, b'STRINGS.STR'])
        event(0x8003264C, [INPUT, 0x80077EB8, 1])
    else:
        _, model, bitmap, texture, geometry, tex_result, defined, loaded, reserve = case
        resource = bytearray(pattern(88))
        resource[1] = 255
        resource[4:8] = word(16384 if defined else 0)
        if loaded:
            resource[6] |= 128
        for offset, value in ((28, -7), (30, 0), (32, -3), (34, 2), (36, -5), (38, -1 if bitmap is None else 1)):
            resource[offset:offset + 2] = half(value)
        resource[40:80] = bytes(40)
        change = bytearray(resource)
        pool = model + b'\x00' + (bitmap or b'absent') + b'\x00' + texture + b'\x00'
        offsets = half(0) + half(len(model) + 1) + half(len(model) + 1 + len(bitmap or b'absent') + 1)
        panel(POOL, pool)
        panel(TABLE, offsets)
        uc.reg_write(regs.UC_MIPS_REG_A0, RESOURCE)
        uc.reg_write(regs.UC_MIPS_REG_A1, geometry & 0xFFFFFFFF)
        if loaded:
            result = 2
        elif not defined:
            fatal = True
            event(0x8001C0D0, [0x80090704, b'Trying to load a gfx that has not been defined\n'], terminate=True)
        else:
            event(0x800391C0, [255], reserve)
            if reserve == -1:
                fatal = True
                event(0x8001C0D0, [0x80090734, b'Too many chars defined'], terminate=True)
            else:
                if geometry:
                    event(0x8003C94C, [255, 0xFFFFFFF9, b'MODELS\\' + model.split(b'.', 1)[0], 0], 32768)
                    change[28:30] = half(32768)
                else:
                    change[28:30] = half(-1)
                if bitmap is not None:
                    event(0x8003CA34, [0xFFFFFFFB, b'TEXTURES\\' + bitmap.split(b'.', 1)[0] + b'.BMP', 1], 65535)
                    change[36:38] = half(65535)
                if geometry:
                    path = b'TEXTURES\\' + texture.split(b'.', 1)[0] + b'.TXR'
                    event(0x8003CA24, [255, 0xFFFFFFFD, path], tex_result)
                    change[32:34] = half(tex_result)
                    if tex_result & 65535 == 65535:
                        fatal = True
                        event(0x8001C0D0, [0x8009078C, b'Load Texture Map %s failed\n', path], terminate=True)
                    else:
                        change[32:34] = half(-1)
                if not fatal:
                    change[6] |= 128
                    result = 1
        panel(RESOURCE, resource, change)
    guards = (b'\xa7' * 16, b'\xb9' * 16)
    regions = []
    for address, data in sorted(panels):
        expected.setdefault(address, data)
        if regions and address <= regions[-1][1] + 32:
            regions[-1][1] = max(regions[-1][1], address + len(data))
        else:
            regions.append([address, address + len(data)])
    images = []
    for start, end in regions:
        initial = bytearray(b'\xc3' * (end - start))
        changed = bytearray(initial)
        for address, data in panels:
            if start <= address and address + len(data) <= end:
                initial[address - start:address - start + len(data)] = data
                changed[address - start:address - start + len(data)] = expected[address]
        write(start - 16, guards[0] + initial + guards[1])
        images.append((start - 16, guards[0] + changed + guards[1]))
    write(STACK - 1040, guards[0])
    write(STACK - 1024, b'\xc9' * 1056)
    write(STACK + 32, guards[1])
    reads = [(a, a + len(b)) for a, b in panels] + [(STACK - 1024, STACK + 32), (FP_SEED, FP_SEED + 132)]
    writes = writable + [(STACK - 1024, STACK + 32), (FP_RESULT, FP_RESULT + 48)]
    ranges = [(a, a + len(b)) for a, b in code]
    trace = []
    stopped = [False]
    services = {x[0] for x in wanted}

    def inside(address, size, bounds):
        address = address & 0x1FFFFFFF | 0x80000000
        return any((a <= address and address + size <= b for a, b in bounds))

    def string(pointer):
        output = bytearray()
        for offset in range(100):
            assert inside(pointer + offset, 1, reads), ('Boundary string bounds', hex(pointer + offset))
            value = bytes(uc.mem_read(pointer + offset & 0x1FFFFFFF, 1))[0]
            if not value:
                return bytes(output)
            output.append(value)
        raise AssertionError('Boundary string unterminated')

    def instruction(uc, address, size, user):
        assert address == SENTINEL or address in services or inside(address, size, ranges), ('Instruction bounds', hex(address))
        if address not in services:
            return
        assert len(trace) < len(wanted)
        callee, args, reply, terminate = wanted[len(trace)]
        assert address == callee
        actual = [uc.reg_read(getattr(regs, 'UC_MIPS_REG_A' + str(i))) for i in range(4)]
        if address == 0x8001C0D0:
            observed = [actual[0], string(actual[0])] + ([string(actual[1])] if len(args) > 2 else [])
        elif address == 0x80038498:
            observed = [actual[0], string(actual[0])]
        elif address in (0x8003C94C, 0x8003CA24):
            observed = actual[:2] + [string(actual[2])] + (actual[3:4] if len(args) == 4 else [])
        elif address == 0x8003CA34:
            observed = [actual[0], string(actual[1]), actual[2]]
        else:
            observed = actual[:len(args)]
        assert observed == args, ('Independent service arguments/order', kind, hex(address), observed, args)
        trace.append([address, [x.hex() if isinstance(x, bytes) else x for x in observed]])
        if terminate:
            stopped[0] = True
            uc.emu_stop()
            return
        for index, reg in enumerate(CALLER_SAVED):
            uc.reg_write(reg, 0xABCD1000 + index * 17)
        uc.reg_write(regs.UC_MIPS_REG_V0, reply & 0xFFFFFFFF)
        uc.reg_write(regs.UC_MIPS_REG_PC, FP_STUB)

    def read(uc, access, address, size, value, user):
        assert inside(address, size, reads), ('Read bounds', hex(address), size)

    def store(uc, access, address, size, value, user):
        assert inside(address, size, writes), ('Write bounds', hex(address), size)
    uc.hook_add(UC_HOOK_CODE, instruction)
    uc.hook_add(UC_HOOK_MEM_READ, read)
    uc.hook_add(UC_HOOK_MEM_WRITE, store)
    if fatal:
        uc.emu_start(FP_INIT, 0, count=20000)
        assert stopped[0], 'Fatal boundary was not reached'
    else:
        execute(FP_INIT)
        assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xA5728193 and uc.reg_read(regs.UC_MIPS_REG_RA) == FP_RETURN
        if result is not None:
            assert uc.reg_read(regs.UC_MIPS_REG_V0) == result
    if fatal:
        uc.emu_start(FP_RETURN, 0, count=50)
    verify_fpu(uc)
    assert len(trace) == len(wanted)
    for address, data in images:
        assert bytes(uc.mem_read(address & 0x1FFFFFFF, len(data))) == data, ('Complete objects/data/guards', hex(address))
    assert bytes(uc.mem_read(STACK - 1040 & 0x1FFFFFFF, 16)) == guards[0] and bytes(uc.mem_read(STACK + 32 & 0x1FFFFFFF, 16)) == guards[1]
    return {'kind': kind, 'trace': trace, 'fatal_boundary_reached': fatal, 'result': result, 'objects_sha256': hashlib.sha256(b''.join(expected.values())).hexdigest()}

def run_animation(code, data, case):
    identifier, name, result, reference, kind, initial = case
    uc, write, execute, code = literal_machine(code, ENTRY)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA5728193)
    resource = bytearray((i * 23 + 19 & 255 for i in range(88)))
    resource[1] = kind
    animation = bytearray((i * 37 + 7 & 255 for i in range(16)))
    animation[8:10] = half(identifier)
    animation[10:12] = half(initial)
    expected = bytearray(animation)
    if identifier >= 0:
        expected[10:12] = half(result)
    elif identifier != -2:
        expected[10:12] = half(reference)
    offsets = half(0) + bytes(14)
    pool = name + b'\x00'
    guards = (b'\xa7' * 16, b'\xb9' * 16)
    panels = [(RESOURCE, bytes(resource)), (ANIMATION, bytes(animation)), (POOL, pool), (TABLE, offsets), (BASE, data)]
    for address, blob in panels:
        write(address - 16, guards[0] + blob + guards[1])
    write(STACK - 1040, guards[0])
    write(STACK - 1024, b'\xc9' * 1056)
    write(STACK + 32, guards[1])
    for reg, value in [(regs.UC_MIPS_REG_A0, RESOURCE), (regs.UC_MIPS_REG_A1, ANIMATION), (regs.UC_MIPS_REG_A2, reference & 0xFFFFFFFF)]:
        uc.reg_write(reg, value)
    ranges = [(a, a + len(b)) for a, b in code]
    reads = [(a, a + len(b)) for a, b in panels] + [(STACK - 1024, STACK + 32), (FP_SEED, FP_SEED + 132)]
    writes = [(ANIMATION, ANIMATION + 16), (STACK - 1024, STACK + 32), (FP_RESULT, FP_RESULT + 48)]
    path = b'KINS\\' + name.split(b'.', 1)[0] + b'.KIN'
    wanted = []
    if identifier >= 0:
        wanted.append(['load', kind, initial & 0xFFFFFFFF, path.hex(), identifier])
        if result & 65535 == 65535:
            wanted.append(['fatal', 0x800906E8, b'Load Kinemation %s failed\n'.hex(), path.hex()])
    trace = []

    def inside(address, size, bounds):
        address = address & 0x1FFFFFFF | 0x80000000
        return any((a <= address and address + size <= b for a, b in bounds))

    def string(pointer, bounds):
        output = bytearray()
        for offset in range(100):
            assert inside(pointer + offset, 1, bounds), ('Host boundary string bounds', hex(pointer + offset))
            ch = bytes(uc.mem_read(pointer + offset & 0x1FFFFFFF, 1))[0]
            if ch == 0:
                return bytes(output)
            output.append(ch)
        raise AssertionError('Boundary string lacks terminator')

    def instruction(uc, address, size, user):
        assert address in (SENTINEL, LOAD, FATAL) or inside(address, size, ranges), ('Instruction bounds', hex(address))
        if address not in (LOAD, FATAL):
            return
        args = [uc.reg_read(getattr(regs, 'UC_MIPS_REG_A' + str(i))) for i in range(4)]
        if address == LOAD:
            event = ['load', args[0], args[1], string(args[2], [(STACK - 1024, STACK + 32)]).hex(), args[3]]
        else:
            event = ['fatal', args[0], string(args[0], [(BASE, BASE + 52)]).hex(), string(args[1], [(STACK - 1024, STACK + 32)]).hex()]
        assert len(trace) < len(wanted) and event == wanted[len(trace)], ('Service arguments/path/order', event, wanted)
        trace.append(event)
        for i, reg in enumerate(CALLER_SAVED):
            uc.reg_write(reg, 0xABCD1000 + i * 17)
        uc.reg_write(regs.UC_MIPS_REG_V0, result & 0xFFFFFFFF if address == LOAD else 0)
        uc.reg_write(regs.UC_MIPS_REG_PC, FP_STUB)

    def read(uc, access, address, size, value, user):
        assert inside(address, size, reads), ('Read bounds', hex(address), size)

    def store(uc, access, address, size, value, user):
        assert inside(address, size, writes), ('Write bounds', hex(address), size)
    uc.hook_add(UC_HOOK_CODE, instruction)
    uc.hook_add(UC_HOOK_MEM_READ, read)
    uc.hook_add(UC_HOOK_MEM_WRITE, store)
    execute(FP_INIT)
    verify_fpu(uc)
    assert trace == wanted and uc.reg_read(regs.UC_MIPS_REG_GP) == 0xA5728193 and (uc.reg_read(regs.UC_MIPS_REG_RA) == FP_RETURN)
    for address, blob in panels:
        body = bytes(expected) if address == ANIMATION else blob
        assert bytes(uc.mem_read(address - 16 & 0x1FFFFFFF, len(blob) + 32)) == guards[0] + body + guards[1], ('Full object/data/guards', hex(address))
    assert bytes(uc.mem_read(STACK - 1040 & 0x1FFFFFFF, 16)) == guards[0] and bytes(uc.mem_read(STACK + 32 & 0x1FFFFFFF, 16)) == guards[1]
    return {'case': [identifier, name.hex(), result, reference, kind, initial], 'trace': trace, 'animation': expected.hex()}
