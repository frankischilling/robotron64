#ifndef ROBOTRON_SDK_AUDIO_DECODER_H
#define ROBOTRON_SDK_AUDIO_DECODER_H

#include "sdk_audio_pipeline.h"
#include "sdk_audio_mix_commands.h"

enum SdkAudioWaveEncoding {
    SDK_AUDIO_ADPCM_WAVE = 0,
    SDK_AUDIO_RAW16_WAVE = 1
};

#define SDK_AUDIO_PHYSICAL(address) ((unsigned int)(address) & 0x1FFFFFFF)

#define SDK_AUDIO_LOAD(cursor, address) \
    SDK_AUDIO_PACKET(cursor, 0x04000000, address)

#define SDK_AUDIO_LOAD_BOOK(cursor, bytes, address) \
    SDK_AUDIO_PACKET(cursor, 0x0B000000 | SDK_AUDIO_FIELD(bytes, 0, 0x00FFFFFF), address)

#define SDK_AUDIO_LOOP_STATE(cursor, address) \
    SDK_AUDIO_PACKET(cursor, 0x0F000000, address)

#define SDK_AUDIO_DECODE(cursor, flags, address) \
    SDK_AUDIO_PACKET(cursor, 0x01000000 | SDK_AUDIO_FIELD(flags, 16, 0xFF), address)

void func_8006F3C0(unsigned char *source, unsigned char *destination, int count);

#endif
