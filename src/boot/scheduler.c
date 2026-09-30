#include "../../include/scheduler_runtime.h"
#include "../../include/sdk_rsp.h"

extern int D_8008D580;
extern int D_8008D584;
extern int D_8008D588;
extern SchedulerTime D_8008E3B0;
extern SchedulerProfile D_8014B9E0[4];
extern SchedulerProfile *D_8014BE40;
extern SchedulerProfile *D_8014BE44;

extern SchedulerTime func_80061450(void);
extern int func_80062240(OSMesgQueue *, OSMesg *, int);
extern int func_800635A0(OSMesgQueue *, OSMesg, int);
extern unsigned int func_800651F0(unsigned int);
extern void func_80060720(void);
extern void func_80065620(void *);
extern void *func_80065670(void);
extern void *func_800656B0(void);

#define SCHEDULER_TIME_US() \
    (func_80061450() * 1000000ULL / D_8008E3B0)

extern unsigned char D_801479E0[], D_801499E0[];

void func_80050440(Scheduler *scheduler, unsigned char mode, unsigned char retraces)
{
    scheduler->graphicsTask = 0;
    scheduler->audioTask = 0;
    scheduler->waitingGraphicsTask = 0;
    scheduler->clients = 0;
    scheduler->firstGraphicsTask = 1;
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
    osCreateThread(&scheduler->thread308, 18, (void (*)(void *))func_80050928, scheduler, D_801499E0, 110);
    osStartThread(&scheduler->thread308);
    osCreateThread(&scheduler->thread4B8, 17, (void (*)(void *))func_80050BD0, scheduler, D_8014B9E0, 100);
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

void func_80050630(void *arg)
{
    OSMesg message = 0;

    for (;;) {
        func_80062240(&((Scheduler *)arg)->retraceQueue, &message, 1);
        D_8008D580++;
        switch ((int)message) {
        case SCHEDULER_RETRACE:
            func_800508D4((Scheduler *)arg, (OSMesg)arg);
            if (D_8008D588 == 0) {
                D_8008D588++;
                D_8014BE44 = &D_8014B9E0[D_8008D584];
                D_8008D584++;
                D_8008D584 &= 3;
                D_8014BE40 = &D_8014B9E0[D_8008D584];
                D_8014BE40->audioCount = 0;
                D_8014BE40->graphicsCount = 0;
                D_8014BE40->frameStart = SCHEDULER_TIME_US();
            }
            break;
        case SCHEDULER_PRENMI:
            func_800508D4((Scheduler *)arg, (OSMesg)((char *)arg + 2));
            break;
        }
    }
}

void func_800507F0(Scheduler *scheduler, SchedulerClient *client, OSMesgQueue *queue)
{
    unsigned int mask;

    mask = func_800651F0(1);
    client->queue = queue;
    client->next = scheduler->clients;
    scheduler->clients = client;
    func_800651F0(mask);
}

void func_80050844(Scheduler *scheduler, SchedulerClient *client)
{
    SchedulerClient *current;
    SchedulerClient *previous;
    unsigned int mask;

    current = scheduler->clients;
    previous = 0;
    mask = func_800651F0(1);
    while (current != 0) {
        if (current == client) {
            if (previous != 0) {
                previous->next = client->next;
            } else {
                scheduler->clients = client->next;
            }
            break;
        }
        previous = current;
        current = current->next;
    }
    func_800651F0(mask);
}

void func_800508D4(Scheduler *scheduler, OSMesg message)
{
    SchedulerClient *client;

    client = scheduler->clients;
    while (client != 0) {
        func_800635A0(client->queue, message, 0);
        client = client->next;
    }
}

void func_80050928(Scheduler *scheduler)
{
    OSMesg signal = 0;
    SchedulerTask *task = 0;
    OSMesgQueue *queue = &scheduler->queue04;
    SchedulerTask *graphicsTask;
    int state;
    unsigned int profileIndex;

    for (state = 0;;) {
        func_80062240(queue, (OSMesg *)&task, 1);
        func_80060720();
        graphicsTask = scheduler->graphicsTask;
        if (graphicsTask != 0) {
            func_80065290();
            func_80062240(&scheduler->spQueue, &signal, 1);
            if (func_800652B0(&graphicsTask->task) != 0) {
                state = 1;
            } else {
                state = 2;
            }
        }

        if (D_8014BE40->audioCount < 4) {
            profileIndex = D_8014BE40->audioCount;
            D_8014BE40->audioWait[profileIndex] = SCHEDULER_TIME_US() - D_8014BE40->frameStart;
        }

        scheduler->audioTask = task;
        func_8006544C(&task->task);
        func_800655DC(&task->task);
        func_80062240(&scheduler->spQueue, &signal, 1);
        scheduler->audioTask = 0;

        if (D_8014BE40->audioCount < 4) {
            D_8014BE40->audioSp[profileIndex] = SCHEDULER_TIME_US() - D_8014BE40->frameStart;
            D_8014BE40->audioCount++;
        }

        if (scheduler->waitingGraphicsTask != 0) {
            func_800635A0(&scheduler->queue11C, (OSMesg)&signal, 1);
        }

        if (state == 1) {
            func_8006544C(&graphicsTask->task);
            func_800655DC(&graphicsTask->task);
        } else if (state == 2) {
            func_800635A0(&scheduler->spQueue, (OSMesg)&signal, 1);
        }

        func_800635A0(task->completionQueue, task->completionMessage, 1);
        state = 0;
    }
}

void func_80050BD0(Scheduler *scheduler)
{
    OSMesg signal = 0;
    SchedulerTask *task;
    unsigned int profileIndex;

    for (;;) {
        func_80062240(&scheduler->queue3C, (OSMesg *)&task, 1);
        func_80050EF0(scheduler, task);

        if (scheduler->audioTask != 0) {
            scheduler->waitingGraphicsTask = task;
            func_80062240(&scheduler->queue11C, &signal, 1);
            scheduler->waitingGraphicsTask = 0;
        }

        if (D_8014BE40->graphicsCount < 8) {
            profileIndex = D_8014BE40->graphicsCount;
            D_8014BE40->graphicsWait[profileIndex] = SCHEDULER_TIME_US() - D_8014BE40->frameStart;
        }

        scheduler->graphicsTask = task;
        func_8006544C(&task->task);
        func_800655DC(&task->task);
        func_80062240(&scheduler->spQueue, &signal, 1);
        scheduler->graphicsTask = 0;

        if (D_8014BE40->graphicsCount < 8) {
            D_8014BE40->graphicsSp[profileIndex] = SCHEDULER_TIME_US() - D_8014BE40->frameStart;
        }

        func_80062240(&scheduler->dpQueue, &signal, 1);

        if (D_8014BE40->graphicsCount < 8) {
            D_8014BE40->graphicsDp[profileIndex] = SCHEDULER_TIME_US() - D_8014BE40->frameStart;
            D_8014BE40->graphicsCount++;
        }

        if (scheduler->firstGraphicsTask != 0) {
            osViBlack(0);
            scheduler->firstGraphicsTask = 0;
        }

        if ((task->flags & 0x40) != 0) {
            func_80065620(task->framebuffer);
            D_8008D588 = 0;
        }

        func_800635A0(task->completionQueue, task->completionMessage, 1);
    }
}

void func_80050EF0(Scheduler *scheduler, SchedulerTask *task)
{
    OSMesg message = 0;
    SchedulerClient client;
    void *framebuffer;

    framebuffer = task->framebuffer;
    while ((func_80065670() == framebuffer) || (func_800656B0() == framebuffer)) {
        func_800507F0(scheduler, &client, &scheduler->queue11C);
        func_80062240(&scheduler->queue11C, &message, 1);
        func_80050844(scheduler, &client);
    }
}
