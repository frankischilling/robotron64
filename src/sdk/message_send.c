#include "../../include/sdk_thread_internal.h"

int func_800635A0(OSMesgQueue *queue, OSMesg message, int flags)
{
    register unsigned int mask;
    register int index;
    register OSThread *thread;

    mask = func_80067560();
    while (queue->count >= queue->capacity) {
        if (flags == 1) {
            D_8008F1B0->state = 8;
            func_8006707C(&queue->senders);
        } else {
            func_80067580(mask);
            return -1;
        }
    }
    index = (queue->first + queue->count) % queue->capacity;
    queue->messages[index] = message;
    queue->count++;
    if (queue->receivers->next != 0) {
        thread = func_800671C4(&queue->receivers);
        osStartThread(thread);
    }
    func_80067580(mask);
    return 0;
}
