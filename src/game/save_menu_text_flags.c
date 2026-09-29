#include "../../include/movie.h"
#include "../../include/text.h"

extern int D_80076000;
extern int D_80076004;
extern int D_80076008;
extern int D_8007600C;

void func_800226E8(int unused)
{
    func_80000B7C(D_80076000, 0, 0x80);
    func_80000B7C(D_80076004, 0, 0x80);
    func_80000B7C(D_80076008, 0, 0x80);
    func_80000B7C(D_8007600C, 0, 0x80);
}

void func_80022754(int unused)
{
    func_80000B7C(D_80076000, 0x100, 0);
    func_80000B7C(D_80076004, 0x100, 0);
    func_80000B7C(D_80076008, 0x100, 0);
    func_80000B7C(D_8007600C, 0x100, 0);
}

void func_800227C0(int unused)
{
    func_80000B7C(*(int *)((unsigned char *)D_800B14A8 + 0x66C), 0x100, 0);
}

void func_800227F4(int unused)
{
    int offset;

    for (offset = 0; offset != 0x8C; offset += 0x1C) {
        func_80000B7C(*(int *)((unsigned char *)D_800B14A8 + 0x66C + offset),
                       0x100, 0);
    }
}
