#include "../../include/object_recovery.h"

int func_8003CCE8(int value)
{
    int result;
    unsigned int bit;
    int square;

    bit = 0x8000;
    if (value >= 0x40000000) {
        return bit;
    }

    result = 0;
    do {
        result |= bit;
        square = result * result;
        if (value == square) {
            return result;
        }
        if (value < square) {
            result &= ~bit;
        }
        bit >>= 1;
    } while (bit != 0);

    return result;
}
