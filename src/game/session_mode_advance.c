#include "../../include/session_menu_internal.h"

extern int D_8009E57C;

void func_80022B78(void)
{
    D_8009E57C = 0;
    D_800AD280++;
    if (D_800AD280 == 9) {
        D_800AD280 = 1;
    }
    D_800AD28C = 0;
    if (D_800AD280 == 6) {
        func_80022528(0, 0, 0);
    }
    if (D_800AD280 == 7) {
        D_800AD280++;
    }
}
