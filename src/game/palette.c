#include "../../include/palette.h"

int func_8003BFEC(int red, int green, int blue)
{
    red >>= 3;
    green >>= 3;
    blue >>= 3;
    red &= 31;
    green &= 31;
    blue &= 31;
    return (blue << 1) | 1 | (green << 6) | (red << 11);
}

void func_8003C020(PaletteColor *colors, int start, int count)
{
    int i;

    for (i = 0; i < count; i++) {
        D_8007BB34[start + i].red = colors->red;
        D_8007BB34[start + i].green = colors->green;
        D_8007BB34[start + i].blue = colors->blue;
        D_8007D6D0[start + i] = func_8003BFEC(colors->red, colors->green,
                                           colors->blue);
        colors++;
    }
}

void func_8003C0DC(PaletteColor *color, int index)
{
    PaletteColor *destination;

    destination = &D_8007BB34[index];
    destination->red = color->red;
    destination->green = color->green;
    destination->blue = color->blue;
    D_8007D6D0[index] = func_8003BFEC(color->red, color->green, color->blue);
}

void func_8003C14C(PaletteColor *color, int index)
{
    PaletteColor *source;

    source = &D_8007BB34[index];
    color->red = source->red;
    color->green = source->green;
    color->blue = source->blue;
}
