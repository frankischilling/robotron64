#include "../../include/model_geometry_internal.h"

extern int D_8007D914;
extern short *D_80138260[];

void func_800404F4(void)
{
    int index;
    short *input;
    short *output;

    if (D_80123AEC != 0) {
        input = D_80123AEC;
        output = D_80138260[D_8007D914];
        for (index = 0; index < 320 * 480; index++) {
            *output++ = *input++;
        }
    }
}
