#ifndef ROBOTRON_AUDIO_VOICE_CAPTURE_INTERNAL_H
#define ROBOTRON_AUDIO_VOICE_CAPTURE_INTERNAL_H

#include "audio_properties_internal.h"

typedef struct AudioCapturedVoice {
    short instanceIndex;
    short voiceIndex;
    unsigned char first;
    unsigned char second;
    unsigned short unknown06;
    void *record;
    int value;
} AudioCapturedVoice;

typedef struct AudioVoiceCapture {
    int count;
    int categoryMask;
    AudioCapturedVoice voices[32];
} AudioVoiceCapture;

typedef char AudioCapturedVoiceMustBe16Bytes[sizeof(AudioCapturedVoice) == 16 ? 1 : -1];
typedef char AudioVoiceCaptureMustBe520Bytes[sizeof(AudioVoiceCapture) == 520 ? 1 : -1];

extern int D_8008DA28;
extern AudioVoiceCapture *D_8008DA2C;
extern AudioVoiceCapture D_80192890;
extern int D_80192A98;

void func_8005C7F8(AudioVoice *voice, void *record, int value,
                   unsigned char first, int second);

#endif
