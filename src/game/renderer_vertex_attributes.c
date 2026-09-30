#include "../../include/renderer_geometry_internal.h"

static const unsigned char D_80094F20[] = "TOO MANY VERTS %d MAX=%d %s %d\n";
static const unsigned char D_80094F40[] = "prims.c";
static const unsigned char D_80094F48[] = "TOO MANY VERTS %d MAX=%d %s %d\n";
static const unsigned char D_80094F68[] = "prims.c";
static const unsigned char D_80094F70[] = "TOO MANY VERTS %d MAX=%d %s %d\n";
static const unsigned char D_80094F90[] = "prims.c";
static const unsigned char D_80094F98[] = "TOO MANY VERTS %d MAX=%d %s %d\n";
static const unsigned char D_80094FB8[] = "prims.c";
static const unsigned char D_80094FC0[] = "TOO MANY VERTS %d MAX=%d %s %d\n";
static const unsigned char D_80094FE0[] = "prims.c";
static const unsigned char D_80094FE8[] = "TOO MANY VERTS %d MAX=%d %s %d\n";
static const unsigned char D_80095008[] = "prims.c";

void func_80043930(int index, short *normal)
{
    int base = D_80123AE4;
    int used = base + index - D_80123B20;
    RendererVertex *vertex;

    if (used > 10000) {
        func_800496E0((unsigned char *)D_80094F20, used, 10000, D_80094F40, 0x79);
    }
    vertex = &D_800CDBD0[base] + index;
    vertex->normal.normal[0] = normal[0] >> 8;
    vertex->normal.normal[1] = normal[1] >> 8;
    vertex->normal.normal[2] = normal[2] >> 8;
}

void func_800439EC(int index, unsigned int color)
{
    int base = D_80123AE4;
    int used = base + index - D_80123B20;
    RendererVertex *vertex;

    if (used > 10000) {
        func_800496E0((unsigned char *)D_80094F48, used, 10000, D_80094F68, 0x8B);
    }
    vertex = &D_800CDBD0[base] + index;
    vertex->color.color[0] = color & 0xFF;
    vertex->color.color[1] = (color >> 8) & 0xFF;
    vertex->color.color[2] = (color >> 16) & 0xFF;
    vertex->color.color[3] = 255;
}

void func_80043AA0(int index, unsigned int color)
{
    int base = D_80123AE4;
    int used = base + index - D_80123B20;
    RendererVertex *vertex;

    if (used > 10000) {
        func_800496E0((unsigned char *)D_80094F70, used, 10000, D_80094F90, 0x9F);
    }
    vertex = &D_800CDBD0[base] + index;
    vertex->color.color[0] = (color >> 24) & 0xFF;
    vertex->color.color[1] = (color >> 16) & 0xFF;
    vertex->color.color[2] = (color >> 8) & 0xFF;
    vertex->color.color[3] = 255;
}

void func_80043B58(int index, unsigned int *packedColor)
{
    unsigned int color;
    int base;
    int used;
    RendererVertex *vertex;

    base = D_80123AE4;
    color = *packedColor;
    used = base + index - D_80123B20;
    if (used > 10000) {
        func_800496E0((unsigned char *)D_80094F98, used, 10000, D_80094FB8, 0xB6);
    }
    vertex = &D_800CDBD0[base] + index;
    vertex->color.color[0] = (color >> 24) & 0xFF;
    vertex->color.color[1] = (color >> 16) & 0xFF;
    vertex->color.color[2] = (color >> 8) & 0xFF;
    vertex->color.color[3] = 255;
}

void func_80043C0C(int index, int u, int v)
{
    int base = D_80123AE4;
    int used = base + index - D_80123B20;
    RendererVertex *vertex;

    if (used > 10000) {
        func_800496E0((unsigned char *)D_80094FC0, used, 10000, D_80094FE0, 0xCC);
    }
    vertex = &D_800CDBD0[base] + index;
    vertex->color.texture[0] = u << 6;
    vertex->color.texture[1] = v << 6;
}

void func_80043CB4(int index, int u, int v, int shift)
{
    int base = D_80123AE4;
    int used = base + index - D_80123B20;
    RendererVertex *vertex;

    if (used > 10000) {
        func_800496E0((unsigned char *)D_80094FE8, used, 10000, D_80095008, 0xD7);
    }
    vertex = &D_800CDBD0[base] + index;
    vertex->color.texture[0] = u << shift;
    vertex->color.texture[1] = v << shift;
}
