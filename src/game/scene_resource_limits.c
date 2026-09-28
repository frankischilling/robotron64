#include "../../include/scene_commands_internal.h"

void func_8001F350(SceneCommand *command)
{
    int index;
    for (index = 0; index < 50; index++) {
        D_800B8F78.resourceLimits[index] = D_800B00B0;
    }
    for (index = 0; index < 50; index++) {
        D_800B8F78.secondaryLimits[index] = D_800B14A4;
    }
}
