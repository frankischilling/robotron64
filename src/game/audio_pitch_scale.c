extern float D_FLT_8008DA30;
extern const float D_FLT_80095CC4;
extern const float D_FLT_80095CC8;

float func_8005B000(int cents)
{
    float factor;
    float result;

    result = 1.0f;
    if (cents >= 0) {
        factor = D_FLT_80095CC4;
    } else {
        factor = D_FLT_80095CC8;
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
