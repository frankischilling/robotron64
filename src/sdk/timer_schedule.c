#include "../../include/sdk_timers.h"

unsigned int func_8006ABA0(SdkTimer *timer, SdkTime countdown, SdkTime interval,
                          OSMesgQueue *queue, OSMesg message)
{
    SdkTime first;

    timer->next = 0;
    timer->previous = 0;
    timer->interval = interval;
    timer->value = countdown != 0 ? countdown : interval;
    timer->queue = queue;
    timer->message = message;
    first = func_80068748(timer);
    if (D_8008F240->next == timer) {
        func_800686D4(first);
    }
    return 0;
}
