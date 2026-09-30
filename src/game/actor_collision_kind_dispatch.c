#include "../../include/actor_collision_services.h"

int func_80016618(ActorBehaviorActorInternal *first,
                   ActorBehaviorActorInternal *second, int third, int fourth)
{
    switch (second->resource24->actorKind) {
    case 4:
    case 5:
    case 6:
        break;
    case 7:
    case 8:
        if (first->resource24->actorKind != 11) {
            func_8001A410(first, second);
            return 0x20;
        }
        break;
    default:
        break;
    }
    return 0;
}
