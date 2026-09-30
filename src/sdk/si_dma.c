#include "../../include/sdk_si.h"
#include "../../include/sdk_io.h"
#include "../../include/audio_io.h"

extern void func_80067360(void *address, unsigned int size);

int func_80069A80(int direction, void *address)
{
    if (func_8006DBF0()) {
        return -1;
    }
    if (direction == 1) {
        func_80067360(address, 64);
    }
    *(volatile unsigned int *)0xA4800000 = func_800606A0(address);
    if (direction == 0) {
        *(volatile unsigned int *)0xA4800004 = 0x1FC007C0;
    } else {
        *(volatile unsigned int *)0xA4800010 = 0x1FC007C0;
    }
    if (direction == 0) {
        func_80065790(address, 64);
    }
    return 0;
}
