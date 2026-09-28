#include "../../include/scene_commands_internal.h"

void func_8001F3C4(SceneCommand *command)
{
    D_800B9A78.valueCE8 = command->arguments[0];
    D_800B9A78.flagsD04 = command->arguments[1] & 3;
    D_800B9A78.flagD08 = (command->arguments[1] & 4) >> 2;
}
