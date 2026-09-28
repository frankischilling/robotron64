#ifndef ROBOTRON_RESOURCE_BRIDGE_INTERNAL_H
#define ROBOTRON_RESOURCE_BRIDGE_INTERNAL_H

#include "actor_resource_internal.h"
#include "object_runtime.h"

/* Prefix views are indexed by the target's separate record strides. */
typedef struct ResourceBridgeModelView {
    unsigned char unknown00[0x14];
    unsigned char loaded;
    unsigned char unknown15;
    short identifier;
} ResourceBridgeModelView;

typedef struct ResourceBridgeAnimationView {
    unsigned char unknown00[0x1F5C];
    unsigned char loaded;
    unsigned char unknown1F5D;
    short identifier;
} ResourceBridgeAnimationView;

typedef struct ResourceBridgeBitmapView {
    unsigned char unknown00[0x3854];
    unsigned char loaded;
    unsigned char unknown3855;
    short identifier;
} ResourceBridgeBitmapView;

extern short D_800C8E00[1000];
extern short D_800C95D0[1000];
extern short D_800C9DA0[1000];
extern int D_80078264;
extern int D_80078268;
extern int D_8007826C;
extern int D_8007BB0C;
extern int D_8007BB10;
extern int D_8007BB14;

void func_8004BD00(int model, int animation, int bitmap);
int func_8003CB10(int kind, int current, unsigned char *path, int identifier);

#endif
