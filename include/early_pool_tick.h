#ifndef ROBOTRON_EARLY_POOL_TICK_H
#define ROBOTRON_EARLY_POOL_TICK_H

/* Known prefix through offset 0x9C. The complete allocation is not claimed. */
typedef struct EarlyPoolTickState {
    int state00;
    int value04;
    unsigned char unknown08[0x90];
    int timer98;
    int start9C;
} EarlyPoolTickState;

typedef char EarlyPoolTickPrefixMustBe160Bytes[
    sizeof(EarlyPoolTickState) == 160 ? 1 : -1];

extern EarlyPoolTickState D_800AE300;

void func_8000D38C(void);
void func_8000D3E8(void);
void func_8000E328(void);
void func_8000E3B4(void);

#endif
