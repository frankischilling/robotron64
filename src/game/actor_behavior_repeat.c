#include "../../include/actor_behavior_internal.h"

void func_8002BF88(ActorBehaviorActorInternal *actor)
{
    actor->frame18 = (func_80039CD0(actor->objectIndex) << 8) - 0x100;
    actor->field4C -= D_8009EF94;

    if (actor->field4C < 0) {
        func_80027AB8((GameActor *) actor, 0, 1);
        actor->field2C =
            ((ActorBehaviorResourceInternal *) actor->resource24)->movement08;
        actor->field6C =
            (func_8003CC88(actor->angle08) *
             ((ActorBehaviorResourceInternal *) actor->resource24)->movement08) /
            0x1000;
        actor->field70 =
            (func_8003CC58(actor->angle08) *
             ((ActorBehaviorResourceInternal *) actor->resource24)->movement08) /
            0x1000;
        func_80039514(actor->objectIndex, actor->angle08);
        return;
    }

    if (actor->flags14 & 0x40) {
        actor->flags14 &= ~0x40;
        actor->callback44(actor);
    }
    actor->flags14 |= 0x40, actor->callback44 = func_8002BF88,
        actor->timer0E = 999;
}
