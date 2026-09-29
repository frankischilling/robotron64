#include "../../include/actor_behavior_more_internal.h"

void func_800292BC(ActorBehaviorActorInternal *actor)
{
    if (actor->animation1F != 1) {
        actor->field2C =
            ((ActorBehaviorResourceInternal *)actor->resource24)->movement08;
        actor->field6C =
            (func_8003CC88(actor->angle08) *
             ((ActorBehaviorResourceInternal *)actor->resource24)->movement08) /
            0x1000;
        actor->field70 =
            (func_8003CC58(actor->angle08) *
             ((ActorBehaviorResourceInternal *)actor->resource24)->movement08) /
            0x1000;
        func_80039514(actor->objectIndex, actor->angle08);
        func_80027AB8((GameActor *)actor, 0, 1);
    }
    actor->position[2] = 0;
}
