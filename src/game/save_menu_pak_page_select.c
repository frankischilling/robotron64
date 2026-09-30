#include "../../include/save_menu_legacy_internal.h"

extern int D_80077A98;
extern int D_80077A94;
extern unsigned char D_800767E0[];
extern unsigned char D_80076474[];
extern unsigned char D_80076C34[];
extern unsigned char D_80076C68[];

void func_80026A10(int unused)
{
    int result = func_800267BC();

    if (result != 1) {
        if (result == -1) {
            if (D_80077A98 >= 2) D_80077A98 = 0;
            if (D_80077A98 != 1) {
                func_80026178(D_800767E0, 0);
                D_80077A98++;
            } else {
                func_80026178(D_80076474, 0);
                D_80077A98++;
            }
        } else {
            if (D_80077A94 == 0) {
                func_80026178(D_80076C34, 0);
            } else {
                func_80026178(D_80076C68, 0);
            }
            D_80077A98 = 0;
        }
    } else {
        D_80077A98 = 0;
    }
}
