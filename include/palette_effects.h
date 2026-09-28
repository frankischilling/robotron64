#ifndef ROBOTRON_PALETTE_EFFECTS_H
#define ROBOTRON_PALETTE_EFFECTS_H

#include "palette.h"

#define PALETTE_EFFECT_COLOR_COUNT 256
#define PALETTE_TRANSITION_COUNT 100
#define PALETTE_FADE_LIMIT 102400

typedef struct PaletteTransition {
    unsigned short paletteIndex : 8;
    unsigned short active : 1;
    unsigned short mode : 7;
    unsigned short unknown02;
    int step;
    int first;
    int second;
    int position;
    int phase;
    int startRed;
    int startGreen;
    int startBlue;
    int endRed;
    int endGreen;
    int endBlue;
    PaletteColor original;
} PaletteTransition;

typedef struct PaletteTransitionConfig {
    int paletteIndex;
    int first;
    int second;
    int mode;
    int phase;
    int step;
} PaletteTransitionConfig;

typedef struct PaletteTransitionRange {
    int first;
    int count;
} PaletteTransitionRange;

typedef char PaletteTransitionMustBe52Bytes[sizeof(PaletteTransition) == 0x34 ? 1 : -1];
typedef char PaletteTransitionConfigMustBe24Bytes[sizeof(PaletteTransitionConfig) == 0x18 ? 1 : -1];
typedef char PaletteTransitionRangeMustBe8Bytes[sizeof(PaletteTransitionRange) == 8 ? 1 : -1];

extern PaletteColor D_80075990;
extern int D_80077C20[];
extern PaletteColor D_8009CD18[PALETTE_EFFECT_COLOR_COUNT];
extern PaletteTransition D_8009D120[PALETTE_TRANSITION_COUNT];
extern PaletteColor D_8009E570;
extern int D_8009E578;
extern int D_8009E580;
extern int D_8009EF94;
extern PaletteColor D_800BB230[];
extern PaletteTransitionConfig D_800BBAC8[];
extern PaletteTransitionRange D_800BEE58[];
extern int D_800BEF48;
extern int D_800BEF4C;

void func_80031564(void);
void func_80031570(int duration);
void func_800315E4(int duration);
int func_80031658(PaletteColor *color, int position, int step);
int func_800316AC(void);
void func_80031B28(int paletteIndex, int first, int second, int mode, int phase, int step);
void func_80031C10(void);
void func_80031C44(int range, int releaseMode);
void func_80031ECC(void);
void func_8003237C(int *command);
void func_800323D4(int *command);
void func_80032434(int *command);
void func_80046EA8(int index, int red, int green, int blue);

#endif
