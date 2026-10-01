#include "../../include/game_memory.h"

float func_8003BDE8(unsigned char *text)
{
    int whole;
    int divisor;
    float value;
    float sign;
    unsigned char character;
    unsigned char *cursor;

    character = *text;
    cursor = text;
    whole = 0;
    sign = 1.0f;
    if (character == '-') {
        sign = -1.0f, character = *++cursor;
    }
    if (func_8003BC2C(character)) {
        do {
            whole = whole * 10;
            whole += *cursor - '0';
            character = cursor[1];
            cursor++;
        } while (func_8003BC2C(character));
    }
    if (*cursor++ == '.') {
        divisor = 1;
        value = whole;
        while (func_8003BC2C(*cursor)) {
            divisor *= 10;
            value += ((unsigned int)*cursor++ - 48.0f) / divisor;
        }
        return sign * value;
    } else {
        return (float)whole * sign;
    }
}
