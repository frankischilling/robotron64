"""Finite independent oracle for the missile callback and its real support."""
import math
import struct

ACTOR, RESOURCE, PLAYER0, PLAYER1, POOL = 0x80210000, 0x80212000, 0x80213000, 0x80213200, 0x80214000
POOL_RESOURCES = 0x80215000
ENTRY, TABLE, STACK = 0x80038830, 0x80094BF0, 0x80300000
NOW, DELTA, RESOURCES, INTERVAL, OPTIONS, PLAYERS, SESSION = 0x8009EFA0, 0x8009EF94, 0x800AC998, 0x800AC974, 0x800AD2F8, 0x8009B190, 0x800AD138
LIST, RANDOM, OBJECT = 0x800AA708, 0x8008F120, 0x800BF918
BOOT, RETURN, FP_INPUT, FP_OUTPUT = 0x80290000, 0x80290100, 0x802A0000, 0x802A0100
PARAMETERS = (
    (0, 0, 1, 31, 100, 1000, 0),
    (17, 2, 0, 1, -101, 250, 1),
    (0, 0, 17, -7, 0x7FFFFFFF, 500, 0),
    (250, 0, 1, 249, 1000, -1, 1),
    (-1, 2, 1, 10, -0x80000000, 4000, 0),
    (0, 0, 0, 127, 99, 0, 1),
    (0, 0, -1, 32767, -1000, 5000, 0),
    (17, 2, 17, -32768, 12345, 127, 1),
)

def word(v):
    return struct.pack('>I', v & 0xFFFFFFFF)

def signed(v):
    return ((v + 0x80000000) & 0xFFFFFFFF) - 0x80000000

def divide(a, b):
    assert b != 0
    return abs(a) // abs(b) * (-1 if (a < 0) != (b < 0) else 1)

def locate(data, a, n):
    for base, blob in data.items():
        if base <= a and a + n <= base + len(blob):
            return blob, a - base
    raise AssertionError(('Outside fixture', hex(a), n))

def put(data, a, value):
    blob, offset = locate(data, a, len(value))
    blob[offset:offset + len(value)] = value

def get(data, a, n=4, signed_value=False):
    blob, offset = locate(data, a, n)
    return int.from_bytes(blob[offset:offset + n], 'big', signed=signed_value)

def bytes_at(data, a, n):
    blob, offset = locate(data, a, n)
    return bytes(blob[offset:offset + n])

def trig(angle):
    phase = angle & 4095
    index = phase & 1023
    if phase & 1024:
        index = 1023 - index
    result = math.floor(32767 * math.sin(index * math.pi / 2046)) // 8
    return -result if phase & 2048 else result

TANGENT = tuple(math.floor(math.tan(i * math.pi / 256) * 32767 + 0.5) for i in range(65))

def heading(x, y):
    if x == 0:
        return 2048 if y < 0 else 0
    if y == 0:
        return 3072 if x < 0 else 1024
    quadrant = (1 if x < 0 else 0) | (2 if y < 0 else 0)
    x, y = abs(x), abs(y)
    value = divide(signed(min(x, y) * 32767), max(x, y))
    if value < TANGENT[1]:
        bucket = 0
    elif value > TANGENT[63]:
        bucket = 64
    else:
        # Inclusive shared endpoints follow the observed table search order.
        bucket, stride = 32, 16
        for _ in range(8):
            if value < TANGENT[bucket]:
                bucket -= stride
                stride >>= 1
            elif value > TANGENT[bucket + 1]:
                bucket += stride
                stride >>= 1
            else:
                break
        else:
            raise AssertionError('Unresolved tangent endpoint')
    angle = bucket if x < y else 128 - bucket
    return (angle, 512 - angle, 256 - angle, angle + 256)[quadrant] * 8

def initial(case):
    kind, initialize, elapsed, template = case
    parameter, flags, delta, period, speed, duration, configuration = PARAMETERS[template]
    clock = 0x100001F0 + template * 31
    current = template & 1
    object_address = OBJECT + (3 if current else 0) * 120
    ranges = [(ACTOR - 16, ACTOR + 140), (RESOURCE - 16, RESOURCE + 108),
              (PLAYER0 - 16, PLAYER0 + 140), (PLAYER1 - 16, PLAYER1 + 140),
              (POOL - 16, POOL + 3 * 124 + 16), (RESOURCES - 16, RESOURCES + 11 * 92 + 16),
              (POOL_RESOURCES - 16, POOL_RESOURCES + 3 * 88 + 16),
              (PLAYERS - 16, PLAYERS + 2 * 3508 + 16), (SESSION - 16, SESSION + 328 + 16),
              (OPTIONS - 16, OPTIONS + 24 + 16), (object_address - 16, object_address + 136)]
    ranges += [(a - 16, a + 20) for a in (NOW, DELTA, INTERVAL, LIST, RANDOM)]
    merged = []
    for a, b in sorted(ranges):
        if merged and a <= merged[-1][1]:
            merged[-1] = (merged[-1][0], max(merged[-1][1], b))
        else:
            merged.append((a, b))
    data = {a: bytearray((a + i * 43 + template * 31) & 255 for i in range(b - a)) for a, b in merged}
    angle = (30, 4090, -32000, 2050, -32768, 0, 1000, -1)[template]
    for a, v in ((NOW, clock), (DELTA, delta), (INTERVAL, (1, 500, 3, -7)[template % 4]),
                 (RANDOM, (0, 1, 174823885, 0x7FFFFFFF, 0xFFFFFFFF, 7, 0x12345678, 9)[template]),
                 (LIST, 0 if template % 3 == 2 else POOL), (OPTIONS + 8, configuration),
                 (SESSION + 0x30, current), (PLAYERS + 8, PLAYER0), (PLAYERS + 3508 + 8, PLAYER1),
                 (ACTOR + 0x24, RESOURCE), (ACTOR + 0x48, clock - elapsed),
                 (ACTOR + 0x50, clock - (0, 250, 251, -1)[template % 4]),
                 (ACTOR + 0x14, flags), (ACTOR + 0x2C, 17), (ACTOR + 0x30, -33),
                 (ACTOR + 0x38, parameter), (RESOURCE + 8, speed),
                 (object_address + 0x18, object_address + 0x1C)):
        put(data, a, word(v))
    put(data, ACTOR + 8, struct.pack('>2h', angle, -10 + template * 17))
    put(data, ACTOR + 0x0C, struct.pack('>h', 3 if current else 0))
    put(data, ACTOR + 0x21, b'\x55')
    put(data, ACTOR + 0x23, bytes((template % 3,)))
    put(data, RESOURCE + 2, bytes((kind,)))
    put(data, RESOURCE + 0x1A, struct.pack('>h', period))
    for index in range(11):
        put(data, RESOURCES + index * 92 + 0x58, word(1500))
    put(data, RESOURCES + kind * 92 + 0x58, word(duration))
    coordinates = ((123, -456, 777), (1500, 900, -999), (-500, 2200, 888),
                   (500, -2200, 999), (-16000, 14000, -777), (0, 0, 555),
                   (999, -1001, 222), (-900, -900, -333))
    for base, values in ((ACTOR + 0x60, coordinates[template]),
                         (PLAYER0 + 0x60, (3000, -4000, 700)),
                         (PLAYER1 + 0x60, (-7000, 6000, 800))):
        put(data, base, b''.join(word(v) for v in values))
    for index, xy in enumerate(((2000, 1000), (5000, -2000), (100, 100))):
        base = POOL + index * 124
        put(data, base + 0x1C, bytes((3 if index < 2 else 2,)))
        put(data, base + 0x1F, b'\0')
        put(data, base + 0x24, word(POOL_RESOURCES + index * 88))
        put(data, POOL_RESOURCES + index * 88 + 2, bytes((index + 1,)))
        put(data, base + 0x60, b''.join(word(v) for v in (*xy, 600)))
        put(data, base + 0x78, word(base + 124 if index < 2 else 0))
    return data, dict(object=object_address, current=current)

def oracle(data, case, info):
    kind, initialize, _, template = case
    expected = {a: bytearray(b) for a, b in data.items()}
    allowed, trace, branches = [], [], []
    a = ACTOR
    def read(address, n=4, signed_value=False):
        return get(expected, address, n, signed_value)
    def write(address, payload):
        put(expected, address, payload)
        allowed.append((address, address + len(payload)))
    def store(offset, v, n=4):
        write(a + offset, (v & ((1 << (n * 8)) - 1)).to_bytes(n, 'big'))
    def call(address, args):
        trace.append((address, tuple(v & 0xFFFFFFFF for v in args), bytes_at(expected, a, 124).hex()))
    def elapsed():
        return (read(NOW) - read(a + 0x48)) & 0xFFFFFFFF
    def random():
        call(0x8004CDE8, ())
        seed = (read(RANDOM) * 4 + 2) & 0xFFFFFFFF
        seed = (seed * (seed + 1) & 0xFFFFFFFF) >> 2
        write(RANDOM, word(seed))
        return seed
    def direction(target):
        dx = signed(read(target + 0x60) - read(a + 0x60))
        dy = signed(read(target + 0x64) - read(a + 0x64))
        call(0x8003CD4C, (dy, dx))
        return heading(dy, dx)
    def angle_submit(angle):
        index = read(a + 0x0C, 2, True)
        call(0x80039514, (index, angle))
        constant = struct.unpack('>f', struct.pack('>f', 3.141592))[0]
        converted = struct.unpack('>f', struct.pack('>f', signed(angle - 1024)))[0]
        product = struct.unpack('>f', struct.pack('>f', converted * constant))[0]
        write(info['object'] + 0x24, struct.pack('>f', product / 2048))
        write(info['object'] + 0x4C, word((1024 - angle) & 0xFFD))
    def short_trig(angle, cosine):
        call(0x8003CC88 if cosine else 0x8003CC58, (angle,))
        return trig(angle + (1024 if cosine else 0))
    def blend():
        call(0x8002A5DC, (a, 250))
        previous, angle = read(a + 0x0A, 2, True), read(a + 8, 2, True)
        if angle - previous >= 2049:
            previous += 4096
        if previous - angle >= 2049:
            angle += 4096
        parameter = max(0, signed(read(a + 0x38) - read(DELTA)))
        store(0x38, parameter)
        remaining = 250 - parameter
        for offset, speed_offset, cosine in ((0x6C, 0x30, True), (0x70, 0x2C, False)):
            old, new = short_trig(previous, cosine), short_trig(angle, cosine)
            speed = read(a + speed_offset, 4, True)
            first = signed(signed(new * remaining) * speed)
            second = signed(signed(parameter * old) * speed)
            store(offset, divide(signed(first + second), 250 * 4096))
        angle_submit(divide(signed(parameter * previous + remaining * angle), 250))
    resource = RESOURCES + kind * 92
    duration = read(resource + 0x58)
    age = elapsed()
    if age > duration:
        store(0x21, 2, 1)
        branches.append('expired')
        return expected, allowed, trace, branches
    branches.append('kind_' + str(kind))
    if kind in (5, 6, 9) and initialize:
        store(0, 0x80005560)
    if kind == 4:
        index = read(a + 0x0C, 2, True)
        if initialize:
            call(0x80039BE4, (index, 3))
            age = elapsed()
        call(0x80039BF0, (index, age // 100 & 7))
        angle_submit(2048)
        store(0x4C, int((duration * 99 & 0xFFFFFFFF) // 100 < elapsed()))
    elif kind == 5 and not initialize:
        store(0x4C, (age * 2 if age * 2 & 256 else -age * 2) & 255)
    elif kind in (6, 10):
        if initialize:
            store(0x50, read(NOW))
            value = random()
            store(0x50, read(a + 0x50) - ((value >> 3) % 250))
        if read(a + 0x38) != 0:
            branches.append('blend_existing')
            blend()
        else:
            should_start = bool(read(a + 0x14) & 2)
            if not should_start and read(DELTA) != 0:
                value = random() >> 3
                period = read(RESOURCE + 0x1A, 2, True)
                remainder = value - divide(value, period) * period
                should_start = (remainder & 0xFFFFFFFF) // read(DELTA) == 0
            if should_start:
                branches.append('blend_new')
                target = PLAYER1 if info['current'] else PLAYER0
                speed = read(RESOURCE + 8, 4, True)
                if read(OPTIONS + 8) == 0:
                    speed = divide(signed(speed * 5), 10)
                call(0x8002A3E8, (a, 250, speed))
                store(0x14, read(a + 0x14) & ~2)
                store(0x30, read(a + 0x2C))
                store(0x2C, speed)
                store(0x38, 250)
                store(0x0A, read(a + 8, 2), 2)
                store(8, direction(target), 2)
                blend()
        if (read(NOW) - read(a + 0x50) & 0xFFFFFFFF) > 250:
            branches.append('child_boundary')
            store(0x50, read(NOW))
            call(0x80015218, (a,))
    elif kind in (7, 8):
        target = PLAYER1 if info['current'] else PLAYER0
        if kind == 8:
            call(0x80027D8C, (a + 0x60, 3, 0, 4, 0))
            best, distance = 0, 0x7FFFFFFF
            node = read(LIST)
            while node:
                if read(node + 0x1C, 1) == 3 and read(read(node + 0x24) + 2, 1) < 4 and read(node + 0x1F, 1) == 0:
                    candidate = signed(abs(signed(read(node + 0x60) - read(a + 0x60))) + abs(signed(read(node + 0x64) - read(a + 0x64))))
                    if candidate < distance:
                        best, distance = node, candidate
                node = read(node + 0x78)
            target = best or target
            branches.append('nearest_found' if best else 'nearest_fallback')
        ratio = divide(read(RESOURCES + 7 * 92 + 0x58, 4, True), read(INTERVAL, 4, True))
        progress = (ratio * elapsed() & 0xFFFFFFFF) // duration
        if read(a + 0x23, 1) < progress:
            branches.append('heading_update')
            store(0x23, progress, 1)
            angle = direction(target) & 0xFF00
            store(8, angle, 2)
            speed = read(RESOURCE + 8, 4, True)
            if read(OPTIONS + 8) == 0:
                speed = divide(signed(speed * 5), 10)
            store(0x2C, speed)
            store(0x6C, divide(signed(short_trig(angle, True) * speed), 4096))
            store(0x70, divide(signed(short_trig(angle, False) * speed), 4096))
            angle_submit(angle)
    return expected, allowed, trace, branches
