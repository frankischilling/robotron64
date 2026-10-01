#include "../../include/save_menu_internal.h"

int func_80031034(int character)
{
    character -= 'a';
    if (character >= 15) {
        character -= 4;
    } else if (character >= 9) {
        character -= 3;
    } else if (character >= 5) {
        character -= 2;
    } else {
        character--;
    }
    return character;
}
