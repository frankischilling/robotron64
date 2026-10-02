#include "../../include/tweak_internal.h"

void func_800378CC(TweakCommand *command)
{
    int key;
    int value;
    int index;

    key = command->name;
    value = command->value;
    for (index = 0; index != 150; index++) {
        if (key == D_8009F030[index].name) {
            break;
        }
    }
    if (index == 150) {
        func_8001C0D0(D_800943D8, command->name);
    }
    D_800B9A78.tweaks[D_800B9A78.tweakCount].variable = index;
    D_800B9A78.tweaks[D_800B9A78.tweakCount].value = value;
    D_800B9A78.tweakCount++;
    if (D_800B9A78.tweakCount > 25) {
        func_8001C0D0(D_800943F0, D_800B9A78.valueCD0, D_800B9A78.unknownCCC);
    }
}
