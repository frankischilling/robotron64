#include "../../include/sdk_audio_reverb.h"

enum AudioEffectParameter {
    EFFECT_INPUT,
    EFFECT_OUTPUT,
    EFFECT_FEEDBACK,
    EFFECT_FEED_FORWARD,
    EFFECT_GAIN,
    EFFECT_CHORUS_RATE,
    EFFECT_CHORUS_DEPTH,
    EFFECT_LOW_PASS
};

int func_8006EE08(void *state, int parameter, void *value)
{
    AudioEffect *effect = state;
    int kind = (parameter - 2) % 8;
    int section = (parameter - 2) / 8;
    int setting = *(int *)value;

    switch (kind) {
    case EFFECT_INPUT:
        effect->delays[section].input = (unsigned int)setting & ~7U;
        break;
    case EFFECT_OUTPUT:
        effect->delays[section].output = (unsigned int)setting & ~7U;
        break;
    case EFFECT_FEED_FORWARD:
        effect->delays[section].feedForward = (short)setting;
        break;
    case EFFECT_FEEDBACK:
        effect->delays[section].feedback = (short)setting;
        break;
    case EFFECT_GAIN:
        effect->delays[section].gain = (short)setting;
        break;
    case EFFECT_CHORUS_RATE:
        effect->delays[section].resampleIncrement =
            (((float)setting / 1000) * 2.0) / D_8008F160->outputRate;
        break;
    case EFFECT_CHORUS_DEPTH:
        effect->delays[section].resampleGain =
            ((float)setting / 173123.404906676) *
            (effect->delays[section].output - effect->delays[section].input);
        break;
    case EFFECT_LOW_PASS:
        if (effect->delays[section].lowPass != 0) {
            effect->delays[section].lowPass->frequency = (short)setting;
            func_8006B8A0(effect->delays[section].lowPass);
        }
        break;
    }
    return 0;
}
