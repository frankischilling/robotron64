#include "../../include/sdk_io.h"

int func_8006B360(int direction, unsigned int deviceAddress, void *dramAddress,
                  unsigned int size)
{
    if (func_8006B3F0()) {
        return -1;
    }
    *(volatile unsigned int *)0xA4040000 = deviceAddress;
    *(volatile unsigned int *)0xA4040004 = func_800606A0(dramAddress);
    if (direction == 0) {
        *(volatile unsigned int *)0xA404000C = size - 1;
    } else {
        *(volatile unsigned int *)0xA4040008 = size - 1;
    }
    return 0;
}
