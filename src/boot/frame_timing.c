#include "../../include/frame.h"

extern unsigned long long D_8008E3B0;
unsigned long long func_80061450(void);
void func_80050084(void);

int func_800495BC(unsigned long long *previous)
{
    unsigned long long interval_start;

    if (previous != 0) {
        unsigned long long old;

        old = *previous;
        *previous = func_80061450() * 1000000000 / D_8008E3B0;
        interval_start = old;
        return (*previous - interval_start) / 1000000;
    }
    return (func_80061450() * 1000000000 / D_8008E3B0) / 1000000;
}

void func_800496B8(void)
{
    func_80050084();
}

void func_800496D8(void)
{
}
