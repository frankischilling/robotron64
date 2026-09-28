#include "../../include/object_runtime.h"

extern int D_80075950;
extern int D_800BA784;

int func_8003B254(void)
{
    if (D_80075950 == 0) {
        return 0;
    }
    if (D_800BA784 != 0) {
        func_800428C0();
    } else {
        func_80042E2C();
    }
    return 1;
}
