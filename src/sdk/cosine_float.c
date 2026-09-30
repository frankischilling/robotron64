extern const double D_DBL_80095D80[5];
extern const double D_DBL_80095DA8;
extern const double D_DBL_80095DB0;
extern const double D_DBL_80095DB8;
extern const float D_FLT_80095DC0;
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
        periods = reduced * D_DBL_80095DA8 + 0.5;
        whole = periods >= 0 ? (int)(periods + 0.5) : (int)(periods - 0.5);
        periods = whole;
        periods -= 0.5;
        reduced = reduced - periods * D_DBL_80095DB0;
        reduced = reduced - periods * D_DBL_80095DB8;
        square = reduced * reduced;
        polynomial = ((D_DBL_80095D80[4] * square + D_DBL_80095D80[3]) * square
                      + D_DBL_80095D80[2]) * square + D_DBL_80095D80[1];
        result = reduced + (reduced * square) * polynomial;
        if ((whole & 1) == 0) {
            return (float)result;
        }
        return -(float)result;
    }
    if (angle != angle) {
        return D_FLT_80095ED0;
    }
    return D_FLT_80095DC0;
}
