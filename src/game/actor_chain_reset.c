#include "../../include/actor_setup_internal.h"

extern int D_8007358C;
extern int D_8009EFA0;

void func_8000F7D8(void)
{
    int index;

    for (index = 0; D_80073590[index].value00 != -1; index++) {
        D_80073590[index].value00 = 0;
    }
    D_8007358C = D_8009EFA0;
}
