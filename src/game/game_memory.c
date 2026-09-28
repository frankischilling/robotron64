#include "../../include/game_memory.h"

unsigned char *func_8003B4C0(unsigned char *text, unsigned char character)
{
    unsigned char *cursor = text;
    unsigned char value;

    for (;;) {
        value = *cursor++;
        if (value == 0) {
            break;
        }
        if (value == character) {
            return cursor - 1;
        }
    }
    return 0;
}

int func_8003B4FC(unsigned char *text)
{
    int length = 0;
    unsigned char value;

    for (;;) {
        value = *text++;
        if (value == 0) {
            break;
        }
        length++;
    }
    return length;
}

void *func_8003B520(void *destination, void *source, int count)
{
    unsigned char *input = source;
    unsigned char *output = destination;
    int index;

    for (index = 0; index < count; index++) {
        *output++ = *input++;
    }
    return output;
}

void *func_8003B594(void *destination, void *source, int count)
{
    unsigned char *input = source;
    unsigned char *output = destination;
    int index;

    if (destination == source) {
        return destination;
    }
    if ((unsigned int)source < (unsigned int)destination) {
        output += count;
        input += count;
        for (index = 0; index < count; index++) {
            *--output = *--input;
        }
    } else {
        for (index = 0; index < count; index++) {
            *output++ = *input++;
        }
    }
    return destination;
}

void *func_8003B694(void *destination, int value, int count)
{
    unsigned char *output = destination;
    int index;

    for (index = 0; index < count; index++) {
        *output++ = value;
    }
    return output;
}

unsigned char *func_8003B6E4(unsigned char *destination, unsigned char *source)
{
    unsigned char *output = destination;
    unsigned char value;

    do {
        value = *source++;
        *output++ = value;
    } while (value != 0);
    return destination;
}

unsigned char *func_8003B704(unsigned char *destination, unsigned char *source, int limit)
{
    unsigned char *output = destination;
    unsigned char value;

    for (;;) {
        value = *source++;
        *output++ = value;
        if (value == 0) {
            break;
        }
        if (--limit == 0) {
            *output = 0;
            break;
        }
    }
    return destination;
}
