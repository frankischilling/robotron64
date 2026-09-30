#include "../../include/graphics_state_internal.h"

void func_800470F4(void)
{
    unsigned int alignedBase;
    int index;

    func_8004BC44();
    D_80126B78 = (unsigned int)func_8004DD6C(0x19000);
    alignedBase = D_80126B78 & 0xFFFFFFF8;
    D_80126B78 = alignedBase;
    D_80126B7C = alignedBase + 0x18FF8;
    D_80126B74 = alignedBase;
    func_800420B0();
    for (index = 0; index < 256; index++) {
        func_80046DD0(index);
    }
}
