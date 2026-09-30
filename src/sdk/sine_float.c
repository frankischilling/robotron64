extern const double D_DBL_80095D30[5];
extern const double D_DBL_80095D58;
extern const double D_DBL_80095D60;
extern const double D_DBL_80095D68;
extern const float D_FLT_80095D70;
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
            polynomial = ((D_DBL_80095D30[4] * square + D_DBL_80095D30[3]) * square
                          + D_DBL_80095D30[2]) * square + D_DBL_80095D30[1];
            result = reduced + (reduced * square) * polynomial;
            return (float)result;
        }
        return angle;
    }
    if (exponent < 0x136) {
        reduced = angle;
        periods = reduced * D_DBL_80095D58;
        whole = periods >= 0 ? (int)(periods + 0.5) : (int)(periods - 0.5);
        periods = whole;
        reduced = reduced - periods * D_DBL_80095D60;
        reduced = reduced - periods * D_DBL_80095D68;
        square = reduced * reduced;
        polynomial = ((D_DBL_80095D30[4] * square + D_DBL_80095D30[3]) * square
                      + D_DBL_80095D30[2]) * square + D_DBL_80095D30[1];
        result = reduced + (reduced * square) * polynomial;
        if ((whole & 1) == 0) {
            return (float)result;
        }
        return -(float)result;
    }
    if (angle != angle) {
        return D_FLT_80095ED0;
    }
    return D_FLT_80095D70;
}
