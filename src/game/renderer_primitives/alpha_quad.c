#include "../../../include/renderer_primitives_internal.h"
#include "../../../include/renderer_polygon_messages.h"


void func_80045214(int *first, int *second, int *third, int *fourth)
{
    int alpha;
    int base;
    unsigned int vertexLoad;
    unsigned int triangle;
    unsigned int indices;
    int used;
    RendererVertex *vertices;

    base = D_80123AE4;
    used = base - D_80123B20 + 3;
    if (used > 10000) {
        func_800496E0((unsigned char *)D_80095128, used, 10000, D_80095148, 0x38D);
    }
    D_80123B14++, D_80123B18++;
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
    alpha = 160;
    D_800CDBD0[base + 0].color.color[3] = alpha;
    D_800CDBD0[base + 1].color.color[3] = alpha;
    D_800CDBD0[base + 2].color.color[3] = alpha;
    D_800CDBD0[base + 3].color.color[3] = alpha;
    vertexLoad = 0x0400103F;
    triangle = 0xBF000000;
    indices = 0x00000204;
    FRAME_COMMAND(vertexLoad, vertices);
    FRAME_COMMAND(triangle, indices);
    indices = 0x00060004;
    FRAME_COMMAND(triangle, indices);
    D_80123AE4 += 4;
}
