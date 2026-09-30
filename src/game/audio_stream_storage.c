#include "../../include/audio_host_internal.h"

void func_80058320(void)
{
    if (D_8008D7F0) {
        if (D_8008D7F4) {
            func_80058938(D_8008D7F4);
            D_8008D7F4 = 0;
        }
        D_8008D7F0 = 0;
    }
}

void *func_80058370(void)
{
    return D_8008D7F4;
}

unsigned int func_80058380(void)
{
    return D_8008D7F8;
}

void func_80058390(int entries, int firstCount, int secondCount, int thirdCount)
{
    D_8008D7E0 = entries;
    D_8008D7E4 = firstCount;
    D_8008D7E8 = secondCount;
    D_8008D7EC = thirdCount;
}
