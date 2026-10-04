#ifndef ROBOTRON_AUDIO_ENGINE_TABLES_INTERNAL_H
#define ROBOTRON_AUDIO_ENGINE_TABLES_INTERNAL_H

#include "audio_properties_internal.h"

typedef struct AudioEngineCommandTable {
    void (*initialize)(AudioContext *context);
    void (*shutdown)(AudioContext *context);
    AudioVoiceCommand reserved[3];
    AudioVoiceCommand stopVoice;
    AudioVoiceCommand muteVoice;
    AudioVoiceCommand voiceCommands[12];
    AudioVoiceCommand sequenceCommands[17];
} AudioEngineCommandTable;

typedef char AudioEngineCommandTableMustBe144Bytes[
    sizeof(AudioEngineCommandTable) == 144 ? 1 : -1];

extern unsigned char D_8008D8D0[36];
extern AudioEngineCommandTable D_8008D920;
/* Alias for the sequence-command member at D_8008D920 + 0x4C. */
extern AudioVoiceCommand D_8008D96C[17];

#endif
