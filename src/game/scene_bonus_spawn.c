#include "../../include/early_game_state.h"
#include "../../include/actor_setup_internal.h"

#include "../../include/scene_counter_internal.h"

void func_80037050(int amount, SceneBucketCounter *counter)
{
    int i;
    EarlyGameActor *actor;
    EarlyGamePosition position;

    position = counter->actor08->position;
    if (D_800AE2FC) {
        counter->count06 += amount;
        for (i = 0; i < amount; i++) {
            actor = (EarlyGameActor *)func_800283D4(9, &D_800B23D0, position.value);
            if (actor != 0) {
                actor->resource24->callback54(actor, 1);
            }
            position.value[0] += 1000;
            position.value[1] += 1000;
        }
    } else {
        counter->value1C += amount;
    }
}
