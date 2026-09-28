#include "../../include/debug_text_internal.h"
#include "../../include/save_game.h"

extern unsigned char D_800941B4[];
extern unsigned char D_800941BC[];
extern DebugTextFont D_80075A44;
extern int D_800BEF50;

void func_800328E0(void)
{
    int value;

    switch (D_800AD284) {
    case 1:
        value = (int)(((unsigned int)(D_8009EFA4 - D_800BEF50) * 99U) / 100U);
        if (value >= 300) {
            D_800AD284 = 2;
        }
        break;

    case 2:
        func_80037420(D_800941B4, 300, 300, &D_80075A44);
        break;

    case 3:
        value =
            (int)(((unsigned int)(D_8009EFA4 - D_800BEF50) * 99U) / 100U) + 300;
        if (value >= 640) {
            D_800AD284 = 0;
        } else {
            func_80037420(D_800941BC, value, 300, &D_80075A44);
        }
        break;
    }
}
