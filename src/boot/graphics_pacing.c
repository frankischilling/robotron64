#include "../../include/graphics_tasks.h"
#include "../../include/scheduler_runtime.h"

typedef signed short s16;

extern int D_8008D574, D_8008D578;
extern OSMesgQueue D_801437A0;
extern OSMesg D_801437B8[];
extern SchedulerClient D_801437D8;
extern OSMesgQueue *D_80143990;

int func_80062240(OSMesgQueue *, OSMesg *, int);
void func_80064CE0(float);

/* Behavior is recovered, but this source still differs from the original code generation. */
void func_8004FEA8(Scheduler *scheduler)
{
    OSMesg msg = 0;

    D_8008D578 = 0;
    osCreateMesgQueue(&D_801437A0, D_801437B8, 8);
    func_800507F0(scheduler, &D_801437D8, &D_801437A0);
    D_80143990 = func_80050628(scheduler);

    for (;;) {
        func_80062240(&D_801437A0, &msg, 1);
        switch (*(s16 *)msg) {
        case 1:
            if (D_8008D574 == 0) {
                if ((unsigned int)D_8008D578 < 2) {
                    D_8008D578++;
                }
            } else if (D_8008D574 == 1 && D_8008D578 == 0) {
                D_8008D578++;
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
