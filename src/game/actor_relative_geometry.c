#include "../../include/early_game_state.h"

#include "../../include/early_game_helpers.h"

void func_8000A2E0(EarlyGameActor *first, EarlyGameActor *second, int *distance, int *angle)
{
    int x;
    int y;

    x = first->position.value[0] - second->position.value[0];
    y = first->position.value[1] - second->position.value[1];
    *angle = func_8000DF14(func_8003CD4C(y, x) - second->angle08);
    *distance = func_8003CCE8(x * x + y * y);
}
