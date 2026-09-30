#ifndef ROBOTRON_SDK_AUDIO_H
#define ROBOTRON_SDK_AUDIO_H

#include "audio_callbacks.h"
#include "audio_runtime.h"

typedef union SdkAudioCommand {
    struct {
        unsigned int first;
        unsigned int second;
    } words;
    unsigned long long packet;
} SdkAudioCommand;

typedef struct AudioLink {
    struct AudioLink *next;
    struct AudioLink *previous;
} AudioLink;

typedef struct AudioRawLoop {
    unsigned int start;
    unsigned int end;
    unsigned int count;
} AudioRawLoop;

typedef short AudioAdpcmState[16];
typedef short AudioResampleState[16];
typedef short AudioEnvelopeState[40];

typedef struct AudioAdpcmLoop {
    unsigned int start;
    unsigned int end;
    unsigned int count;
    AudioAdpcmState state;
} AudioAdpcmLoop;

typedef struct AudioAdpcmBook {
    int order;
    int predictorCount;
    short coefficients[128];
} AudioAdpcmBook;

typedef struct AudioWaveTable {
    unsigned char *base;
    int length;
    unsigned char type;
    unsigned char flags;
    union {
        struct {
            AudioAdpcmLoop *loop;
            AudioAdpcmBook *book;
        } adpcm;
        struct {
            AudioRawLoop *loop;
        } raw;
    } wave;
} AudioWaveTable;

typedef union AudioParameterValue {
    float floating;
    int integer;
} AudioParameterValue;

typedef struct AudioParameter {
    struct AudioParameter *next;
    int delta;
    short type;
    AudioParameterValue data;
    AudioParameterValue more;
    AudioParameterValue stillMore;
    AudioParameterValue last;
} AudioParameter;

typedef struct AudioStartParameter {
    AudioParameter *next;
    int delta;
    short type;
    short unity;
    float pitch;
    short volume;
    unsigned char pan;
    unsigned char effectMix;
    int samples;
    AudioWaveTable *wave;
} AudioStartParameter;

typedef struct AudioFilter {
    struct AudioFilter *source;
    SdkAudioCommand *(*handler)(void *, short *, int, int, SdkAudioCommand *);
    int (*setParameter)(void *, int, void *);
    short input;
    short output;
    int type;
} AudioFilter;

typedef AudioDmaCallback (*AudioDmaFactory)(void *state);

typedef struct AudioLoadFilter {
    AudioFilter filter;
    AudioAdpcmState *state;
    AudioAdpcmState *loopState;
    AudioRawLoop loop;
    AudioWaveTable *table;
    int bookSize;
    AudioDmaCallback dma;
    void *dmaState;
    int sample;
    int lastSample;
    int first;
    int memoryInput;
} AudioLoadFilter;

typedef struct AudioResampler {
    AudioFilter filter;
    AudioResampleState *state;
    float ratio;
    int unityPitch;
    float delta;
    int first;
    AudioParameter *controlList;
    AudioParameter *controlTail;
    int motion;
} AudioResampler;

typedef struct AudioEnvelopeMixer {
    AudioFilter filter;
    AudioEnvelopeState *state;
    short pan;
    short volume;
    short currentLeft;
    short currentRight;
    short dryAmount;
    short wetAmount;
    unsigned short leftRateLow;
    short leftRateHigh;
    short leftTarget;
    unsigned short rightRateLow;
    short rightRateHigh;
    short rightTarget;
    int delta;
    int segmentEnd;
    int first;
    AudioParameter *controlList;
    AudioParameter *controlTail;
    AudioFilter **sources;
    int motion;
} AudioEnvelopeMixer;

typedef struct SdkAudioVoice SdkAudioVoice;

typedef struct AudioPhysicalVoice {
    AudioLink node;
    SdkAudioVoice *voice;
    AudioFilter *channel;
    AudioLoadFilter decoder;
    AudioResampler resampler;
    AudioEnvelopeMixer envelope;
    int offset;
} AudioPhysicalVoice;

typedef struct AudioFreeParameter {
    AudioParameter *next;
    int delta;
    short type;
    AudioPhysicalVoice *physical;
} AudioFreeParameter;

struct SdkAudioVoice {
    AudioLink node;
    AudioPhysicalVoice *physical;
    AudioWaveTable *table;
    void *clientPrivate;
    short state;
    short priority;
    short effectBus;
    short unityPitch;
};

typedef struct SdkAudioVoiceConfig {
    short priority;
    short effectBus;
    unsigned char unityPitch;
} SdkAudioVoiceConfig;

struct AudioSynth {
    AudioCallbackState *head;
    AudioLink freeVoices;
    AudioLink allocatedVoices;
    AudioLink pendingFreeVoices;
    int parameterSamples;
    int currentSamples;
    AudioDmaFactory dma;
    AudioHeap *heap;
    AudioParameter *parameterList;
    struct AudioBus *mainBus;
    struct AudioAuxiliaryBus *auxiliaryBus;
    AudioFilter *outputFilter;
    int physicalVoiceCount;
    int maxAuxiliaryBuses;
    int outputRate;
    int maxOutputSamples;
};

typedef struct SdkAudioSynthConfig {
    int maxVirtualVoices;
    int maxPhysicalVoices;
    int maxUpdates;
    int maxEffectBuses;
    AudioDmaFactory dma;
    AudioHeap *heap;
    int outputRate;
    unsigned char effectType;
    int *parameters;
} SdkAudioSynthConfig;

typedef char SdkAudioCommandMustBe8Bytes[sizeof(SdkAudioCommand) == 8 ? 1 : -1];
typedef char AudioLinkMustBe8Bytes[sizeof(AudioLink) == 8 ? 1 : -1];
typedef char AudioRawLoopMustBe12Bytes[sizeof(AudioRawLoop) == 12 ? 1 : -1];
typedef char AudioAdpcmLoopMustBe44Bytes[sizeof(AudioAdpcmLoop) == 44 ? 1 : -1];
typedef char AudioAdpcmBookMustBe264Bytes[sizeof(AudioAdpcmBook) == 264 ? 1 : -1];
typedef char AudioWaveTableMustBe20Bytes[sizeof(AudioWaveTable) == 20 ? 1 : -1];
typedef char AudioParameterMustBe28Bytes[sizeof(AudioParameter) == 0x1C ? 1 : -1];
typedef char AudioStartParameterMustBe28Bytes[sizeof(AudioStartParameter) == 0x1C ? 1 : -1];
typedef char AudioFreeParameterMustBe16Bytes[sizeof(AudioFreeParameter) == 0x10 ? 1 : -1];
typedef char AudioFilterMustBe20Bytes[sizeof(AudioFilter) == 0x14 ? 1 : -1];
typedef char AudioLoadFilterMustBe72Bytes[sizeof(AudioLoadFilter) == 0x48 ? 1 : -1];
typedef char AudioResamplerMustBe52Bytes[sizeof(AudioResampler) == 0x34 ? 1 : -1];
typedef char AudioEnvelopeMixerMustBe76Bytes[sizeof(AudioEnvelopeMixer) == 0x4C ? 1 : -1];
typedef char AudioPhysicalVoiceMustBe220Bytes[sizeof(AudioPhysicalVoice) == 0xDC ? 1 : -1];
typedef char SdkAudioVoiceMustBe28Bytes[sizeof(SdkAudioVoice) == 0x1C ? 1 : -1];
typedef char SdkAudioVoiceConfigMustBe6Bytes[sizeof(SdkAudioVoiceConfig) == 6 ? 1 : -1];
typedef char AudioSynthMustBe76Bytes[sizeof(AudioSynth) == 0x4C ? 1 : -1];
typedef char SdkAudioSynthConfigMustBe36Bytes[sizeof(SdkAudioSynthConfig) == 0x24 ? 1 : -1];

void func_80065AB0(AudioLink *node);
void func_80065AE0(AudioLink *node, AudioLink *after);
void func_80065B3C(AudioSynth *synth, SdkAudioSynthConfig *configuration);
int func_80065C38(AudioSynth *synth, int microseconds);
void func_80065C90(AudioSynth *synth, AudioPhysicalVoice *voice);
void func_80065CC8(AudioSynth *synth);
void func_80065D28(AudioParameter *parameter);
AudioParameter *func_80065D40(void);
SdkAudioCommand *func_80065D78(SdkAudioCommand *commands, unsigned int *generated,
                               short *outputBuffer, int outputCount);
void func_80066010(AudioSynth *synth, SdkAudioSynthConfig *configuration);
int func_80066360(AudioSynth *synth, AudioPhysicalVoice **voice, short priority);
int func_80066448(AudioSynth *synth, SdkAudioVoice *voice, SdkAudioVoiceConfig *configuration);
void func_80066590(AudioSynth *synth, SdkAudioVoice *voice, AudioWaveTable *wave,
                   float pitch, short volume, unsigned char pan,
                   unsigned char effect, int attackTime);
void func_80066680(AudioSynth *synth, SdkAudioVoice *voice, float pitch);
void func_80066710(AudioSynth *synth, SdkAudioVoice *voice, short volume, int time);
void func_800667B0(AudioSynth *synth, SdkAudioVoice *voice, unsigned char pan);
void func_80066840(AudioSynth *synth, SdkAudioVoice *voice);
void func_800668C0(AudioSynth *synth, SdkAudioVoice *voice);
void func_80066970(AudioSynth *synth, SdkAudioVoice *voice, short priority);
void func_8006B5A0(AudioSynth *synth);

#endif
