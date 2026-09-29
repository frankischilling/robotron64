#include "../../include/compression_internal.h"

int func_8005FAB0(unsigned char *source, void *destination, void *scratch, unsigned int size)
{
    D_80192BEC = ~0U;
    D_80192BD0 = source + 4;
    D_80192BE4 = 1;
    return func_8005F878(destination, scratch, size);
}
