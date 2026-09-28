#include "../../include/sound_bridge_internal.h"

int func_80036064(GameActor *actor, int fallback)
{
    if (D_8007394C != 0) {
        return (actor->unknown00[4] + D_800BEF6C + 0x400) & 0xFFF;
    }
    return fallback;
}

void func_800360A0(void)
{
}

int func_800360A8(int value)
{
    return value;
}

void func_800360B0(void)
{
}

int func_800360B8(unsigned char *label)
{
    return -1;
}

void func_800360C4(int enabled)
{
    if (enabled != 0) {
        func_800360B0();
    }
}
