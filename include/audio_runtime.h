#ifndef ROBOTRON_AUDIO_RUNTIME_H
#define ROBOTRON_AUDIO_RUNTIME_H

#include "audio_control.h"
#include "audio_io.h"
#include "scheduler_runtime.h"

typedef struct AudioHeap {
    unsigned char *start;
    unsigned char *current;
    int length;
    int count;
} AudioHeap;

typedef struct AudioSettings {
    float frameRate;
    unsigned int frequency;
    int bufferSize;
    AudioHeap *heap;
    unsigned char *romBase;
    int effectType;
    int *effectParameters;
} AudioSettings;

typedef struct AudioTaskRecord {
    SchedulerTask scheduler;
    short messageType;
    unsigned short unknown5A;
    struct AudioTaskRecord *self;
} AudioTaskRecord;

typedef struct AudioRspRecord {
    void *data;
    short count;
    unsigned short unknown06;
    RspTask task;
} AudioRspRecord;

typedef char AudioHeapMustBe16Bytes[sizeof(AudioHeap) == 0x10 ? 1 : -1];
typedef char AudioSettingsMustBe28Bytes[sizeof(AudioSettings) == 0x1C ? 1 : -1];
typedef char AudioTaskRecordMustBe96Bytes[sizeof(AudioTaskRecord) == 0x60 ? 1 : -1];
typedef char AudioRspRecordMustBe72Bytes[sizeof(AudioRspRecord) == 0x48 ? 1 : -1];

extern void *D_8014BE50;
extern int D_8014BE54;
extern AudioRspRecord *D_8008D7A0;
extern AudioRspRecord *D_80190188[3];

void func_8005109C(int priority, int televisionType);
void func_80051380(void *argument);
void func_80051A0C(AudioSettings *settings);
RspTask *func_8005211C(void);
RspTask *func_800521C8(AudioRspRecord *record);
void func_800526D0(void);
void func_80052700(void);

void func_800656F0(AudioHeap *heap, void *start, int length);
void *func_80065730(unsigned char *file, int line, AudioHeap *heap, int count,
                   int size);

#endif
