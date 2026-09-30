#include "../../include/frame.h"
#include "../../include/object_helpers.h"

float func_8003A1C8(float *value)
{
    *value = D_800C8B88.value1C;
    return *value;
}

void func_8003A1E4(float value)
{
    D_800C8B88.value1C = value;
    D_800C8BD8.unknown00[0] = value;
}

void func_8003A214(float value)
{
    D_800C8B88.scale20 *= value;
}

float func_8003A230(void)
{
    return D_800C8B88.scale20;
}

void func_8003A240(float value)
{
    D_800C8B88.scale20 = value;
}

void func_8003A24C(float value, float unused1, float unused2)
{
    D_800C8B88.value00 = value;
}

void func_8003A260(float *x, float *y, float *z)
{
    *x = D_800C8B88.position10[0];
    *y = D_800C8B88.position10[1];
    *z = D_800C8B88.position10[2];
}

void func_8003A28C(float *value)
{
    *value = D_800C8B88.angle04[0];
}

void func_8003A29C(float *value)
{
    *value = D_800C8B88.angle04[1];
}

void func_8003A2AC(float *value)
{
    *value = D_800C8B88.angle04[2];
}

void func_8003A2BC(float *x, float *y, float *z)
{
    *x = D_800C8B88.angle04[0];
    *y = D_800C8B88.angle04[1];
    *z = D_800C8B88.angle04[2];
}

int func_8003A2E8(void)
{
    return D_800C8B88.value3C;
}
