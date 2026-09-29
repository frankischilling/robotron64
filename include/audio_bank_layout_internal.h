#ifndef ROBOTRON_AUDIO_BANK_LAYOUT_INTERNAL_H
#define ROBOTRON_AUDIO_BANK_LAYOUT_INTERNAL_H

#include "audio_patch_table_internal.h"

typedef struct AudioPatchBank {
    unsigned char unknown00[4];
    short patchCount;
    short patchRecordSize;
    short regionCount;
    short regionRecordSize;
    short waveCount;
    short waveRecordSize;
    short drumCount;
    short drumRecordSize;
    unsigned int extraDataSize;
    unsigned char *data;
} AudioPatchBank;

typedef struct AudioLoopGroup {
    short unknown00;
    short rawCount;
    short adpcmCount;
    short bookCount;
} AudioLoopGroup;

/* Each serialized loop record starts on the bank's eight-byte boundary. */
#define AUDIO_BANK_STRIDE(type) ((sizeof(type) + 7) & ~7U)
#define AUDIO_BANK_ALIGN(pointer) ((void *)(((unsigned int)(pointer) + 7) & ~7U))

typedef char AudioPatchBankMustBe28Bytes[sizeof(AudioPatchBank) == 28 ? 1 : -1];
typedef char AudioLoopGroupMustBe8Bytes[sizeof(AudioLoopGroup) == 8 ? 1 : -1];

extern int D_8008D83C;
extern AudioPatchBank *D_80192824;
extern unsigned int *D_80192838;
extern AudioLoopGroup *D_8019283C;
extern unsigned char *D_80192840;
extern unsigned char *D_80192844;
extern AudioAdpcmBook *D_80192848;
extern AudioRawLoop D_80192850;
extern AudioAdpcmLoop D_80192860;

void func_8005B3A8(AudioContext *context);

#endif
