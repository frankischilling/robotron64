#include "../../include/audio_runtime.h"
#include "../../include/audio_config.h"
#include "../../include/audio_loader_internal.h"
#include "../../include/heap.h"

extern unsigned char D_0066BEE0[];
extern unsigned char D_0077B780[];
extern unsigned char D_00783380[];
extern int D_800AF1E0;
extern AudioTaskRecord D_8014BE58[];
extern SchedulerTask D_8014BF78[];
extern unsigned char D_8014C080[];
extern OSMesgQueue D_8018FF30;
extern OSMesg D_8018FF48[];
extern OSMesgQueue D_8018FF68;
extern OSMesg D_8018FF80[];
extern OSThread D_8018FFA0;
extern unsigned char D_8018DF30[];
extern unsigned char *D_80190150;
extern AudioHeap D_80190158;

int func_80052D70(unsigned char *source);
void func_80058890(void (*callback)(int, int, int));
void func_800588C8(int (*callback)(int, int, int, int));
int func_8005D220(AudioContext *context, unsigned char *source);
void func_8005D2E4(AudioContext *context, unsigned char *source, int flags,
                 void *allocation, int size);
int func_8005D830(int value, int count);
void func_8005D8AC(int value, int count, void *allocation);

void func_8005109C(int priority, int televisionType)
{
    int messageType;
    AudioSettings settings;
    AudioConfiguration configuration;
    int bankSize;
    int sequenceSize;
    int index;
    OSThread *thread;
    void *sequence;

    D_800AF1E0 = 11;
    D_8014BE54 = 0x1D4C0;
    D_8014BE50 = func_8004DD6C(D_8014BE54);
    func_80058890(func_80051034);
    func_800588C8(func_80051044);
    func_80052948(&configuration);
    configuration.flags = 0x115F;
    configuration.values[0] += 8;
    configuration.values[1] += 0x20;
    configuration.values[6] += 0x18;
    configuration.values[3] = 0xA0;
    configuration.values[8] = 0x30;
    configuration.values[12] = 0x20;
    func_80052780(&configuration);
    func_800656F0(&D_80190158, D_8014C080, 0x41EB0);
    messageType = 2;
    if (televisionType == 2) {
        settings.frameRate = 30.0f;
    } else {
        settings.frameRate = 60.0f;
    }
    settings.frequency = 0x5622;
    settings.bufferSize = 0xC00;
    settings.heap = &D_80190158;
    settings.romBase = D_0066BEE0;
    settings.effectType = messageType;
    settings.effectParameters = 0;
    func_80051A0C(&settings);
    bankSize = func_80052D70(D_0077B780);
    func_8005303C(D_0077B780,
        func_80065730(0, 0, &D_80190158, 1, bankSize), bankSize);
    sequenceSize = func_8005D220(func_80052A74(), D_00783380);
    sequence = func_80065730(0, 0, &D_80190158, 1, sequenceSize);
    func_8005D2E4(func_80052A74(), D_00783380, 0, sequence, sequenceSize);
    func_8005D8AC(0, 0x88,
        func_80065730(0, 0, &D_80190158, 1, func_8005D830(0, 0x88)));
    D_80190150 = func_80065730(0, 0, &D_80190158, 1, 4);
    D_80190150 += 0x10;
    for (index = 0; index < 3; index++) {
        D_8014BE58[index].self = &D_8014BE58[index];
        D_8014BE58[index].messageType = messageType;
    }
    osCreateMesgQueue(&D_8018FF68, D_8018FF80, 8);
    osCreateMesgQueue(&D_8018FF30, D_8018FF48, 8);
    thread = &D_8018FFA0;
    osCreateThread(thread, priority, func_80051380, 0, D_8018DF30 + 0x2000, priority);
    osStartThread(thread);
    func_8004DC70(D_8014BE50);
}
