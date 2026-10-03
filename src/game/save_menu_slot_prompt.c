#include "../../include/save_menu_internal.h"

extern unsigned char D_8009401C[];
extern unsigned char D_80094028[];

void func_800308AC(int unused);
void func_800309D0(int *selection);
void func_80030798(void);

void func_800308E8(int unused)
{
    func_800278AC(0, 1, 0);
    func_800263E0(D_8009401C, D_800BB200, 8, 0xC5, 0, 0,
                  func_800309D0, func_800308AC, 0x12C);
}

void func_80030958(int unused)
{
    func_800278AC(0, 1, 0);
    func_800263E0(D_80094028, D_800BB200, 8, 0xC5, 0, 0,
                  func_800309D0, func_800308AC, 0x12C);
    func_80030798();
}
