#include "../../include/actor_behavior_more_internal.h"

void func_80029154(ActorBehaviorActorInternal *actor)
{
    actor->frame18 = func_80039CD0(actor->objectIndex) << 8;
    actor->flags14 |= 0x40;
}
