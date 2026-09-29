#include "../../include/sdk_thread_internal.h"

void osCreateMesgQueue(OSMesgQueue *queue, OSMesg *messages, int capacity)
{
    queue->receivers = (OSThread *)&D_8008F1A0;
    queue->senders = (OSThread *)&D_8008F1A0;
    queue->count = 0;
    queue->first = 0;
    queue->capacity = capacity;
    queue->messages = messages;
}
