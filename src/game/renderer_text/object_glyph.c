#include "../../../include/renderer_image_setup_internal.h"
#include "../../../include/renderer_primitives_internal.h"

extern unsigned char D_8007DB20[];
extern int D_8008CB20;
extern int D_800CD2B0;
int func_800498F0(unsigned char character);
int func_80047048(void);
int func_80047094(int count);
int func_8003CC58(int angle);

/* The retail function leaves its return register unset. */
/* Nonmatching candidate; see docs/renderer-diagnostics-and-text.md. */
void func_8004A2B4(RendererDrawState *draw, unsigned char character, int mode)
{
    int position[3];
    FixedMatrix matrix;
    unsigned char *address;

    character = func_800498F0(character);
    matrix = D_800CD250;
    if (mode != 0) {
        func_8004DB34(&D_800CD250);
        position[0] = -draw->position[0] >> 2;
        position[1] = draw->position[1] >> 2;
        position[2] = -draw->position[2] >> 2;
        D_8008CB20 = 50;
    } else {
        position[0] = (draw->position[0] - D_800C8BD8.position[0]) >> 1;
        position[1] = (draw->position[1] - D_800C8BD8.position[1]) >> 1;
        position[2] = (draw->position[2] - D_800C8BD8.position[2]) >> 1;
        D_8008CB20 = 100;
    }
    func_8004D4B4(draw->projectedPosition, &D_800CD250, position);
    func_80047570(draw);
    address = &D_8007DB20[character * 1024];
    address = (unsigned char *)((unsigned int)address & ~7);

    D_80123B00 = (int)address;
    FRAME_COMMAND(0xE7000000, 0);
    FRAME_COMMAND(0xFD900000, address);
    FRAME_COMMAND(0xF5900000, 0x07080200);
    FRAME_COMMAND(0xE6000000, 0);
    FRAME_COMMAND(0xF3000000, 0x071FF200);
    FRAME_COMMAND(0xE7000000, 0);
    FRAME_COMMAND(0xF5880800, 0x00080200);
    FRAME_COMMAND(0xF2000000, 0x0007C07C);
    D_80123AE4 = func_80047048();
    if (D_80123AE4 != -1) {
        RendererVertex *vertices = &D_800CDBD0[D_80123AE4];
        int negativeSize;
        int right;

        negativeSize = -D_8008CB20;
        right = -D_8008CB20 + D_8008CB20;
        D_800CDBD0[D_80123AE4 + 0].color.position[1] = D_8008CB20 + D_8008CB20;
        D_800CDBD0[D_80123AE4 + 0].color.position[0] = right;
        D_800CDBD0[D_80123AE4 + 0].color.position[2] = 0;
        D_800CDBD0[D_80123AE4 + 1].color.position[0] = negativeSize - D_8008CB20;
        D_800CDBD0[D_80123AE4 + 1].color.position[1] = D_8008CB20 + D_8008CB20;
        D_800CDBD0[D_80123AE4 + 1].color.position[2] = 0;
        D_800CDBD0[D_80123AE4 + 2].color.position[0] = negativeSize - D_8008CB20;
        D_800CDBD0[D_80123AE4 + 2].color.position[1] = 0;
        D_800CDBD0[D_80123AE4 + 2].color.position[2] = 0;
        D_800CDBD0[D_80123AE4 + 3].color.position[0] = right;
        D_800CDBD0[D_80123AE4 + 3].color.position[1] = 0;
        D_800CDBD0[D_80123AE4 + 3].color.position[2] = 0;
        vertices[0].color.color[0] = 255;
        vertices[0].color.color[1] = 255;
        vertices[0].color.color[2] = 255;
        vertices[0].color.color[3] = 255;
        vertices[1].color.color[0] = 255;
        vertices[1].color.color[1] = 255;
        vertices[1].color.color[2] = 255;
        vertices[1].color.color[3] = 255;
        vertices[2].color.color[0] = D_8008CB24;
        vertices[2].color.color[1] = D_8008CB28;
        vertices[2].color.color[2] = D_8008CB2C;
        vertices[2].color.color[3] = 255;
        vertices[3].color.color[0] = D_8008CB24;
        vertices[3].color.color[1] = D_8008CB28;
        vertices[3].color.color[2] = D_8008CB2C;
        vertices[3].color.color[3] = 255;
        vertices[0].color.texture[1] = 0;
        vertices[0].color.texture[0] = 0;
        vertices[1].color.texture[0] = 3072;
        vertices[1].color.texture[1] = 0;
        vertices[2].color.texture[0] = 3072;
        vertices[2].color.texture[1] = 3072;
        vertices[3].color.texture[1] = 3072;
        vertices[3].color.texture[0] = 0;
        FRAME_COMMAND(0x0400103F, &D_800CDBD0[D_80123AE4]);
        D_80123B14++;
        D_80123B18++;
        RENDERER_QUAD(3, 2, 1, 0);
        func_80047094(4);
        D_800CD250 = matrix;
    }
}
