#ifndef ROBOTRON_RENDERER_SETUP_INTERNAL_H
#define ROBOTRON_RENDERER_SETUP_INTERNAL_H

#include "frame.h"
#include "sdk_camera.h"

typedef union SdkViewport {
    struct {
        short scale[4];
        short translation[4];
    } values;
    long long alignment;
} SdkViewport;

typedef union SdkAmbient {
    struct {
        unsigned char color[3];
        char padding03;
        unsigned char colorCopy[3];
        char padding07;
    } value;
    long long alignment;
} SdkAmbient;

typedef char SdkViewportMustBe16Bytes[sizeof(SdkViewport) == 16 ? 1 : -1];
typedef char SdkAmbientMustBe8Bytes[sizeof(SdkAmbient) == 8 ? 1 : -1];

extern const SdkViewport D_8007CAC8;
extern const SdkAmbient D_8007CB00;
extern const SdkLight D_8007CB08;
extern const FrameCommand D_8007C5C0[6];
extern const FrameCommand D_8007C5F0[7];
extern const FrameCommand D_8007C628[7];
extern const FrameCommand D_8007C660[7];
extern const FrameCommand D_8007C698[7];
extern const FrameCommand D_8007C6D0[6];
extern const FrameCommand D_8007C700[7];
extern const FrameCommand D_8007C738[7];
extern const FrameCommand D_8007CA70[11];
extern const FrameCommand D_8007CB18[8];
extern const FrameCommand D_8007CB58[16];

#define RENDERER_SETUP_COMMAND(first, second) { { (first), (unsigned long)(second) } }

#endif
