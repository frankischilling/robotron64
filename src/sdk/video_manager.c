#include "../../include/sdk_video_manager.h"
#include "../../include/sdk_timers.h"

SdkDeviceManager D_8008F140 = {0};
OSThread D_801950B0;
unsigned char D_80195260[0x1000];
OSMesgQueue D_80196260;
OSMesg D_80196278[5];
SdkVideoMessage D_80196290;
SdkVideoMessage D_801962A8;
unsigned short D_801962C0;

void osCreateViManager(int priority)
{
    unsigned int mask;
    int previousPriority;
    int currentPriority;

    if (D_8008F140.active == 0) {
        func_800684D0();
        osCreateMesgQueue(&D_80196260, D_80196278, 5);
        D_80196290.type = 13;
        D_80196290.priority = 0;
        D_80196290.returnQueue = 0;
        D_801962A8.type = 14;
        D_801962A8.priority = 0;
        D_801962A8.returnQueue = 0;
        osSetEventMesg(7, &D_80196260, &D_80196290);
        osSetEventMesg(3, &D_80196260, &D_801962A8);
        previousPriority = -1;
        currentPriority = func_80067890(0);
        if (currentPriority < priority) {
            previousPriority = currentPriority;
            osSetThreadPri(0, priority);
        }
        mask = func_80067560();
        D_8008F140.active = 1;
        D_8008F140.thread = &D_801950B0;
        D_8008F140.commandQueue = &D_80196260;
        D_8008F140.eventQueue = &D_80196260;
        D_8008F140.accessQueue = 0;
        D_8008F140.dma = 0;
        D_8008F140.extendedDma = 0;
        osCreateThread(&D_801950B0, 0, func_80064EC8, &D_8008F140,
                       D_80195260 + sizeof(D_80195260), priority);
        func_80068050();
        osStartThread(&D_801950B0);
        func_80067580(mask);
        if (previousPriority != -1) {
            osSetThreadPri(0, previousPriority);
        }
    }
}

void func_80064EC8(void *argument)
{
    SdkVideoContext *context;
    SdkDeviceManager *manager;
    SdkVideoMessage *message;
    int first;
    unsigned int count;

    message = 0;
    first = 0;
    context = func_8006AC80();
    D_801962C0 = context->retraces;
    if (D_801962C0 == 0) {
        D_801962C0 = 1;
    }
    manager = argument;
    while (1) {
        func_80062240(manager->eventQueue, (OSMesg *)&message, 1);
        switch (message->type) {
        case 13:
            func_8006AC90();
            D_801962C0--;
            if (D_801962C0 == 0) {
                context = func_8006AC80();
                if (context->queue != 0) {
                    func_800635A0(context->queue, context->message, 0);
                }
                D_801962C0 = context->retraces;
            }
            D_8019645C++;
            if (first) {
                count = func_800684C0();
                D_80196450 = count;
                first = 0;
            }
            count = D_80196458;
            D_80196458 = func_800684C0();
            count = D_80196458 - count;
            D_80196450 = D_80196450 + count;
            break;
        case 14:
            func_8006855C();
            break;
        }
    }
}
