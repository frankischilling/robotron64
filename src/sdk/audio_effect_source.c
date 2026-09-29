#include "../../include/sdk_audio_reverb.h"

int func_8006F064(void *state, int parameter, void *value)
{
    AudioFilter *effect = state;

    switch (parameter) {
    case SDK_AUDIO_SET_SOURCE:
        effect->source = value;
        break;
    default:
        break;
    }
    return 0;
}
