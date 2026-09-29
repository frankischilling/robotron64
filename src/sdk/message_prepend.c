#include "../../include/sdk_thread_internal.h"

int func_8006B420(OSMesgQueue *queue, OSMesg message, int flags)
{
    register unsigned int mask;
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
    queue->first = (queue->first + queue->capacity - 1) % queue->capacity;
    queue->messages[queue->first] = message;
    queue->count++;
    if (queue->receivers->next != 0) {
        thread = func_800671C4(&queue->receivers);
        osStartThread(thread);
    }
    func_80067580(mask);
    return 0;
}
