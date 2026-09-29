#include "../../include/compression_internal.h"

int func_8005FB58(unsigned int source, void *destination, unsigned int outputLimit,
                  void *scratch, unsigned int size)
{
    D_80192BEC = outputLimit;
    if (outputLimit) {
        D_80192BD8 = source;
        D_80192BE4 = 0;
        return func_8005F878(destination, scratch, size);
    }
    return 0;
}
