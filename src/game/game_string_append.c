#include "../../include/game_memory.h"

unsigned char *func_8003B734(unsigned char *destination, unsigned char *source)
{
    unsigned char character = 0;
    unsigned char *output;

    output = destination;
    do {
        character = *output++;
    } while (character != 0);
    output--;
    do {
        character = *source++;
        *output++ = character;
    } while (character != 0);
    return destination;
}
