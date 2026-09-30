#include "../../include/frame.h"
#include "../../include/object_helpers.h"

void func_80039F10(float x, float y, float z)
{
    D_800C8B88.position30[2] = z;
    D_800C8B88.position10[2] = z;
    D_800C8B88.position30[0] = x;
    D_800C8B88.position30[1] = y;
    D_800C8B88.position10[0] = x;
    D_800C8B88.position10[1] = y;
    D_800C8BD8.position[0] = x * 12.0f;
    D_800C8BD8.position[1] = -(y * 12.0f);
    D_800C8BD8.position[2] = z * 12.0f;
}
