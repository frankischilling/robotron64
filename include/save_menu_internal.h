#ifndef ROBOTRON_SAVE_MENU_INTERNAL_H
#define ROBOTRON_SAVE_MENU_INTERNAL_H

#include "save_game.h"

typedef struct SaveMenuContinueCode {
    unsigned int checksum : 3;
    unsigned int value18 : 15;
    unsigned int option08 : 3;
    unsigned int option0C : 4;
    unsigned int value1C : 7;
    unsigned int level : 8;
    unsigned int unused : 24;
} SaveMenuContinueCode;

typedef char SaveMenuContinueCodeMustBe8Bytes[
    sizeof(SaveMenuContinueCode) == 8 ? 1 : -1];

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

int func_80031080(GamePlayerState *player, unsigned char *text);
void func_800312B0(GamePlayerState *player, unsigned char *text);

#endif
