#include "../../include/sdk_thread_internal.h"

int func_80062240(OSMesgQueue *queue, OSMesg *message, int flags)
{
    register unsigned int mask;
    register OSThread *thread;

    mask = func_80067560();
    while (queue->count == 0) {
        if (flags == 0) {
            func_80067580(mask);
            return -1;
        }
        D_8008F1B0->state = 8;
        func_8006707C(&queue->receivers);
    }
    if (message != 0) {
        *message = queue->messages[queue->first];
    }
    queue->first = (queue->first + 1) % queue->capacity;
    queue->count--;
    if (queue->senders->next != 0) {
        thread = func_800671C4(&queue->senders);
        osStartThread(thread);
    }
    func_80067580(mask);
    return 0;
}
