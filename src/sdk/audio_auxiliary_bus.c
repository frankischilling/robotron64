#include "../../include/sdk_audio_pipeline.h"
#include "../../include/sdk_audio_mix_commands.h"

SdkAudioCommand *func_8006DA50(void *state, short *output, int samples,
                               int offset, SdkAudioCommand *commands)
{
    AudioBus *bus = state;
    AudioFilter **sources = bus->sources;
    SdkAudioCommand *cursor = commands;
    int index;

    SDK_AUDIO_CLEAR(cursor++, SDK_AUDIO_AUX_LEFT, samples * 2);
    SDK_AUDIO_CLEAR(cursor++, SDK_AUDIO_AUX_RIGHT, samples * 2);
    for (index = 0; index < bus->sourceCount; index++) {
        cursor = sources[index]->handler(sources[index], output, samples, offset, cursor);
    }
    return cursor;
}

int func_8006DA20(void *state, int parameter, void *value)
{
    AudioBus *bus = state;
    AudioFilter **sources = bus->sources;

    if (parameter == SDK_AUDIO_ADD_SOURCE) {
        sources[bus->sourceCount] = value;
        bus->sourceCount++;
    }
    return 0;
}
