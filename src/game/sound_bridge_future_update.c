#include "../../include/sound_bridge_internal.h"

int func_80036318(void)
{
    int index;
    int result;

    result = 0;
    for (index = 0; index < 15; index++) {
        if (D_800BEF70[index].flags.bits.active &&
            D_800BEF70[index].delay <
                (unsigned int)(D_8009EFA0 - D_800BEF70[index].startTime)) {
            result = 1;
            func_8003614C(D_800BEF70[index].sound, D_800BEF70[index].mode,
                          D_800BEF70[index].value, D_800BEF70[index].extra);
            D_800BEF70[index].flags.bits.active = 0;
        }
    }
    return result;
}
