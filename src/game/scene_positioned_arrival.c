#include "../../include/scene_commands_internal.h"

void func_8001F7FC(SceneCommand *command)
{
    int category;
    int resource;
    int trigger;
    int delay;
    int x;
    int y;

    category = command->arguments[0];
    resource = command->arguments[1];
    trigger = command->arguments[2];
    delay = command->arguments[3];
    x = command->arguments[4];
    y = command->arguments[5];
    func_8001FCE4(0, category, resource, trigger, delay, 1,
                  x * 3000 - 30000, y * 3000 - 30000);
}
