#include "../../include/sound_bridge_internal.h"

static const unsigned char D_800942E0[] = "Out of future sound handles\n";

int func_80036288(int sound, int mode, int value, int extra, unsigned int delay)
{
    int index;

    for (index = 0; index < 15; index++) {
        if (!D_800BEF70[index].flags.bits.active) {
            D_800BEF70[index].flags.bits.active = 1;
            D_800BEF70[index].startTime = D_8009EFA0;
            D_800BEF70[index].delay = delay;
            D_800BEF70[index].sound = sound;
            D_800BEF70[index].value = value;
            D_800BEF70[index].extra = extra;
            D_800BEF70[index].mode = mode;
            return 1;
        }
    }

    func_8001C2C4((unsigned char *)D_800942E0);
    return 0;
}
