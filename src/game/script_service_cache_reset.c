#include "../../include/script_service_internal.h"

void func_8001C740(void)
{
    int index;

    for (index = 0; index < 100; index++) {
        D_80097650[index].flags.bits.registered = 0;
    }
}
