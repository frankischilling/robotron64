#include "../../include/actor_behavior_more_internal.h"

typedef struct ActorBehaviorScaleResource {
    unsigned char unknown00[8];
    int movement08;
    int scale0C;
} ActorBehaviorScaleResource;

void func_8002937C(ActorBehaviorActorInternal *actor)
{
    actor->field2C =
        ((ActorBehaviorScaleResource *)actor->resource24)->movement08;
    actor->field6C =
        (func_8003CC88(actor->angle08) *
         ((ActorBehaviorScaleResource *)actor->resource24)->movement08) /
        0x1000;
    actor->field70 =
        (func_8003CC58(actor->angle08) *
         ((ActorBehaviorScaleResource *)actor->resource24)->movement08) /
        0x1000;
    func_80039514(actor->objectIndex, actor->angle08);
    func_80027AB8((GameActor *)actor, 0, 1);
    func_800399E4(actor->objectIndex,
                  (float)(((ActorBehaviorScaleResource *)actor->resource24)->scale0C
                          << 12) /
                      40960.0f);
}
