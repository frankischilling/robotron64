#include "../../include/sound_bridge_internal.h"

int func_800361FC(void)
{
    int index;

    for (index = 0; index < 15; index++) {
        D_800BEF70[index].flags.bits.active = 0;
    }
    return 1;
}
