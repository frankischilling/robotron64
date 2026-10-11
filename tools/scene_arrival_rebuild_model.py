"""Independent arrival rebuild model over complete actor and scene fixtures."""

import random
import struct

from check_actor_group_path import word
from check_movie_storage import pattern
from check_scene_arrivals import oracle as insert_model

POOL, HEAD, STRIDE, ACTORS = 0x800A4628, 0x800AA708, 124, 200
ACTOR_RESOURCES, RESOURCE_STRIDE = 0x80220010, 88
LIMITS, LIMIT_SIZE = 0x800B8F78, 416
SCENE, SCENE_SIZE = 0x800B9A78, 3348
DEFAULTS, DEFAULT_STRIDE = 0x800AF1F0, 104
SEED = 0x8008F120


def prepare(case):
    records = case.get('actors', [])
    assert len({record['slot'] for record in records}) == len(records)
    pool = pattern(ACTORS * STRIDE + 4, 19)
    resources = pattern(ACTORS * RESOURCE_STRIDE, 83)
    for index, record in enumerate(records):
        slot = record['slot']
        assert 0 <= slot < ACTORS
        offset = slot * STRIDE
        resource = slot * RESOURCE_STRIDE
        pool[offset + 0x1C] = record.get('category', 0)
        pool[offset + 0x21] = record.get('state', 7)
        pool[offset + 0x22] = record.get('value', 1)
        pool[offset + 0x24:offset + 0x28] = word(ACTOR_RESOURCES + resource)
        pool[offset + 0x28:offset + 0x2C] = word(record.get('blocked', 0))
        parent = record.get('parent')
        assert parent is None or 0 <= parent < ACTORS
        pool[offset + 0x3C:offset + 0x40] = word(0 if parent is None else POOL + parent * STRIDE)
        pool[offset + 0x60:offset + 0x64] = word(record.get('x', -257))
        pool[offset + 0x64:offset + 0x68] = word(record.get('y', 257))
        following = records[index + 1]['slot'] if index + 1 < len(records) else None
        pool[offset + 0x78:offset + 0x7C] = word(0 if following is None else POOL + following * STRIDE)
        resources[resource + 2] = record.get('kind', 17)
    pool[-4:] = word(POOL + records[0]['slot'] * STRIDE if records else 0)
    scene = pattern(SCENE_SIZE, 37)
    for index in range(256):
        scene[0x44 + index * 12:0x50 + index * 12] = bytes(12)
    for index, arrival in enumerate(case.get('arrivals', [])):
        scene[0x44 + index * 12:0x50 + index * 12] = struct.pack('>BBBBhhhh', *arrival)
    scene[0xCC8:0xCCC] = word(len(case.get('arrivals', [])))
    defaults = pattern(36 * DEFAULT_STRIDE, 119)
    delays = case.get('delays', [1200 + index * 100 for index in range(36)])
    assert len(delays) == 36
    for index, delay in enumerate(delays):
        defaults[index * DEFAULT_STRIDE + 100:index * DEFAULT_STRIDE + 104] = word(delay)
    return {'actors': (POOL, bytes(pool)), 'resources': (ACTOR_RESOURCES, bytes(resources)),
            'limits': (LIMITS, bytes(pattern(LIMIT_SIZE, 71))), 'scene': (SCENE, bytes(scene)),
            'defaults': (DEFAULTS, bytes(defaults)), 'seed': (SEED, word(case.get('seed', 174823885)))}


def model(case, panels, integrated):
    expected = {name: bytearray(data) for name, (_, data) in panels.items()}
    normal, secondary, behavior = [0] * 36, [0] * 8, [0] * 11
    groups, limits, calls, player = {}, [], [], False
    for record in case.get('actors', []):
        category, kind = record.get('category', 0), record.get('kind', 17)
        parent = record.get('parent')
        if category == 7 and kind < 11:
            behavior[kind] += 1
        elif category == 0 and not record.get('blocked', 0) and kind not in (4, 33, 34):
            assert kind < 36, 'Normal-kind fixtures stay inside the observed 36-word table'
            normal[kind] += 1
            if 9 <= kind < 13 or 13 <= kind < 17 and parent is not None:
                slot = record['slot'] if kind < 13 else parent
                value = record.get('value', 1) if kind < 13 else 1
                previous, _ = groups.get(slot, (0, kind))
                groups[slot] = ((previous + value) & 255, kind if kind < 13 else kind - 4)
            elif 17 <= kind < 21:
                limits.append(record.get('value', 1))
        elif category == 1 and kind not in (10, 13) and parent is None:
            calls.append((1, 1, kind, 1, 1, 1, record.get('x', -257), record.get('y', 257)))
        elif category == 3 and kind < 4:
            secondary[kind] += 1
        elif category == 8:
            player = True
            expected['actors'][record['slot'] * STRIDE + 0x21] = 2
    assert len(groups) <= 50 and len(limits) <= 50, 'Fixtures keep global limit writes within their declared arrays'
    for index, value in enumerate(limits):
        expected['limits'][0xD8 + index * 4:0xDC + index * 4] = word(value)
    for kind in range(9, 17):
        normal[kind] = 0
    for index, slot in enumerate(sorted(groups)):
        value, kind = groups[slot]
        expected['limits'][0x10 + index * 4:0x14 + index * 4] = word(value)
        normal[kind] += 1
    if player:
        calls.append((1, 8, 0, 1, 2000, 1, -1, -1))
    delays = case.get('delays', [1200 + index * 100 for index in range(36)])
    for category, counts in ((0, normal), (3, secondary), (7, behavior)):
        for index, count in enumerate(counts):
            if count:
                value = delays[index] if category == 0 else 0
                delay = abs(value) // 100 * (-1 if value < 0 else 1)
                calls.append((1, category, index, 1, delay, count, -1, -1))
    diagnostics = []
    if integrated:
        scene = bytes(expected['scene'])
        seed = int.from_bytes(expected['seed'], 'big')
        for replace, category, resource, trigger, delay, count, x, y in calls:
            total = int.from_bytes(scene[0xCC8:0xCCC], 'big', signed=True)
            args = dict(total=total, replace=replace, category=category, resource=resource,
                        trigger=trigger, delay=delay, count=count, x=x, y=y, seed=seed)
            scene, seed, draws, messages, _, _, _ = insert_model(args, scene, bytes(expected['defaults']))
            assert not draws
            diagnostics.extend(messages)
        expected['scene'] = bytearray(scene)
        expected['seed'] = bytearray(word(seed))
    return {name: bytes(data) for name, data in expected.items()}, calls, diagnostics


def cases():
    yield {}
    for category in range(256):
        yield {'actors': [dict(slot=199, category=category, kind=17)]}
    for kind in range(36):
        for blocked in (0, 1):
            yield {'actors': [dict(slot=0, kind=kind, blocked=blocked, value=255)]}
    for kind in range(256):
        yield {'actors': [dict(slot=199, category=1, kind=kind, x=-1, y=-257)]}
    for category, bound in ((3, 10), (7, 14)):
        for kind in range(bound):
            yield {'actors': [dict(slot=0, category=category, kind=kind)]}
    for value in (0, 1, 127, 128, 255):
        for kind in range(9, 17):
            yield {'actors': [dict(slot=199, kind=kind, value=value, parent=0),
                              dict(slot=0, kind=kind + 4 if kind < 13 else kind, parent=0, value=255)]}
    for x in (-0x80000000, -65536, -257, -256, -1, 0, 255, 256, 0x7FFFFFFF):
        for y in (-0x80000000, -1, 0, 0x7FFFFFFF):
            yield {'actors': [dict(slot=0, category=1, kind=3, x=x, y=y)]}
    for delay in (-0x80000000, -10001, -101, -100, -99, -1, 0, 99, 100, 101, 9999, 10000, 3276700, 0x7FFFFFFF):
        yield {'actors': [dict(slot=0, kind=0)], 'delays': [delay] * 36}
    for category, kind in ((0, 2), (7, 10), (0, 13), (3, 3)):
        yield {'actors': [dict(slot=index, category=category, kind=kind, parent=0 if kind == 13 else None, value=255) for index in range(200)]}
    yield {'actors': [dict(slot=index, kind=17 + index % 4, value=index) for index in reversed(range(50))]}
    yield {'actors': [dict(slot=index, kind=9 + index % 4, value=255) for index in reversed(range(50))]}
    for total in (1, 5, 255, 256):
        for kind in (0, 8):
            arrival = (1, 1, 0, kind, 2, 2, -1, -1)
            yield {'actors': [dict(slot=0, category=1 if kind == 0 else 8, kind=0)], 'arrivals': [arrival] * total}
    rng = random.Random(0x20F8C)
    for _ in range(200):
        slots = rng.sample(range(200), rng.randrange(0, 33))
        records = []
        for slot in slots:
            category = rng.choice((0, 0, 1, 3, 7, 8, 9, 255))
            kind = rng.randrange(36) if category == 0 else rng.randrange(256)
            records.append(dict(slot=slot, category=category, kind=kind, blocked=rng.randrange(2),
                                value=rng.randrange(256), parent=rng.choice((None, None, rng.randrange(200))),
                                x=rng.randrange(-0x80000000, 0x80000000), y=rng.randrange(-0x80000000, 0x80000000)))
        yield {'actors': records, 'seed': rng.randrange(0x100000000)}
