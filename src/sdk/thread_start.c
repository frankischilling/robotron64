#include "../../include/sdk_thread_internal.h"

void osStartThread(OSThread *thread)
{
    register unsigned int mask;

    mask = func_80067560();
    switch (thread->state) {
    case 8:
        thread->state = 2;
        func_8006717C(&D_8008F1A8, thread);
        break;
    case 1:
        if (thread->queue == 0 || thread->queue == &D_8008F1A8) {
            thread->state = 2;
            func_8006717C(&D_8008F1A8, thread);
        } else {
            thread->state = 8;
            func_8006717C(thread->queue, thread);
            func_8006717C(&D_8008F1A8, func_800671C4(thread->queue));
        }
        break;
    }
    if (D_8008F1B0 == 0) {
        func_800671D4();
    } else if (D_8008F1B0->priority < D_8008F1A8->priority) {
        D_8008F1B0->state = 2;
        func_8006707C(&D_8008F1A8);
    }
    func_80067580(mask);
}
