#include "../../include/save_menu_internal.h"

extern int D_800BB158;
extern unsigned char D_80077B70[];

void func_80030798(void);

void func_800309D0(int *selection)
{
    D_800BB158 = *selection;
    if (D_800AD318.data.occupied[D_800BB158] != 0) {
        func_800278AC(0, 1, 0);
        func_80026178(D_80077B70, 0);
        return;
    }
    func_80030798();
}
