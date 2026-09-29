#include "../../include/save_menu_legacy_internal.h"

void func_800265B8(int unused)
{
    func_800278AC(0, 0, 0);
    if (func_800267BC() != 1) {
        D_80075FC4 = 3;
        D_800AD15C = 0xFFFF;
        D_800AD280 = 5;
        D_800AD28C = 0;
    }
}
