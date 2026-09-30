#include "../../include/palette_effects.h"
#include "../../include/scalar_math.h"

void func_80031564(void)
{
    D_8009E578 = 0;
}

void func_80031570(int duration)
{
    func_80031658(&D_80075990, PALETTE_FADE_LIMIT,
                  func_8004CEF0(-PALETTE_FADE_LIMIT) / (duration << 8));
}

void func_800315E4(int duration)
{
    func_80031658(&D_80075990, -PALETTE_FADE_LIMIT,
                  func_8004CEF0(-PALETTE_FADE_LIMIT) / (duration << 8));
}

int func_80031658(PaletteColor *color, int position, int step)
{
    D_8009E570 = *color;
    D_8009E580 = 0;
    D_8009E578 = position;
    func_800316AC();
    D_8009E580 = step;
    return D_8009E578;
}
