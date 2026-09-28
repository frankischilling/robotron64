#include "../../include/audio_runtime.h"

extern int D_8008D764;
extern int D_8008D768;
extern SchedulerTask D_8014BF78[];
extern OSMesgQueue D_8018FF30;
extern OSMesgQueue D_8018FF68;

void func_8004F850(void);
SchedulerTime func_80061450(void);
int func_80062240(OSMesgQueue *queue, OSMesg *message, int flags);
int func_800635A0(OSMesgQueue *queue, OSMesg message, int flags);

void func_80051380(void *argument)
{
    int messageType;
    int taskIndex;
    SchedulerTask *task;
    RspTask *rsp;
    int outstanding;
    OSMesg message;
    int stopping;
    int next;
    SchedulerClient client;

    outstanding = 0;
    stopping = 0;
    next = 0;
    func_800507F0(&D_801378D0, &client, &D_8018FF30);
    do {
        func_80062240(&D_8018FF30, &message, 1);
        messageType = *(short *)message;
        switch (messageType) {
        case 1:
            func_8004F850();
            if (outstanding < 3) {
                D_8008D764 = func_80061450();
                rsp = func_8005211C();
                if (rsp == 0) {
                    break;
                }
                D_8008D768 = func_80061450() - D_8008D764;
                taskIndex = next % 3;
                task = &D_8014BF78[taskIndex];
                next++;
                task->next = 0;
                task->completionMessage = 0;
                task->completionQueue = &D_8018FF68;
                task->task = *rsp;
                func_800635A0(func_80050620(&D_801378D0), task, 1);
                outstanding++;
            }
            if (func_80062240(&D_8018FF68, &message, 1) != -1) {
                outstanding--;
            }
            break;
        case 3:
            outstanding = 6;
            break;
        case 10:
            stopping = 1;
            break;
        }
    } while (stopping == 0);
    func_800526D0();
}
