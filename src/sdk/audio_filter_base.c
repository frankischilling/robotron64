#include "../../include/sdk_audio_pipeline.h"

void func_8006E750(AudioFilter *filter,
                   SdkAudioCommand *(*handler)(void *, short *, int, int, SdkAudioCommand *),
                   int (*setParameter)(void *, int, void *), int type)
{
    filter->source = 0;
    filter->handler = handler;
    filter->setParameter = setParameter;
    filter->input = 0;
    filter->output = 0;
    filter->type = type;
}
