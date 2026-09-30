#include "../../include/actor_behavior_more_internal.h"

void func_8002945C(ActorBehaviorActorInternal *actor)
{
    if (actor->animation1F != 1) {
        actor->field48 = D_8009EFA0;
        actor->countdown54 = D_8009EFA0;
        func_80027AB8((GameActor *)actor, 7, 1);
    }
}
