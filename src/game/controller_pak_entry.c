#include "../../include/controller_services.h"
#include "../../include/game_memory.h"
#include "../../include/text.h"

void func_800363D0(unsigned char *destination, unsigned char *format, ...);

int func_8004FB48(int slot, unsigned int *pages, unsigned char *name)
{
    SdkPfsState *state;
    unsigned char character;
    unsigned char extension;
    unsigned char index;
    int nameLength;

    if (D_80143650[slot] != 0) {
        return 0;
    }
    state = &D_80143450[slot];
    func_8004FAC0((unsigned char *)state->gameName);
    func_8003B6E4(name, D_80143690);
    extension = ' ';
    if (state->extension[0] != 0) {
        character = state->extension[0];
        if (character >= 15 && character < 66) {
            extension = D_8008D520[character - 15];
        }
    }
    for (index = 0; index < (nameLength = func_8003B4FC(name)); index++) {
        if (func_8000060C(name[index]) == -1) {
            name[index] = ' ';
        }
    }
    func_800363D0(name, D_80095BE0, name, extension);
    *pages = (state->fileSize + 255) >> 8;
    return 1;
}
