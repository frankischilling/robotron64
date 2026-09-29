#include "../../include/early_game_helpers.h"

int func_8000DF14(int angle)
{
    angle &= 0xFFF;
    if (angle >= 0x800) {
        angle -= 0x1000;
    }
    return angle;
}
