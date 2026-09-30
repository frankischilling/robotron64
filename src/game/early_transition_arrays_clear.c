#include "../../include/early_parameter_internal.h"

void func_8000E328(void)
{
    int i;

    D_800972C0 = 0;
    for (i = 0; i < 8; i++) {
        D_800972C8[i] = 0;
        D_80097318[i] = 0;
        D_80097328[i] = 0;
        D_800972F8[i] = 0;
    }
}
