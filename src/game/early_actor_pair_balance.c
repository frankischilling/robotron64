#include "../../include/early_game_state.h"

void func_80015130(EarlyGameActor *first, EarlyGameActor *second)
{
    int old;

    if (first->value10[0] < 0) {
        first->value10[0] = 0;
    }
    if (second->value10[0] < 0) {
        second->value10[0] = 0;
    }
    old = first->value10[0];
    first->value10[0] -= second->value10[0];
    second->value10[0] -= old;
}
