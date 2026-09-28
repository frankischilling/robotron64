#include "../../include/game_memory.h"

float func_8003BDE8(unsigned char *text)
{
    int divisor = 1;
    int whole = 0;
    float value;
    float sign = 1.0f;

    if (*text == '-') {
        sign = -1.0f;
        text++;
    }
    while (func_8003BC2C(*text)) {
        whole *= 10;
        whole += *text++;
        whole -= '0';
    }
    if (*text++ == '.') {
        value = whole;
        while (func_8003BC2C(*text)) {
            divisor *= 10;
            value += ((unsigned int)*text++ - 48.0f) / divisor;
        }
        return sign * value;
    } else {
        return (float)whole * sign;
    }
}
