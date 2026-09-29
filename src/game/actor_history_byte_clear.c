#include "../../include/actor_behavior_internal.h"

extern unsigned char D_8008D4AC[];

void func_8004EB60(ActorBehaviorActorInternal *actor)
{
    D_8008D4AC[actor->field50] = 0;
}
