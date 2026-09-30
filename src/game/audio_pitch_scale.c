extern float D_FLT_8008DA30;

float func_8005B000(int cents)
{
    float factor;
    float result;

    result = 1.0f;
    if (cents >= 0) {
        factor = 1.00057781f;
    } else {
        factor = 0.99942255f;
        cents = -cents;
    }
    while (cents) {
        if (cents & 1) {
            result *= factor;
        }
        factor *= factor;
        cents >>= 1;
    }
    result *= D_FLT_8008DA30;
    return result;
}
