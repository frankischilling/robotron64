#include "../../include/sdk_si.h"

int func_800669B0(unsigned int address, unsigned int *word)
{
    if (func_8006DBF0()) {
        return -1;
    }
    *word = *(volatile unsigned int *)(address | 0xA0000000);
    return 0;
}
