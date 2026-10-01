#ifndef ROBOTRON_EARLY_INPUT_INTERNAL_H
#define ROBOTRON_EARLY_INPUT_INTERNAL_H

#include "save_game.h"
#include "controller_input.h"

/* Input processing uses this prefix of the existing session state. */
typedef struct EarlyPlayerInputState {
    int flags00;
    int port04;
    int value08;
    int pressed0C;
    int buttons10;
    int previous14;
    int sequence18;
    int held1C;
    int pressed20;
} EarlyPlayerInputState;

typedef struct EarlyPlayerCounters {
    short values[14];
    short timers[14];
} EarlyPlayerCounters;

typedef struct EarlyInputSequence {
    int unknown00;
    int unknown04;
    int unknown08;
    int unknown0C;
    int unknown10;
    int length;
    short *buttons;
} EarlyInputSequence;

typedef char EarlyInputSequenceMustBe28Bytes[
    sizeof(EarlyInputSequence) == 0x1C ? 1 : -1];
typedef char EarlyPlayerCountersMustBe56Bytes[
    sizeof(EarlyPlayerCounters) == 0x38 ? 1 : -1];
typedef char EarlyPlayerInputPrefixMustBe36Bytes[
    sizeof(EarlyPlayerInputState) == 0x24 ? 1 : -1];

extern EarlyPlayerCounters D_8009E9E0;
extern EarlyInputSequence D_8009EE08[14];
extern int D_80097648;
extern int D_8009764C;
extern unsigned int D_8009EF9C;

int func_8001BFB0(EarlyPlayerInputState *state);
void func_8001BF48(int *state);
void func_8001A1F0(GameSessionState *session);

#endif
