#include "../../include/compression_internal.h"

int func_8005F878(void *destination, void *scratch, unsigned int size)
{
    unsigned int bitBuffer;
    unsigned int bitCount;
    unsigned int final;
    unsigned int kind;
    int result;

    D_80192BD4 = destination;
    result = func_8005F71C(scratch, size, D_80192BE4);
    if (result != 0) {
        return result;
    }
    D_80192BF4 = 0;
    D_80192C0C = 0;
    D_80192C08 = 0;
    do {
        bitCount = D_80192C0C;
        bitBuffer = D_80192C08;
        INFLATE_NEED_BITS(1);
        final = bitBuffer & 1;
        INFLATE_DROP_BITS(1);
        INFLATE_NEED_BITS(2);
        kind = bitBuffer & 3;
        INFLATE_DROP_BITS(2);
        D_80192C08 = bitBuffer;
        D_80192C0C = bitCount;
        if (kind == 2) {
            result = func_8005EEE0();
        } else if (kind == 0) {
            result = func_8005E9D0();
        } else if (kind == 1) {
            result = func_8005ECA8();
        } else {
            result = 5;
        }
    } while (!final && !result);
    D_80192BF0 += D_80192BF4;
    func_8005EE98();
    if (result == 9) {
        result = 0;
    }
    return result;
}
