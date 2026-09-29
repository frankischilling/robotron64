#include "../../include/early_game_more.h"
#include "../../include/early_game_state.h"

extern void func_80035244(EarlyGameActor *actor, int second);

int func_800162AC(EarlyGameActor *actor, int second, int third, int fourth)
{
    if (actor->animation1F != 1 && (actor->flags14 & 0x4400) == 0) {
        func_80035244(actor, second);
    }
    return 0x20;
}
