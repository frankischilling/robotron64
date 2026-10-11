"""Independent model of retail arrival-update decisions and call boundaries."""
import struct
from scene_arrival_rebuild_model import prepare as base_prepare, POOL, HEAD, STRIDE, ACTOR_RESOURCES, RESOURCE_STRIDE, SCENE, SCENE_SIZE, DEFAULTS, DEFAULT_STRIDE, SEED, LIMITS
from check_scene_arrivals import random_value, divide
from check_actor_group_path import word
from check_movie_storage import pattern
SESSION, PLAYERS, BORN, BORN_RESOURCE, CALLBACK = (0x800AD138, 0x8009B190, 0x80240010, 0x80250010, 0x80000180)
LAST, CLOCK, OLD_DELAY, SOUND, ACTIVE, ENABLED, RATE = (0x8009A880, 0x8009EFA0, 0x80077AD8, 0x80074BC0, 0x800C8B7C, 0x800BAE94, 0x8009EF94)
NORMAL, BOSS, SCENE_CREATE, TEXT_CREATE, OTHER_CREATE, POSITION, SOUND_CALL, FATAL = (0x8001AF44, 0x8001049C, 0x8001F240, 0x8001A350, 0x800283D4, 0x80027ED4, 0x8003614C, 0x8001C0D0)

def signed(v):
    return (v + 0x80000000) % 0x100000000 - 0x80000000

def half(v):
    return (v + 0x8000) % 0x10000 - 0x8000

def arrivals(case):
    return [dict(trigger=a.get('trigger', 5), state=a.get('state', 1), resource=a.get('resource', 0), category=a.get('category', 0), delay=half(a.get('delay', 0)), count=half(a.get('count', 1)), x=half(a.get('x', 0)), y=half(a.get('y', 0))) for a in case.get('arrivals', [])]

def prepare(case):
    a = arrivals(case)
    panels = base_prepare({'actors': case.get('actors', []), 'arrivals': [(r['trigger'], r['state'], r['resource'], r['category'], r['delay'], r['count'], r['x'], r['y']) for r in a], 'seed': case.get('seed', 174823885), 'delays': case.get('defaults', [1200 + i * 100 for i in range(36)])})
    resources = bytearray(panels['resources'][1])
    for actor in case.get('actors', []):
        resources[actor['slot'] * RESOURCE_STRIDE] = actor.get('resource_category', 0)
    panels['resources'] = (ACTOR_RESOURCES, bytes(resources))
    session = bytearray(pattern(328, 39))
    session[48:52] = word(case.get('player', 0))
    session[56:64] = word(case.get('choice0', 0)) + word(case.get('choice1', 1))
    session[104:108] = word(case.get('timestamp', 0))
    session[144:148] = word(case.get('player_present', 0))
    for offset, key, count in ((184, 'behavior', 36), (256, 'scene_counts', 8), (272, 'other_counts', 11), (294, 'text_counts', 16)):
        values = case.get(key, [0] * count)
        assert len(values) == count
        session[offset:offset + 2 * count] = b''.join((struct.pack('>h', half(v)) for v in values))
    panels['session'] = (SESSION, bytes(session))
    players = bytearray(pattern(3508 * 2, 89))
    for i in range(2):
        for offset, key in ((28, 'active_players'), (36, 'phases'), (156, 'scores')):
            players[i * 3508 + offset:i * 3508 + offset + 4] = word(case.get(key, [1, 1])[i])
    panels['players'] = (PLAYERS, bytes(players))
    limits = bytearray(panels['limits'][1])
    limits[:4] = word(case.get('flags', 0))
    panels['limits'] = (LIMITS, bytes(limits))
    for name, address, key, default in (('last', LAST, 'last', 0), ('old_delay', OLD_DELAY, 'old_delay', 0), ('sound', SOUND, 'sound', 0), ('active', ACTIVE, 'active', 0), ('enabled', ENABLED, 'enabled', 1)):
        panels[name] = (address, word(case.get(key, default)))
    timing = bytearray(pattern(CLOCK + 4 - RATE, 73))
    timing[:4] = word(case.get('rate', 1))
    timing[CLOCK - RATE:] = word(case.get('clock', 2000))
    panels['timing'] = (RATE, bytes(timing))
    born = bytearray(pattern(124, 21))
    born[36:40] = word(BORN_RESOURCE)
    resource = bytearray(pattern(88, 45))
    resource[84:88] = word(CALLBACK)
    panels['born'] = (BORN, bytes(born))
    panels['born_resource'] = (BORN_RESOURCE, bytes(resource))
    return panels

def model(case, panels):
    expected = {k: bytearray(v[1]) for k, v in panels.items()}
    records = arrivals(case)
    counts = [0] * 36
    for actor in case.get('actors', []):
        kind = actor.get('kind', 17)
        if actor.get('resource_category', 0) == 0 and (kind < 5 or kind >= 9) and (kind not in (33, 34)):
            counts[kind] += 1
    total = sum(counts)
    clock = case.get('clock', 2000) & 0xFFFFFFFF
    elapsed = clock - case.get('timestamp', 0) & 0xFFFFFFFF
    if clock - case.get('last', 0) & 0xFFFFFFFF >= 1001:
        expected['last'][:] = word(case.get('last', 0) + 1000)
    previous = total
    events = []
    seed = case.get('seed', 174823885) & 0xFFFFFFFF
    sound = case.get('sound', 0)
    attempt = 0
    position_attempt = 0
    rng_draws = 0
    for i, a in enumerate(records):
        state, cat, kind, trigger = (a['state'], a['category'], a['resource'], a['trigger'])
        if state == 0:
            continue
        if state == 2:
            if cat == 0 or (cat == 8 and trigger != 0):
                total = signed(total + a['count'])
            continue
        if state != 1:
            events.append((FATAL, (0x80091834,)))
            continue
        assert cat in (0, 1, 3, 7, 8, 9), 'Invalid state-1 category has an uninitialized retail count after a returning fatal observer'
        if cat in (0, 8) and trigger != 3:
            total = signed(total + a['count'])
        current = {0: lambda: counts[kind], 1: lambda: case.get('text_counts', [0] * 16)[kind], 3: lambda: case.get('scene_counts', [0] * 8)[kind], 7: lambda: case.get('other_counts', [0] * 11)[kind], 8: lambda: int(case.get('player_present', 0) != 0), 9: lambda: 0}[cat]()
        capacity = lambda increment: signed(case.get('active', 0) + increment) < 50
        time_ready = case.get('old_delay', 0) + 1000 & 0xFFFFFFFF < elapsed
        if trigger == 0:
            ready = current < a['delay'] and time_ready and capacity(a['count'])
        elif trigger == 1:
            ready = (previous == 0 and cat == 0 or a['delay'] * 100 & 0xFFFFFFFF < elapsed) and capacity(a['count'])
            if ready:
                previous = signed(previous + 1)
        elif trigger == 2:
            ready = a['delay'] >= current and time_ready and capacity(1)
        elif trigger == 4:
            ready = False
            if case.get('rate', 1) != 0:
                assert a['delay'] != 0, 'Zero retail modulo divisor excluded'
                seed = random_value(seed)
                rng_draws += 1
                r = seed >> 3
                remainder = r - divide(r, abs(a['delay'])) * abs(a['delay'])
                ready = (remainder * 100 & 0xFFFFFFFF) // (case.get('rate', 1) & 0xFFFFFFFF) == 0 and capacity(a['count'])
        elif trigger == 5:
            ready = True
        elif trigger == 3:
            ready = False
            if elapsed >= 1001:
                delay = a['delay']
                player = case.get('player', 0)
                conditions = {0: lambda: case.get('scores', [1, 1])[player] >= 2001, 1: lambda: previous == 0, 2: lambda: not any(case.get('scene_counts', [0] * 8)), 3: lambda: case.get('player_present', 0) == 0, 4: lambda: signed(sum(case.get('behavior', [0] * 36)[:5])) == 0, 5: lambda: bool(case.get('flags', 0) & 0x20000000) and half(case.get('flags', 0)) <= 0, 6: lambda: case.get('active_players', [1, 1])[case.get('choice%d' % player, player)] == 1}
                if delay in conditions:
                    ready = conditions[delay]()
                else:
                    events.append((FATAL, (0x80091888, delay & 0xFFFFFFFF)))
        else:
            ready = False
        if not ready:
            continue
        attempts = 1 if trigger == 2 or cat == 8 else a['count']
        for _ in range(max(0, attempts)):
            position = (a['x'], a['y'], 0) if a['x'] == -1 else (a['x'] * 256, a['y'] * 256, 0)
            failed = False
            if position[:2] == (-1, -1):
                events.append((POSITION, (position, 0, 2 if elapsed >= 501 else 1)))
                choices = case.get('position_success', [True])
                success = choices[position_attempt % len(choices)]
                position_attempt += 1
                failed = not success
                if success:
                    position = tuple(case.get('position_result', [257, -513, 0]))
            if failed:
                continue
            created = None
            if cat == 0:
                default = case.get('defaults', [1200 + i * 100 for i in range(36)])[kind]
                special = trigger == 1 and a['delay'] == divide(signed(default), 100)
                events.append((NORMAL, (kind, position, 0xBEE0 if special else 0)))
                created = True
                if special and 25 <= kind < 29 and (sound == 0):
                    sound = 1
                    events.append((SOUND_CALL, (17, 0, 1, 0)))
            elif cat == 8:
                events.append((BOSS, (kind, position, case.get('phases', [1, 1])[case.get('player', 0)])))
                created = True
            elif cat == 3:
                events.append((SCENE_CREATE, (0x800ACE58 + kind * 88, position)))
                created = True
            elif cat == 1 and kind != 8:
                events.append((TEXT_CREATE, (0x8009F560 + kind * 88, position)))
                created = True
            elif cat in (1, 7):
                if case.get('enabled', 1) != 0 and kind not in (8, 9, 10):
                    events.append((OTHER_CREATE, (cat, 0x8009AA00 + kind * 92, position)))
                    created = True
            elif cat == 9:
                if kind not in (226, 227, 228, 229, 211, 210, 230, 231, 232, 233, 234, 235):
                    events.append((OTHER_CREATE, (cat, 0x800B1BE8 + kind * 88, position)))
                    created = True
            if created:
                choices = case.get('spawn_success', [True])
                success = choices[attempt % len(choices)]
                attempt += 1
                failed = not success
                if success and cat != 8:
                    if cat == 0:
                        counts[kind] += 1
                    events.append((CALLBACK, (BORN, 1)))
            if not failed and trigger != 5:
                a['count'] = half(a['count'] - 1)
        if trigger == 5 or a['count'] < 2:
            a['state'] = 2 if trigger == 5 else 0
            for later in records[i + 1:]:
                if later['category'] == cat and later['state'] == 2:
                    later['state'] = 1
                    if later['trigger'] == 1:
                        later['delay'] = half(later['delay'] + elapsed // 100)
                    break
    for i, a in enumerate(records):
        expected['scene'][68 + i * 12:80 + i * 12] = struct.pack('>BBBBhhhh', a['trigger'], a['state'], a['resource'], a['category'], a['delay'], a['count'], a['x'], a['y'])
    expected['seed'][:] = word(seed)
    expected['sound'][:] = word(sound)
    return ({k: bytes(v) for k, v in expected.items()}, events, total, rng_draws)
