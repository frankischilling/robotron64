#include "../../include/scheduler.h"

extern OSThread *D_8008F1B0;

int func_80067890(OSThread *thread)
{
    if (!thread) {
        thread = D_8008F1B0;
    }
    return thread->priority;
}
