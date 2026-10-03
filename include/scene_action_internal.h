#ifndef ROBOTRON_SCENE_ACTION_INTERNAL_H
#define ROBOTRON_SCENE_ACTION_INTERNAL_H

#include "early_game_state.h"
#include "scene_player_runtime_internal.h"

extern int D_80073A40;
extern int D_8007BB18;
extern int D_80097644;
extern int D_8009EFA0;
extern int D_800AD280;
extern int D_8009E57C;
extern int D_800AD30C;
extern int D_8009E574;
extern unsigned char *D_80076FF4;
extern unsigned char D_80076FB4[];
extern unsigned char D_80076E44[];
extern int D_80097640;
extern int D_800AD288;
extern int D_800AD284;
extern int D_800BAE8C;
extern int D_8009D118;
extern TextGlyphResource D_8009AFD8[];

void func_80022528(int level, int mode, int extra);
void func_800278AC(int first, int second, void (*callback)(void));
int func_8003614C(int sound, int value, int enabled, int extra);
void func_80026178(void *menu, int mode);
void func_8001B8D8(int *selection, ScenePlayerRuntime *player);

#endif
