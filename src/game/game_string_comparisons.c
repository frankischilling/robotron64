#include "../../include/game_memory.h"

unsigned char *func_8003B734(unsigned char *destination, unsigned char *source)
{
    unsigned char character;
    unsigned char value;
    unsigned char *output = destination;

    do {
        character = *output++;
    } while (character != 0);
    output--;
    do {
        value = *source++;
        *output++ = value;
    } while (value != 0);
    return destination;
}

int func_8003B7FC(const unsigned char *left, const unsigned char *right)
{
    unsigned char value;

    for (;;) {
        value = *left++;
        if (value != *right) {
            return value - *right;
        }
        if (value == 0) {
            return 0;
        }
        right++;
    }
}

int func_8003B838(unsigned char *left, unsigned char *right, int count)
{
    unsigned char value;

    if (count > 0) {
        for (;;) {
            value = func_8003BC5C(*left);
            count--;
            if (value != func_8003BC5C(*right)) {
                value = func_8003BC5C(*left);
                return value - func_8003BC5C(*right);
            }
            if (*left++ == 0) {
                break;
            }
            right++;
            if (count <= 0) {
                break;
            }
        }
    }
    return 0;
}

int func_8003B8E0(unsigned char *left, unsigned char *right, int count)
{
    unsigned char value;

    while (count > 0) {
        value = *left++;
        if (value != *right) {
            return value - *right;
        }
        count--;
        if (value == 0) {
            return 0;
        }
        right++;
    }
    return 0;
}
