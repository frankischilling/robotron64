#include "../../include/renderer_primitives_internal.h"

int func_80047048(void);
int func_80047094(int count);

void func_8004B098(unsigned char *address, int size)
{
    D_80123B00 = (int)address;
    D_80123B04 = (int)address;
    FRAME_COMMAND(0xE7000000, 0);
    FRAME_COMMAND(0xFD100000, address);
    FRAME_COMMAND(0xF5100000, 0x07080200);
    FRAME_COMMAND(0xE6000000, 0);
    FRAME_COMMAND(0xF3000000, 0x073FF100);
    FRAME_COMMAND(0xE7000000, 0);
    FRAME_COMMAND(0xF5101000, 0x00080200);
    FRAME_COMMAND(0xF2000000, 0x0007C07C);
    D_80123AE4 = func_80047048();
    if (D_80123AE4 != -1) {
        RendererVertex *vertices = &D_800CDBD0[D_80123AE4];

        D_800CDBD0[D_80123AE4 + 0].color.position[1] = -size;
        D_800CDBD0[D_80123AE4 + 0].color.position[0] = size;
        D_800CDBD0[D_80123AE4 + 0].color.position[2] = 0;
        D_800CDBD0[D_80123AE4 + 1].color.position[0] = -size;
        D_800CDBD0[D_80123AE4 + 1].color.position[1] = -size;
        D_800CDBD0[D_80123AE4 + 1].color.position[2] = 0;
        D_800CDBD0[D_80123AE4 + 2].color.position[0] = -size;
        D_800CDBD0[D_80123AE4 + 2].color.position[1] = size;
        D_800CDBD0[D_80123AE4 + 2].color.position[2] = 0;
        D_800CDBD0[D_80123AE4 + 3].color.position[0] = size;
        D_800CDBD0[D_80123AE4 + 3].color.position[1] = size;
        D_800CDBD0[D_80123AE4 + 3].color.position[2] = 0;
        vertices[0].color.color[0] = 255;
        vertices[0].color.color[1] = 255;
        vertices[0].color.color[2] = 255;
        vertices[0].color.color[3] = D_80123AE8;
        vertices[1].color.color[2] = 255;
        vertices[1].color.color[1] = 255;
        vertices[1].color.color[0] = 255;
        vertices[1].color.color[3] = D_80123AE8;
        vertices[2].color.color[2] = 255;
        vertices[2].color.color[1] = 255;
        vertices[2].color.color[0] = 255;
        vertices[2].color.color[3] = D_80123AE8;
        vertices[3].color.color[2] = 255;
        vertices[3].color.color[1] = 255;
        vertices[3].color.color[0] = 255;
        vertices[3].color.color[3] = D_80123AE8;
        vertices[0].color.texture[1] = 0;
        vertices[0].color.texture[0] = 0;
        vertices[1].color.texture[0] = 4096;
        vertices[1].color.texture[1] = 0;
        vertices[2].color.texture[0] = 4096;
        vertices[2].color.texture[1] = 4096;
        vertices[3].color.texture[1] = 4096;
        vertices[3].color.texture[0] = 0;
        FRAME_COMMAND(0x0400103F, &D_800CDBD0[D_80123AE4]);
        RENDERER_QUAD(0, 1, 2, 3);
        func_80047094(4);
    }
}
