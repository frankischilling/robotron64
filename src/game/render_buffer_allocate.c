#include "../../include/heap.h"

extern unsigned char *D_8013D9C0;
extern unsigned char *D_8013D9C4;
extern unsigned char *D_8013D9C8;

void func_8004BC44(void)
{
    D_8013D9C4 = func_8004DD6C(0xFA000);
    D_8013D9C0 = D_8013D9C4;
    D_8013D9C8 = D_8013D9C4 + 0xFA000;
}
