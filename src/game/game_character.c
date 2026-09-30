#include "../../include/game_memory.h"

int func_8003BBAC(unsigned char character)
{
    if ((character >= ' ') && (character < 0x7F)) {
        return 1;
    }
    return 0;
}

int func_8003BBDC(unsigned char character)
{
    if ((character >= 'A') && (character <= 'Z')) {
        return 1;
    }
    if ((character >= 'a') && (character <= 'z')) {
        return 1;
    }
    return 0;
}

int func_8003BC2C(unsigned char character)
{
    if ((character >= '0') && (character <= '9')) {
        return 1;
    }
    return 0;
}

unsigned char func_8003BC5C(unsigned char character)
{
    if ((character >= 'a') && (character <= 'z')) {
        character -= 'a' - 'A';
    }
    return character;
}

unsigned char func_8003BC90(unsigned char character)
{
    if ((character >= 'A') && (character <= 'Z')) {
        character += 'a' - 'A';
    }
    return character;
}

unsigned char *func_8003BCC4(unsigned char *text)
{
    unsigned char *start = text;
    unsigned char character;

    for (;;) {
        character = *text++;
        if (character == 0) {
            break;
        }
        if ((character >= 'A') && (character <= 'Z')) {
            character += 'a' - 'A';
        }
        text[-1] = character;
    }
    return start;
}

unsigned char *func_8003BD08(unsigned char *text)
{
    unsigned char *start = text;
    unsigned char character;

    for (;;) {
        character = *text++;
        if (character == 0) {
            break;
        }
        if ((character >= 'a') && (character <= 'z')) {
            character -= 'a' - 'A';
        }
        text[-1] = character;
    }
    return start;
}
