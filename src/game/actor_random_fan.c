#include "../../include/actor_animation_state.h"
#include "../../include/actor_projectile_internal.h"

extern int D_800AC97C;
extern int D_800ACD90[];

void func_800295CC(ActorBehaviorActorInternal *actor)
{
    int count;
    int i;
    unsigned int flags;

    switch (actor->resource24->actorKind) {
    case 26:
        count = 2;
        break;
    case 27:
        count = 4;
        break;
    case 28:
        if (((func_8004CDE8() >> 3) % 255) & 0xC0) {
            count = 0;
        } else {
            count = (func_8004CDE8() >> 3) % 4 + 4;
        }
        break;
    default:
        count = 1;
        break;
    }
    func_80039C1C(actor->objectIndex, 80, 80, 80);
    for (i = 0; i < count; i++) {
        if (D_800ACD90[7] + D_800ACD90[8] < D_800AC97C) {
            func_8003919C((GameActor *)actor, (i << 9) - ((count << 9) / 2),
                          actor->resource24->actorKind - 25);
        }
    }
    flags = actor->flags14;
    if (flags & 0x40) {
        actor->flags14 = flags & ~0x40;
        actor->callback44(actor);
        flags = actor->flags14;
    }
    actor->flags14 = flags | 0x40,
        actor->callback44 = func_80029210,
        actor->timer0E = 999;
}
