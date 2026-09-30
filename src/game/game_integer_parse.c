#include "../../include/game_memory.h"

int func_8003BD4C(unsigned char *text)
{
    int value;
    int sign;
    unsigned char character;
    unsigned char *cursor;

    character = *text;
    cursor = text;
    value = 0;
    sign = 1;
    if (character == '-') {
        cursor++;
        character = *cursor;
        sign = -1;
    }
    if (func_8003BC2C(character)) {
        do {
            value = value * 10;
            value += *cursor - '0';
            character = cursor[1];
            cursor++;
        } while (func_8003BC2C(character));
    }
    return sign * value;
}
