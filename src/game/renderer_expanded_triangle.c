#include "../../include/renderer_primitives_internal.h"

typedef struct RendererExpansionPosition {
    int x;
    int y;
    int z;
} RendererExpansionPosition;

static const unsigned char D_80095060[] = "TOO MANY VERTS %d MAX=%d %s %d\n";
static const unsigned char D_80095080[] = "prims.c";

void func_800444F8(int *first, int *second, int *third)
{
    RendererExpansionPosition center;
    RendererExpansionPosition offset;
    int index;
    int base;
    int corner;
    RendererVertex *vertices;
    int used;

    base = D_80123AE4;
    used = base - D_80123B20 + 2;
    if (used > 10000) {
        func_800496E0((unsigned char *)D_80095060, used, 10000, D_80095080, 0x252);
    }
    D_80123B10++, D_80123B18++;
    for (index = 0; index < 3; index++) {
        corner = D_80123AE0;
        D_800CDBD0[base + index].color.texture[0] = D_8007CDB0[corner & 3][0];
        D_800CDBD0[base + index].color.texture[1] = D_8007CDB0[corner & 3][1];
        D_80123AE0 = corner >> 2;
    }
    center.x = (second[0] + third[0] + first[0]) / 3;
    center.z = (second[2] + third[2] + first[2]) / 3;
    offset.x = 0;
    offset.z = 0;
    if (D_800BF90C == 0) {
        offset.x = ((center.x * 4) * D_8007CDC0) / 256;
        offset.z = ((center.z * 4) * D_8007CDC0) / 256;
    }
    vertices = &D_800CDBD0[base];
    D_800CDBD0[base + 0].color.position[0] = first[0] + offset.x;
    D_800CDBD0[base + 0].color.position[1] = first[1];
    D_800CDBD0[base + 0].color.position[2] = first[2] + offset.z;
    D_800CDBD0[base + 1].color.position[0] = second[0] + offset.x;
    D_800CDBD0[base + 1].color.position[1] = second[1];
    D_800CDBD0[base + 1].color.position[2] = second[2] + offset.z;
    D_800CDBD0[base + 2].color.position[0] = third[0] + offset.x;
    D_800CDBD0[base + 2].color.position[1] = third[1];
    D_800CDBD0[base + 2].color.position[2] = third[2] + offset.z;
    D_800CDBD0[base + 0].color.color[3] = D_80123AE8;
    D_800CDBD0[base + 1].color.color[3] = D_80123AE8;
    D_800CDBD0[base + 2].color.color[3] = D_80123AE8;
    FRAME_COMMAND(0x04000C2F, vertices);
    FRAME_COMMAND(0xBF000000, 0x00000204);
    D_80123AE4 += 3;
}
