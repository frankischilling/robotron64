#include "../../include/sdk_thread_internal.h"

void osCreateThread(OSThread *thread, int id, void (*entry)(void *),
                    void *argument, void *stack, int priority)
{
    register unsigned int mask;
    unsigned int interruptMask;

    thread->id = id;
    thread->priority = priority;
    thread->next = 0;
    thread->queue = 0;
    thread->context.pc = (unsigned int)entry;
    thread->context.a0 = (long long)(int)argument;
    thread->context.sp = (long long)(int)stack - 16;
    thread->context.ra = (long long)(int)func_80067350;
    interruptMask = 0x003FFF01;
    thread->context.status = 0xFF03;
    thread->context.rcpMask = (interruptMask & 0x003F0000) >> 16;
    thread->context.fpcsr = 0x01000800;
    thread->fpUsed = 0;
    thread->state = 1;
    thread->flags = 0;
    mask = func_80067560();
    thread->activeNext = D_8008F1AC;
    D_8008F1AC = thread;
    func_80067580(mask);
}
