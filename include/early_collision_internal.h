#ifndef ROBOTRON_EARLY_COLLISION_INTERNAL_H
#define ROBOTRON_EARLY_COLLISION_INTERNAL_H

#include "early_game_state.h"

/* Only these two signed halfwords are interpreted by the distance helper. */
typedef struct CollisionDistanceResource {
    unsigned char unknown00[0x16];
    short value16;
    unsigned char unknown18[0x38];
    short playbackSpeed;
} CollisionDistanceResource;

typedef char CollisionDistanceResourcePrefixMustBe84Bytes[
    sizeof(CollisionDistanceResource) == 0x54 ? 1 : -1];

int func_80015020(EarlyGameActor *first, EarlyGameActor *second,
                  int *firstPosition, int *secondPosition, int *distance);

#endif
