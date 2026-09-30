#include "../../include/model_geometry_internal.h"

void func_8003F818(int count, RendererNormal *output,
                  RendererNormal *first, RendererNormal *second)
{
    int index;

    for (index = 0; index < count; index++, output++, first++, second++) {
        if (index < 12) {
            (*output)[0] = (*second)[0];
            (*output)[1] = (*second)[1];
            (*output)[2] = (*second)[2];
        } else {
            (*output)[0] = (*first)[0];
            (*output)[1] = (*first)[1];
            (*output)[2] = (*first)[2];
        }
    }
}
