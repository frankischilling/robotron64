#include "../../include/save_menu_nav_internal.h"

void func_80025C40(int *selection)
{
    int value;

    value = *selection;
    if (value >= 0) {
        if (func_80021B20(value) == 0) {
            *selection += D_800761F0;
        }
    } else {
        *selection = 1;
    }
    func_800363D0(D_80076FBC, D_80092BF4, func_80021B20(*selection));
    func_80000518(D_80076FBC);
}
