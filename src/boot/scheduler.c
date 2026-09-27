#include "../../include/scheduler.h"

extern unsigned char D_801479E0[], D_801499E0[], D_8014B9E0[];
void func_80050630(void *);
void func_80050928(void *);
void func_80050BD0(void *);

void func_80050440(Scheduler *scheduler, unsigned char mode, unsigned char retraces)
{
    scheduler->unknown66C = 0;
    scheduler->unknown670 = 0;
    scheduler->unknown674 = 0;
    scheduler->unknown668 = 0;
    scheduler->unknown678 = 1;
    scheduler->unknown00 = 1;
    scheduler->unknown02 = 3;

    osCreateMesgQueue(&scheduler->retraceQueue, scheduler->retraceMessages, 8);
    osCreateMesgQueue(&scheduler->spQueue, scheduler->spMessages, 8);
    osCreateMesgQueue(&scheduler->dpQueue, scheduler->dpMessages, 8);
    osCreateMesgQueue(&scheduler->queue3C, scheduler->messages54, 8);
    osCreateMesgQueue(&scheduler->queue04, scheduler->messages1C, 8);
    osCreateMesgQueue(&scheduler->queue11C, scheduler->messages134, 8);

    osCreateViManager(254);
    osViSetMode(&D_8008E400[mode]);
    osViBlack(1);
    osViSetEvent(&scheduler->retraceQueue, (OSMesg)SCHEDULER_RETRACE, retraces);
    osSetEventMesg(EVENT_SP, &scheduler->spQueue, (OSMesg)SCHEDULER_SP);
    osSetEventMesg(EVENT_DP, &scheduler->dpQueue, (OSMesg)SCHEDULER_DP);
    osSetEventMesg(EVENT_PRENMI, &scheduler->retraceQueue, (OSMesg)SCHEDULER_PRENMI);

    osCreateThread(&scheduler->thread158, 19, func_80050630, scheduler, D_801479E0, 120);
    osStartThread(&scheduler->thread158);
    osCreateThread(&scheduler->thread308, 18, func_80050928, scheduler, D_801499E0, 110);
    osStartThread(&scheduler->thread308);
    osCreateThread(&scheduler->thread4B8, 17, func_80050BD0, scheduler, D_8014B9E0, 100);
    osStartThread(&scheduler->thread4B8);
}

OSMesgQueue *func_80050620(Scheduler *scheduler)
{
    return &scheduler->queue04;
}

OSMesgQueue *func_80050628(Scheduler *scheduler)
{
    return &scheduler->queue3C;
}
