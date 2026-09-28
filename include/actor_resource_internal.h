#ifndef ROBOTRON_ACTOR_RESOURCE_INTERNAL_H
#define ROBOTRON_ACTOR_RESOURCE_INTERNAL_H

#include "actor.h"

typedef union ActorResourceWord04Internal {
    struct {
        unsigned short unknown04;
        ActorResourceFlags flags06;
    } fields;
    struct {
        unsigned int unknownHigh : 17;
        unsigned int defined : 1;
        unsigned int unknownLow : 14;
    } bits;
} ActorResourceWord04Internal;

typedef struct ActorResource58Internal {
    unsigned char unk00;
    unsigned char kind;
    unsigned char actorKind;
    unsigned char unknown03;
    ActorResourceWord04Internal word04;
    int speed;
    int scale;
    unsigned char unknown10[0xC];
    short modelHandle1C;
    short modelName1E;
    short textureMapHandle20;
    short textureMapName22;
    short bitmapHandle24;
    short bitmapName26;
    ActorAnimation *animations[10];
    short playbackSpeed;
    short unknown52;
    int field54;
} ActorResource58Internal;

typedef struct ActorResource68Internal {
    unsigned char unknown00[6];
    ActorResourceFlags flags06;
    int speed;
    unsigned char unknown0C[0x58];
    int arrivalDelay;
} ActorResource68Internal;

typedef struct ActorResource5CInternal {
    unsigned char unknown00[6];
    ActorResourceFlags flags06;
    int speed;
    unsigned char unknown0C[0x4C];
    int value58;
} ActorResource5CInternal;

typedef struct ActorResource60Internal {
    unsigned char unknown00[0xA];
    ActorResourceFlags flags0A;
    unsigned char unknown0C[0x54];
} ActorResource60Internal;

typedef char ActorResource68InternalMustBe104Bytes[
    sizeof(ActorResource68Internal) == 0x68 ? 1 : -1];
typedef char ActorResource5CInternalMustBe92Bytes[
    sizeof(ActorResource5CInternal) == 0x5C ? 1 : -1];
typedef char ActorResource60InternalMustBe96Bytes[
    sizeof(ActorResource60Internal) == 0x60 ? 1 : -1];
typedef char ActorResource58InternalMustBe88Bytes[
    sizeof(ActorResource58Internal) == 0x58 ? 1 : -1];
typedef char ActorResourceWord04InternalMustBe4Bytes[
    sizeof(ActorResourceWord04Internal) == 4 ? 1 : -1];

extern TextGlyphResource D_800ACE58[];
extern TextGlyphResource D_8009AFD8[];
extern TextGlyphResource D_8009B138;
extern unsigned char D_800B6FC8[];
extern unsigned char D_800B0090[];
extern int D_800AD118;
extern unsigned char D_800B2168[];
extern unsigned char D_800ACD8C[];
extern unsigned char D_8009AFC0[];

extern ActorResource68Internal D_800AF1F0[];
extern ActorResource5CInternal D_800AC998[];
extern ActorResource5CInternal D_8009AA00[];
extern ActorResource60Internal D_8009EA18[];

extern unsigned char D_80090704[];
extern unsigned char D_80090734[];
extern unsigned char D_8009074C[];
extern unsigned char D_80090754[];
extern unsigned char D_80090760[];
extern unsigned char D_80090768[];
extern unsigned char D_80090770[];
extern unsigned char D_8009077C[];
extern unsigned char D_80090784[];
extern unsigned char D_8009078C[];

extern int func_800391C0(int kind);
extern void func_800391F0(int kind, ActorAnimation *animation, int model,
                         int textureMap, int bitmap);
extern int func_8003C94C(int kind, int current, unsigned char *path, int identifier);
extern int func_8003CA24(int kind, int current, unsigned char *path);
extern int func_8003CA34(int current, unsigned char *path, int identifier);
extern void func_8001CE70(TextGlyphResource *resource, ActorAnimation *animation,
                         int reference);

#endif
