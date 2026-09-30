#include "../../include/graphics_tasks.h"
#include "../../include/scheduler_runtime.h"

typedef signed short s16;

extern signed short D_80143994, D_80143996;
extern int D_8008D574, D_8008D578;
extern unsigned int D_8014599C;
extern OSMesgQueue D_801437A0;
extern OSMesg D_801437B8[];
extern SchedulerClient D_801437D8;
extern OSMesgQueue *D_80143990;

int func_80062240(OSMesgQueue *, OSMesg *, int);
void func_80064CE0(float);

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

void func_8004FEA8(Scheduler *scheduler)
{
    OSMesg msg = 0;
    int value;

    D_8008D578 = 0;
    osCreateMesgQueue(&D_801437A0, D_801437B8, 8);
    func_800507F0(scheduler, &D_801437D8, &D_801437A0);
    D_80143990 = func_80050628(scheduler);

    for (;;) {
        func_80062240(&D_801437A0, &msg, 1);
        value = *(s16 *)msg;
        switch (value) {
        case 1:
            value = D_8008D574;
            if ((unsigned int)value >= 31) {
                if (value != -1) {
                    continue;
                }
            } else {
                switch (value) {
                case 0:
                    if ((unsigned int)D_8008D578 < 2) {
                        D_8008D578++;
                    }
                    break;
                case 1:
                    if (D_8008D578 == 0) {
                        D_8008D578++;
                    }
                    break;
                case 2:
                case 3:
                case 5:
                case 30:
                    break;
                }
            }
            break;
        case 2:
            D_8008D578--;
            break;
        case 3:
            func_80064CE0(1.0f);
            D_8008D578 += 2;
            break;
        }
    }
}
