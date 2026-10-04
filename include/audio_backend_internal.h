#ifndef ROBOTRON_AUDIO_BACKEND_INTERNAL_H
#define ROBOTRON_AUDIO_BACKEND_INTERNAL_H

#include "audio_properties_internal.h"
#include "audio_callbacks.h"
#include "audio_voice_capture_internal.h"
#include "sdk_audio.h"

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
    AudioWaveTable sdk;
    int tuning;
};

typedef SdkAudioVoice AudioSynthVoice;
typedef SdkAudioVoiceConfig AudioSynthVoiceConfiguration;

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
void func_8005BA24(AudioVoice *voice);
void func_8005971C(AudioVoice *voice);
void func_8005BCC8(AudioVoice *voice);
void func_8005BCD0(AudioVoice *voice);
void func_8005BCD8(AudioVoice *voice);
void func_8005BEFC(AudioVoice *voice);
void func_8005C0A0(AudioVoice *voice);
void func_8005C1D8(AudioVoice *voice);
void func_8005C334(AudioStatusRecord *hardware, AudioVoice *voice, AudioPatchRegion *region,
                   AudioWaveRecord *wave, unsigned char key, unsigned char velocity);
void func_8005C3E4(AudioStatusRecord *voice);
void func_8005C4F8(AudioStatusRecord *voice, int releaseTime);
void func_8005C5BC(AudioStatusRecord *voice);
void func_8005C684(AudioStatusRecord *voice);
void func_8005CA34(AudioVoice *voice);
void func_8005CBB4(AudioVoice *voice);

#endif
