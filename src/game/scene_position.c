#include "../../include/scene_commands_internal.h"

void func_8001F3FC(SceneCommand *command)
{
    int index;
    int x;
    int y;
    int z;

    index = command->arguments[0];
    x = command->arguments[1];
    y = command->arguments[2];
    z = command->arguments[3];
    D_800B9A78.positionEnabled[index] = 1;
    D_800B9A78.positions[index][0] = x * 3000 - 30000;
    D_800B9A78.positions[index][1] = y * 3000 - 30000;
    D_800B9A78.positions[index][2] = z * 3000;
}
