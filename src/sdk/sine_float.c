#include "../../include/sdk_float_values.h"

const SdkDoubleValue D_DBL_80095D30[5] = {
    {{0x3FF00000, 0x00000000}},
    {{0xBFC55554, 0xBC83656D}},
    {{0x3F8110ED, 0x3804C2A0}},
    {{0xBF29F6FF, 0xEEA56814}},
    {{0x3EC5DBDF, 0x0E314BFE}},
};
const SdkDoubleValue D_DBL_80095D58 = {{0x3FD45F30, 0x6DC9C883}};
const SdkDoubleValue D_DBL_80095D60 = {{0x400921FB, 0x50000000}};
const SdkDoubleValue D_DBL_80095D68 = {{0x3E6110B4, 0x611A6263}};
const SdkFloatValue D_FLT_80095D70 = {0};

extern float D_FLT_80095ED0;

float func_80063230(float angle)
{
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
    if (exponent < 0xFF) {
        reduced = angle;
        if (exponent >= 0xE6) {
            square = reduced * reduced;
            polynomial = ((D_DBL_80095D30[4].value * square + D_DBL_80095D30[3].value) * square
                          + D_DBL_80095D30[2].value) * square + D_DBL_80095D30[1].value;
            result = reduced + (reduced * square) * polynomial;
            return (float)result;
        }
        return angle;
    }
    if (exponent < 0x136) {
        reduced = angle;
        periods = reduced * D_DBL_80095D58.value;
        whole = periods >= 0 ? (int)(periods + 0.5) : (int)(periods - 0.5);
        periods = whole;
        reduced = reduced - periods * D_DBL_80095D60.value;
        reduced = reduced - periods * D_DBL_80095D68.value;
        square = reduced * reduced;
        polynomial = ((D_DBL_80095D30[4].value * square + D_DBL_80095D30[3].value) * square
                      + D_DBL_80095D30[2].value) * square + D_DBL_80095D30[1].value;
        result = reduced + (reduced * square) * polynomial;
        if ((whole & 1) == 0) {
            return (float)result;
        }
        return -(float)result;
    }
    if (angle != angle) {
        return D_FLT_80095ED0;
    }
    return D_FLT_80095D70.value;
}
