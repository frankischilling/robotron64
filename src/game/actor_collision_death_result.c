#include "../../include/actor_behavior_internal.h"
#include "../../include/early_game_state.h"

#include "../../include/actor_collision_services.h"
#include "../../include/sound_bridge_internal.h"

unsigned char func_80017CDC(ActorBehaviorActorInternal *first,
                            ActorBehaviorActorInternal *second,
                            int *firstPosition, int *secondPosition)
{
    EarlyGamePosition position;
    int result;

    if (!(first->flags14 & 0x100)) {
        result = 0;
        func_80015130((EarlyGameActor *)first, (EarlyGameActor *)second);
        position.value[0] = (secondPosition[0] + firstPosition[0]) / 2;
        position.value[1] = (secondPosition[1] + firstPosition[1]) / 2;
        position.value[2] = 0;
        if (second->unknown10[0] <= 0) {
            switch (second->resource24->actorKind) {
            case 4:
            default:
                func_80015184(19, position.value);
                break;
            case 5:
                func_80015184(19, position.value);
                break;
            case 6:
                func_80015184(19, position.value);
                func_8003614C(15, 0, 1, 0);
                break;
            case 7:
            case 8:
                func_80015184(129, position.value);
                func_8003614C(15, 0, 1, 0);
                break;
            }
            result = 0x20;
        }
        if (first->unknown10[0] <= 0) {
            result |= 2;
        }
    } else {
        result = 2;
    }
    return result;
}
