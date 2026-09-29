#include "../../include/sdk_timers.h"

SdkTime func_80068748(SdkTimer *timer)
{
    SdkTimer *next;
    SdkTime value;
    unsigned int mask;

    mask = func_80067560();
    for (next = D_8008F240->next, value = timer->value;
         next != D_8008F240 && value > next->value; next = next->next) {
        value -= next->value;
    }
    timer->value = value;
    if (next != D_8008F240) {
        next->value -= value;
    }
    timer->next = next;
    timer->previous = next->previous;
    next->previous->next = timer;
    next->previous = timer;
    func_80067580(mask);
    return value;
}
