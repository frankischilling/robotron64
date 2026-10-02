#ifndef ROBOTRON_RENDERER_RESOURCE_STORAGE_H
#define ROBOTRON_RENDERER_RESOURCE_STORAGE_H

#include "object_recovery.h"

typedef struct RendererModelCacheRecord {
    ObjectRecoveryDatFile *data;
    unsigned char loaded;
    unsigned char unknown05;
    short identifier;
    unsigned int flags;
    unsigned char unknown0C[8];
} RendererModelCacheRecord;

typedef struct RendererAnimationCacheRecord {
    ObjectRecoveryDatPoint *data;
    int pointCount;
    int frameCount;
    unsigned char loaded;
    unsigned char unknown0D;
    short identifier;
} RendererAnimationCacheRecord;

typedef char RendererModelCacheRecordMustBe20Bytes[
    sizeof(RendererModelCacheRecord) == 20 ? 1 : -1];
typedef char RendererAnimationCacheRecordMustBe16Bytes[
    sizeof(RendererAnimationCacheRecord) == 16 ? 1 : -1];

extern RendererModelCacheRecord D_80078284[400];
extern RendererAnimationCacheRecord D_8007A1C4[400];

#endif
