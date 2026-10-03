#ifndef ROBOTRON_EARLY_SESSION_STATE_H
#define ROBOTRON_EARLY_SESSION_STATE_H

#include "early_game_state.h"
#include "save_game.h"

typedef struct EarlySceneResourceRecord {
    int unknown00;
    unsigned char resource04[0x5C];
} EarlySceneResourceRecord;

typedef char EarlySceneResourceRecordMustBe96Bytes[
    sizeof(EarlySceneResourceRecord) == 0x60 ? 1 : -1];

typedef struct EarlyAnimationResetSlot {
    int value00;
    int threshold04;
    unsigned char enabled08;
    unsigned char value09;
    unsigned char unknown0A[2];
} EarlyAnimationResetSlot;

typedef struct EarlyAnimationChoiceSlot {
    int animation00;
    unsigned int weight04;
    unsigned char callback08;
    unsigned char value09;
    unsigned char unknown0A[2];
} EarlyAnimationChoiceSlot;

typedef union EarlyAnimationSlot {
    EarlyAnimationChoiceSlot choice;
    EarlyAnimationResetSlot reset;
} EarlyAnimationSlot;

typedef struct EarlyAnimationRecord {
    int sceneAnimation00;
    unsigned char unknown04[8];
    int animation0C;
    unsigned char unknown10[5];
    unsigned char value15;
    unsigned char unknown16[2];
    int initialAnimation18;
    unsigned char unknown1C[8];
    EarlyAnimationSlot movement24[6];
    EarlyAnimationSlot weighted6C[5];
    EarlyAnimationSlot resetA8[3];
} EarlyAnimationRecord;

typedef char EarlyAnimationResetSlotMustBe12Bytes[
    sizeof(EarlyAnimationResetSlot) == 0xC ? 1 : -1];

typedef char EarlyAnimationChoiceSlotMustBe12Bytes[
    sizeof(EarlyAnimationChoiceSlot) == 0xC ? 1 : -1];

typedef char EarlyAnimationSlotMustBe12Bytes[
    sizeof(EarlyAnimationSlot) == 0xC ? 1 : -1];

typedef char EarlyAnimationRecordMustBe204Bytes[
    sizeof(EarlyAnimationRecord) == 0xCC ? 1 : -1];

void func_8000E6F0(GameActor *actor);
void func_8000ECE4(EarlyGameActor *actor, int animation,
                   ActorBehaviorCallbackInternal callback, int timer, int value);
void func_8000EDE0(EarlyGameActor *actor);
void func_80010460(int enabled);

#endif
