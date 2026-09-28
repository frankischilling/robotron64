#ifndef ROBOTRON_TEXT_H
#define ROBOTRON_TEXT_H

#include "object.h"
#include "game_memory.h"

/* Recovered layouts; offset-based fields remain under investigation. */
typedef struct TextValue3 {
    unsigned int words[3];
} TextValue3;

typedef struct TextRecord {
    unsigned int active : 1;
    unsigned int flag30 : 1;
    unsigned int unkFlag : 1;
    signed int options : 18;
    unsigned int unkBits : 11;
    int unk04;
    int mode;
    int value0C;
    int value10;
    int value14;
    int value18;
    int value1C;
    int objectIndex20;
    unsigned char text[64];
    int property64;
    int scale[3];
    int length;
    short objects[60];
    int unkF0;
    TextValue3 valueF4;
    unsigned int sentinel[3];
} TextRecord;

/* Animation records are shared by text glyphs and live game actors. */
typedef struct ActorAnimation {
    short objectIndex;
    short field02;
    short track;
    short frameIndex;
    short field08;
    short loopIndex;
    short frameDuration;
    unsigned char sound;
    unsigned char soundMode;
} ActorAnimation;

typedef union ActorResourceFlags {
    short value;
    struct {
        short loaded : 1;
        unsigned short remaining : 15;
    } bits;
} ActorResourceFlags;

typedef struct TextGlyphResource {
    unsigned char unk00;
    unsigned char kind;
    unsigned char actorKind;
    unsigned char unknown03[3];
    ActorResourceFlags flags06;
    int speed;
    int scale;
    unsigned char unknown10[2];
    short field12;
    short field14;
    unsigned char unknown16[0x12];
    union {
        short *indices;
        ActorAnimation *tracks[10];
    } animation;
    short playbackSpeed;
    short unknown52;
    int field54;
} TextGlyphResource;

typedef char ActorResourceFlagsMustBe2Bytes[sizeof(ActorResourceFlags) == 2 ? 1 : -1];
typedef char TextGlyphResourceMustBe88Bytes[sizeof(TextGlyphResource) == 0x58 ? 1 : -1];

extern int D_80072B40[];
extern int D_80072BA8[];
extern TextRecord D_800B6FF8[30];
extern TextGlyphResource D_800B1BE8[];
extern char D_8008F620[];
extern void func_8001C0D0(char *format, ...);
extern int func_8003921C(int kind, int value, int enabled, TextGlyphResource *resource);
extern int func_80039E1C(int object, int value);
extern int func_8003947C(int object, int index);
extern void func_80039DCC(int object, int value);
extern int func_80039E0C(int object, int mode);
extern void func_80039E5C(int object, int value);
extern void func_80039E80(int object, int value);
extern char D_8008F64C[];
extern int func_800392F4(int object);
extern int D_8009EFA4;

unsigned int func_80000450(unsigned int value);
int func_80000460(int enabled, unsigned char character);
unsigned char *func_80000518(unsigned char *text);
unsigned char *func_80000568(unsigned char *text);
void func_800005A4(unsigned char *text);
void func_800005E0(void);
int func_8000060C(int character);
int func_80000750(int character, int scale, int mode, int object);
int func_80000918(unsigned char *text, int scale, int mode, int options);
void func_80000ACC(int *slot);
void func_80000B7C(int slot, int set, int clear);
int func_80000E74(int slot);
void func_80000EB4(int slot, TextValue3 *value);
int func_80000F08(int slot);

void func_80000F48(int slot, unsigned char *text);
int func_800011AC(int *slot, unsigned char *text, int scale, int mode, int replace, int options);

int func_80001270(int slot, int offset, unsigned char *text);
void func_80001360(void);

typedef struct TextRunProperty {
    short run;
    unsigned char unknown;
    unsigned char value;
} TextRunProperty;
int func_800013D0(int slot, TextRunProperty *properties);
int func_800014FC(int slot, TextRunProperty *properties);
void func_80001638(int slot, int value);

void func_800016D8(int *values, int unused);

#endif
