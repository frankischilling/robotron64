#include "../../include/scene_commands_internal.h"

void func_8001F4B8(SceneCommand *command)
{
    int first;
    int second;

    first = command->arguments[0];
    second = command->arguments[1];
    D_800B9A78.enabledCF4 = 1;
    D_800B9A78.valueCF0 = first;
    D_800B9A78.valueCF8 = second;
}
