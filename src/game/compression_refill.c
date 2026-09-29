#include "../../include/compression_internal.h"

unsigned char func_8005F804(void)
{
    func_80051924(D_80192BD8, D_80192BDC, 0x10000);
    D_80192BD8 += 0x10000;
    D_80192BD0 = D_80192BDC;
    D_80192BE0 = 0xFFFF;
    return *D_80192BD0++;
}
