#include "../../include/sdk_io.h"

unsigned int func_800606A0(void *address)
{
    if ((unsigned int)address >= 0x80000000 &&
        (unsigned int)address < 0xA0000000) {
        return (unsigned int)address & 0x1FFFFFFF;
    }
    if ((unsigned int)address >= 0xA0000000 &&
        (unsigned int)address < 0xC0000000) {
        return (unsigned int)address & 0x1FFFFFFF;
    }
    return func_80068190(address);
}
