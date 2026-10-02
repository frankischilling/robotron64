#include "../../../include/renderer_image_setup_internal.h"
#include "../../../include/renderer_primitives_internal.h"

extern unsigned char D_8007DB20[];
extern int D_8008CB20;
extern int D_800CD2B0;
int func_800498F0(unsigned char character);
int func_80047048(void);
int func_80047094(int count);
int func_8003CC58(int angle);

/* Nonmatching candidate; see docs/renderer-diagnostics-and-text.md. */
void func_80049E3C(unsigned char character)
{
    FixedMatrix matrix;
    RendererDrawState draw;
    unsigned char *address;
    int alpha;

    D_8008CB20 = 20;
    draw.angle[0] = 0;
    draw.angle[1] = 0;
    draw.angle[2] = 0;
    draw.scale[0] = D_8008CB34;
    draw.scale[1] = D_8008CB34;
    draw.scale[2] = D_8008CB34;
    draw.projectedPosition[0] = D_8013D9A0;
    draw.projectedPosition[1] = D_8013D9A4;
    draw.projectedPosition[2] = D_8013D9A8;
    func_8004DB34(&matrix);
    func_80047570(&draw);
    address = &D_8007DB20[func_800498F0(character) * 1024];
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

        D_800CDBD0[D_80123AE4 + 0].color.position[0] = D_8008CB20;
        D_800CDBD0[D_80123AE4 + 0].color.position[1] = D_8008CB20;
        D_800CDBD0[D_80123AE4 + 0].color.position[2] = 0;
        D_800CDBD0[D_80123AE4 + 1].color.position[0] = -D_8008CB20;
        D_800CDBD0[D_80123AE4 + 1].color.position[1] = D_8008CB20;
        D_800CDBD0[D_80123AE4 + 1].color.position[2] = 0;
        D_800CDBD0[D_80123AE4 + 2].color.position[0] = -D_8008CB20;
        D_800CDBD0[D_80123AE4 + 2].color.position[1] = -D_8008CB20;
        D_800CDBD0[D_80123AE4 + 2].color.position[2] = 0;
        D_800CDBD0[D_80123AE4 + 3].color.position[0] = D_8008CB20;
        D_800CDBD0[D_80123AE4 + 3].color.position[1] = -D_8008CB20;
        D_800CDBD0[D_80123AE4 + 3].color.position[2] = 0;
        D_800CD2B0 += 10;
        func_8003CC58(D_800CD2B0);
        alpha = 255;
        if (character == 14) {
            RendererVertex *vertices;
            vertices = &D_800CDBD0[D_80123AE4];
            vertices[0].color.color[3] = alpha;
            vertices[0].color.color[0] = 0;
            vertices[0].color.color[1] = 0;
            vertices[0].color.color[2] = 255;
            vertices[1].color.color[3] = alpha;
            vertices[1].color.color[0] = 0;
            vertices[1].color.color[1] = 0;
            vertices[1].color.color[2] = 255;
            vertices[2].color.color[3] = alpha;
            vertices[2].color.color[0] = 0;
            vertices[2].color.color[1] = 0;
            vertices[2].color.color[2] = 255;
            vertices[3].color.color[3] = alpha;
            vertices[3].color.color[0] = 0;
            vertices[3].color.color[1] = 0;
            vertices[3].color.color[2] = 255;
        } else if (character == 15) {
            RendererVertex *vertices;
            vertices = &D_800CDBD0[D_80123AE4];
            vertices[0].color.color[3] = alpha;
            vertices[0].color.color[0] = 0;
            vertices[0].color.color[1] = 255;
            vertices[0].color.color[2] = 0;
            vertices[1].color.color[3] = alpha;
            vertices[1].color.color[0] = 0;
            vertices[1].color.color[1] = 255;
            vertices[1].color.color[2] = 0;
            vertices[2].color.color[3] = alpha;
            vertices[2].color.color[0] = 0;
            vertices[2].color.color[1] = 255;
            vertices[2].color.color[2] = 0;
            vertices[3].color.color[3] = alpha;
            vertices[3].color.color[0] = 0;
            vertices[3].color.color[1] = 255;
            vertices[3].color.color[2] = 0;
        } else if (character == '[') {
            RendererVertex *vertices;
            vertices = &D_800CDBD0[D_80123AE4];
            vertices[0].color.color[3] = alpha;
            vertices[0].color.color[0] = 255;
            vertices[0].color.color[1] = 0;
            vertices[0].color.color[2] = 0;
            vertices[1].color.color[3] = alpha;
            vertices[1].color.color[0] = 255;
            vertices[1].color.color[1] = 0;
            vertices[1].color.color[2] = 0;
            vertices[2].color.color[3] = alpha;
            vertices[2].color.color[0] = 255;
            vertices[2].color.color[1] = 0;
            vertices[2].color.color[2] = 0;
            vertices[3].color.color[3] = alpha;
            vertices[3].color.color[0] = 255;
            vertices[3].color.color[1] = 0;
            vertices[3].color.color[2] = 0;
        } else {
            RendererVertex *vertices;
            vertices = &D_800CDBD0[D_80123AE4];
            vertices[0].color.color[3] = alpha;
            vertices[0].color.color[0] = 255;
            vertices[0].color.color[1] = 255;
            vertices[0].color.color[2] = 255;
            vertices[1].color.color[3] = alpha;
            vertices[1].color.color[0] = 255;
            vertices[1].color.color[1] = 255;
            vertices[1].color.color[2] = 255;
            vertices[2].color.color[3] = alpha;
            vertices[2].color.color[0] = D_8008CB24;
            vertices[2].color.color[1] = D_8008CB28;
            vertices[2].color.color[2] = D_8008CB2C;
            vertices[3].color.color[3] = alpha;
            vertices[3].color.color[0] = D_8008CB24;
            vertices[3].color.color[1] = D_8008CB28;
            vertices[3].color.color[2] = D_8008CB2C;
        }
        D_800CDBD0[D_80123AE4 + 0].color.texture[1] = 0;
        D_800CDBD0[D_80123AE4 + 0].color.texture[0] = 0;
        D_800CDBD0[D_80123AE4 + 1].color.texture[0] = 3072;
        D_800CDBD0[D_80123AE4 + 1].color.texture[1] = 0;
        D_800CDBD0[D_80123AE4 + 2].color.texture[0] = 3072;
        D_800CDBD0[D_80123AE4 + 2].color.texture[1] = 3072;
        D_800CDBD0[D_80123AE4 + 3].color.texture[1] = 3072;
        D_800CDBD0[D_80123AE4 + 3].color.texture[0] = 0;
        FRAME_COMMAND(0x0400103F, &D_800CDBD0[D_80123AE4]);
        RENDERER_QUAD(0, 1, 2, 3);
        RENDERER_QUAD(3, 2, 1, 0);
        func_80047094(4);
        D_8013D9A0 -= D_8008CB20 * 2;
    }
}
