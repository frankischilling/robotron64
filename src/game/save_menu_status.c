#include "../../include/static_menu_internal.h"
#include "../../include/save_menu_internal.h"

extern int D_80077C08;
extern int D_80077C0C;
extern int D_80077C10;
extern void *D_800AEE9C;
extern void *D_800BB220;
extern unsigned char D_8007636C[];
extern unsigned char D_800763F0[];
extern unsigned char D_80076598[];
extern unsigned char D_800766BC[];
extern unsigned char D_80076C34[];
extern unsigned char D_80076C68[];
extern unsigned char D_80076C9C[];
extern unsigned char D_80076BD8[];
extern unsigned char D_80076D70[];
extern unsigned char D_80094034[];
extern unsigned char D_80094040[];

void func_800308AC(int unused);
void func_800309D0(int *selection);

void func_80030A80(int unused)
{
    int result;

    result = func_800301A4(1, 1);
    switch (result) {
    case 1:
        D_800BB220 = D_80076D70;
        func_800278AC(0, 1, 0);
        func_800263E0(D_80094034, D_800BB200, 8, 0xC5, 0, 0,
                      func_800305F8, func_800308AC, 0x12C);
        D_80077C0C = 0;
        break;
    case -4:
        if (D_80077C0C >= 2) {
            D_80077C0C = 0;
        }
        if (D_80077C0C != 1) {
            D_800BB220 = D_800AEE9C;
            func_800278AC(0, 1, 0);
            func_80026178(D_80076598, 0);
            D_80077C0C++;
        } else {
            func_80026178(D_8007636C, 0);
            D_80077C0C++;
        }
        break;
    case -3:
        func_80026178(D_80076C34, 0);
        D_80077C0C = 0;
        break;
    case -2:
        func_80026178(D_80076C68, 0);
        D_80077C0C = 0;
        break;
    case -1:
        func_80026178(D_80076C9C, 0);
        D_80077C0C = 0;
        break;
    }
}

void func_80030C3C(int unused)
{
    int result;

    D_80077C08 = 0;
    result = func_800301A4(1, 0);
    switch (result) {
    case -4:
        if (D_80077C10 >= 2) {
            D_80077C10 = 0;
        }
        if (D_80077C10 != 1) {
            D_800BB220 = D_800AEE9C;
            func_800278AC(0, 1, 0);
            func_80026178(D_800766BC, 0);
            D_80077C10++;
        } else {
            func_80026178(D_800763F0, 0);
            D_80077C10++;
        }
        break;
    case -3:
    case -1:
    case 1:
        D_800BB220 = D_8007751C;
        func_800278AC(0, 1, 0);
        func_800263E0(D_80094040, D_800BB200, 8, 0xC5, 0, 0,
                      func_800309D0, func_800308AC, 0x12C);
        D_80077C10 = 0;
        break;
    case -2:
        func_80026178(D_80076BD8, 0);
        D_80077C10 = 0;
        break;
    }
}
