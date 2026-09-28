#include "../../include/command_script.h"
#include "../../include/scalar_math.h"

void func_80032550(int value, unsigned char *destination, int base)
{
    unsigned char digits[10];
    int index;
    int negative = 0;

    if (value == 0) {
        *destination++ = '0';
        *destination = 0;
        return;
    }
    if (value < 0) {
        value = func_8004CEF0(value);
        negative = 1;
    }
    for (index = 0; index < 10 && value != 0; index++) {
        digits[index] = value % base + '0';
        value /= base;
    }
    if (negative != 0) {
        *destination++ = '-';
    }
    for (index--; index >= 0; index--) {
        *destination++ = digits[index];
    }
    *destination = 0;
}
