#ifndef ROBOTRON_SDK_AUDIO_MIX_COMMANDS_H
#define ROBOTRON_SDK_AUDIO_MIX_COMMANDS_H

#include "sdk_audio_commands.h"

enum SdkAudioDmemBuffer {
    SDK_AUDIO_TEMPORARY = 0x000,
    SDK_AUDIO_DECODER_OUTPUT = 0x140,
    SDK_AUDIO_MAIN_LEFT = 0x440,
    SDK_AUDIO_MAIN_RIGHT = 0x580,
    SDK_AUDIO_AUX_LEFT = 0x6C0,
    SDK_AUDIO_AUX_RIGHT = 0x800
};

#define SDK_AUDIO_FIELD(value, shift, mask) \
    (((unsigned int)(value) & (mask)) << (shift))

#define SDK_AUDIO_CLEAR(cursor, address, bytes) \
    SDK_AUDIO_PACKET(cursor, 0x02000000 | SDK_AUDIO_FIELD(address, 0, 0x00FFFFFF), bytes)

#define SDK_AUDIO_BUFFER(cursor, flags, input, output, bytes) \
    SDK_AUDIO_PACKET(cursor, 0x08000000 | SDK_AUDIO_FIELD(flags, 16, 0xFF) | \
        SDK_AUDIO_FIELD(input, 0, 0xFFFF), SDK_AUDIO_FIELD(output, 16, 0xFFFF) | \
        SDK_AUDIO_FIELD(bytes, 0, 0xFFFF))

#define SDK_AUDIO_MIX(cursor, flags, gain, input, output) \
    SDK_AUDIO_PACKET(cursor, 0x0C000000 | SDK_AUDIO_FIELD(flags, 16, 0xFF) | \
        SDK_AUDIO_FIELD(gain, 0, 0xFFFF), SDK_AUDIO_FIELD(input, 16, 0xFFFF) | \
        SDK_AUDIO_FIELD(output, 0, 0xFFFF))

#define SDK_AUDIO_INTERLEAVE(cursor, left, right) \
    SDK_AUDIO_PACKET(cursor, 0x0D000000, SDK_AUDIO_FIELD(left, 16, 0xFFFF) | \
        SDK_AUDIO_FIELD(right, 0, 0xFFFF))

#define SDK_AUDIO_SAVE(cursor, address) \
    SDK_AUDIO_PACKET(cursor, 0x06000000, address)

#define SDK_AUDIO_DMEM_MOVE(cursor, input, output, bytes) \
    SDK_AUDIO_PACKET(cursor, 0x0A000000 | SDK_AUDIO_FIELD(input, 0, 0x00FFFFFF), \
        SDK_AUDIO_FIELD(output, 16, 0xFFFF) | SDK_AUDIO_FIELD(bytes, 0, 0xFFFF))

#define SDK_AUDIO_RESAMPLE(cursor, flags, pitch, state) \
    SDK_AUDIO_PACKET(cursor, 0x05000000 | SDK_AUDIO_FIELD(flags, 16, 0xFF) | \
        SDK_AUDIO_FIELD(pitch, 0, 0xFFFF), state)

#endif
