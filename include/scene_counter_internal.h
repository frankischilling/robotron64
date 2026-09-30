#ifndef ROBOTRON_SCENE_COUNTER_INTERNAL_H
#define ROBOTRON_SCENE_COUNTER_INTERNAL_H

#include "early_game_state.h"

/* Shared prefix used by score buckets and bonus creation, not a full player. */
typedef struct SceneBucketCounter {
    unsigned char unknown00[6];
    unsigned char count06;
    unsigned char unknown07;
    EarlyGameActor *actor08;
    unsigned char unknown0C[0xC];
    int value18;
    int value1C;
} SceneBucketCounter;

typedef char SceneBucketCounterPrefixMustBe32Bytes[
    sizeof(SceneBucketCounter) == 32 ? 1 : -1];

extern int D_800AE2FC;

void func_80037050(int amount, SceneBucketCounter *counter);
int func_80037144(int amount, SceneBucketCounter *counter);

#endif
