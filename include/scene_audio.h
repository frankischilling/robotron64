#ifndef ROBOTRON_SCENE_AUDIO_H
#define ROBOTRON_SCENE_AUDIO_H

/* The retail diagnostics identify this request as background-image state. */
typedef struct SceneBackgroundRequest {
    short resource;
    short flags;
    short scrolling;
    short field06;
    int mode;
    short field0C;
} SceneBackgroundRequest;

extern SceneBackgroundRequest D_800B8F68;

void func_8001F8E8(int resource, int flags, int mode, int field0C, int scrolling);
void func_8001F90C(void);

#endif
