#ifndef ROBOTRON_SAVE_MENU_INTERNAL_H
#define ROBOTRON_SAVE_MENU_INTERNAL_H

#include "save_game.h"

extern int D_80076EC0;
extern int D_800AF1E0;
extern unsigned char D_80076E44[];

void func_80026178(void *menu, int mode);
int func_8003614C(int sound, int value, int enabled, int extra);
void func_80051680(int value, int mode, int enabled);
void func_80051854(int value);
void func_80051888(int value);

void func_80030DC0(int *selection);
void func_80030EAC(int *selection);
void func_80030F20(int *selection);
void func_80030F50(int *selection);
void func_80030F94(int *selection);
void func_80030FB8(int *selection);
int func_80030FEC(int value);
int func_80031034(int character);

#endif
