#ifndef ROBOTRON_EARLY_GAME_MEDIUM_H
#define ROBOTRON_EARLY_GAME_MEDIUM_H

#include "early_game_state.h"

typedef struct EarlyPointerState {
    int unknown00;
    int value04;
    void *entry08;
} EarlyPointerState;

typedef char EarlyPointerStateMustBe12Bytes[
    sizeof(EarlyPointerState) == 0xC ? 1 : -1];

int func_80017C10(EarlyGameActor *actor, EarlyGameActor *other,
                  int unused2, int unused3);
void func_8001A170(EarlyPointerState *state, int index, int value);
int func_8001BC38(int mask);

#endif
