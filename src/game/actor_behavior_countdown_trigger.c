#include "../../include/actor_behavior_internal.h"

void func_8002DD40(ActorBehaviorActorInternal *actor, int enabled)
{
    if (enabled != 0) {
        if (actor->flags14 & 0x40) {
            actor->flags14 &= ~0x40;
            actor->callback44(actor);
        }
        actor->flags14 |= 0x40, actor->callback44 = func_8002DCB8,
            actor->timer0E = 999;
        actor->countdown54 = 6;
    }
}
