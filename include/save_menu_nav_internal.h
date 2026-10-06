#include "static_menu_internal.h"
#ifndef ROBOTRON_SAVE_MENU_NAV_INTERNAL_H
#define ROBOTRON_SAVE_MENU_NAV_INTERNAL_H

#include "actor.h"
#include "object.h"
#include "object_helpers.h"
#include "save_game.h"
#include "menu_label_internal.h"
#include "text.h"

typedef struct SaveMenuActorInternal {
    unsigned char unknown00[0xC];
    short objectIndex;
    short value0E;
    unsigned char unknown10[4];
    unsigned int flags14;
    unsigned char unknown18[9];
    unsigned char state21;
    unsigned char unknown22[2];
    TextGlyphResource *resource24;
    unsigned char unknown28[0x1C];
    void (*callback44)(struct SaveMenuActorInternal *actor);
} SaveMenuActorInternal;

typedef struct SaveMenuNodeInternal {
    unsigned int flags00;
    int textSlot04;
    unsigned char unknown08[8];
    int textSlot10;
    int selection14;
    struct SaveMenuNodeInternal *next18;
    unsigned char unknown1C[4];
    struct SaveMenuNodeInternal *child20;
    int sound24;
    unsigned char unknown28[4];
    int preview2C;
} SaveMenuNodeInternal;

typedef struct SaveMenuNavigationStateInternal {
    int timestamp00;
    SaveMenuNodeInternal *menu04;
    SaveMenuNodeInternal *previous08;
    SaveMenuNodeInternal *menu0C;
    int value10;
    unsigned char unknown14[8];
    SaveMenuActorInternal *previewActor1C;
    SaveMenuActorInternal *actor20;
    unsigned char unknown24[8];
    float cameraX2C;
    float cameraY30;
    float cameraZ34;
    int cameraAngleX38;
    int cameraAngleY3C;
    int cameraAngleZ40;
    unsigned char unknown44[4];
    int previewY48;
    unsigned char unknown4C[4];
    SaveMenuNodeInternal *selected50;
    int transition54;
    int restoreCamera58;
    int releasePreview5C;
    void (*callback60)(void);
} SaveMenuNavigationStateInternal;

typedef char SaveMenuNodeInternalMustBe48Bytes[
    sizeof(SaveMenuNodeInternal) == 0x30 ? 1 : -1];
typedef char SaveMenuNavigationStateInternalMustBe100Bytes[
    sizeof(SaveMenuNavigationStateInternal) == 0x64 ? 1 : -1];

extern SaveMenuNavigationStateInternal D_800AEE98;
extern int D_800AEEB4;
extern int D_800761F0;
extern int D_800761F4;
extern unsigned char D_80076D70[];
extern unsigned char D_80076F18[];
extern unsigned char *D_80076FBC;
extern unsigned char D_80077A8C[];
extern unsigned char D_80092BF4[];
extern TextGlyphResource D_800B2218;
extern float D_FLT_800938D0;

void func_80026178(void *menu, int mode);
int func_8003614C(int sound, int value, int enabled, int extra);
int func_8004CDE8(void);
void func_80039F10(float x, float y, float z);
void func_80039FCC(int x, int y, int z);

void func_80025D9C(SaveMenuActorInternal *actor);
void func_80025E68(SaveMenuActorInternal *actor);
void func_80025EF0(int x, int y, int z);
void func_80026044(void);
void func_8002606C(int restoreCamera, int releasePreview);

#endif
