#include "../../../../include/audio_synthesis_internal.h"

AudioPoolState D_801901E0;
AudioDmaBuffer *D_801901EC;
unsigned int D_801901F0;
unsigned int D_801901F4;
unsigned int D_801901F8;
unsigned int D_801901FC;
SdkAudioVoice *D_80190200;
unsigned char *D_80190204;
OSMesgQueue D_80190208;
SdkPiDmaMessage *D_80190220;
OSMesg *D_80190224;
OSMesgQueue D_80190228;
OSMesg D_80190240[8];

unsigned int D_8008D828 = 24;
unsigned int D_8008D82C = 32;
unsigned int D_8008D830 = 2048;
unsigned int D_8008D834 = 80;
unsigned int D_8008D838 = 1;
int D_8008D83C = 24;
int D_8008D840 = 48;
