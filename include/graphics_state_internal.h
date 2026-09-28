#ifndef ROBOTRON_GRAPHICS_STATE_INTERNAL_H
#define ROBOTRON_GRAPHICS_STATE_INTERNAL_H

#include "frame.h"
#include "heap.h"
#include "rom_files.h"
#include "debug_output.h"

/* The renderer uses the 16-byte, doubleword-aligned directional-light format. */
typedef union GraphicsLight {
    struct {
        unsigned char color[3];
        unsigned char reserved03;
        unsigned char colorCopy[3];
        unsigned char reserved07;
        signed char direction[3];
        unsigned char reserved0B;
    } values;
    unsigned long long alignment[2];
} GraphicsLight;

/* Only the tile origin at the end of this renderer-state prefix is known. */
typedef struct GraphicsTileState {
    unsigned char unknown000[0x180];
    int tileX;
    int tileY;
} GraphicsTileState;

typedef int GraphicsFrameCounters[8];

#define GRAPHICS_FIELD(value, shift, width) \
    ((unsigned int)(((unsigned int)(value) & ((1 << (width)) - 1)) << (shift)))

typedef char GraphicsLightMustBe16Bytes[sizeof(GraphicsLight) == 16 ? 1 : -1];
typedef char GraphicsTilePrefixMustBe188Bytes[sizeof(GraphicsTileState) == 0x188 ? 1 : -1];
typedef char GraphicsFrameCountersMustBe32Bytes[sizeof(GraphicsFrameCounters) == 32 ? 1 : -1];

extern void *D_80123AEC;
extern void *D_8013823C;
extern FrameCommand D_8007D5E8[];
extern FrameCommand D_8007C970[];
extern int D_8007BF34[];
extern GraphicsLight D_80123B28[];
extern int D_8007D5D8;
extern int D_8007D5DC;
extern int D_8007D5E0;
extern int D_8007D5E4;
extern int D_8007D6A8;
extern int D_800BEF60;
extern int D_800BF2C0;
extern int D_800BF2C4;
extern int D_800C85B8;
extern int D_80123AE8;
extern int D_80123B00;
extern int D_80123B04;
extern int D_80123B08;
extern int D_80123B0C;
extern int D_80123B10;
extern int D_80123B14;
extern int D_80123B18;
extern int D_80123B1C;
extern int D_80123B20;
extern int D_80126B28;
extern GraphicsFrameCounters D_80126B30;
/* The arena cursor and bounds are stored as 32-bit byte addresses. */
extern unsigned int D_80126B74;
extern unsigned int D_80126B78;
extern unsigned int D_80126B7C;
extern int D_80126B80;
extern int D_80126B84;

void func_800420B0(void);
void func_80046608(void);
void func_80046650(void);
void func_800466E4(void);
void func_80046774(void);
void func_80046800(void);
void func_8004688C(void);
void func_80046954(void);
void func_80046A20(void);
void func_80046AD0(void);
void func_80046B44(void);
void func_80046BB8(void);
void func_80046C2C(void);
void func_80046CF8(int unused, int index);
void func_80046DD0(int index);
void func_80046EA8(int index, int red, int green, int blue);
void func_8004729C(int mode);
void func_80049BAC(void);
void func_8004ABC8(void);
void func_8004BC44(void);

#endif
