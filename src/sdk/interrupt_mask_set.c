#include "../../include/sdk_time.h"

extern unsigned int D_8008E3C0;

void func_8006E6A0(unsigned int bits)
{
    register unsigned int mask;

    mask = func_80067560();
    D_8008E3C0 |= bits;
    func_80067580(mask);
}
