#ifndef ROBOTRON_SAVE_MENU_LEGACY_INTERNAL_H
#define ROBOTRON_SAVE_MENU_LEGACY_INTERNAL_H

#include "save_game.h"

extern int D_80075FC4;
extern int D_800761F4;
extern int D_800AD15C;
extern int D_800AD28C;
extern int D_800AD288;
extern int D_800BB128;

extern unsigned char D_80076230[];
extern unsigned char D_8007628C[];
extern unsigned char D_800762E8[];
extern unsigned char D_8007683C[];
extern unsigned char D_80076D70[];
extern unsigned char D_80076E44[];
extern unsigned char D_8007751C[];
extern unsigned char D_80092BD0[];
extern unsigned char D_80092BD8[];
extern unsigned char D_80092BDC[];
extern unsigned char D_80092BE4[];
extern unsigned char D_80092BE8[];

void func_8001A1F0(GameSessionState *state);
void func_8001DF94(int first, int second);
void func_8002606C(int restoreCamera, int releasePreview);
void func_80026178(void *menu, int mode);
int func_800267BC(void);
void func_8002674C(void);
void func_80026A10(int value);
void func_80030A80(int unused);
void func_80030C3C(int unused);
int func_8004FA14(int slot);

#endif
