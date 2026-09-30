#include "../../include/sdk_time.h"

SdkTime func_80061450(void)
{
    unsigned int current;
    unsigned int elapsed;
    SdkTime time;
    register unsigned int mask;

    mask = func_80067560();
    current = func_800684C0();
    elapsed = current - D_80196458;
    time = D_80196450;
    func_80067580(mask);
    return elapsed + time;
}
