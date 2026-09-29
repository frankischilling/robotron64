#include "../../include/sdk_timers.h"

void func_800686D4(SdkTime cycles)
{
    SdkTime absolute;
    unsigned int mask;

    mask = func_80067560();
    D_80196460 = func_800684C0();
    absolute = D_80196460 + cycles;
    func_8006E740((unsigned int)absolute);
    func_80067580(mask);
}
