#include "../../include/sdk_timers.h"

int func_800635A0(OSMesgQueue *queue, OSMesg message, int flags);

void func_8006855C(void)
{
    SdkTimer *timer;
    unsigned int current;
    unsigned int elapsed;

    if (D_8008F240->next == D_8008F240) {
        return;
    }
    for (;;) {
        timer = D_8008F240->next;
        if (timer == D_8008F240) {
            func_8006E740(0);
            D_80196460 = 0;
            break;
        }
        current = func_800684C0();
        elapsed = current - D_80196460;
        D_80196460 = current;
        if (elapsed < timer->value) {
            timer->value -= elapsed;
            func_800686D4(timer->value);
            break;
        }
        timer->previous->next = timer->next;
        timer->next->previous = timer->previous;
        timer->next = 0;
        timer->previous = 0;
        if (timer->queue != 0) {
            func_800635A0(timer->queue, timer->message, 0);
        }
        if (timer->interval != 0) {
            timer->value = timer->interval;
            func_80068748(timer);
        }
    }
}
