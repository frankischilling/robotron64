#include "../../../include/palette_effects.h"

int func_800316AC(void)
{
    int i;
    PaletteColor colors[PALETTE_EFFECT_COLOR_COUNT];
    int weight;
    int inverse;

    if (D_8009E578 == 0) {
        return 0;
    }
    if (D_8009E578 < 0) {
        D_8009E578 += D_8009E580 * D_8009EF94;
        if (D_8009E578 >= 0) {
            D_8009E578 = -1;
        }
        weight = D_8009E578 + PALETTE_FADE_LIMIT;
    } else {
        D_8009E578 -= D_8009E580 * D_8009EF94;
        if (D_8009E578 < 0) {
            D_8009E578 = 0;
        }
        weight = D_8009E578;
    }
    inverse = PALETTE_FADE_LIMIT - weight;
    for (i = 0; i < PALETTE_EFFECT_COLOR_COUNT; i++) {
        colors[i].blue = (D_8009CD18[i].blue * inverse +
                          D_8009E570.blue * weight) / PALETTE_FADE_LIMIT;
        colors[i].green = (D_8009CD18[i].green * inverse +
                           D_8009E570.green * weight) / PALETTE_FADE_LIMIT;
        colors[i].red = (D_8009CD18[i].red * inverse +
                         D_8009E570.red * weight) / PALETTE_FADE_LIMIT;
    }
    return D_8009E578;
}
