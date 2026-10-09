#include "control_setup_internal.h"
#include "static_menu_internal.h"
#ifndef ROBOTRON_SESSION_MENU_INTERNAL_H
#define ROBOTRON_SESSION_MENU_INTERNAL_H

#include "actor.h"
#include "save_game.h"
#include "scene_audio.h"
#include "frame.h"
#include "platform_services.h"
#include "audio_game.h"

typedef struct SessionMenuPreview {
    int position[3];
    int firstResource;
    int secondResource;
    GameActor *firstActor;
    GameActor *secondActor;
} SessionMenuPreview;

typedef char SessionMenuPreviewMustBe28Bytes[
    sizeof(SessionMenuPreview) == 0x1C ? 1 : -1];

extern SessionMenuPreview D_80077AE0[2];
extern int D_80077B18;
extern int D_80077B1C;
extern int D_80073888;
extern int D_80073890;
extern int D_8009EF94;
extern int D_800BB150;
extern int D_800BB154;
extern int D_800B8F64;
extern int D_8009CD10;
extern int D_8009CD0C;
extern int D_800AD168;
extern int D_800AD28C;
extern int D_800AEE90;
extern int D_800AEE94;
extern int *D_80076FC8;
extern unsigned char D_80077054[];
extern unsigned char D_800773C4[];
extern unsigned char D_80093F90[];

void func_80022528(int level, int mode, int extra);
void func_80022B78(void);
void func_80025C40(int *selection);
void func_80026178(void *menu, int mode);
int func_8003614C(int sound, int value, int enabled, int extra);
int func_80039E3C(int object);
void func_8001F2CC(unsigned char *path, int mode);

void func_8002F4D0(int *selection);
void func_8002F4EC(void);
void func_8002F638(int *selection);
void func_8002F79C(int *selection);
void func_8002F7C8(int *selection);
void func_8002F804(void);
void func_8002F864(void);
void func_8002F8A4(void);
void func_8002F8D0(void);
void func_8002F930(int *selection);
void func_8002F980(void);
void func_8002F9A4(int *selection);
void func_8002F9D4(void);
void func_8002FA34(int *selection);
void func_8002FA70(void);
void func_8002FA9C(int *selection);
void func_8002FAE0(int *selection);
void func_8002FB30(int *selection);
void func_8002FB54(int *selection);
void func_8002FC08(int *selection);
void func_8002FC44(int *selection);
void func_8002FC70(int *selection);
void func_8002FC9C(int *selection);
void func_8002FD20(int *selection);
void func_8002FD44(int refreshSelection);

#endif
