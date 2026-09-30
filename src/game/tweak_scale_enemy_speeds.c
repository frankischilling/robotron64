#include "../../include/tweak_internal.h"

void func_80038228(void)
{
    D_800AF1F0[17].speed *= 2;
    D_800AF1F0[18].speed *= 2;
    D_800AF1F0[19].speed *= 2;
    D_800AF1F0[20].speed *= 2;
    D_800AF1F0[26].speed = D_800AF1F0[26].speed * 5 / 3;
    D_800AF1F0[27].speed = D_800AF1F0[27].speed * 5 / 3;
    D_800AF1F0[28].speed = D_800AF1F0[28].speed * 9 / 3;
    D_800AF1F0[10].speed = D_800AF1F0[10].speed * 4 / 2;
    D_800AF1F0[11].speed = D_800AF1F0[11].speed * 5 / 2;
    D_800AF1F0[12].speed = D_800AF1F0[12].speed * 6 / 2;
}
