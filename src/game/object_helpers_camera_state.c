#include "../../include/object_helpers.h"

int func_80039EA0(int value0, int value1)
{
    D_800C8B88.value40 = value1;
    D_800C8B88.value3C = value0;
    return value0;
}

void func_80039EB8(int value, unsigned char flags)
{
    D_800C8BD4 = flags & 1;
    D_800C8BD5 = flags & 2;
    D_800C8BD6 = flags & 4;
    D_FLT_800C8BD0 = value;
}

int func_80039EF4(void)
{
    return D_800C8B88.value44;
}

void func_80039F04(int value)
{
    D_800C8B88.value44 = value;
}
