#include "../../include/tweak_internal.h"

void func_80037588(TweakCommand *command)
{
    int name;
    int value;

    if (D_8009F02A >= 150) {
        func_8001C0D0(D_80094378);
    }
    name = command->name;
    value = command->value;
    D_8009F030[D_8009F02A].target = 0;
    D_8009F030[D_8009F02A].name = name;
    D_8009F030[D_8009F02A].initialValue = value;
    D_8009F02A++;
    D_8009F4E0[D_8009F02C - 1].count++;
}
