#include "../../include/palette.h"
#include "../../include/scalar_math.h"

int func_80031420(PaletteColor *color, PaletteColor *palette)
{
    int bestIndex;
    int bestDistance;
    int index;
    int distance;
    int red;
    int green;
    int blue;

    red = 0;
    green = 0;
    blue = 0;
    if (color->unused == 0) {
        red = color->red;
        green = color->green;
        blue = color->blue;
    }

    bestDistance = 0x300;
    index = 0;
    do {
        distance = func_8004CEF0(red - palette->red);
        distance += func_8004CEF0(green - palette->green);
        distance += func_8004CEF0(blue - palette->blue);
        if (distance < bestDistance) {
            bestIndex = index;
            bestDistance = distance;
        }
        index++;
        palette++;
    } while (index != 0x100);

    return bestIndex;
}
