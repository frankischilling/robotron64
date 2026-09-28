#include "../../include/palette_effects.h"

void func_80031C44(int range, int releaseMode)
{
    int weight;
    int inverse;
    int index;
    int config;
    PaletteColor color;

    if (releaseMode != 0) {
        for (index = 0; index < PALETTE_TRANSITION_COUNT; index++) {
            if (D_8009D120[index].active != 0) {
                if (D_8009E578 != 0) {
                    if (D_8009E578 < 0) {
                        weight = D_8009E578 + PALETTE_FADE_LIMIT;
                    } else {
                        weight = D_8009E578;
                    }
                    inverse = PALETTE_FADE_LIMIT - weight;
                    color.blue = (D_8009D120[index].original.blue * inverse +
                                  D_8009E570.blue * weight) / PALETTE_FADE_LIMIT;
                    color.green = (D_8009D120[index].original.green * inverse +
                                   D_8009E570.green * weight) / PALETTE_FADE_LIMIT;
                    color.red = (D_8009D120[index].original.red * inverse +
                                 D_8009E570.red * weight) / PALETTE_FADE_LIMIT;
                    func_8003C0DC(&color, D_8009D120[index].paletteIndex);
                }
                if (releaseMode != 2) {
                    D_8009D120[index].active = 0;
                }
            }
        }
    }
    if (range >= 0) {
        for (index = 0; index < D_800BEE58[range].count; index++) {
            config = D_800BEE58[range].first + index;
            func_80031B28(D_800BBAC8[config].paletteIndex,
                          D_800BBAC8[config].first,
                          D_800BBAC8[config].second,
                          D_800BBAC8[config].mode,
                          D_800BBAC8[config].phase,
                          D_800BBAC8[config].step);
        }
    }
}
