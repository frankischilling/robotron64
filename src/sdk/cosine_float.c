#include "../../include/sdk_float_values.h"

const SdkDoubleValue D_DBL_80095D80[5] = {
    {{0x3FF00000, 0x00000000}},
    {{0xBFC55554, 0xBC83656D}},
    {{0x3F8110ED, 0x3804C2A0}},
    {{0xBF29F6FF, 0xEEA56814}},
    {{0x3EC5DBDF, 0x0E314BFE}},
};
const SdkDoubleValue D_DBL_80095DA8 = {{0x3FD45F30, 0x6DC9C883}};
const SdkDoubleValue D_DBL_80095DB0 = {{0x400921FB, 0x50000000}};
const SdkDoubleValue D_DBL_80095DB8 = {{0x3E6110B4, 0x611A6263}};
const SdkFloatValue D_FLT_80095DC0 = {0};

extern float D_FLT_80095ED0;

float func_800633F0(float angle)
{
    float absolute;
    double reduced;
    double square;
    double polynomial;
    double periods;
    int whole;
    double result;
    int bits;
    int exponent;

    bits = *(int *)&angle;
    exponent = (bits >> 22) & 0x1FF;
    if (exponent < 0x136) {
        absolute = angle > 0 ? angle : -angle;
        reduced = absolute;
        periods = reduced * D_DBL_80095DA8.value + 0.5;
        whole = periods >= 0 ? (int)(periods + 0.5) : (int)(periods - 0.5);
        periods = whole;
        periods -= 0.5;
        reduced = reduced - periods * D_DBL_80095DB0.value;
        reduced = reduced - periods * D_DBL_80095DB8.value;
        square = reduced * reduced;
        polynomial = ((D_DBL_80095D80[4].value * square + D_DBL_80095D80[3].value) * square
                      + D_DBL_80095D80[2].value) * square + D_DBL_80095D80[1].value;
        result = reduced + (reduced * square) * polynomial;
        if ((whole & 1) == 0) {
            return (float)result;
        }
        return -(float)result;
    }
    if (angle != angle) {
        return D_FLT_80095ED0;
    }
    return D_FLT_80095DC0.value;
}
