#ifndef ROBOTRON_SCHEDULER_RUNTIME_H
#define ROBOTRON_SCHEDULER_RUNTIME_H

#include "scheduler_task.h"

typedef unsigned long long SchedulerTime;

typedef struct SchedulerProfile SchedulerProfile;

struct SchedulerClient {
    SchedulerClient *next;
    OSMesgQueue *queue;
};

struct SchedulerProfile {
    unsigned int graphicsCount;
    unsigned int audioCount;
    SchedulerTime frameStart;
    SchedulerTime graphicsWait[8];
    SchedulerTime graphicsDp[8];
    SchedulerTime graphicsSp[8];
    SchedulerTime audioWait[4];
    SchedulerTime audioSp[4];
    unsigned char unknown110[8];
};

typedef char SchedulerClientMustBe8Bytes[sizeof(SchedulerClient) == 8 ? 1 : -1];
typedef char SchedulerProfileMustBe280Bytes[sizeof(SchedulerProfile) == 0x118 ? 1 : -1];

void func_80050630(void *arg);
void func_800507F0(Scheduler *scheduler, SchedulerClient *client, OSMesgQueue *queue);
void func_80050844(Scheduler *scheduler, SchedulerClient *client);
void func_800508D4(Scheduler *scheduler, OSMesg message);
void func_80050928(Scheduler *scheduler);
void func_80050BD0(Scheduler *scheduler);
void func_80050EF0(Scheduler *scheduler, SchedulerTask *task);
void func_80050FB0(int value);
void func_80050FD0(void);
void func_80050FF0(void);
void func_80051014(void);
void func_80051034(int arg0, int arg1, int arg2);
int func_80051044(int arg0, int arg1, int arg2, int arg3);

#endif
