#include "../../include/scene_commands_internal.h"

void func_8001F5B4(SceneCommand *command)
{
    int delay;
    int trigger;
    int resource;
    int count;

    resource = command->arguments[0];
    count = command->arguments[1];
    trigger = command->arguments[2];
    delay = command->arguments[3];
    if (resource >= 9 && resource < 13 && count >= 51) {
        func_8001C0D0(D_8009178C);
    }
    if (resource >= 17 && resource < 21 && count >= 51) {
        func_8001C0D0(D_800917A8);
    }
    if (resource >= 0 && resource < 4 && trigger == 2) {
        count += D_800BAE98;
    }
    func_8001FCE4(0, 0, resource, trigger, delay, count, -1, -1);
}
