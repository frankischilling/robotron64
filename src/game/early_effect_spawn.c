#include "../../include/early_game_state.h"
#include "../../include/early_game_more.h"
#include "../../include/actor_setup_internal.h"

void func_80009F90(EarlyGameActor *source, int kind)
{
    EarlyGameActor *actor;

    actor = (EarlyGameActor *)func_800283D4(9, &D_800B2428, source->position.value);
    if (actor != 0) {
        actor->position.value[2] = 0;
        actor->field5C = (int)func_80009F58;
        actor->field50 = 240;
        switch (kind) {
            case 0: actor->callback00 = func_800058F0; break;
            case 1: actor->callback00 = func_80005E80; break;
            case 2: actor->callback00 = func_80006654; break;
            case 3: actor->callback00 = func_80006C1C; break;
            case 4: actor->callback00 = func_80007180; break;
            case 5: actor->callback00 = func_80006240; break;
            default: actor->callback00 = func_800058F0; break;
        }
    }
}
