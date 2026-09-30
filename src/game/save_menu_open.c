#include "../../include/save_menu_internal.h"

extern void *D_800AEE9C;
extern unsigned char D_8007751C[];

void func_80030C3C(int mode);

void func_80030A3C(int unused)
{
    func_800278AC(0, 1, 0);
    D_800AEE9C = D_8007751C;
    func_80030C3C(0);
}
