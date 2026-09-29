#ifndef ROBOTRON_AUDIO_BACKEND_INTERNAL_H
#define ROBOTRON_AUDIO_BACKEND_INTERNAL_H

#include "audio_properties_internal.h"
#include "audio_callbacks.h"
#include "audio_voice_capture_internal.h"

struct AudioPatchRegion {
    unsigned char priority;
    unsigned char volume;
    signed char pan;
    unsigned char unknown03;
    unsigned char rootKey;
    signed char detune;
    unsigned char keyMin;
    unsigned char keyMax;
    signed char pitchDown;
    signed char pitchUp;
    short waveIndex;
    unsigned short attackTime;
    unsigned short decayTime;
    unsigned short releaseTime;
    unsigned char attackVolume;
    unsigned char decayVolume;
};

struct AudioWaveRecord {
    unsigned char *data;
    unsigned int length;
    unsigned char type;
    unsigned char flags;
    unsigned short unknown0A;
    void *loop;
    void *book;
    int tuning;
};

typedef struct AudioSynthVoice {
    struct AudioSynthVoice *next;
    struct AudioSynthVoice *previous;
    void *physicalVoice;
    AudioWaveRecord *wave;
    void *clientPrivate;
    short state;
    short priority;
    short effectBus;
    short unityPitch;
} AudioSynthVoice;

typedef struct AudioSynthVoiceConfiguration {
    short priority;
    short effect;
    unsigned char unityPitch;
} AudioSynthVoiceConfiguration;

typedef char AudioPatchRegionMustBe20Bytes[sizeof(AudioPatchRegion) == 20 ? 1 : -1];
typedef char AudioWaveRecordMustBe24Bytes[sizeof(AudioWaveRecord) == 24 ? 1 : -1];
typedef char AudioSynthVoiceMustBe28Bytes[sizeof(AudioSynthVoice) == 28 ? 1 : -1];
typedef char AudioSynthVoiceConfigurationMustBe6Bytes[sizeof(AudioSynthVoiceConfiguration) == 6 ? 1 : -1];

extern unsigned char D_8008DA1C;
extern unsigned char D_8008DA20;
extern unsigned char D_8008DA24;
extern int D_8008D860;
extern AudioSynthVoice *D_80190200;
extern AudioContext *D_80192810;
extern AudioInstance *D_80192814;
extern AudioVoice *D_80192818;
extern AudioStatusRecord *D_8019281C;
extern int D_80192820;
extern unsigned int *D_80192828;

float func_8005B000(int cents);
void func_8005B064(AudioStatusRecord *voice);
void func_8005B854(AudioVoice *voice);
void func_8005971C(AudioVoice *voice);
void func_8005C334(AudioStatusRecord *hardware, AudioVoice *voice, AudioPatchRegion *region,
                   AudioWaveRecord *wave, unsigned char key, unsigned char velocity);
void func_8005C3E4(AudioStatusRecord *voice);
void func_8005C4F8(AudioStatusRecord *voice, int releaseTime);
void func_8005C5BC(AudioStatusRecord *voice);
void func_8005C684(AudioStatusRecord *voice);

int func_80066448(AudioSynth *synth, AudioSynthVoice *voice,
                  AudioSynthVoiceConfiguration *configuration);
void func_80066590(AudioSynth *synth, AudioSynthVoice *voice, AudioWaveRecord *wave,
                   float pitch, short volume, unsigned char pan,
                   unsigned char effect, int attackTime);
void func_80066680(AudioSynth *synth, AudioSynthVoice *voice, float pitch);
void func_80066710(AudioSynth *synth, AudioSynthVoice *voice, short volume, int time);
void func_800667B0(AudioSynth *synth, AudioSynthVoice *voice, unsigned char value);
void func_80066840(AudioSynth *synth, AudioSynthVoice *voice);
void func_800668C0(AudioSynth *synth, AudioSynthVoice *voice);
void func_80066970(AudioSynth *synth, AudioSynthVoice *voice, int value);

#endif
