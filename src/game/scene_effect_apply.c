#include "../../include/scene_commands_internal.h"

void func_8001F87C(void)
{
    int index;

    for (index = 0; index < D_800B9A78.effectCount; index++) {
        func_80031C44(D_800B9A78.effectFirst[index], D_800B9A78.effectSecond[index]);
    }
}
