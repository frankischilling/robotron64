#include "../../include/actor_behavior_internal.h"

void func_8002A3E8(ActorBehaviorActorInternal *actor, int parameter, int value)
{
    actor->flags14 &= ~2;
    actor->field30 = actor->field2C;
    actor->field2C = value;
    actor->parameter38 = parameter;
    actor->previousAngle0A = actor->angle08;
}
