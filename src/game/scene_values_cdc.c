#include "../../include/scene_commands_internal.h"

void func_8001F494(SceneCommand *command)
{
    int first;
    int second;
    int third;

    first = command->arguments[0];
    second = command->arguments[1];
    third = command->arguments[2];
    D_800B9A78.valueCDC = first;
    D_800B9A78.valueCE0 = second;
    D_800B9A78.valueCE4 = third;
}
