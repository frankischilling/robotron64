#include "../../include/scene_commands_internal.h"

void func_8001F4DC(SceneCommand *command)
{
    if (D_800B9A78.effectCount >= 4) {
        func_8001C0D0(D_8009176C);
    }
    D_800B9A78.effectFirst[D_800B9A78.effectCount] = command->arguments[0];
    D_800B9A78.effectSecond[D_800B9A78.effectCount] = command->arguments[1];
    D_800B9A78.effectCount++;
}
