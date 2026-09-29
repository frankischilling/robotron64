#include "../../include/sdk_audio_effect.h"

void func_8006B8A0(AudioLowPass *filter)
{
    int index, scaledFrequency;
    short coefficient;
    double multiplier, power;

    scaledFrequency = filter->frequency * 16384;
    coefficient = scaledFrequency >> 15;
    filter->gain = 16384 - coefficient;
    filter->first = 1;
    for (index = 0; index < 8; index++) {
        filter->vector.coefficients[index] = 0;
    }
    filter->vector.coefficients[index++] = coefficient;
    power = multiplier = (double)coefficient / 16384;
    for (; index < 16; index++) {
        power *= multiplier;
        filter->vector.coefficients[index] = power * 16384;
    }
}
