#include "../../include/sdk_thread_internal.h"
#include "../../include/sdk_events.h"

void func_8006E3AC(void)
{
    SdkEventMessage *event;
    OSMesgQueue *queue;
    int index;
    register OSThread *thread;

    event = &D_80195030[8];
    queue = event->queue;
    if (queue != 0) {
        if (queue->count >= queue->capacity) {
            goto done;
        }
        index = (queue->first + queue->count) % queue->capacity;
        queue->messages[index] = event->message;
        queue->count++;
        if (queue->receivers->next != 0) {
            thread = func_800671C4(&queue->receivers);
            func_8006717C(&D_8008F1A8, thread);
        }
    }
done:;
}
