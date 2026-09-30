#include "../../include/actor_behavior_internal.h"

extern int D_8009EFA0;
extern unsigned int D_800ACC18;

void func_80036ED8(ActorBehaviorActorInternal *actor, int unused)
{
    ActorBehaviorActorInternal *parent;
    unsigned int elapsed;

    parent = (ActorBehaviorActorInternal *)actor->field3C;
    if (parent == 0 || parent->kind1C != 5 ||
        parent->resource24->actorKind != 6 ||
        (elapsed = D_8009EFA0 - actor->field48, D_800ACC18 < elapsed)) {
        actor->state21 = 2;
        return;
    }

    actor->frame18 = (elapsed % 3U) * 0x55;
    actor->position[0] =
        parent->position[0] +
        ((func_8003CC88(parent->angle08 + 0x800) * actor->countdown54 *
          actor->countdown54) * 0x15E) / 0x1000;
    actor->position[1] =
        parent->position[1] +
        ((func_8003CC58(parent->angle08 + 0x800) * actor->countdown54 *
          actor->countdown54) * 0x15E) / 0x1000;
}
