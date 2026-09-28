#include "../../include/graphics_tasks.h"
#include "../../include/scheduler_runtime.h"

extern signed short D_80143994, D_80143996;
extern int D_8008D574;
extern unsigned int D_8014599C;
extern OSMesgQueue D_801437A0;
extern OSMesg D_801437B8[];
extern SchedulerClient D_801437D8;
extern OSMesgQueue *D_80143990;

void func_8004FE10(void *arg)
{
    D_80143994 = 2;
    D_80143996 = 4;
    D_8008D574 = -1;
    D_8014599C = 0;
}

void func_8004FE44(Scheduler *scheduler)
{
    func_8004FE10(0);
    osCreateMesgQueue(&D_801437A0, D_801437B8, 8);
    func_800507F0(scheduler, &D_801437D8, &D_801437A0);
    D_80143990 = func_80050628(scheduler);
}
