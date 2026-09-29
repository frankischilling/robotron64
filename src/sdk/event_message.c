#include "../../include/scheduler.h"
#include "../../include/sdk_time.h"

typedef struct SdkEventMessage {
    OSMesgQueue *queue;
    OSMesg message;
} SdkEventMessage;

extern SdkEventMessage D_80195030[];

void osSetEventMesg(int event, OSMesgQueue *queue, OSMesg message)
{
    register unsigned int mask;
    SdkEventMessage *record;

    mask = func_80067560();
    record = &D_80195030[event];
    record->queue = queue;
    record->message = message;
    func_80067580(mask);
}
