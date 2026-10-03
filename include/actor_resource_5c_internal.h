#ifndef ROBOTRON_ACTOR_RESOURCE_5C_INTERNAL_H
#define ROBOTRON_ACTOR_RESOURCE_5C_INTERNAL_H

#include "actor.h"

typedef struct ActorResource5CInternal {
    unsigned char unknown00[6];
    ActorResourceFlags flags06;
    int speed;
    unsigned char unknown0C[0x4C];
    int value58;
} ActorResource5CInternal;

typedef char ActorResource5CInternalMustBe92Bytes[
    sizeof(ActorResource5CInternal) == 0x5C ? 1 : -1];

#endif
