#include "../../include/model_geometry_internal.h"

extern int func_8000A21C(int minimum, int maximum);

void func_8004000C(RendererPosition *output, RendererPosition *input,
                  int count, int unused)
{
    int index;

    for (index = 0; index < count; index++) {
        (*output)[0] = (*input)[0] + func_8000A21C(-100, 100);
        (*output)[1] = (*input)[1] + func_8000A21C(-100, 100);
        (*output)[2] = (*input)[2] / 2 + func_8000A21C(-100, 100) - 500;
        input++;
        output++;
    }
}
