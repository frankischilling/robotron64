#include "../../../include/early_render_effects_internal.h"

extern int D_8013826C;
extern int D_80138270;
extern int D_80138274;

/* Excluded candidate: the complete instruction comparison still differs. */
void func_8000A910(int angle, int size)
{
    int base;
    int red;
    int green;
    int blue;
    int alpha;
    int height;
    RendererVertex *vertices;

    angle &= 4095;
    angle /= 1024;
    base = D_80123AE4 = func_80047048();
    if (base != -1) {
        vertices = &D_800CDBD0[base];
        vertices[0].color.color[0] = red = D_80138270;
        vertices[0].color.color[1] = green = D_80138274;
        vertices[0].color.color[2] = blue = D_8013826C;
        vertices[0].color.color[3] = alpha = (size * 64) / 16;
        vertices[1].color.color[0] = red;
        vertices[1].color.color[1] = green;
        vertices[1].color.color[2] = blue;
        vertices[1].color.color[3] = alpha;
        vertices[2].color.color[0] = red;
        vertices[2].color.color[1] = green;
        vertices[2].color.color[2] = blue;
        vertices[2].color.color[3] = alpha;
        vertices[3].color.color[0] = red;
        vertices[3].color.color[1] = green;
        vertices[3].color.color[2] = blue;
        vertices[3].color.color[3] = alpha;
        vertices[4].color.color[0] = red;
        vertices[4].color.color[1] = green;
        vertices[4].color.color[2] = blue;
        vertices[4].color.color[3] = alpha;
        vertices[5].color.color[0] = red;
        vertices[5].color.color[1] = green;
        vertices[5].color.color[2] = blue;
        vertices[5].color.color[3] = alpha;
        vertices[6].color.color[0] = red;
        vertices[6].color.color[1] = green;
        vertices[6].color.color[2] = blue;
        vertices[6].color.color[3] = alpha;
        vertices[7].color.color[0] = red;
        vertices[7].color.color[1] = green;
        vertices[7].color.color[2] = blue;
        vertices[7].color.color[3] = alpha;
        height = (size * 370) / 16;
        if (angle == 0 || angle == 2) {
            vertices[0].color.position[0] = 50;
            vertices[0].color.position[2] = 100;
            vertices[0].color.position[1] = 0;
            vertices[1].color.position[0] = 50;
            vertices[1].color.position[1] = 0;
            vertices[1].color.position[2] = 0;
            vertices[2].color.position[0] = 50;
            vertices[2].color.position[1] = height;
            vertices[2].color.position[2] = 0;
            vertices[3].color.position[1] = height;
            vertices[3].color.position[2] = 100;
            vertices[3].color.position[0] = 50;
            vertices[4].color.position[0] = -50;
            vertices[4].color.position[2] = 100;
            vertices[4].color.position[1] = 0;
            vertices[5].color.position[0] = -50;
            vertices[5].color.position[1] = 0;
            vertices[5].color.position[2] = 0;
            vertices[6].color.position[1] = height;
            vertices[6].color.position[0] = -50;
            vertices[6].color.position[2] = 0;
            vertices[7].color.position[1] = height;
            vertices[7].color.position[0] = -50;
            vertices[7].color.position[2] = 100;
        } else {
            vertices[0].color.position[0] = 100;
            vertices[0].color.position[1] = 0;
            vertices[0].color.position[2] = 50;
            vertices[1].color.position[0] = -100;
            vertices[1].color.position[1] = 0;
            vertices[1].color.position[2] = 50;
            vertices[2].color.position[0] = -100;
            vertices[2].color.position[1] = height;
            vertices[2].color.position[2] = 50;
            vertices[3].color.position[1] = height;
            vertices[3].color.position[0] = 100;
            vertices[3].color.position[2] = 50;
            vertices[4].color.position[2] = -50;
            vertices[4].color.position[0] = 100;
            vertices[4].color.position[1] = 0;
            vertices[5].color.position[0] = -100;
            vertices[5].color.position[2] = -50;
            vertices[5].color.position[1] = 0;
            vertices[6].color.position[1] = height;
            vertices[6].color.position[0] = -100;
            vertices[6].color.position[2] = -50;
            vertices[7].color.position[1] = height;
            vertices[7].color.position[2] = -50;
            vertices[7].color.position[0] = 100;
        }
        FRAME_COMMAND(0x0400207F, &D_800CDBD0[D_80123AE4]);
        RENDERER_QUAD(0, 1, 2, 3);
        RENDERER_QUAD(7, 6, 5, 4);
        RENDERER_QUAD(2, 6, 7, 3);
        RENDERER_QUAD(0, 3, 7, 4);
        RENDERER_QUAD(1, 2, 6, 5);
        D_80123AE4 += 8;
        func_80047094(D_80123AE4 - base);
    }
}
