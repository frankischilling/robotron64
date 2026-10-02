#include "../../../include/renderer_primitives_internal.h"
#include "../../../include/renderer_polygon_messages.h"


/* Excluded candidate; see docs/renderer-polygon-emission.md. */
void func_800453D8(int x0, int y0, int x1, int y1)
{
    RendererVertex *vertices;
    unsigned int vertexLoad;
    unsigned int lineCommand;
    unsigned int indices;
    int base;
    int used;

    base = D_80123AE4;
    used = base - D_80123B20 + 1;
    if (used > 10000) {
        func_800496E0((unsigned char *)D_80095150, used, 10000, D_80095170, 0x3C1);
    }
    vertices = &D_800CDBD0[base];
    D_800CDBD0[base + 0].color.position[0] = x0;
    D_800CDBD0[base + 0].color.position[1] = y0;
    D_800CDBD0[base + 0].color.position[2] = 10;
    D_800CDBD0[base + 1].color.position[0] = x1;
    D_800CDBD0[base + 1].color.position[1] = y1;
    D_800CDBD0[base + 1].color.position[2] = 10;
    vertices[0].color.color[0] = 255;
    vertices[0].color.color[1] = 255;
    vertices[0].color.color[2] = 0;
    vertices[0].color.color[3] = 255;
    vertices[1].color.color[0] = 255;
    vertices[1].color.color[1] = 255;
    vertices[1].color.color[2] = 0;
    vertices[1].color.color[3] = 255;
    D_80123AE4 += 2;
    vertexLoad = 0x0400081F;
    lineCommand = 0xB5000000;
    indices = 0x00000200;
    FRAME_COMMAND(vertexLoad, vertices);
    FRAME_COMMAND(lineCommand, indices);
}
