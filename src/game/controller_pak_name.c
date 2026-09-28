#include "../../include/controller_services.h"
#include "../../include/game_memory.h"

unsigned char *func_8004FAC0(unsigned char *name)
{
    unsigned char *source;
    unsigned char *destination;
    unsigned char character;
    unsigned char decoded;

    func_8003B694(D_80143690, 0, sizeof(D_80143690));
    source = name;
    destination = D_80143690;
    for (;;) {
        decoded = ' ';
        character = *source++;
        if (character >= 15 && character < 66) {
            decoded = D_8008D520[character - 15];
        }
        *destination++ = decoded;
        if (character == 0) {
            break;
        }
    }
    return D_80143690;
}
