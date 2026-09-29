#include "../../include/early_game_helpers.h"

extern EarlyGamePoolState *D_800AE4F4;

void func_8000D034(int unused)
{
    EarlyGamePoolState *pool = D_800AE4F4;
    pool->count++;
}

void func_8000D054(int unused)
{
    EarlyGamePoolState *pool = D_800AE4F4;
    *(int *)((char *)pool + pool->index * 604 + 0x4E8) = 0;
}
