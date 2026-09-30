#ifndef ROBOTRON_EARLY_SESSION_STATE_H
#define ROBOTRON_EARLY_SESSION_STATE_H

#include "early_game_state.h"
#include "save_game.h"

typedef struct EarlyAnimationRecord {
    unsigned char unknown00[0xC];
    int animation0C;
    unsigned char unknown10[5];
    unsigned char value15;
    unsigned char unknown16[0xB6];
} EarlyAnimationRecord;

typedef char EarlyAnimationRecordMustBe204Bytes[
    sizeof(EarlyAnimationRecord) == 0xCC ? 1 : -1];

void func_8000E6F0(GameActor *actor);
void func_8000ECE4(EarlyGameActor *actor, int animation,
                   ActorBehaviorCallbackInternal callback, int timer, int value);
void func_8000EDE0(EarlyGameActor *actor);
void func_80010460(int enabled);

#endif
