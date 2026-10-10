"""Finite movie command/path behavior with independent object and call oracles."""
import hashlib
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs
from resource_literal_execution import (literal_machine, verify_fpu, CALLER_SAVED,
    FP_INIT, FP_STUB, FP_RETURN, FP_SEED, FP_RESULT)
from check_actor_group_path import word, SENTINEL

CONFIG, COMMAND, INPUT = 0x80210010, 0x80212010, 0x80213010
HEADER, INTEGERS, FLOATS = 0x80215010, 0x80216010, 0x80217010
TRACKS, CURRENT, CONFIG_PTR = 0x800B00B8, 0x800972A0, 0x800B14A8
STACK = 0x80300000
EXPECTED = ((0x8008F840, b'Too many movie props\0'),
    (0x8008F858, b'Too many priFrames from prop %d\0'),
    (0x8008F878, b'Too many color cycles in movie\0'),
    (0x8008F898, b'Too many Movie strings\0'),
    (0x8008F8B0, b'PATHS\\\0'), (0x8008F8B8, b'.MOV\0'),
    (0x8008F8C0, b'.MOV\0'), (0x8008F8C8, b'All control paths used\0'),
    (0x8008F8E0, b'.STR\0'), (0x8008F8E8, b'.INT\0'),
    (0x8008F8F0, b'.FLT\0'), (0x8008F8F8, b'Too many movie Callbacks\0'),
    (0x8008F914, b'DO3DMOVIE\0'), (0x8008F920, b'ERASE SCREEN\0'))
LIMITS = {'prop': (0x80003184, 0x64, 10, 0x8008F840),
    'primary': (0x800032EC, None, 10, 0x8008F858),
    'cycle': (0x80003408, 0x480, 3, 0x8008F878),
    'string': (0x800036A4, 0x660, 7, 0x8008F898),
    'callback': (0x8000440C, 0x664, 3, 0x8008F8F8)}


def pattern(size, seed):
    return bytes((i * 37 + seed * 19 + i // 7) & 255 for i in range(size))


def inside(address, size, ranges):
    address = (address & 0x1FFFFFFF) | 0x80000000
    return any(a <= address and address + size <= b for a, b in ranges)


def run(code, arrays, case, fault=None):
    kind = case[0]
    entry = 0x80003A7C if kind == 'file' else 0x80004C3C if kind == 'update' else LIMITS[kind][0]
    uc, write, execute, loaded = literal_machine(code, entry)
    if fault is not None:
        kind_fault, item = fault
        if kind_fault == 'saved_fpu':
            assert 20 <= item < 32
            # Replace one caller-saved clobber with a guest load into a saved FPR.
            write(FP_STUB, word(0xC4003080 | item << 16))
        elif kind_fault == 'read_guard':
            write(FP_RETURN, word(0x8C022FF0))
        elif kind_fault == 'write_guard':
            write(FP_RETURN, word(0xAC0230F0))
        elif kind_fault == 'code_guard':
            write(FP_RETURN, word(0x08000420))
        else:
            raise AssertionError(('Unknown guest fault', fault))
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA5728193)
    panels, wanted, writable, saved = [], [], [], {}
    fatal, result = False, None
    literals = dict(EXPECTED)

    def panel(address, data, changed=None):
        panels.append((address, bytes(data), bytes(data if changed is None else changed)))
        if changed is not None: writable.append((address, address + len(data)))

    def event(address, args, reply=0, size_write=None, terminate=False):
        wanted.append((address, args, reply, size_write, terminate))

    def fatal_event(address, prop=None):
        args = [address, literals[address][:-1]]
        if prop is not None: args += [prop & 0xFFFFFFFF]
        event(0x8001C0D0, args, terminate=True)

    if kind in LIMITS:
        _, count, prop, value, seed = case
        config = bytearray(pattern(0x72C, seed)); change = bytearray(config)
        _, offset, limit, address = LIMITS[kind]
        if kind == 'primary': offset = 0x70 + prop * 0x68 + 0x14
        config[offset:offset + 4] = word(count); change[offset:offset + 4] = word(count)
        fatal = count >= limit if kind in ('prop', 'cycle') else count == limit
        command = b''.join(word(x) for x in (0x913, prop, value, -value, value + 37, value - 19))
        panel(COMMAND, command); panel(CONFIG_PTR, word(CONFIG))
        uc.reg_write(regs.UC_MIPS_REG_A0, COMMAND)
        if kind == 'callback':
            uc.reg_write(regs.UC_MIPS_REG_A0, 0x80012340 + prop * 4)
            uc.reg_write(regs.UC_MIPS_REG_A1, value & 0xFFFFFFFF)
        if fatal: fatal_event(address, prop if kind == 'primary' else None)
        else:
            if kind == 'prop':
                at = 0x70 + count * 0x68
                change[at:at + 2] = (prop & 65535).to_bytes(2, 'big')
                change[at + 2:at + 4] = ((value & 32767) << 1).to_bytes(2, 'big')
                change[at + 16:at + 20] = word(0)
            elif kind == 'primary':
                at = 0x70 + prop * 0x68
                change[at + 24 + count * 4:at + 28 + count * 4] = word(value)
                change[at + 64 + count * 4:at + 68 + count * 4] = word(-value)
            elif kind == 'cycle':
                change[0x484 + count * 4:0x488 + count * 4] = word(prop)
                change[0x490 + count * 4:0x494 + count * 4] = word(value)
            elif kind == 'string':
                at = 0x668 + count * 28
                for off, item in ((0, prop), (12, value), (16, value + 37), (20, -value), (24, value - 19)):
                    change[at + off:at + off + 4] = word(item)
            else:
                at = 0x648 + count * 8
                change[at:at + 8] = word(0x80012340 + prop * 4) + word(value)
            change[offset:offset + 4] = word(count + 1)
        panel(CONFIG, config, change)
    elif kind == 'file':
        _, name, slot, cached, int_count, float_count, seed = case
        identifier = 0x12345678
        tracks = bytearray(pattern(25 * 204, seed)); changed = bytearray(tracks)
        for i in range(25):
            tracks[i * 204 + 52:i * 204 + 56] = word(-1000 - i)
            tracks[i * 204 + 116:i * 204 + 120] = word(1)
        if slot is not None:
            if cached: tracks[slot * 204 + 52:slot * 204 + 56] = word(identifier)
            else: tracks[slot * 204 + 116:slot * 204 + 120] = word(0)
        changed[:] = tracks
        current = word(0x81234560); new_current = current
        header = bytearray(pattern(204, seed + 7))
        header[0x84:0x8C] = word(int_count) + word(float_count)
        panel(INPUT, name + b'\0'); panel(HEADER, header)
        panel(INTEGERS, pattern(64, seed + 11)); panel(FLOATS, pattern(64, seed + 13))
        uc.reg_write(regs.UC_MIPS_REG_A0, identifier); uc.reg_write(regs.UC_MIPS_REG_A1, INPUT)
        if cached: result = slot
        else:
            path = b'PATHS\\' + name
            dot = path.find(b'.')
            movie = (path[:dot] if dot >= 0 else path) + b'.MOV'
            if slot is None:
                fatal = True; fatal_event(0x8008F8C8)
            else:
                new_current = word(TRACKS + slot * 204)
                root = movie.split(b'.', 1)[0]
                event(0x8003C64C, [root + b'.STR', 'size'], HEADER, 204)
                event(0x8003C698, [HEADER])
                image = bytearray(header)
                if int_count:
                    event(0x8003C64C, [root + b'.INT', 'size'], INTEGERS, 64)
                    image[0xC4:0xC8] = word(INTEGERS)
                if float_count:
                    event(0x8003C64C, [root + b'.FLT', 'size'], FLOATS, 64)
                    image[0xC8:0xCC] = word(FLOATS)
                image[52:56] = word(identifier); image[116:120] = word(1)
                changed[slot * 204:(slot + 1) * 204] = image
                result = slot
        panel(TRACKS, tracks, changed); panel(CURRENT, current, new_current)
    else:
        _, erase, seed = case
        panel(CONFIG, pattern(0x72C, seed)); panel(CONFIG_PTR, word(CONFIG)); panel(0x800AD158, word(0))
        uc.reg_write(regs.UC_MIPS_REG_A0, erase & 0xFFFFFFFF)
        event(0x800360B8, [0x8008F914, b'DO3DMOVIE'])
        if erase: event(0x800360B8, [0x8008F920, b'ERASE SCREEN'])
        event(0x80005354, [], reply=1)

    for register in ('S0','S1','S2','S3','S4','S5','S6','S7','FP','GP'):
        r=getattr(regs,'UC_MIPS_REG_'+register); saved[r]=uc.reg_read(r)
    # Whole panels include two canaries. Guard holes separately from legal data.
    for a, initial, changed in panels: write(a - 16, b'\xA7' * 16 + initial + b'\xB9' * 16)
    for a, data in arrays: write(a, data)
    write(STACK - 1040, b'\xA7' * 16 + b'\xC9' * 1056 + b'\xB9' * 16)
    readable=[(a,a+len(data)) for a,data,_ in panels] + [(a,a+len(data)) for a,data in arrays]
    readable += [(STACK-1024,STACK+32),(FP_SEED,FP_SEED+132)]
    writable += [(STACK-1024,STACK+32),(FP_RESULT,FP_RESULT+48)]
    executable=[(a,a+len(data)) for a,data in loaded]
    services={e[0] for e in wanted};trace=[];stopped=[False]

    def read_bytes(address,length): return bytes(uc.mem_read(address & 0x1FFFFFFF,length))
    def string(address):
        out=bytearray()
        for off in range(256):
            assert inside(address+off,1,readable),('Service string bounds',hex(address+off))
            ch=read_bytes(address+off,1)[0]
            if ch==0:return bytes(out)
            out.append(ch)
        raise AssertionError('Unterminated boundary string')

    def instruction(uc,address,size,user):
        assert address==SENTINEL or address in services or inside(address,size,executable),('Code bounds',hex(address))
        if address not in services:return
        assert len(trace)<len(wanted),('Unexpected service call',hex(address))
        callee,args,reply,size_write,terminate=wanted[len(trace)]
        assert address==callee,('Call order',hex(address),hex(callee))
        actual=[uc.reg_read(getattr(regs,'UC_MIPS_REG_A'+str(i))) for i in range(4)]
        details=[]
        if address==0x8003C64C:
            path=string(actual[0]);assert path==args[0],('File path',path,args[0])
            assert actual[1]%4==0 and inside(actual[1],4,[(STACK-1024,STACK+32)]),'Size output pointer'
            write(actual[1],word(size_write));details=[path.hex(),size_write,reply]
        elif address in (0x8001C0D0,0x800360B8):
            assert actual[0]==args[0] and string(actual[0])==args[1],('Literal boundary',actual[0],args)
            if len(args)>2:assert actual[1]==args[2],('Fatal prop argument',actual[1],args[2])
            details=[args[0],args[1].hex()]+args[2:]
        else:
            assert actual[:len(args)]==args,('Service arguments',actual,args)
            details=args
        trace.append([address,details])
        if terminate:stopped[0]=True;uc.emu_stop();return
        for i,r in enumerate(CALLER_SAVED):uc.reg_write(r,0xABCD1000+i*17)
        uc.reg_write(regs.UC_MIPS_REG_HI,0xB1234567);uc.reg_write(regs.UC_MIPS_REG_LO,0xC1234567)
        uc.reg_write(regs.UC_MIPS_REG_V0,reply & 0xFFFFFFFF);uc.reg_write(regs.UC_MIPS_REG_PC,FP_STUB)

    def read(uc,access,address,size,value,user):
        assert inside(address,size,readable),('Read bounds',hex(address),size,case)
    def store(uc,access,address,size,value,user):
        assert inside(address,size,writable),('Write bounds',hex(address),size,case)
    uc.hook_add(UC_HOOK_CODE,instruction);uc.hook_add(UC_HOOK_MEM_READ,read);uc.hook_add(UC_HOOK_MEM_WRITE,store)
    if fatal:
        uc.emu_start(FP_INIT,0,count=20000);assert stopped[0],'Missing fatal call'
        uc.emu_start(FP_RETURN,0,count=50)
    else:
        execute(FP_INIT);assert uc.reg_read(regs.UC_MIPS_REG_RA)==FP_RETURN
        assert all(uc.reg_read(r)==value for r,value in saved.items()),'Saved integer registers'
        if result is not None:assert uc.reg_read(regs.UC_MIPS_REG_V0)==result,('Return value',case)
    verify_fpu(uc);assert len(trace)==len(wanted)
    digest=hashlib.sha256()
    for a,initial,changed in panels:
        expected=b'\xA7'*16+changed+b'\xB9'*16
        assert read_bytes(a-16,len(expected))==expected,('Complete object/guards',hex(a),case)
        digest.update(changed)
    for a,data in EXPECTED:
        assert read_bytes(a,len(data))==data,('Complete literal oracle',hex(a))
    assert read_bytes(STACK-1040,16)==b'\xA7'*16 and read_bytes(STACK+32,16)==b'\xB9'*16,'Stack canaries'
    return dict(kind=kind,trace=trace,fatal=fatal,result=result,objects_sha256=digest.hexdigest())
