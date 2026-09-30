#include "../../include/actor_collision_services.h"
#include "../../include/actor_animation_state.h"
#include "../../include/early_game_state.h"

unsigned char func_80017ACC(ActorBehaviorActorInternal *first,
                          ActorBehaviorActorInternal *second,
                          int *firstPosition, int *secondPosition)
{
    EarlyGamePosition position;
    int result = 0;

    if (!(second->flags14 & 0x100)) {
        if (first->resource24->actorKind >= 4) {
            func_80015130((EarlyGameActor *)first, (EarlyGameActor *)second);
            if (first->unknown10[0] <= 0) {
                func_80029D98(first);
            } else {
                position.value[0] = (secondPosition[0] + firstPosition[0]) / 2;
                position.value[1] = (secondPosition[1] + firstPosition[1]) / 2;
                position.value[2] = 0;
                func_80015184(19, position.value);
            }
            if (second->unknown10[0] == 0) {
                result = 0x20;
            }
        } else if (second->resource24->actorKind == 1 &&
                   second->resource24->actorKind == 2 &&
                   first->resource24->actorKind < 4 &&
                   D_800AD2F8.field08 >= 2) {
            func_80029E5C(first);
        }
    } else {
        result = 0x20;
    }
    return result;
}
