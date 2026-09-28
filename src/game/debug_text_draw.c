#include "../../include/debug_text_internal.h"

void func_8003C604(unsigned char character, int x, int y, DebugTextFont *font);

void func_80037420(unsigned char *text, int x, int y, DebugTextFont *font)
{
    unsigned char character;

    character = *text;
    while (character != 0) {
        if (character != ' ' && character != '_') {
            func_8003C604(character, x, y, font);
        }
        character = *++text;
        x += font->advance;
    }
}
