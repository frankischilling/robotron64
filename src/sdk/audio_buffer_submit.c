#include "../../include/audio_io.h"
#include "../../include/sdk_io.h"

static unsigned char D_8008F170 = 0;

int func_80065B70(void *address, unsigned int size)
{
    void *adjusted;

    adjusted = address;
    if (D_8008F170 != 0) {
        adjusted = (unsigned char *)address - 0x2000;
    }
    if ((((unsigned int)address + size) & 0x3FFF) == 0x2000) {
        D_8008F170 = 1;
    } else {
        D_8008F170 = 0;
    }
    if (func_8006B5B0() != 0) {
        return -1;
    }
    *(volatile unsigned int *)0xA4500000 = func_800606A0(adjusted);
    *(volatile unsigned int *)0xA4500004 = size;
    return 0;
}
