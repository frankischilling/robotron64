#include "../../../include/palette_effects.h"
void func_80031B28(int paletteIndex, int first, int second, int mode, int phase, int step)
{
    char index;
    PaletteTransition *transition;
    int i;
    for (i = 0; i < PALETTE_TRANSITION_COUNT; i++)
    {
        transition = &D_8009D120[i];
        index = paletteIndex;
        if ((&D_8009D120[i])->active == 0)
        {
            (&D_8009D120[i])->startRed = D_800BB230[first].red;
            (&D_8009D120[i])->startGreen = D_800BB230[first].green;
            (&D_8009D120[i])->startBlue = D_800BB230[first].blue;
            (&D_8009D120[i])->endRed = D_800BB230[second].red;
            (&D_8009D120[i])->endGreen = D_800BB230[second].green;
            (&D_8009D120[i])->endBlue = D_800BB230[second].blue;
            (&D_8009D120[i])->phase = phase;
            (&D_8009D120[i])->step = step;
            (&D_8009D120[i])->paletteIndex = index;
            (&D_8009D120[i])->first = first;
            (&D_8009D120[i])->second = second;
            (&D_8009D120[i])->mode = mode;
            (&D_8009D120[i])->position = 0;
            (&D_8009D120[i])->original = D_8009CD18[transition->paletteIndex];
            (&D_8009D120[i])->active = 1;
            return;
        }
    }

}
