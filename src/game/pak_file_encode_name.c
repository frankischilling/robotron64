#include "../../include/pak_file.h"

unsigned char *func_8004C65C(unsigned char *name)
{
    unsigned char *destination;
    unsigned char character;
    unsigned char encoded;

    destination = D_8013DC10;
    do {
        character = *name++;
        encoded = character;
        if (character >= 'A' && character <= 'Z') {
            encoded = character - 0x27;
        }
        if (character >= '0' && character <= '9') {
            encoded = character - 0x20;
        }
        if (character == ' ') {
            encoded = 15;
        }
        *destination++ = encoded;
    } while (character != 0);
    return D_8013DC10;
}
