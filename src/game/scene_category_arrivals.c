#include "../../include/scene_commands_internal.h"

void func_8001F6AC(SceneCommand *command)
{
    int resource;
    int count;
    int trigger;
    int delay;

    resource = command->arguments[0];
    count = command->arguments[1];
    trigger = command->arguments[2];
    delay = command->arguments[3];
    func_8001FCE4(0, 3, resource, trigger, delay, count, -1, -1);
}

void func_8001F6FC(SceneCommand *command)
{
    int resource;

    resource = command->arguments[0];
    func_8001FCE4(0, 8, resource, 1, 10000, 1, 0, 0);
}

void func_8001F744(SceneCommand *command)
{
    int resource;
    int count;
    int trigger;
    int delay;

    resource = command->arguments[0];
    count = command->arguments[1];
    trigger = command->arguments[2];
    delay = command->arguments[3];
    func_8001FCE4(0, 7, resource, trigger, delay, count, -1, -1);
}

void func_8001F794(SceneCommand *command)
{
    int resource;
    int count;
    int trigger;
    int delay;

    resource = command->arguments[0];
    count = command->arguments[1];
    trigger = command->arguments[2];
    delay = command->arguments[3];
    func_8001FCE4(0, 1, resource, trigger, delay, count, -1, -1);
}
