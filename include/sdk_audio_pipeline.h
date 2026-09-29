#ifndef ROBOTRON_SDK_AUDIO_PIPELINE_H
#define ROBOTRON_SDK_AUDIO_PIPELINE_H

#include "sdk_audio.h"

typedef struct AudioSaveFilter {
    AudioFilter filter;
    int dramOutput;
    int first;
} AudioSaveFilter;

typedef struct AudioBus {
    AudioFilter filter;
    int sourceCount;
    int maxSources;
    AudioFilter **sources;
} AudioBus;

typedef struct AudioDelay AudioDelay;

typedef struct AudioEffect {
    AudioFilter filter;
    short *base;
    short *input;
    unsigned int length;
    AudioDelay *delays;
    unsigned char sectionCount;
    int (*parameterHandler)(void *, int, void *);
} AudioEffect;

typedef struct AudioAuxiliaryBus {
    AudioBus bus;
    AudioEffect effects[1];
} AudioAuxiliaryBus;

typedef char AudioSaveFilterMustBe28Bytes[sizeof(AudioSaveFilter) == 28 ? 1 : -1];
typedef char AudioBusMustBe32Bytes[sizeof(AudioBus) == 32 ? 1 : -1];
typedef char AudioEffectMustBe44Bytes[sizeof(AudioEffect) == 44 ? 1 : -1];
typedef char AudioAuxiliaryBusMustBe76Bytes[sizeof(AudioAuxiliaryBus) == 76 ? 1 : -1];

void func_8006B5E0(AudioSaveFilter *filter);
void func_8006B624(AudioBus *bus, void *sources, int maxSources);
void func_8006B678(AudioAuxiliaryBus *bus, void *sources, int maxSources);
void func_8006B6CC(AudioResampler *filter, AudioHeap *heap);
void func_8006B754(AudioLoadFilter *filter, AudioDmaFactory factory, AudioHeap *heap);
void func_8006B7FC(AudioEnvelopeMixer *filter, AudioHeap *heap);
AudioEffect *func_8006BD80(AudioSynth *synth, short bus,
                          SdkAudioSynthConfig *configuration, AudioHeap *heap);
int func_8006BE20(void *filter, int parameter, void *value);
int func_8006BF70(void *filter, int parameter, void *value);
int func_8006CAC0(void *filter, int parameter, void *value);
int func_8006CED4(void *filter, int parameter, void *value);
int func_8006DA20(void *filter, int parameter, void *value);
int func_8006DB30(void *filter, int parameter, void *value);
SdkAudioCommand *func_8006BE50(void *filter, short *output, int samples,
                               int offset, SdkAudioCommand *commands);
SdkAudioCommand *func_8006C61C(void *filter, short *output, int samples,
                               int offset, SdkAudioCommand *commands);
SdkAudioCommand *func_8006CBAC(void *filter, short *output, int samples,
                               int offset, SdkAudioCommand *commands);
SdkAudioCommand *func_8006D4CC(void *filter, short *output, int samples,
                               int offset, SdkAudioCommand *commands);
SdkAudioCommand *func_8006DA50(void *filter, short *output, int samples,
                               int offset, SdkAudioCommand *commands);
SdkAudioCommand *func_8006DB64(void *filter, short *output, int samples,
                               int offset, SdkAudioCommand *commands);
void func_8006E750(AudioFilter *filter,
                   SdkAudioCommand *(*handler)(void *, short *, int, int, SdkAudioCommand *),
                   int (*setParameter)(void *, int, void *), int type);

#endif
