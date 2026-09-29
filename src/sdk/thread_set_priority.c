#include "../../include/sdk_thread_internal.h"

void func_800675A0(OSThread **queue, OSThread *thread);

void osSetThreadPri(OSThread *thread, int priority)
{
    register unsigned int mask;

    mask = func_80067560();
    if (thread == 0) {
        thread = D_8008F1B0;
    }
    if (thread->priority != priority) {
        thread->priority = priority;
        if (thread != D_8008F1B0 && thread->state != 1) {
            func_800675A0(thread->queue, thread);
            func_8006717C(thread->queue, thread);
        }
        if (D_8008F1B0->priority < D_8008F1A8->priority) {
            D_8008F1B0->state = 2;
            func_8006707C(&D_8008F1A8);
        }
    }
    func_80067580(mask);
}
