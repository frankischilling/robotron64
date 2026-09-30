#ifndef ROBOTRON_SESSION_SETUP_INTERNAL_H
#define ROBOTRON_SESSION_SETUP_INTERNAL_H

#include "text.h"

typedef struct SessionSetupCommand {
    int opcode;
    int argument0;
    int argument1;
    int argument2;
    int argument3;
    int argument4;
} SessionSetupCommand;

typedef struct SessionSetupPair {
    int first;
    int second;
} SessionSetupPair;

typedef union SessionSetupValue58 {
    int word;
    struct {
        short high;
        short low;
    } halves;
    SessionSetupPair pair;
} SessionSetupValue58;

typedef union SessionSetupFlags {
    struct {
        short value04;
        short value06;
    } fields;
    struct {
        unsigned int high : 16;
        signed int loaded : 1;
        signed int defined : 1;
        signed int flag13 : 1;
        signed int states : 13;
    } bits;
} SessionSetupFlags;

typedef struct SessionSetupKinemation {
    short name;
    short loopIndex;
    short duration;
    unsigned char sound;
    unsigned char soundMode;
} SessionSetupKinemation;

typedef union SessionSetupAnimation {
    ActorAnimation playback;
    struct {
        short objectIndex;
        short field02;
        short track;
        short frameIndex;
        SessionSetupKinemation kinemation;
    } setup;
} SessionSetupAnimation;

struct GameActor;
typedef void (*SessionActorInitializer)(struct GameActor *actor, int state);

typedef struct SessionSetupRecord {
    unsigned char type;
    unsigned char definitionIndex;
    unsigned char variant;
    unsigned char unknown03;
    SessionSetupFlags flags04;
    int value08;
    int value0C;
    short value10;
    short value12;
    short value14;
    short value16;
    short unknown18;
    short value1A;
    short unknown1C;
    short value1E;
    short unknown20;
    short value22;
    short unknown24;
    short value26;
    SessionSetupAnimation *entries[10];
    short value50;
    short unknown52;
    SessionActorInitializer initializeActor;
    SessionSetupValue58 value58;
    int value60;
    int value64;
} SessionSetupRecord;

typedef char SessionSetupFlagsMustBe4Bytes[sizeof(SessionSetupFlags) == 4 ? 1 : -1];
typedef char SessionSetupKinemationMustBe8Bytes[sizeof(SessionSetupKinemation) == 8 ? 1 : -1];
typedef char SessionSetupAnimationMustBe16Bytes[sizeof(SessionSetupAnimation) == 16 ? 1 : -1];
typedef char SessionSetupRecordMustBe104Bytes[sizeof(SessionSetupRecord) == 0x68 ? 1 : -1];

extern SessionSetupRecord *D_80077AD0;
extern int D_80077AD8;
extern int D_8009EFB4;
extern int D_800AD12C;
extern int D_800AD130;
extern int D_800AD134;
extern int D_800AD15C;
extern int D_800AD280;
extern int D_800AD28C;
extern int D_800BB148;
extern int D_800AD118;
extern int D_800AC970;
extern int D_80077AD4;
extern int D_800BB144;
extern int D_80075A18;
extern int D_80075954[];
extern int D_800A4578;
extern SessionSetupAnimation D_800AA710[];
extern SessionSetupAnimation D_800A4538[4];

extern unsigned char D_80093D18[];
extern unsigned char D_80093D48[];
extern unsigned char D_80093D7C[];
extern unsigned char D_80093DA0[];
extern char D_80093D20[];
extern char D_80093D50[];
extern char D_80093D84[];
extern char D_80093DA8[];
extern char D_80093DD4[];
extern char D_80093DFC[];
extern char D_80093E1C[];
extern char D_80093E38[];
extern char D_80093E60[];
extern char D_80093E94[];

void func_8001C49C(unsigned char *format, ...);
unsigned char *func_800383C4(int identifier);

void func_8002E65C(SessionSetupCommand *command);
void func_8002ECC4(SessionSetupCommand *command);
void func_8002ECEC(SessionSetupCommand *command);
void func_8002ED00(SessionSetupCommand *command);
void func_8002ED3C(SessionSetupCommand *command);
void func_8002ED50(SessionSetupCommand *command);
void func_8002ED78(SessionSetupCommand *command);
void func_8002ED9C(SessionSetupCommand *command);
void func_8002EDB0(SessionSetupCommand *command);
void func_8002EE24(SessionSetupCommand *command);
void func_8002EE38(SessionSetupCommand *command);
void func_8002EFC4(SessionSetupCommand *command);
void func_8002EFD8(SessionSetupCommand *command);
void func_8002F088(SessionSetupCommand *command);
void func_8002F098(SessionSetupCommand *command);
void func_8002F100(SessionSetupCommand *command);
void func_8002F128(SessionSetupCommand *command);
void func_8002F1A4(SessionSetupCommand *command);
void func_8002F1DC(SessionSetupCommand *command);
void func_8002F23C(SessionSetupCommand *command);
void func_8002F29C(SessionSetupCommand *command);
void func_8002F334(SessionSetupCommand *command);
void func_8002F414(SessionSetupCommand *command);
void func_8002F450(SessionSetupCommand *command);
void func_8002F464(SessionSetupCommand *command);
void func_8002F49C(SessionSetupCommand *command);
void func_8002F4B0(SessionSetupCommand *command);
void func_8002F85C(void);
void func_8002F980(void);

#endif
