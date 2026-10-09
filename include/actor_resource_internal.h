#ifndef ROBOTRON_ACTOR_RESOURCE_INTERNAL_H
#define ROBOTRON_ACTOR_RESOURCE_INTERNAL_H

#include "actor.h"
#include "actor_resource_5c_internal.h"

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
    unsigned char unknown0C[4];
    short step10;
    unsigned char unknown12[6];
    short current18;
    short rate1A;
    unsigned char unknown1C[0xC];
    ActorAnimation *firstAnimation28;
    unsigned char unknown2C[0x34];
    int updateTime60;
    int arrivalDelay;
} ActorResource68Internal;

typedef struct ActorResource60Internal {
    unsigned char unknown00[0xA];
    ActorResourceFlags flags0A;
    unsigned char unknown0C[0x54];
} ActorResource60Internal;

/* The group loader steps by 96 bytes; the script command writes ten
 * integer parameters after its ten resource slots. */
typedef struct ActorGroupedResourceEntryInternal {
    TextGlyphResource resource;
    unsigned char unknown58[8];
} ActorGroupedResourceEntryInternal;

typedef struct ActorResourceGroupInternal {
    int count;
    ActorGroupedResourceEntryInternal resources[10];
    int parameters[10];
} ActorResourceGroupInternal;

typedef char ActorGroupedResourceEntryInternalMustBe96Bytes[
    sizeof(ActorGroupedResourceEntryInternal) == 0x60 ? 1 : -1];
typedef char ActorResourceGroupInternalMustBe1004Bytes[
    sizeof(ActorResourceGroupInternal) == 0x3EC ? 1 : -1];

typedef char ActorResource68InternalMustBe104Bytes[
    sizeof(ActorResource68Internal) == 0x68 ? 1 : -1];
typedef char ActorResource60InternalMustBe96Bytes[
    sizeof(ActorResource60Internal) == 0x60 ? 1 : -1];
typedef char ActorResource58InternalMustBe88Bytes[
    sizeof(ActorResource58Internal) == 0x58 ? 1 : -1];
typedef char ActorResourceWord04InternalMustBe4Bytes[
    sizeof(ActorResourceWord04Internal) == 4 ? 1 : -1];

extern TextGlyphResource D_800ACE58[8];
extern TextGlyphResource D_8009AFD8[4];
extern TextGlyphResource D_8009B138;
extern unsigned char D_800B6FC8[];
extern int D_800B0090;
extern int D_800AD118;
extern unsigned char D_800B2168[];
extern unsigned char D_800ACD8C[];
extern unsigned char D_8009AFC0[];

extern ActorResource68Internal D_800AF1F0[36];
extern ActorResource5CInternal D_800AC998[11];
extern ActorResource5CInternal D_8009AA00[16];
extern ActorResourceGroupInternal D_8009EA18[1];
extern int D_8009EE04;


extern int func_800391C0(int kind);
extern void func_800391F0(int kind, ActorAnimation *animation, int model,
                         int textureMap, int bitmap);
extern int func_8003C94C(int kind, int current, unsigned char *path, int identifier);
extern int func_8003CA24(int kind, int current, unsigned char *path);
extern int func_8003CA34(int current, unsigned char *path, int identifier);
extern void func_8001CE70(TextGlyphResource *resource, ActorAnimation *animation,
                         int reference);

extern unsigned char D_800906D0[8];
extern unsigned char D_800906D8[8];
extern unsigned char D_800906E0[8];
extern unsigned char D_800906E8[28];
extern unsigned char D_80090704[48];
extern unsigned char D_80090734[24];
extern unsigned char D_8009074C[8];
extern unsigned char D_80090754[12];
extern unsigned char D_80090760[8];
extern unsigned char D_80090768[8];
extern unsigned char D_80090770[12];
extern unsigned char D_8009077C[8];
extern unsigned char D_80090784[8];
extern unsigned char D_8009078C[28];

#endif
