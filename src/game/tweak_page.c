#include "../../include/tweak_internal.h"

void func_80037508(TweakCommand *command)
{
    int title;

    if (D_8009F02C == 20) {
        func_8001C0D0(D_80094350);
    }
    title = command->name;
    D_8009F4E0[D_8009F02C].title = title;
    D_8009F4E0[D_8009F02C].firstVariable = D_8009F02A;
    D_8009F4E0[D_8009F02C].count = 0;
    D_8009F02C++;
}
