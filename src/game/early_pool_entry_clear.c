#include "../../include/early_game_helpers.h"

extern EarlyGamePoolState *D_800AE4F4;

void func_8000CF70(int unused)
{
    EarlyGamePoolState *pool = D_800AE4F4;
    *(int *)((char *)pool + pool->count * 124 + 16) = 0;
}
