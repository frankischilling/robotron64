#include "../../include/geometry_bridge_internal.h"

void func_8003FC14(GeometryPoint *output, GeometryPoint *input, int count, int value)
{
    int i;

    for (i = 0; i < count; i++) {
        output->x = ((256 - value) * input->x) >> 8;
        output->y = ((256 - value) * input->y) >> 8;
        output->z = ((256 - value) * input->z) >> 8;
        output++;
        input++;
    }
}
