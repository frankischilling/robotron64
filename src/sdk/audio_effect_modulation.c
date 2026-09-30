#include "../../include/sdk_audio_reverb.h"

float func_8006E770(AudioDelay *delay, int samples)
{
    float value;

    delay->resampleValue += delay->resampleIncrement * samples;
    delay->resampleValue = delay->resampleValue > 2.0
                              ? delay->resampleValue - 4.0
                              : delay->resampleValue;
    value = delay->resampleValue;
    value = value < 0 ? -value : value;
    value -= 1.0;
    return delay->resampleGain * value;
}
