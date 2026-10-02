#ifndef ROBOTRON_SOUND_BRIDGE_INTERNAL_H
#define ROBOTRON_SOUND_BRIDGE_INTERNAL_H

#include "destination_format.h"

#include "actor.h"

typedef struct SoundDefinition {
    int value00;
    int value04;
    int value08;
    int platformFlag;
    int value10;
} SoundDefinition;

typedef struct SoundDefinitionCommand {
    int opcode;
    int index;
    int value00;
    int value04;
    int value08;
    int value10;
    int platformFlag;
} SoundDefinitionCommand;

typedef union FutureSoundFlags {
    struct {
        signed int active : 1;
        unsigned int unknown : 31;
    } bits;
    int value;
} FutureSoundFlags;

typedef struct FutureSound {
    FutureSoundFlags flags;
    int sound;
    int mode;
    int value;
    int extra;
    unsigned int startTime;
    unsigned int delay;
} FutureSound;

typedef char SoundDefinitionMustBe20Bytes[sizeof(SoundDefinition) == 0x14 ? 1 : -1];
typedef char FutureSoundMustBe28Bytes[sizeof(FutureSound) == 0x1C ? 1 : -1];

extern int D_8007394C;
extern int D_8009EFA0;
extern int D_8009EFB4;
extern int D_800BEF6C;
extern SoundDefinition D_800AE568[117];
extern FutureSound D_800BEF70[15];
extern FutureSound D_800BF114[];

void func_8001C2C4(unsigned char *format, ...);
void func_800515B0(int index, int unused);

int func_80036064(GameActor *actor, int fallback);
void func_800360A0(void);
int func_800360A8(int value);
void func_800360B0(void);
int func_800360B8(unsigned char *label);
void func_800360C4(int enabled);
void func_800360F0(SoundDefinitionCommand *command);
void func_80036138(int value);
int func_8003614C(int sound, int mode, int value, int extra);
int func_800361FC(void);
int func_80036288(int sound, int mode, int value, int extra, unsigned int delay);
int func_80036318(void);


#endif
