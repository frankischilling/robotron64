#ifndef ROBOTRON_SCENE_COMMANDS_INTERNAL_H
#define ROBOTRON_SCENE_COMMANDS_INTERNAL_H

#include "actor.h"
#include "scene_definition.h"
#include "save_game.h"
#include "scene_audio.h"
#include "game_memory.h"
#include "platform_services.h"

typedef struct SceneCommand {
    int opcode;
    int arguments[8];
} SceneCommand;

typedef struct SceneFileBoundary {
    int startLevel;
    int name;
} SceneFileBoundary;

extern SceneFileBoundary D_800A42B0[80];
extern int D_800A4530;
extern int D_800B00B0;
extern int D_800B14A4;
extern int D_800BA784;
extern int D_800BA764;
extern int D_800BAE98;
extern int D_8009EFB4;
extern char D_8009176C[];
extern char D_8009178C[];
extern char D_800917A8[];
extern char D_800917F8[28];
extern unsigned char D_80091814[32];

unsigned char *func_800383C4(int identifier);
void func_8002A808(GameActor *actor, int state);
int func_8004CDE8(void);
void func_80031C44(int first, int second);

GameActor *func_8001F240(TextGlyphResource *resource, int *position);
void func_8001F2B4(void);
void func_8001F2C0(int first, int second);
void func_8001F2CC(unsigned char *path, int mode);
int func_8001F2D8(int level);
void func_8001F350(SceneCommand *command);
void func_8001F3C4(SceneCommand *command);
void func_8001F3FC(SceneCommand *command);
void func_8001F468(SceneCommand *command);
void func_8001F478(SceneCommand *command);
void func_8001F494(SceneCommand *command);
void func_8001F4B8(SceneCommand *command);
void func_8001F4DC(SceneCommand *command);
void func_8001F55C(SceneCommand *command);
void func_8001F56C(SceneCommand *command);
void func_8001F574(SceneCommand *command);
void func_8001F57C(SceneCommand *command);
void func_8001F584(SceneCommand *command);
void func_8001F58C(SceneCommand *command);
void func_8001F5B4(SceneCommand *command);
void func_8001F6AC(SceneCommand *command);
void func_8001F6FC(SceneCommand *command);
void func_8001F744(SceneCommand *command);
void func_8001F794(SceneCommand *command);
void func_8001F7E4(SceneCommand *command);
void func_8001F7EC(SceneCommand *command);
void func_8001F7F4(SceneCommand *command);
void func_8001F7FC(SceneCommand *command);
void func_8001F868(SceneCommand *command);
void func_8001F87C(void);
void func_8001FCE4(int replace, int category, int resourceIndex,
                  int trigger, int delay, unsigned int count, int x, int y);

void func_80021C3C(int *output, int enabled);

#endif
