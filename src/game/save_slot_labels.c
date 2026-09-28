#include "../../include/save_game.h"
#include "../../include/text.h"

void func_80030054(void)
{
    int slot;
    unsigned char *level;
    unsigned char *mode;

    for (slot = 0; slot < 8; slot++) {
        if (D_800AD318.data.occupied[slot] != 0) {
            if (func_80021B20(D_800AD318.data.slots[slot].session.level) != 0) {
                level = func_80021B20(D_800AD318.data.slots[slot].session.level);
            } else {
                level = func_80021B20(D_800AD318.data.slots[slot].session.level + 1);
            }
            if (D_800AD318.data.slots[slot].session.mode == 2) {
                mode = D_80093FF0;
            } else {
                mode = D_80093FF4;
            }
            func_800363D0(D_800BB160[slot], D_80093FE4, level, mode);
        } else {
            func_800363D0(D_800BB160[slot], D_80093FF8);
        }
        D_800BB200[slot] = D_800BB160[slot];
        func_80000518(D_800BB160[slot]);
        func_80027940(D_800BB200, 8);
    }
}
