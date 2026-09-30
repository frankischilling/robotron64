#include "../../include/sdk_short_math.h"

short func_8005FBB0(unsigned short angle)
{
    short value;

    angle >>= 4;
    if (angle & 0x400) {
        value = D_8008DBB0[0x3FF - (angle & 0x3FF)];
    } else {
        value = D_8008DBB0[angle & 0x3FF];
    }
    if (angle & 0x800) {
        return -value;
    }
    return value;
}
