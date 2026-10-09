#ifndef ROBOTRON_RENDERER_PRIMITIVES_INTERNAL_H
#define ROBOTRON_RENDERER_PRIMITIVES_INTERNAL_H

#include "renderer_geometry_internal.h"
#include "palette.h"

/* The first 24 bytes shared by the mesh submission callers. */
typedef struct RendererMeshPrefix {
    unsigned int value00;
    int vertexCount;
    RendererNormal *normals;
    unsigned int value0C;
    RendererPolygon *polygons;
    int polygonCount;
} RendererMeshPrefix;

typedef char RendererMeshPrefixMustBe24Bytes[
    sizeof(RendererMeshPrefix) == 24 ? 1 : -1];

extern short D_800736D0[4][2];
extern short D_8007CDB0[4][2];
extern int D_8007CDC0;
extern int D_800BF90C;

#define RENDERER_SET_POSITION(vertex, input) { \
    (vertex).color.position[0] = (input)[0]; \
    (vertex).color.position[1] = (input)[1]; \
    (vertex).color.position[2] = (input)[2]; \
}

#define RENDERER_SET_EXPANDED_POSITION(vertex, input, offsetX, offsetZ) { \
    (vertex).color.position[0] = (input)[0] + (offsetX); \
    (vertex).color.position[1] = (input)[1]; \
    (vertex).color.position[2] = (input)[2] + (offsetZ); \
}

#define RENDERER_TRIANGLE_WORD(first, second, third) \
    (GRAPHICS_FIELD((first) * 2, 16, 8) | \
     GRAPHICS_FIELD((second) * 2, 8, 8) | \
     GRAPHICS_FIELD((third) * 2, 0, 8))

/* The game's caller supplies the first index as the triangle rotation flag. */
#define RENDERER_TRIANGLE(first, second, third) { \
    FrameCommand *command = D_80138254++; \
    command->words.w0 = 0xBF000000; \
    command->words.w1 = (first) == 0 ? \
        RENDERER_TRIANGLE_WORD(first, second, third) : ((first) == 1 ? \
        RENDERER_TRIANGLE_WORD(second, third, first) : \
        RENDERER_TRIANGLE_WORD(third, first, second)); \
}

#define RENDERER_QUAD(first, second, third, fourth) \
    FRAME_COMMAND(RENDERER_TRIANGLE_WORD(second, third, fourth) | 0xB1000000, \
                  RENDERER_TRIANGLE_WORD(second, fourth, first))

void func_80044F60(int *first, int *second, int *third, int *fourth);
void func_80045214(int *first, int *second, int *third, int *fourth);

void func_80045534(RendererMeshPrefix *mesh, RendererPosition *positions);

int func_80045A08(short *commands, RendererMeshPrefix *mesh, int destination);

void func_80045F40(int first, int count, int destination);
void func_800460D8(int first, int count, int destination, RendererNormal *normals);

#endif
