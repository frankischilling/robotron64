#include "../../include/actor_behavior_more_internal.h"

void func_80029B20(ActorBehaviorActorInternal *actor)
{
    if (D_800C8B7C + 1 < 50) {
        func_8001AF44(((unsigned char *)actor->resource24)[2] + 4, actor->position, actor);
    } else {
        func_80027AB8((GameActor *)actor, 0, 1);
    }
}
