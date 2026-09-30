#include "../../include/sdk_si.h"

int func_80066A00(unsigned int address, unsigned int word)
{
    if (func_8006DBF0()) {
        return -1;
    }
    *(volatile unsigned int *)(address | 0xA0000000) = word;
    return 0;
}
