#include "../../include/debug_output.h"

extern unsigned char *D_8013D9C0;
extern unsigned char *D_8013D9C8;
extern unsigned char D_800954F0[];
extern unsigned char D_80095524[];

void *func_8004BBD0(unsigned int size)
{
    D_8013D9C0 += size;
    if (D_8013D9C0 > D_8013D9C8) {
        func_800496E0(D_800954F0, D_8013D9C0, D_8013D9C8,
                      size, D_80095524, 94);
    }
    return D_8013D9C0 - size;
}
