#include "../../include/compression_internal.h"

int func_8005FB08(unsigned int source, void *destination, void *scratch, unsigned int size)
{
    D_80192BEC = ~0U;
    D_80192BD8 = source;
    D_80192BE4 = 0;
    return func_8005F878(destination, scratch, size);
}
