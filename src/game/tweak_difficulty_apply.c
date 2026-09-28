#include "../../include/tweak_internal.h"

void func_80037700(void)
{
    int index;

    if (D_800AD300 == 0) {
        for (index = 0; index < D_8009F028; index++) {
            *D_8009F030[D_8009FAE0[index].variable].target += D_8009FAE0[index].easy;
        }
    } else if (D_800AD300 >= 2) {
        for (index = 0; index < D_8009F028; index++) {
            *D_8009F030[D_8009FAE0[index].variable].target += D_8009FAE0[index].hard;
        }
    }
}
