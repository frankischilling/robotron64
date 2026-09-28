#ifndef ROBOTRON_SCENE_AUDIO_H
#define ROBOTRON_SCENE_AUDIO_H

typedef struct SceneAudioRequest {
    short first;
    short second;
    short field04;
    short field06;
    int duration;
    short field0C;
} SceneAudioRequest;

extern SceneAudioRequest D_800B8F68;

void func_8001F8E8(int first, int second, int duration, int mode, int extra);
void func_8001F90C(void);

#endif
