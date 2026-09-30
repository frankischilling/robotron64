#include "../../include/audio_host_internal.h"

void func_80058890(void (*callback)(void))
{
    D_80190330 = callback;
}

void func_8005889C(void)
{
    if (D_80190330) {
        D_80190330();
    }
}

void func_800588C8(int (*callback)(unsigned char, int, int, int, int))
{
    D_80190334 = callback;
}

int func_800588D4(unsigned char code, int first, int second, int third, int value)
{
    if (D_80190334) {
        return D_80190334(code, first, second, third, value);
    }
    return -1;
}
