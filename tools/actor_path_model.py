"""Independent wrapped-integer model for the actor path execution checker."""

import math
import struct

ACTOR = 0x80210000
PARAMETER = 0x80211000
TANGENT = [math.floor(math.tan(i * math.pi / 256) * 32767 + 0.5) for i in range(65)]
LENGTHS = (61, 420, 719, 1200)
POINTS = ((-3000, 700), (5000, -4000), (-101, 303), (9000, 17), (210, -270))


def word(value):
    return struct.pack('>I', value & 0xFFFFFFFF)


def signed32(value):
    return ((value + 0x80000000) & 0xFFFFFFFF) - 0x80000000


def divide(numerator, denominator):
    """Divide toward zero, independently of Python's floor division."""
    sign = -1 if (numerator < 0) != (denominator < 0) else 1
    return abs(numerator) // abs(denominator) * sign


def sine(angle):
    angle &= 4095
    half = angle & 2047
    index = min(half, 2047 - half)
    magnitude = math.floor(32767 * math.sin(index * math.pi / 2046)) // 8
    return -magnitude if angle & 2048 else magnitude


def rotate(point, angle):
    x, y = point
    cosine, negative_sine = sine(angle + 1024), -sine(angle)
    return (divide(signed32(x * cosine - y * negative_sine), 4096),
            divide(signed32(x * negative_sine + cosine * y), 4096))


def tangent_bucket(value):
    if value < TANGENT[1]:
        return 0
    if value > TANGENT[63]:
        return 64
    index, stride = 32, 16
    # Inclusive endpoints retain the retail search's choice at exact table values.
    for _ in range(8):
        if value < TANGENT[index]:
            index -= stride
            stride >>= 1
        elif value > TANGENT[index + 1]:
            index += stride
            stride >>= 1
        else:
            return index
    raise AssertionError(('Unresolved tangent bucket', value))


def heading(x, y):
    if x == 0:
        return (256 if y < 0 else 0) * 8
    if y == 0:
        return (384 if x < 0 else 128) * 8
    quadrant = (1 if x < 0 else 0) | (2 if y < 0 else 0)
    x, y = abs(x), abs(y)
    if x < y:
        angle = tangent_bucket(divide(signed32(x * 32767), y))
    else:
        angle = 128 - tangent_bucket(divide(signed32(y * 32767), x))
    return (angle, 512 - angle, 256 - angle, angle + 256)[quadrant] * 8


def oracle(case):
    count, index, progress_kind, speed, angle, group = case
    actor = bytearray(b'\xA5' * 124)
    actor[12:14] = struct.pack('>h', 17)
    actor[0x28:0x2C] = word(PARAMETER)
    actor[0x4C:0x50] = word(index)
    progress = (0, LENGTHS[index] - 1, LENGTHS[index])[progress_kind]
    actor[0x50:0x54] = word(progress)
    step = signed32(divide(divide(signed32(speed * 15), 100), 2) * 60)
    while step >= signed32(LENGTHS[index] - progress):
        step = signed32(signed32(step - LENGTHS[index]) + progress)
        index += 1
        if index >= count - 1:
            return dict(actor=actor.hex(),
                        trace=[['0x8000e5c8', [ACTOR, 1], actor.hex()]])
        progress = 0
    progress = signed32(progress + step)
    actor[0x4C:0x50] = word(index)
    actor[0x50:0x54] = word(progress)
    first, second = rotate(POINTS[index], angle), rotate(POINTS[index + 1], angle)
    for axis in range(2):
        delta = signed32(second[axis] - first[axis])
        offset = divide(signed32(delta * progress), LENGTHS[index])
        actor[0x60 + axis * 4:0x64 + axis * 4] = word(signed32(first[axis] + offset))
    direction = heading(signed32(second[1] - first[1]), signed32(second[0] - first[0]))
    actor[8:10] = struct.pack('>H', direction & 65535)
    trace = [['0x80039514', [17, direction & 0xFFFFFFFF], actor.hex()]]
    actor[0x6C:0x78] = b'\0' * 12
    return dict(actor=actor.hex(), trace=trace)
