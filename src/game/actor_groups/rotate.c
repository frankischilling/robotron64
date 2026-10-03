#include "../../../include/object_recovery.h"

/* Excluded candidates; complete instruction comparisons still differ. */
void func_8000E720(int *destination, int *source, int angle)
{
    int sine;
    int maskedAngle;
    int x;
    int y;
    int cosine;
    int negativeSine;

    maskedAngle = (1024 - angle) & 4095;
    cosine = func_8003CC88(maskedAngle);
    sine = func_8003CC58(maskedAngle);
    negativeSine = -sine;
    x = source[0] * cosine - source[1] * negativeSine;
    y = cosine * source[1] + source[0] * negativeSine;
    destination[0] = x / 4096;
    destination[1] = y / 4096;
}

void func_8000E7E0(int *destination, int *source, int angle)
{
    int sine;
    int maskedAngle;
    int x;
    int y;
    int cosine;
    int negativeSine;

    maskedAngle = angle & 4095;
    cosine = func_8003CC88(maskedAngle);
    sine = func_8003CC58(maskedAngle);
    negativeSine = -sine;
    x = source[0] * cosine - source[1] * negativeSine;
    y = cosine * source[1] + source[0] * negativeSine;
    destination[0] = x / 4096;
    destination[1] = y / 4096;
}
