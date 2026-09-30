#include "../../include/scene_commands_internal.h"

int func_8001F2D8(int level)
{
    int index;

    for (index = 1; index < D_800A4530; index++) {
        if (level < D_800A42B0[index].startLevel) {
            func_8001F2CC(func_800383C4(D_800A42B0[index - 1].name), 2);
            return 1;
        }
    }
    return 0;
}
