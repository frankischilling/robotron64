#include "../../include/actor_animation_state.h"
#include "../../include/actor_collision_services.h"
#include "../../include/actor_collision_separation_internal.h"

void func_8001A410(ActorBehaviorActorInternal *first,
                    ActorBehaviorActorInternal *second);

int func_80017A2C(ActorBehaviorActorInternal *first,
                   ActorBehaviorActorInternal *second, int third, int fourth)
{
    switch (first->resource24->actorKind) {
    case 11:
        if (first->animation1F != 1) {
            func_80029D98(second);
            func_8001A410(first, second);
        }
        break;
    default:
        func_80018E1C(first, second, 0, 1, (int *)third, (int *)fourth);
        second->flags14 |= 2;
    }
    return 0;
}
