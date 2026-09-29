#ifndef ROBOTRON_AUDIO_PATCH_TABLE_INTERNAL_H
#define ROBOTRON_AUDIO_PATCH_TABLE_INTERNAL_H

#include "audio_backend_internal.h"

typedef struct AudioPatchRecord {
    unsigned char regionCount;
    unsigned char unknown01;
    short firstRegion;
} AudioPatchRecord;

typedef struct AudioNoteCommand {
    unsigned char key;
    unsigned char velocity;
    unsigned char remainingRegions;
} AudioNoteCommand;

typedef char AudioPatchRecordMustBe4Bytes[sizeof(AudioPatchRecord) == 4 ? 1 : -1];
typedef char AudioNoteCommandMustBe3Bytes[sizeof(AudioNoteCommand) == 3 ? 1 : -1];

extern AudioPatchRecord *D_8019282C;
extern AudioPatchRegion *D_80192830;
extern AudioWaveRecord *D_80192834;

#endif
