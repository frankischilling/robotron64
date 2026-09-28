#include "../../include/scene_commands_internal.h"

void func_8001F478(SceneCommand *command)
{
    int first;
    int second;

    first = command->arguments[0];
    second = command->arguments[1];
    D_800B9A78.valueCD0 = first;
    D_800B9A78.valueCD8 = second;
}
