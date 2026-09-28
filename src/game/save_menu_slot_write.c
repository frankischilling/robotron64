#include "../../include/save_menu_internal.h"

extern int D_80075FB8;
extern int D_80077C04;
extern int D_80077C08;
extern int D_800BB158;
extern unsigned char D_80076B14[];
extern unsigned char D_80076B70[];
extern unsigned char D_80076BA4[];
extern unsigned char D_80076BD8[];

void func_80030798(void)
{
    int result;

    func_800301A4(1, 0);
    if (D_80077C04 != 0 || D_80077C08 != 0) {
        func_80026178(D_80076B14, 0);
        D_80075FB8 = 0;
    } else {
        func_8002FE68(&D_800AD318.data.slots[D_800BB158]);
        D_800AD318.data.occupied[D_800BB158] = 1;
        result = func_80030420(1);
        switch (result) {
        case 1:
            break;
        case 0:
            func_80026178(D_80076B70, 0);
            break;
        case -2:
            func_80026178(D_80076BD8, 0);
            break;
        case -3:
            func_80026178(D_80076BA4, 0);
            break;
        }
    }
}
