#ifndef ROBOTRON_AUDIO_CALLBACKS_H
#define ROBOTRON_AUDIO_CALLBACKS_H

typedef struct AudioSynth AudioSynth;

typedef int (*AudioDmaCallback)(int deviceAddress, int length, void *state);
typedef int (*AudioCallback)(void *argument);

typedef struct AudioDmaBuffer {
    struct AudioDmaBuffer *next;
    struct AudioDmaBuffer *previous;
    unsigned int deviceAddress;
    unsigned int lastFrame;
    unsigned char *data;
} AudioDmaBuffer;

typedef struct AudioPoolState {
    unsigned char initialized;
    AudioDmaBuffer *active;
    AudioDmaBuffer *free;
} AudioPoolState;

typedef struct AudioCallbackState {
    struct AudioCallbackState *next;
    void *argument;
    AudioCallback callback;
    int fieldC;
    int field10;
} AudioCallbackState;

typedef char AudioDmaBufferMustBe20Bytes[sizeof(AudioDmaBuffer) == 20 ? 1 : -1];
typedef char AudioPoolStateMustBe12Bytes[sizeof(AudioPoolState) == 12 ? 1 : -1];
typedef char AudioCallbackStateMustBe20Bytes[sizeof(AudioCallbackState) == 20 ? 1 : -1];

extern AudioPoolState D_801901E0;
extern AudioDmaBuffer *D_801901EC;
extern AudioCallbackState D_80190260;
extern void *D_80190274;
extern AudioSynth *D_8008F160;
extern AudioSynth D_80190194;

int func_80052378(int deviceAddress, int length, void *state);
AudioDmaCallback func_8005254C(void);
void func_800526D0(void);
void func_80052700(void);
int func_80052754(void *argument);
void func_80058A58(void);
void func_80065B04(AudioSynth *synth);
void func_80066310(AudioSynth *owner, AudioCallbackState *state);

#endif
