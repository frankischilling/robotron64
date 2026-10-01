#ifndef ROBOTRON_AUDIO_SEQUENCE_INTERNAL_H
#define ROBOTRON_AUDIO_SEQUENCE_INTERNAL_H

#include "audio_properties_internal.h"
#include "audio_file_services_internal.h"
#include "audio_host_internal.h"

/* Serialized sequence entries use the unsigned interpretation of the count. */
typedef struct AudioSequenceHeader {
    unsigned char category;
    unsigned char parameter01;
    short property02;
    short property04;
    unsigned char parameter06;
    unsigned char parameter07;
    unsigned char unknown08;
    unsigned char controlMask;
    short property0A;
    short property0C;
    short labelCount;
    unsigned int commandBytes;
} AudioSequenceHeader;

typedef struct AudioSequenceTrack {
    AudioSequenceHeader *header;
    unsigned int *labels;
    unsigned char *commands;
} AudioSequenceTrack;

typedef struct AudioSequenceEntry {
    unsigned short trackCount;
    unsigned char storageMode;
    unsigned char unknown03;
    unsigned int dataBytes;
    unsigned int fileOffset;
    AudioSequenceTrack *tracks;
} AudioSequenceEntry;

typedef struct AudioSequenceFileHeader {
    unsigned char unknown00[14];
    unsigned short sequenceCount;
    unsigned char storageMode;
    unsigned char unknown11[3];
    unsigned int packedTableBytes;
    unsigned int tableBytes;
    unsigned int unknown1C;
} AudioSequenceFileHeader;

typedef char AudioSequenceHeaderMustBe20Bytes[sizeof(AudioSequenceHeader) == 20 ? 1 : -1];
typedef char AudioSequenceTrackMustBe12Bytes[sizeof(AudioSequenceTrack) == 12 ? 1 : -1];
typedef char AudioSequenceEntryMustBe16Bytes[sizeof(AudioSequenceEntry) == 16 ? 1 : -1];
typedef char AudioSequenceFileHeaderMustBe32Bytes[sizeof(AudioSequenceFileHeader) == 32 ? 1 : -1];

extern unsigned int D_8008D858;
extern AudioSequenceFileHeader D_80192B80;
extern AudioContext *D_80192BA0;
extern unsigned int D_80192BBC;
extern int D_80192BC0;

void func_8005362C(AudioVoice *voice, AudioSequenceTrack *track,
                   AudioProperties *properties);

int func_8005CE0C(int index, unsigned char *destination);
int func_8005D220(AudioContext *context, unsigned int address);
int func_8005D2E4(AudioContext *context, unsigned int address, int keepOpen, AudioRecordSlot *table);
void func_8005D4A4(void);
int func_8005D4C8(int index);
int func_8005D584(int index, unsigned char *destination);
int func_8005D610(int index);
int func_8005D690(short *indices);
int func_8005D708(short *indices, unsigned char *destination);
int func_8005D7B4(short *indices);
int func_8005D830(int first, int count);
int func_8005D8AC(int first, int count, unsigned char *destination);
int func_8005D95C(int first, int count);

#endif
