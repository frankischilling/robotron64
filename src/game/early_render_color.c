#include "../../include/early_game_helpers.h"

extern int D_80138270;
extern int D_80138274;
extern int D_8013826C;

void func_8000A200(int red, int green, int blue)
{
    D_80138270 = red;
    D_8013826C = blue;
    D_80138274 = green;
}
