#ifndef ROBOTRON_RENDERER_RESOURCE_LOADER_H
#define ROBOTRON_RENDERER_RESOURCE_LOADER_H

#include "resource_bridge_internal.h"
#include "object_recovery.h"

/* Prefix views; callers index the base with separate 20/16/8-byte strides. */
typedef struct RendererModelCacheView {
    unsigned char unknown00[16];
    ObjectRecoveryDatFile *data;
    unsigned char loaded;
    unsigned char unknown15;
    short identifier;
} RendererModelCacheView;

typedef struct RendererAnimationCacheView {
    unsigned char unknown00[0x1F50];
    ObjectRecoveryDatPoint *data;
    int pointCount;
    int frameCount;
    unsigned char loaded;
    unsigned char unknown1F5D;
    short identifier;
} RendererAnimationCacheView;

typedef struct RendererBitmapCacheView {
    unsigned char unknown00[0x3850];
    void *data;
    unsigned char loaded;
    unsigned char unknown3855;
    short identifier;
} RendererBitmapCacheView;

typedef struct RendererAnimationFilePrefix {
    short pointCount;
    short frameCount;
    unsigned char unknown04[4];
} RendererAnimationFilePrefix;

typedef char RendererAnimationFilePrefixMustBe8Bytes[
    sizeof(RendererAnimationFilePrefix) == 8 ? 1 : -1];
typedef char RendererModelCacheViewMustBe24Bytes[
    sizeof(RendererModelCacheView) == 24 ? 1 : -1];
typedef char RendererAnimationCacheViewMustBe8032Bytes[
    sizeof(RendererAnimationCacheView) == 0x1F60 ? 1 : -1];
typedef char RendererBitmapCacheViewMustBe14424Bytes[
    sizeof(RendererBitmapCacheView) == 0x3858 ? 1 : -1];

extern int D_8008D360;
extern int D_8008D364;
extern int D_8008D368;

extern const unsigned char D_80095530[];
extern const unsigned char D_80095540[];
extern const unsigned char D_80095564[];
extern const unsigned char D_80095570[];
extern const unsigned char D_8009557C[];
extern const unsigned char D_8009559C[];
extern const unsigned char D_800955A8[];
extern const unsigned char D_800955B8[];
extern const unsigned char D_800955D8[];

#endif
