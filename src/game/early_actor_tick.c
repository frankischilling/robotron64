#include "../../include/early_game_more.h"
#include "../../include/early_game_state.h"

void func_80009F58(EarlyGameActor *actor, int unused)
{
    actor->field4C++;
    actor->field50 -= D_8009EF94;
    if (actor->field50 < 0) {
        actor->state21 = 2;
    }
}
