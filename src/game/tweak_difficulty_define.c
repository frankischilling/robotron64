#include "../../include/tweak_internal.h"

void func_8003762C(TweakCommand *command)
{
    int name;
    int easy;
    int hard;
    int index;

    name = command->name;
    easy = command->value;
    hard = command->alternate;
    for (index = 0; index != 150; index++) {
        if (name == D_8009F030[index].name) {
            break;
        }
    }
    if (index == 150) {
        func_8001C0D0(D_8009439C, command->name);
    }
    D_8009FAE0[D_8009F028].variable = index;
    D_8009FAE0[D_8009F028].easy = easy;
    D_8009FAE0[D_8009F028].hard = hard;
    D_8009F028++;
    if (D_8009F028 > 60) {
        func_8001C0D0(D_800943B4);
    }
}
