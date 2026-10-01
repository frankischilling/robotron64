#ifndef ROBOTRON_EARLY_POOL_TICK_H
#define ROBOTRON_EARLY_POOL_TICK_H

typedef struct EarlyPoolResetPair {
    int index;
    int value;
} EarlyPoolResetPair;

/* Known prefix through offset 0x1F0. The complete allocation is not claimed. */
typedef struct EarlyPoolTickState {
    int state00;
    int value04;
    unsigned char unknown08[0x90];
    int timer98;
    int start9C;
    int frameA0;
    EarlyPoolResetPair groupsA4[9][4];
    int indices1C4[10];
    int enabled1EC;
    int sentinel1F0;
} EarlyPoolTickState;

typedef char EarlyPoolResetPairMustBe8Bytes[
    sizeof(EarlyPoolResetPair) == 8 ? 1 : -1];
typedef char EarlyPoolTickPrefixMustBe500Bytes[
    sizeof(EarlyPoolTickState) == 500 ? 1 : -1];

extern EarlyPoolTickState D_800AE300;

void func_8000D38C(void);
void func_8000D3E8(void);
void func_8000D4F8(void);
void func_8000E328(void);
void func_8000E3B4(void);

#endif
