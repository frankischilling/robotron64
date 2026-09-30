#ifndef ROBOTRON_ACTOR_POSITION_PAIRS_H
#define ROBOTRON_ACTOR_POSITION_PAIRS_H

#include "early_game_state.h"

typedef struct ActorPositionPair {
    EarlyGameActor *follower;
    EarlyGameActor *source;
} ActorPositionPair;

typedef char ActorPositionPairMustBe8Bytes[
    sizeof(ActorPositionPair) == 8 ? 1 : -1];

extern ActorPositionPair D_800A4580[20];
int func_80027A10(EarlyGameActor *follower, EarlyGameActor *source);

#endif
