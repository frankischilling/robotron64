#include "../../include/renderer_debug_text.h"

void func_8004B4F8(int value, int x, int y)
{
    int count;
    int i;
    int drawX = x;
    int drawY = y;
    unsigned char digits[24];

    count = func_8004B2E0(value, digits);
    if (count < 21) {
        for (i = count - 1; i >= 0; i--) {
            func_80049DD8(drawX, drawY, 200);
            func_80049E3C(digits[i] + '0');
            drawX -= 8;
        }
    }
}
