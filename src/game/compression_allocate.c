#include "../../include/compression_internal.h"

void *func_8005F7E0(unsigned int size)
{
    void *allocation;

    allocation = D_80192BFC;
    D_80192BFC = (unsigned char *)(((unsigned int)allocation + size + 7) & ~7U);
    return allocation;
}
