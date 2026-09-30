#include "../../include/compression_internal.h"

int func_8005E9D0(void)
{
    unsigned int count;
    unsigned int window;
    unsigned int bitBuffer;
    unsigned int bitCount;

    bitBuffer = D_80192C08;
    bitCount = D_80192C0C;
    count = bitCount & 7;
    window = D_80192BF4;
    INFLATE_DROP_BITS(count);
    INFLATE_NEED_BITS(16);
    count = bitBuffer & 0xFFFF;
    INFLATE_DROP_BITS(16);
    INFLATE_NEED_BITS(16);
    if (count != (~bitBuffer & 0xFFFF)) {
        return 3;
    }
    INFLATE_DROP_BITS(16);
    if (count > D_80192BEC) {
        count = D_80192BEC;
    }
    D_80192BEC -= count;
    while (count--) {
        INFLATE_NEED_BITS(8);
        *D_80192BD4++ = bitBuffer;
        if (++window == 0x8000) {
            INFLATE_ADVANCE_WINDOW(window);
        }
        INFLATE_DROP_BITS(8);
    }
    D_80192BF4 = window;
    D_80192C08 = bitBuffer;
    D_80192C0C = bitCount;
    return D_80192BEC == 0 ? 9 : 0;
}
