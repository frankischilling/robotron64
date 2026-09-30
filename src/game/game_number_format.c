#include "../../include/game_memory.h"

extern unsigned char D_8007BB1C[];
int func_8004CEF0(int value);

void func_8003B928(int value, unsigned char *text, int radix)
{
    unsigned char digits[10];
    int negative = 0;
    int count;
    unsigned int hexadecimal;

    if (value == 0) {
        *text++ = '0';
        *text = 0;
        return;
    } else {
        if (radix == 16) {
            hexadecimal = value;
            for (count = 0; (count < 10) && (hexadecimal != 0); count++) {
                digits[count] = D_8007BB1C[hexadecimal & 15];
                hexadecimal >>= 4;
            }
        } else {
            if (value < 0) {
                value = func_8004CEF0(value);
                negative = 1;
            }
            for (count = 0; (count < 10) && (value != 0); count++) {
                digits[count] = D_8007BB1C[value % radix];
                value /= radix;
            }
            if (negative) {
                *text++ = '-';
            }
        }
        for (count--; count >= 0; count--) {
            *text++ = digits[count];
        }
    }
    *text = 0;
}

void func_8003BA90(float value, unsigned char *text, int radix)
{
    unsigned char digits[10];
    int negative = 0;
    int count;
    int scaled = 1000.0f * value;

    if (scaled == 0) {
        *text++ = '0';
        *text = 0;
        return;
    } else {
        if (scaled < 0) {
            scaled = -scaled;
            negative = 1;
        }
        for (count = 0; (count < 10) && (scaled != 0); count++) {
            digits[count] = D_8007BB1C[scaled % radix];
            scaled /= radix;
        }
        if (negative) {
            *text++ = '-';
        }
        for (count--; count >= 0; count--) {
            *text++ = digits[count];
        }
    }
    *text = 0;
}
