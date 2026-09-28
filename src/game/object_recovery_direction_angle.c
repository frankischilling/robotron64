#include "../../include/object_recovery.h"
#include "../../include/scalar_math.h"

int func_8003CD70(int x, int y)
{
    int quadrant;
    int angle;
    int original_x;

    original_x = x;
    if (original_x == 0) {
        if (y < 0) {
            return 0x100;
        }
        return 0;
    }
    if (y == 0) {
        if (original_x < 0) {
            return 0x180;
        }
        return 0x80;
    }

    quadrant = 0;
    if (original_x < 0) {
        quadrant = 1;
    }
    if (y < 0) {
        quadrant |= 2;
    }

    x = func_8004CEF0(original_x);
    y = func_8004CEF0(y);
    if (x < y) {
        angle = func_8003CEF4((x * 32767) / y);
    } else {
        angle = 0x80 - func_8003CEF4((y * 32767) / x);
    }

    switch (quadrant) {
    case 0:
        return angle;
    case 1:
        return 0x200 - angle;
    case 2:
        return 0x100 - angle;
    case 3:
        return angle + 0x100;
    }
    return 0;
}
