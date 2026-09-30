#include "../../include/early_game_state.h"
#include "../../include/scene_counter_internal.h"
#include "../../include/actor_animation_state.h"
#include "../../include/actor_collision_services.h"

extern int D_800739CC;

int func_80017E50(EarlyGameActor *first, EarlyGameActor *second,
                  int *firstPosition, int *secondPosition)
{
    EarlyGamePosition position;

    if (!(first->flags14 & 0x100)) {
        if (D_800AD138.value8C == 0) {
            func_80037144(100, (SceneBucketCounter *)first->owner3C);
            first->value10[0] /= 5;
            func_80015130(second, first);
            position.value[0] = (secondPosition[0] + firstPosition[0]) / 2;
            position.value[1] = (secondPosition[1] + firstPosition[1]) / 2;
            position.value[2] = 0;
            func_80015218(first);
            func_80039C1C(second->objectIndex0C, 150, 150, 0);
            D_800739CC = D_8009EFA0;
        } else {
            position.value[0] = (secondPosition[0] + firstPosition[0]) / 2;
            position.value[1] = (secondPosition[1] + firstPosition[1]) / 2;
            position.value[2] = 0;
            func_80015184(19, position.value);
        }
    }
    return 2;
}
