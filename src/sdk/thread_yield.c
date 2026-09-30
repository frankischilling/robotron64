#include "../../include/sdk_thread_internal.h"

void func_8006E6F0(void)
{
    register unsigned int mask;

    mask = func_80067560();
    D_8008F1B0->state = 2;
    func_8006707C(&D_8008F1A8);
    func_80067580(mask);
}
