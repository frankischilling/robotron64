#include "../../include/renderer_geometry_internal.h"

static const unsigned char D_80095010[] = "TOO MANY VERTS %d MAX=%d %s %d\n";
static const unsigned char D_80095030[] = "prims.c";
static const unsigned char D_80095038[] = "TOO MANY VERTS %d MAX=%d %s %d\n";
static const unsigned char D_80095058[] = "prims.c";

void func_80044270(int *first, int *second, int *third)
{
    /* Unused local slots retained from the target stack layout. */
    int unused0;
    int base;
    int unused1;
    int used;

    base = D_80123AE4;

    used = base - D_80123B20 + 2;
    if (used > 10000) {
        func_800496E0((unsigned char *)D_80095010, used, 10000, D_80095030, 0x209);
    }
    D_80123B10++, D_80123B18++;
    {
        RendererVertex *vertices = &D_800CDBD0[base];
        vertices[0].color.position[0] = first[0];
        vertices[0].color.position[1] = first[1];
        vertices[0].color.position[2] = first[2];
        vertices[1].color.position[0] = second[0];
        vertices[1].color.position[1] = second[1];
        vertices[1].color.position[2] = second[2];
        vertices[2].color.position[0] = third[0];
        vertices[2].color.position[1] = third[1];
        vertices[2].color.position[2] = third[2];
    }
    D_80123AE4 += 3;
}

void func_800443A0(int *first, int *second, int *third, int *fourth)
{
    /* Unused local slots retained from the target stack layout. */
    int unused0;
    int base;
    int unused1;
    int used;

    base = D_80123AE4;

    D_80123B14++, D_80123B18++;
    used = base - D_80123B20 + 3;
    if (used > 10000) {
        func_800496E0((unsigned char *)D_80095038, used, 10000, D_80095058, 0x22C);
    }
    {
        RendererVertex *vertices = &D_800CDBD0[base];
        vertices[0].color.position[0] = first[0];
        vertices[0].color.position[1] = first[1];
        vertices[0].color.position[2] = first[2];
        vertices[1].color.position[0] = second[0];
        vertices[1].color.position[1] = second[1];
        vertices[1].color.position[2] = second[2];
        vertices[2].color.position[0] = third[0];
        vertices[2].color.position[1] = third[1];
        vertices[2].color.position[2] = third[2];
        vertices[3].color.position[0] = fourth[0];
        vertices[3].color.position[1] = fourth[1];
        vertices[3].color.position[2] = fourth[2];
    }
    D_80123AE4 += 4;
}
