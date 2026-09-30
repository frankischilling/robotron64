#ifndef ROBOTRON_ACTOR_SETUP_INTERNAL_H
#define ROBOTRON_ACTOR_SETUP_INTERNAL_H

#include "actor_resource_internal.h"
#include "scene_definition.h"
#include "actor_dynamic_pool_internal.h"

typedef SceneResourceState ActorSetupStateInternal;

typedef union ActorSetupOptionFlagsInternal {
    signed char value;
    unsigned char raw;
    struct {
        unsigned char high : 1;
        unsigned char mode : 3;
        unsigned char low : 4;
    } bits;
} ActorSetupOptionFlagsInternal;

typedef struct ActorSetupOptionsInternal {
    unsigned char unknown00[0x12];
    ActorSetupOptionFlagsInternal flags12;
} ActorSetupOptionsInternal;

typedef struct ActorSetupRequestViewInternal {
    unsigned char unknown00[0x46];
    unsigned char resourceIndex46;
    unsigned char type47;
    unsigned char unknown48[2];
    short value4A;
} ActorSetupRequestViewInternal;

typedef struct ActorSetupChainEntryInternal {
    unsigned char unknown00[8];
    int actorResourceIndex;
    unsigned char unknown0C[8];
    int extraResourceIndex;
    unsigned char unknown18[4];
} ActorSetupChainEntryInternal;

typedef struct ActorSetupGroupedResourcesInternal {
    int count;
    unsigned char resources[10][0x60];
    unsigned char unknown3C4[0x28];
} ActorSetupGroupedResourcesInternal;

typedef struct ActorSetupTextEntryInternal {
    int formatValue;
    unsigned char formatData[0xC];
    int textSlot;
} ActorSetupTextEntryInternal;

typedef struct ActorSetupTextLayoutInternal {
    int count;
    int unknown04;
    int baseX;
    int baseZ;
    int height;
    int stepX;
    int stepZ;
} ActorSetupTextLayoutInternal;

typedef char ActorSetupChainEntryInternalMustBe28Bytes[
    sizeof(ActorSetupChainEntryInternal) == 0x1C ? 1 : -1];
typedef char ActorSetupGroupedResourcesInternalMustBe1004Bytes[
    sizeof(ActorSetupGroupedResourcesInternal) == 0x3EC ? 1 : -1];
typedef char ActorSetupTextEntryInternalMustBe20Bytes[
    sizeof(ActorSetupTextEntryInternal) == 0x14 ? 1 : -1];
typedef char ActorSetupTextLayoutInternalMustBe28Bytes[
    sizeof(ActorSetupTextLayoutInternal) == 0x1C ? 1 : -1];

extern short D_800B8F74;
extern short D_800B8F7C;
extern unsigned char D_80074AA4[];
extern unsigned char D_80074ACC[];
extern int D_800AD2C8[2];
extern ActorSetupOptionsInternal D_800AD2D8;
extern int D_80074A20;
extern int D_80073598;
extern ActorSetupChainEntryInternal D_80073590[];
extern int D_800BA740;

extern TextGlyphResource D_800B5658[];
extern TextGlyphResource D_800B59C8[];
extern TextGlyphResource D_800B3D40[];
extern TextGlyphResource D_800B4630[];
extern TextGlyphResource D_800B28F8;
extern TextGlyphResource D_800B4F20;
extern TextGlyphResource D_800B4F78;
extern TextGlyphResource D_800B3030;
extern TextGlyphResource D_800B3AD8;
extern TextGlyphResource D_800B3B30;
extern TextGlyphResource D_800B3B88;
extern TextGlyphResource D_800B3BE0;
extern TextGlyphResource D_800B6788;
extern TextGlyphResource D_800B3C38;
extern TextGlyphResource D_800B3C90;
extern TextGlyphResource D_800B3CE8;
extern TextGlyphResource D_800B2FD8;
extern TextGlyphResource D_800B1F58[];
extern TextGlyphResource D_800B2110[];
extern TextGlyphResource D_800B2270;
extern TextGlyphResource D_800B23D0;
extern TextGlyphResource D_800B2428;
extern TextGlyphResource D_800B2480;
extern TextGlyphResource D_800B26E8;
extern TextGlyphResource D_800B2740;
extern TextGlyphResource D_800B27F0;
extern TextGlyphResource D_800B4D10;

extern TextGlyphResource D_8009B030;
extern TextGlyphResource D_8009B088;
extern TextGlyphResource D_8009B0E0;
extern TextGlyphResource D_8009F560[];
extern TextGlyphResource D_8009F878;
extern TextGlyphResource D_8009F8D0;
extern TextGlyphResource D_8009F928;
extern TextGlyphResource D_8009F9D8;

extern ActorAnimation D_800A4538[4];
extern ActorAnimation D_800A4558[];
extern unsigned char D_8009AFC0[];
extern unsigned char D_8009AFC8[];

extern ActorResource68Internal D_800AFF58;
extern ActorResource68Internal D_800AFFC0;
extern unsigned char D_800907A8[];

extern void func_80036670(void);

#endif
