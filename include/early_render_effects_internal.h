#ifndef ROBOTRON_EARLY_RENDER_EFFECTS_INTERNAL_H
#define ROBOTRON_EARLY_RENDER_EFFECTS_INTERNAL_H

#include "early_render_internal.h"
#include "renderer_draw_state_internal.h"
#include "renderer_primitives_internal.h"
#include "fixed_geometry.h"
#include "object_recovery.h"
#include "early_game_state.h"

extern int D_800730D8;
extern int D_800730DC;
extern int D_800730E0[8][3];

void func_8000B1E4(void);
void func_8000B5AC(void);
int func_8000B9D4(EarlyGameActor *actor, int mode);
int func_80047048(void);
int func_80047094(int count);
int func_8000A21C(int minimum, int maximum);

#endif
