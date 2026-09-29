#ifndef ROBOTRON_SDK_AUDIO_ENVELOPE_H
#define ROBOTRON_SDK_AUDIO_ENVELOPE_H

#include "sdk_audio_pipeline.h"
#include "sdk_audio_mix_commands.h"
#include "sdk_io.h"

typedef struct AudioSimpleStartParameter {
    AudioParameter *next;
    int delta;
    short type;
    short unity;
    AudioWaveTable *wave;
} AudioSimpleStartParameter;

typedef char AudioSimpleStartParameterMustBe16Bytes[
    sizeof(AudioSimpleStartParameter) == 16 ? 1 : -1];

enum SdkAudioEnvelopeFlags {
    SDK_AUDIO_ENVELOPE_CONTINUE = 0,
    SDK_AUDIO_ENVELOPE_INITIALIZE = 1,
    SDK_AUDIO_ENVELOPE_LEFT = 2,
    SDK_AUDIO_ENVELOPE_VOLUME = 4,
    SDK_AUDIO_ENVELOPE_AUXILIARY = 8
};

#define SDK_AUDIO_VOLUME(cursor, flags, volume, high, low) \
    SDK_AUDIO_PACKET(cursor, 0x09000000 | SDK_AUDIO_FIELD(flags, 16, 0xFF) | \
        SDK_AUDIO_FIELD(volume, 0, 0xFFFF), \
        SDK_AUDIO_FIELD(high, 16, 0xFFFF) | SDK_AUDIO_FIELD(low, 0, 0xFFFF))

#define SDK_AUDIO_ENVELOPE(cursor, flags, address) \
    SDK_AUDIO_PACKET(cursor, 0x03000000 | SDK_AUDIO_FIELD(flags, 16, 0xFF), address)

double func_8006CDC0(double value, int exponent);
double func_8006CDE8(double value, int *exponent);

#endif
