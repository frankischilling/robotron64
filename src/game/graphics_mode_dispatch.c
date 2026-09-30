#include "../../include/graphics_state_internal.h"

void func_8004729C(int mode)
{
    if (mode != D_8007D5D8) {
        if (D_8007D5D8 == 18) {
            FRAME_COMMAND(0xB9000002, 0);
        }
        D_8007D5D8 = mode;
        FRAME_COMMAND(0xE7000000, 0);
        switch (mode) {
        case 17:
            D_800C85B8 = 1;
            D_80123AE8 = 255;
            func_80046BB8();
            break;
        case 16:
            D_800C85B8 = 0;
            D_80123AE8 = 64;
            func_8004688C();
            break;
        case 15:
            D_800C85B8 = 0;
            D_80123AE8 = 64;
            func_80046A20();
            break;
        case 24:
            func_80049BAC();
            D_80123AE8 = 64;
            D_800C85B8 = 0;
            break;
        case 1:
            func_80046774();
            D_80123AE8 = 160;
            D_800C85B8 = 0;
            break;
        case 2:
            func_80046800();
            D_80123AE8 = 255;
            D_800C85B8 = 0;
            break;
        case 6:
            func_80046608();
            D_80123B00 = 0;
            D_80123AE8 = 255;
            D_800C85B8 = 1;
            break;
        case 14:
            D_80123AE8 = 255;
            D_800C85B8 = 1;
            func_80046954();
            D_80123B00 = 0;
            break;
        case 8:
            D_80123AE8 = 255;
            D_800C85B8 = 1;
            func_80046AD0();
            break;
        case 18:
            D_80123AE8 = 255;
            D_800C85B8 = 1;
            func_80046B44();
            break;
        default:
            D_800C85B8 = 1;
            D_80123AE8 = 255;
            func_80046C2C();
            break;
        }
    }
}
