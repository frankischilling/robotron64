#include "../../include/save_menu_internal.h"

void func_80030EAC(int *selection)
{
    int value;

    value = D_800AF1E0;
    D_80076EC0 = value;
    D_800AD2F8.field04 = value < D_800AD2F8.field04 ? value : D_800AD2F8.field04;

    if (value < *selection) {
        D_800AD2F8.field04 = 0;
        *selection = 0;
    }
    func_80051680(*selection + 1, 1, 1);
}
