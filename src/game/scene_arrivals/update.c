#include "../../../include/scene_commands_internal.h"
#include "../../../include/actor_animation_state.h"
#include "../../../include/actor_resource_internal.h"
#include "../../../include/actor_motion_internal.h"

extern int D_8009A880;
extern int D_80077AD8;
extern int D_80074BC0;
extern int D_800C8B7C;
extern int D_800BA740;
extern int D_800BAE94;
extern int D_8009B22C;
extern TextGlyphResource D_8009F560[];
extern unsigned char D_80091834[], D_80091860[], D_80091888[], D_800918B0[];
struct EarlyGameActor *func_8001049C(int index, int *position, int phase);
ActorBehaviorActorInternal *func_8001AF44(int kind, int *position, ActorBehaviorActorInternal *parent);
int func_8003614C(int sound, int value, int enabled, int extra);

/* Excluded candidate. Complete code and dispatch bytes still differ. */
int func_80020134(void)
{
    int total = 0;
    int counts[36];
    int previousTotal;
    int index;
    int currentCount;
    int spacing;
    int ready;
    int failed;
    int created;
    int next;
    short attempts;
    unsigned int elapsed;
    unsigned char kind;
    ActorMotionPositionInternal position;
    ActorBehaviorActorInternal *actor;
    SceneArrival *arrival;
    SceneArrival *later;
    short *sceneCount;

    func_8003B694(counts, 0, sizeof(counts));
    for (actor = (ActorBehaviorActorInternal *)D_800AA708;
         actor != 0; actor = actor->next78) {
        if (actor->resource24->unk00 == 0 &&
            ((kind = actor->resource24->actorKind) < 5 || kind >= 9) &&
            kind != 33 && kind != 34) {
            total++;
            counts[kind]++;
        }
    }
    if ((unsigned int)(D_8009EFA0 - D_8009A880) >= 1001U) {
        D_8009A880 += 1000;
        for (index = 0; index < 36; index++) {
            if ((index >= 5 && index < 9) || index == 33 || index == 34) {
                total -= counts[index];
                counts[index] = 0;
            }
        }
    }
    previousTotal = total;
    for (index = 0; index < D_800BA740; index++) {
        arrival = &D_800B9A78.arrivals[index];
        switch (arrival->state) {
        case 0:
            break;
        case 2:
            if (arrival->category == 0 ||
                (arrival->category == 8 && arrival->trigger != 0)) {
                total += arrival->count;
            }
            break;
        case 1:
            ready = 0;
            if ((arrival->category == 0 || arrival->category == 8) &&
                arrival->trigger != 3) {
                total += arrival->count;
            }
            switch (arrival->category) {
            case 8: currentCount = D_800AD138.animationReady90 != 0; break;
            case 0: currentCount = counts[arrival->resourceIndex]; break;
            case 3: currentCount = D_800AD138.activeSceneActors[arrival->resourceIndex]; break;
            case 1: currentCount = D_800AD138.randomSpawnActors[arrival->resourceIndex]; break;
            case 7: currentCount = D_800AD138.unknownCounters110[arrival->resourceIndex]; break;
            case 9: currentCount = 0; break;
            default: func_8001C0D0(D_80091860, arrival->category); break;
            }
            elapsed = D_8009EFA0 - D_800AD138.timestamp68;
            spacing = elapsed >= 501U ? 2 : 1;
            switch (arrival->trigger) {
            case 0:
                if (currentCount < arrival->delay &&
                    (unsigned int)(D_80077AD8 + 1000) < elapsed &&
                    arrival->count + D_800C8B7C < 50) {
                    ready = 1;
                }
                break;
            case 1:
                if (((previousTotal == 0 && arrival->category == 0) ||
                     (unsigned int)(arrival->delay * 100) < elapsed) &&
                    arrival->count + D_800C8B7C < 50) {
                    ready = 1;
                    previousTotal++;
                }
                break;
            case 2:
                if (arrival->delay >= currentCount &&
                    (unsigned int)(D_80077AD8 + 1000) < elapsed &&
                    D_800C8B7C + 1 < 50) {
                    ready = 1;
                }
                break;
            case 4:
                if (D_8009EF94 != 0 &&
                    (unsigned int)(((int)((unsigned int)func_8004CDE8() >> 3) % arrival->delay) * 100) /
                        (unsigned int)D_8009EF94 == 0 &&
                    arrival->count + D_800C8B7C < 50) {
                    ready = 1;
                }
                break;
            case 5:
                ready = 1;
                break;
            case 3:
                if (elapsed >= 1001U) {
                    switch (arrival->delay) {
                    case 0:
                        if (*(int *)((char *)&D_8009B22C + D_800AD138.saved.currentPlayer * sizeof(GamePlayerState)) >= 2001) ready = 1;
                        break;
                    case 1:
                        if (previousTotal == 0) ready = 1;
                        break;
                    case 6:
                        if (D_8009B190[D_800AD138.saved.playerChoices38[D_800AD138.saved.currentPlayer]].saved.active - 1 == 0) ready = 1;
                        break;
                    case 2:
                        ready = 1;
                        for (sceneCount = D_800AD138.activeSceneActors;
                             sceneCount != D_800AD138.activeSceneActors + 8; sceneCount++) {
                            if (*sceneCount != 0) {
                                ready = 0;
                                break;
                            }
                        }
                        break;
                    case 3:
                        if (D_800AD138.animationReady90 == 0) ready = 1;
                        break;
                    case 4:
                        if (D_800AD138.activeBehaviorActors[4] + D_800AD138.activeBehaviorActors[0] +
                            D_800AD138.activeBehaviorActors[1] + D_800AD138.activeBehaviorActors[2] +
                            D_800AD138.activeBehaviorActors[3] == 0) ready = 1;
                        break;
                    case 5:
                        if ((D_800B8F78.word00.value & 0x20000000) &&
                            D_800B8F78.word00.fields.value02 <= 0) ready = 1;
                        break;
                    default:
                        func_8001C0D0(D_80091888, arrival->delay);
                        break;
                    }
                }
                break;
            }
            if (ready) {
                attempts = arrival->trigger == 2 || arrival->category == 8 ? 1 : arrival->count;
                for (created = 0; attempts > 0 && created != attempts; created++) {
                    failed = 0;
                    /* Retail tests x twice here, then copies y without scaling. */
                    if (arrival->x == -1 && arrival->x == -1) {
                        position.x = arrival->x;
                        position.y = arrival->y;
                        position.z = 0;
                    } else {
                        position.x = arrival->x << 8;
                        position.y = arrival->y << 8;
                        position.z = 0;
                    }
                    if (position.x == -1 && position.y == -1) {
                        failed = func_80027ED4(&position, 0, spacing) == 0;
                    }
                    if (!failed) {
                        switch (arrival->category) {
                        case 0:
                            if (arrival->trigger == 1 && arrival->delay == D_800AF1F0[arrival->resourceIndex].arrivalDelay / 100) {
                                actor = func_8001AF44(arrival->resourceIndex, &position.x, (ActorBehaviorActorInternal *)0xBEE0);
                                if (arrival->resourceIndex >= 25 && arrival->resourceIndex < 29 && D_80074BC0 == 0) {
                                    D_80074BC0 = 1;
                                    func_8003614C(17, 0, 1, 0);
                                }
                            } else {
                                actor = func_8001AF44(arrival->resourceIndex, &position.x, 0);
                            }
                            if (actor == 0) failed = 1;
                            else {
                                counts[arrival->resourceIndex]++;
                                ((void (*)(ActorBehaviorActorInternal *, int))actor->resource24->field54)(actor, 1);
                            }
                            break;
                        case 8:
                            if (func_8001049C(arrival->resourceIndex, &position.x,
                                D_8009B190[D_800AD138.saved.currentPlayer].saved.value24) == 0) failed = 1;
                            break;
                        case 3:
                            actor = (ActorBehaviorActorInternal *)func_8001F240(&D_800ACE58[arrival->resourceIndex], &position.x);
                            if (actor == 0) failed = 1;
                            else ((void (*)(ActorBehaviorActorInternal *, int))actor->resource24->field54)(actor, 1);
                            break;
                        case 1:
                            if (arrival->resourceIndex != 8) {
                                actor = func_8001A350(&D_8009F560[arrival->resourceIndex], &position.x);
                                if (actor == 0) failed = 1;
                                else ((void (*)(ActorBehaviorActorInternal *, int))actor->resource24->field54)(actor, 1);
                                break;
                            }
                            /* Kind 8 deliberately uses the category-7 path. */
                        case 7:
                            if (D_800BAE94 != 0 && arrival->resourceIndex != 8 &&
                                arrival->resourceIndex != 9 && arrival->resourceIndex != 10) {
                                actor = (ActorBehaviorActorInternal *)func_800283D4(arrival->category,
                                    (TextGlyphResource *)&D_8009AA00[arrival->resourceIndex], &position.x);
                                if (actor == 0) failed = 1;
                                else ((void (*)(ActorBehaviorActorInternal *, int))actor->resource24->field54)(actor, 1);
                            }
                            break;
                        case 9:
                            kind = arrival->resourceIndex;
                            if (kind != 226 && kind != 227 && kind != 228 && kind != 229 &&
                                kind != 211 && kind != 210 && kind != 230 && kind != 231 &&
                                kind != 232 && kind != 233 && kind != 234 && kind != 235) {
                                actor = (ActorBehaviorActorInternal *)func_800283D4(arrival->category, &D_800B1BE8[kind], &position.x);
                                if (actor == 0) failed = 1;
                                else ((void (*)(ActorBehaviorActorInternal *, int))actor->resource24->field54)(actor, 1);
                            }
                            break;
                        default:
                            func_8001C0D0(D_800918B0, arrival->category);
                            break;
                        }
                        if (!failed && arrival->trigger != 5) arrival->count--;
                    }
                }
                if (arrival->trigger == 5 || arrival->count < 2) {
                    arrival->state = arrival->trigger == 5 ? 2 : 0;
                    for (next = index + 1; next < D_800BA740; next++) {
                        later = &D_800B9A78.arrivals[next];
                        if (arrival->category == later->category && later->state == 2) {
                            later->state = 1;
                            if (later->trigger == 1) {
                                later->delay += (unsigned int)(D_8009EFA0 - D_800AD138.timestamp68) / 100U;
                            }
                            break;
                        }
                    }
                }
            }
            break;
        default:
            func_8001C0D0(D_80091834);
            break;
        }
    }
    return total;
}
