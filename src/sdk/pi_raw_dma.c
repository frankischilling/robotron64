#include "../../include/sdk_io.h"

extern unsigned int D_80000308;

int func_800678B0(int direction, unsigned int deviceAddress, void *dramAddress,
                  unsigned int size)
{
    register unsigned int status;

    status = *(volatile unsigned int *)0xA4600010;
    while (status & 3) {
        status = *(volatile unsigned int *)0xA4600010;
    }
    *(volatile unsigned int *)0xA4600000 = func_800606A0(dramAddress);
    *(volatile unsigned int *)0xA4600004 =
        (D_80000308 | deviceAddress) & 0x1FFFFFFF;
    switch (direction) {
    case 0:
        *(volatile unsigned int *)0xA460000C = size - 1;
        break;
    case 1:
        *(volatile unsigned int *)0xA4600008 = size - 1;
        break;
    default:
        return -1;
    }
    return 0;
}
