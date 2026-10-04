#ifndef ROBOTRON_AUDIO_SYNTHESIS_INTERNAL_H
#define ROBOTRON_AUDIO_SYNTHESIS_INTERNAL_H

#include "audio_runtime.h"
#include "sdk_audio.h"
#include "sdk_pi_dma.h"

extern OSMesgQueue D_80190228;
extern OSMesg D_80190240[8];
extern int D_8008D83C;
extern int D_8008D840;
extern unsigned int D_8008D828;
extern unsigned int D_8008D82C;
extern unsigned int D_8008D830;
extern unsigned int D_8008D834;
extern unsigned int D_8008D838;
extern unsigned int D_801901F0;
extern unsigned int D_801901F4;
extern unsigned int D_801901F8;
extern unsigned int D_801901FC;
extern SdkAudioVoice *D_80190200;
extern unsigned char *D_80190204;
extern OSMesgQueue D_80190208;
extern SdkPiDmaMessage *D_80190220;
extern OSMesg *D_80190224;
extern const float D_80095CC0;

void func_80051C00(SdkAudioSynthConfig *configuration, AudioSettings *settings);
void func_8005AD50(unsigned int rate);
void func_8005AD88(int value);
int func_80065950(unsigned int frequency);

#endif
