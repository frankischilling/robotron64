#ifndef ROBOTRON_RENDERER_GEOMETRY_INTERNAL_H
#define ROBOTRON_RENDERER_GEOMETRY_INTERNAL_H

#include "graphics_state_internal.h"

typedef struct RendererVertexColor {
    short position[3];
    unsigned short flags;
    short texture[2];
    unsigned char color[4];
} RendererVertexColor;

typedef struct RendererVertexNormal {
    short position[3];
    unsigned short flags;
    short texture[2];
    signed char normal[3];
    unsigned char alpha;
} RendererVertexNormal;

typedef union RendererVertex {
    RendererVertexColor color;
    RendererVertexNormal normal;
    unsigned long long alignment;
} RendererVertex;

/* Mesh polygons have a 36-byte stride and up to four indexed vertices. */
typedef struct RendererPolygon {
    unsigned char colorIndex;
    unsigned char vertexCount;
    unsigned char textureIndex;
    unsigned char textureCorners;
    short vertices[4];
    int colors[4];
    short normals[4];
} RendererPolygon;

typedef short RendererNormal[4];
typedef int RendererPosition[3];

typedef char RendererVertexMustBe16Bytes[sizeof(RendererVertex) == 16 ? 1 : -1];
typedef char RendererPolygonMustBe36Bytes[sizeof(RendererPolygon) == 36 ? 1 : -1];
typedef char RendererNormalMustBe8Bytes[sizeof(RendererNormal) == 8 ? 1 : -1];

extern RendererVertex D_800CDBD0[22000];
extern RendererPosition D_800CA5A0[];
extern int D_8007CDAC;
extern unsigned short D_8007D6D0[];
extern unsigned int D_800BF5E8;
extern int D_80123AD4;
extern int D_80123AD8;
extern int D_80123ADC;
extern unsigned char D_80123AE0;
extern int D_80123AE4;
extern int D_80123AF0;
extern int D_80123AF4;
extern int D_80123AF8;

void func_80043930(int index, short *normal);
void func_800439EC(int index, unsigned int color);
void func_80043AA0(int index, unsigned int color);
void func_80043B58(int index, unsigned int *color);
void func_80043C0C(int index, int u, int v);
void func_80043CB4(int index, int u, int v, int shift);
void func_80043D68(RendererPolygon *polygon);
void func_80043E80(RendererPolygon *polygon);
void func_80043EEC(RendererPolygon *polygon);
void func_8004417C(int light);
void func_800441D0(RendererPolygon *polygon);
void func_80044270(int *first, int *second, int *third);
void func_800443A0(int *first, int *second, int *third, int *fourth);
void func_800462DC(unsigned int address);
void func_800463E8(unsigned int address);
void func_80049AD8(unsigned short *palette);

#endif
