#include "../../include/sdk_thread_internal.h"

void func_800675A0(OSThread **queue, OSThread *thread);

void func_8006E4A0(OSThread *thread)
{
    register unsigned int mask;
    register OSThread *previous;
    register OSThread *next;

    mask = func_80067560();
    if (thread == 0) {
        thread = D_8008F1B0;
    } else if (thread->state != 1) {
        func_800675A0(thread->queue, thread);
    }
    if (D_8008F1AC == thread) {
        D_8008F1AC = D_8008F1AC->activeNext;
    } else {
        previous = D_8008F1AC;
        next = previous->activeNext;
        while (next != 0) {
            if (next == thread) {
                previous->activeNext = thread->activeNext;
                break;
            }
            previous = next;
            next = previous->activeNext;
        }
    }
    if (thread == D_8008F1B0) {
        func_800671D4();
    }
    func_80067580(mask);
}
