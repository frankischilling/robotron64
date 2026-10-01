#include "../../include/save_menu_internal.h"

void func_80030DC0(int *selection)
{
    if ((D_800AD2F8.field10 % 5000) < 2500) {
        D_800AD2F8.field10 = D_800AD2F8.field10 - (D_800AD2F8.field10 % 5000) + 5000;
    } else {
        D_800AD2F8.field10 = D_800AD2F8.field10 - (D_800AD2F8.field10 % 5000);
    }
    if (D_800AD2F8.field10 < 10000) {
        D_800AD2F8.field10 = 10000;
    }
    if (D_800AD2F8.field10 == 15000) {
        D_800AD2F8.field10 = 25000;
    }
    if (D_800AD2F8.field10 == 20000) {
        D_800AD2F8.field10 = 10000;
    }
    if (D_800AD2F8.field10 == 30000) {
        D_800AD2F8.field10 = 50000;
    }
    if (D_800AD2F8.field10 == 45000) {
        D_800AD2F8.field10 = 25000;
    }
    if (D_800AD2F8.field10 == 55000) {
        D_800AD2F8.field10 = 100000;
    }
    if (D_800AD2F8.field10 == 95000) {
        D_800AD2F8.field10 = 50000;
    }
    if (D_800AD2F8.field10 >= 105000) {
        D_800AD2F8.field10 = 105000;
    }
}
