#include "../../include/sdk_audio_pipeline.h"
#include "../../include/sdk_audio_mix_commands.h"

SdkAudioCommand *func_8006DB64(void *state, short *output, int samples,
                               int offset, SdkAudioCommand *commands)
{
    AudioSaveFilter *save = state;
    AudioFilter *source = save->filter.source;
    SdkAudioCommand *cursor;

    cursor = source->handler(source, output, samples, offset, commands);
    SDK_AUDIO_BUFFER(cursor++, 0, 0, 0, samples * 2);
    SDK_AUDIO_INTERLEAVE(cursor++, SDK_AUDIO_MAIN_LEFT, SDK_AUDIO_MAIN_RIGHT);
    SDK_AUDIO_BUFFER(cursor++, 0, 0, 0, samples * 4);
    SDK_AUDIO_SAVE(cursor++, save->dramOutput);
    return cursor;
}

int func_8006DB30(void *state, int parameter, void *value)
{
    AudioSaveFilter *save = state;

    switch (parameter) {
    case SDK_AUDIO_SET_SOURCE:
        save->filter.source = value;
        break;
    case SDK_AUDIO_SET_DRAM:
        save->dramOutput = (int)value;
        break;
    }
    return 0;
}
