"""Independent finite CPU/memory model for the excluded actor ring callback.

Integer wrap, arithmetic shifts and signed halfword stores describe the pinned
MIPS execution. Display words are checked; RSP/RDP execution is outside this model.
"""

import math
import struct

def word(value):
    return struct.pack('>I', value & 0xFFFFFFFF)

ENTRY,STACK,ACTOR,DLIST=0x80006240,0x80300000,0x80210000,0x80200000
OBJECTS,POOL,MATRIX,CAMERA=0x800BF918,0x800CDBD0,0x800CD250,0x800C8BD8
CURSOR,ALLOCATOR,FRAME_BASE,MODE,ALPHA,FLAG,DL_CURSOR=0x80123AE4,0x80126B84,0x80123B20,0x8007D5D8,0x80123AE8,0x800C85B8,0x80138254
MAT_CURSOR,MAT_SLOT,MAT_POOL,PALETTE=0x8007D6A8,0x8007D910,0x80126B90,0x8007BB34
BOOT,RETURN,FP_INPUT,FP_OUTPUT=0x80290000,0x80290100,0x802A0000,0x802A0100

def signed(v):
    return (v&0x7FFFFFFF)-(v&0x80000000)
def locate(data,address,size):
    for start,payload in data.items():
        if start<=address and address+size<=start+len(payload):return payload,address-start
    raise AssertionError(('Outside fixture',hex(address),size))
def put(data,address,payload):
    block,offset=locate(data,address,len(payload));block[offset:offset+len(payload)]=payload
def u32(data,address):
    block,offset=locate(data,address,4);return int.from_bytes(block[offset:offset+4],'big')
def vector(data,address):return tuple(signed(u32(data,address+4*i)) for i in range(3))
def narrow16(v):return (v&0x7FFF)-(v&0x8000)
def scaled_sine(angle):
    phase=angle&4095;index=phase&1023
    if phase&1024:index=1023-index
    v=math.floor(32767*math.sin(index*math.pi/2046))
    if phase&2048:v=-v
    return int(v/8)
def initial(case):
    state,first,mode,index,matrix_id,rgb_id=case
    object_address=OBJECTS+index*120
    matrix_number,slot=7,1
    matrix_address=MAT_POOL+matrix_number*128+slot*64
    matrices=((32768,0,0,0,32768,0,0,0,32768),
              (16000,-21000,7000,32767,32768,-1000,-22000,137,31000),
              (0x7FFFFFFF,-0x80000000,-1,1,-32768,32768,0,65535,-65536))
    matrix=matrices[matrix_id]
    coords=((12345,-6789,4567),(-64001,64001,0x7FFFFFFF),(0x7FFFFFFF,-0x80000000,-1))[matrix_id]
    camera=((12,-23,34),(64000,-64000,-1),(-1,1,-0x80000000))[matrix_id]
    color=((17,93,201),(0,255,128),(255,1,0))[rgb_id]
    failed=signed(first-0)>9800 or first==-1
    ranges=[(ACTOR-16,ACTOR+124+16),(object_address-16,object_address+120+16),
            (CAMERA-16,CAMERA+40+16),(MATRIX-16,MATRIX+36+16),
            (matrix_address-16,matrix_address+64+16),(DLIST-16,DLIST+512),
            (PALETTE+4-16,PALETTE+8+16)]
    if not failed:ranges.append((POOL+first*16-16,POOL+(first+32)*16+16))
    ranges += [(address-16,address+20) for address in (CURSOR,ALLOCATOR,FRAME_BASE,MODE,ALPHA,FLAG,DL_CURSOR,MAT_CURSOR,MAT_SLOT)]
    merged=[]
    for a,b in sorted(ranges):
        if merged and a<=merged[-1][1]:merged[-1]=(merged[-1][0],max(merged[-1][1],b))
        else:merged.append((a,b))
    data={a:bytearray((a+i*43+matrix_id*31+rgb_id*17)&255 for i in range(b-a)) for a,b in merged}
    for a,v in ((ACTOR+0x4C,state),(CURSOR,139),(ALLOCATOR,first),(FRAME_BASE,0),(MODE,mode),
                (ALPHA,89),(FLAG,37),(DL_CURSOR,DLIST),(MAT_CURSOR,matrix_number),(MAT_SLOT,slot)):
        put(data,a,word(v))
    put(data,ACTOR+0x0C,struct.pack('>h',index))
    for start,values in ((object_address+0x54,coords),(CAMERA+0x1C,camera),(MATRIX,matrix)):
        put(data,start,b''.join(word(v) for v in values))
    put(data,PALETTE+4,bytes(color))
    return data,dict(object=object_address,matrix_address=matrix_address,matrix_number=matrix_number,slot=slot,
                     matrix=matrix,coords=coords,camera=camera,color=color,failed=failed)
def oracle(data,case,info):
    state,first,mode,index,matrix_id,rgb_id=case
    expected={a:bytearray(b) for a,b in data.items()};allowed=[];trace=[];packets=[]
    def store(a,b):put(expected,a,b);allowed.append((a,a+len(b)))
    def command(a,b):packets.append((a&0xFFFFFFFF,b&0xFFFFFFFF))
    trace.append((0x8004729C,1))
    if mode!=1:
        if mode==18:command(0xB9000002,0)
        store(MODE,word(1));command(0xE7000000,0);trace.append((0x80046774,None))
        for a,b in ((0xB6000000,0x60000),(0xB7000000,0x205),(0xFCFFFFFF,0xFFFE793C),(0xB900031D,0x005049D8)):command(a,b)
        store(ALPHA,word(160));store(FLAG,word(0))
    trace.append((0x80047048,None))
    if signed(first)>9800:trace.append((0x80048DC0,'warning'))
    store(CURSOR,word(-1 if info['failed'] else first))
    result=1
    if not info['failed']:
        result=0
        trace.append((0x8003C14C,('color',1)))
        relative=tuple(signed(a-b)>>1 for a,b in zip(info['coords'],info['camera']))
        trace.append((0x8004D4B4,(info['object']+0x60,MATRIX,relative)))
        transformed=[]
        for row in range(3):
            products=[signed(relative[col]*info['matrix'][row*3+col])>>15 for col in range(3)]
            transformed.append(signed(sum(products)))
        trace.append((0x80047D88,(info['object']+0x38,MATRIX)))
        projected=[max(-32000,min(32000,v)) for v in transformed]
        for axis,value in enumerate(projected):store(info['object']+0x60+axis*4,word(value))
        high=[];low=[]
        for col in range(3):
            high.extend([narrow16(info['matrix'][row*3+col]>>15) for row in range(3)]+[0])
            low.extend([narrow16(info['matrix'][row*3+col]<<1) for row in range(3)]+[0])
        high.extend(projected+[1]);low.extend([0,0,0,0])
        store(info['matrix_address'],struct.pack('>32h',*(high+low)))
        command(0x01020040,info['matrix_address']-0x80000000)
        store(MAT_CURSOR,word(info['matrix_number']+1))
        alpha=max(10,signed(208-signed(state*10)))&255
        radius=signed(state*150+150)
        for point,angle in enumerate(range(0,4096,256)):
            trace.extend(((0x8003CC88,angle),(0x8005FC20,angle<<4),(0x8005FBB0,((angle<<4)+0x4000)&65535),
                          (0x8003CC58,angle),(0x8005FBB0,angle<<4)))
            x=narrow16(signed(scaled_sine(angle+1024)*radius)>>12)
            z=narrow16(signed(scaled_sine(angle)*radius)>>12)
            for ring,height in enumerate((100,300)):
                address=POOL+(first+point*2+ring)*16
                store(address,struct.pack('>3h',x,height,z))
                store(address+12,bytes(info['color'])+bytes([alpha]))
        command(0x040081FF,POOL+first*16)
        for point in range(16):
            a,b,c=(point*2+2)&31,(point*2+3)&31,(point*2+1)&31
            d=(point*4)&255
            command(0xB1000000|(a<<17)|(b<<9)|(c<<1),(a<<17)|(c<<9)|d)
            command(0xB1000000|(c<<17)|(b<<9)|(a<<1),(c<<17)|(a<<9)|d)
        trace.append((0x80047094,32));store(ALLOCATOR,word(first+32))
    payload=b''.join(word(a)+word(b) for a,b in packets)
    store(DLIST,payload);store(DL_CURSOR,word(DLIST+len(payload)))
    return expected,allowed,trace,result
