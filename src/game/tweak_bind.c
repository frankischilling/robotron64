#include "../../include/tweak_internal.h"

void func_8003799C(unsigned char *name, int *target)
{
    int identifier;
    int index;

    identifier = func_800383F8(name);
    for (index = 0; index < D_8009F02A; index++) {
        if (D_8009F030[index].name == identifier) {
            D_8009F030[index].target = target;
            *target = D_8009F030[index].initialValue;
            return;
        }
    }
    if (D_800781C0 != 0) {
        func_8001C0D0(D_80094420, name);
    }
}
