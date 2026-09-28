#include "../../include/object_recovery.h"

extern int D_8007C338[];

int func_8003CEF4(int value)
{
    unsigned int step;
    int index;

    if (value < D_8007C338[1]) {
        return 0;
    }
    if (value > D_8007C338[63]) {
        return 64;
    }

    step = 16;
    index = 32;
    for (;;) {
        if (value < D_8007C338[index]) {
            index -= step;
            step >>= 1;
        } else if (value > D_8007C338[index + 1]) {
            index += step;
            step >>= 1;
        } else {
            return index;
        }
    }
}
