#include "../../include/geometry_bridge_internal.h"

void func_8003FA18(GeometryPoint *output, GeometryPoint *input, int count, int value)
{
    int i;

    for (i = 0; i < count; i++) {
        output->x = ((value * 2 + 256) * input->x) >> 8;
        output->z = ((value * 3 + 256) * input->z) >> 8;
        output->y = (((256 - value) * input->y) >> 8) + D_800CD2A0;
        output++;
        input++;
    }
}
