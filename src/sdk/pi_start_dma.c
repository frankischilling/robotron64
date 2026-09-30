#include "../../include/sdk_pi_dma.h"

int func_80065840(SdkPiDmaMessage *message, int priority, int direction,
                  unsigned int cartridgeAddress, void *dramAddress,
                  unsigned int size, OSMesgQueue *returnQueue)
{
    register int result;
    register OSMesgQueue *queue;

    if (!D_8008E3D0) {
        return -1;
    }
    if (direction == 0) {
        message->type = 11;
    } else {
        message->type = 12;
    }
    message->priority = priority;
    message->returnQueue = returnQueue;
    message->dramAddress = dramAddress;
    message->cartridgeAddress = cartridgeAddress;
    message->size = size;
    message->handle = 0;
    if (priority == 1) {
        queue = func_8006B570();
        result = func_8006B420(queue, message, 0);
    } else {
        queue = func_8006B570();
        result = func_800635A0(queue, message, 0);
    }
    return result;
}
