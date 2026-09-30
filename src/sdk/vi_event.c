#include "../../include/sdk_video_internal.h"

void osViSetEvent(OSMesgQueue *queue, OSMesg message, unsigned int retraces)
{
    register unsigned int mask;

    mask = func_80067560();
    D_8008F234->queue = queue;
    D_8008F234->message = message;
    D_8008F234->retraces = retraces;
    func_80067580(mask);
}
