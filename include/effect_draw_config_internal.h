#ifndef ROBOTRON_EFFECT_DRAW_CONFIG_INTERNAL_H
#define ROBOTRON_EFFECT_DRAW_CONFIG_INTERNAL_H

#include "early_game_state.h"

typedef struct EffectDrawConfig {
    int frame;
    int frameDelta;
    int scale;
    int scaleDelta;
    int height;
    int flag;
    int flagDelta;
    int billboard;
    unsigned short *palette;
    EarlyGameActorResource *resource;
} EffectDrawConfig;

typedef char EffectDrawConfigMustBe40Bytes[
    sizeof(EffectDrawConfig) == 40 ? 1 : -1];

extern EffectDrawConfig D_80072C00[31];

#endif
