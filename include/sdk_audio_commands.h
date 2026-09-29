#ifndef ROBOTRON_SDK_AUDIO_COMMANDS_H
#define ROBOTRON_SDK_AUDIO_COMMANDS_H

#include "sdk_audio.h"

enum SdkAudioFilterParameter {
    SDK_AUDIO_FREE_VOICE,
    SDK_AUDIO_SET_SOURCE,
    SDK_AUDIO_ADD_SOURCE,
    SDK_AUDIO_ADD_UPDATE,
    SDK_AUDIO_RESET,
    SDK_AUDIO_SET_WAVETABLE,
    SDK_AUDIO_SET_DRAM,
    SDK_AUDIO_SET_PITCH,
    SDK_AUDIO_SET_UNITY_PITCH,
    SDK_AUDIO_START,
    SDK_AUDIO_SET_STATE,
    SDK_AUDIO_SET_VOLUME,
    SDK_AUDIO_SET_PAN,
    SDK_AUDIO_START_VOICE_PARAMETERS,
    SDK_AUDIO_START_VOICE,
    SDK_AUDIO_STOP_VOICE,
    SDK_AUDIO_SET_EFFECT_AMOUNT
};

/* A command cursor may have a post-increment: evaluate it once per packet. */
#define SDK_AUDIO_PACKET(cursor, word0, word1) { \
    SdkAudioCommand *packet = (cursor); \
    packet->words.first = (unsigned int)(word0); \
    packet->words.second = (unsigned int)(word1); \
}

#define SDK_AUDIO_SEGMENT(cursor, segment, address) \
    SDK_AUDIO_PACKET(cursor, 0x07000000, \
        (((unsigned int)(segment) & 0xFF) << 24) | ((unsigned int)(address) & 0x00FFFFFF))

#endif
