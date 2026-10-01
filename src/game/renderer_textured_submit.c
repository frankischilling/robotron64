#include "../../include/renderer_primitives_internal.h"

short D_8007CDB0[4][2] = {
    {0, 0},
    {0, 1984},
    {1984, 1984},
    {1984, 0}
};

static const unsigned char D_800950B0[] = "TOO MANY VERTS %d MAX=%d %s %d\n";
static const unsigned char D_800950D0[] = "prims.c";
static const unsigned char D_800950D8[] = "TOO MANY VERTS %d MAX=%d %s %d\n";
static const unsigned char D_800950F8[] = "prims.c";

void func_80044B18(int *first, int *second, int *third, int *fourth)
{
    int index;
    int base;
    int corner;
    RendererVertex *vertices;
    int used;

    base = D_80123AE4;
    used = base - D_80123B20 + 3;
    if (used > 10000) {
        func_800496E0((unsigned char *)D_800950B0, used, 10000, D_800950D0, 0x2EA);
    }
    D_80123B14++, D_80123B18++;
    for (index = 0; index < 4; index++) {
        corner = D_80123AE0;
        D_800CDBD0[base + index].color.texture[0] = D_8007CDB0[corner & 3][0];
        D_800CDBD0[base + index].color.texture[1] = D_8007CDB0[corner & 3][1];
        D_80123AE0 = corner >> 2;
    }
    vertices = &D_800CDBD0[base];
    D_800CDBD0[base + 0].color.position[0] = first[0];
    D_800CDBD0[base + 0].color.position[1] = first[1];
    D_800CDBD0[base + 0].color.position[2] = first[2];
    D_800CDBD0[base + 1].color.position[0] = second[0];
    D_800CDBD0[base + 1].color.position[1] = second[1];
    D_800CDBD0[base + 1].color.position[2] = second[2];
    D_800CDBD0[base + 2].color.position[0] = third[0];
    D_800CDBD0[base + 2].color.position[1] = third[1];
    D_800CDBD0[base + 2].color.position[2] = third[2];
    D_800CDBD0[base + 3].color.position[0] = fourth[0];
    D_800CDBD0[base + 3].color.position[1] = fourth[1];
    D_800CDBD0[base + 3].color.position[2] = fourth[2];
    D_800CDBD0[base + 0].color.color[3] = D_80123AE8;
    D_800CDBD0[base + 1].color.color[3] = D_80123AE8;
    D_800CDBD0[base + 2].color.color[3] = D_80123AE8;
    D_800CDBD0[base + 3].color.color[3] = D_80123AE8;
    FRAME_COMMAND(0x0400103F, vertices);
    RENDERER_QUAD(0, 1, 2, 3);
    D_80123AE4 += 4;
}

void func_80044D84(int *first, int *second, int *third)
{
    int index;
    int base;
    int corner;
    RendererVertex *vertices;
    int used;

    base = D_80123AE4;
    used = base - D_80123B20 + 2;
    if (used > 10000) {
        func_800496E0((unsigned char *)D_800950D8, used, 10000, D_800950F8, 0x31E);
    }
    D_80123B10++, D_80123B18++;
    for (index = 0; index < 3; index++) {
        corner = D_80123AE0;
        D_800CDBD0[base + index].color.texture[0] = D_8007CDB0[corner & 3][0];
        D_800CDBD0[base + index].color.texture[1] = D_8007CDB0[corner & 3][1];
        D_80123AE0 = corner >> 2;
    }
    vertices = &D_800CDBD0[base];
    D_800CDBD0[base + 0].color.position[0] = first[0];
    D_800CDBD0[base + 0].color.position[1] = first[1];
    D_800CDBD0[base + 0].color.position[2] = first[2];
    D_800CDBD0[base + 1].color.position[0] = second[0];
    D_800CDBD0[base + 1].color.position[1] = second[1];
    D_800CDBD0[base + 1].color.position[2] = second[2];
    D_800CDBD0[base + 2].color.position[0] = third[0];
    D_800CDBD0[base + 2].color.position[1] = third[1];
    D_800CDBD0[base + 2].color.position[2] = third[2];
    D_800CDBD0[base + 0].color.color[3] = D_80123AE8;
    D_800CDBD0[base + 1].color.color[3] = D_80123AE8;
    D_800CDBD0[base + 2].color.color[3] = D_80123AE8;
    FRAME_COMMAND(0x04000C2F, vertices);
    FRAME_COMMAND(0xBF000000, 0x00000204);
    D_80123AE4 += 3;
}
