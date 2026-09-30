#include "../../include/sdk_audio_pipeline.h"
#include "../../include/sdk_audio_mix_commands.h"

SdkAudioCommand *func_8006BE50(void *state, short *output, int samples,
                               int offset, SdkAudioCommand *commands)
{
    AudioBus *bus = state;
    AudioFilter **sources = bus->sources;
    SdkAudioCommand *cursor = commands;
    int index;

    SDK_AUDIO_CLEAR(cursor++, SDK_AUDIO_MAIN_LEFT, samples * 2);
    SDK_AUDIO_CLEAR(cursor++, SDK_AUDIO_MAIN_RIGHT, samples * 2);
    for (index = 0; index < bus->sourceCount; index++) {
        cursor = sources[index]->handler(sources[index], output, samples, offset, cursor);
        SDK_AUDIO_BUFFER(cursor++, 0, 0, 0, samples * 2);
        SDK_AUDIO_MIX(cursor++, 0, 0x7FFF, SDK_AUDIO_AUX_LEFT, SDK_AUDIO_MAIN_LEFT);
        SDK_AUDIO_MIX(cursor++, 0, 0x7FFF, SDK_AUDIO_AUX_RIGHT, SDK_AUDIO_MAIN_RIGHT);
    }
    return cursor;
}

int func_8006BE20(void *state, int parameter, void *value)
{
    AudioBus *bus = state;
    AudioFilter **sources = bus->sources;

    if (parameter == SDK_AUDIO_ADD_SOURCE) {
        sources[bus->sourceCount] = value;
        bus->sourceCount++;
    }
    return 0;
}
