#ifndef ROBOTRON_TWEAK_INTERNAL_H
#define ROBOTRON_TWEAK_INTERNAL_H

#include "actor_resource_internal.h"
#include "scene_definition.h"
#include "game_memory.h"

typedef struct TweakCommand {
    int opcode;
    int name;
    int value;
    int alternate;
} TweakCommand;

typedef struct TweakPage {
    short title;
    short firstVariable;
    short count;
} TweakPage;

typedef struct TweakVariable {
    short initialValue;
    short name;
    int *target;
} TweakVariable;

typedef struct TweakDifficulty {
    short variable;
    short easy;
    short hard;
} TweakDifficulty;

typedef char TweakPageMustBe6Bytes[sizeof(TweakPage) == 6 ? 1 : -1];
typedef char TweakVariableMustBe8Bytes[sizeof(TweakVariable) == 8 ? 1 : -1];
typedef char TweakDifficultyMustBe6Bytes[sizeof(TweakDifficulty) == 6 ? 1 : -1];

extern short D_8009F024;
extern short D_8009F026;
extern short D_8009F028;
extern short D_8009F02A;
extern short D_8009F02C;
extern int D_8009F558;
extern TweakVariable D_8009F030[150];
extern TweakPage D_8009F4E0[20];
extern TweakDifficulty D_8009FAE0[60];
extern int D_800AD300;
extern int D_800BA778;
extern int D_800781C0;

extern char D_80094350[];
extern char D_80094378[];
extern char D_8009439C[];
extern char D_800943B4[];
extern char D_800943D8[];
extern char D_800943F0[];
extern char D_80094420[];

void func_800360B8();
void func_800374D0(void);
void func_80037508(TweakCommand *command);
void func_80037588(TweakCommand *command);
void func_8003762C(TweakCommand *command);
void func_80037700(void);
void func_800377E4(void);
void func_800378CC(TweakCommand *command);
void func_8003799C(unsigned char *name, int *target);
void func_80037A20(void);
void func_80038228(void);
int func_800383F8(unsigned char *name);

#endif
