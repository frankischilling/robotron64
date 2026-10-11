#include "../../../include/early_render_effects_internal.h"

extern int D_8013826C;
extern int D_80138270;
extern int D_80138274;

#define PRISM_POSITION(vertex, x, y, z) { \
    (vertex).color.position[0] = (x); \
    (vertex).color.position[1] = (y); \
    (vertex).color.position[2] = (z); \
}

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
            PRISM_POSITION(vertices[0], 50, 0, 100);
            PRISM_POSITION(vertices[1], 50, 0, 0);
            PRISM_POSITION(vertices[2], 50, height, 0);
            PRISM_POSITION(vertices[3], 50, height, 100);
            PRISM_POSITION(vertices[4], -50, 0, 100);
            PRISM_POSITION(vertices[5], -50, 0, 0);
            PRISM_POSITION(vertices[6], -50, height, 0);
            PRISM_POSITION(vertices[7], -50, height, 100);
        } else {
            PRISM_POSITION(vertices[0], 100, 0, 50);
            PRISM_POSITION(vertices[1], -100, 0, 50);
            PRISM_POSITION(vertices[2], -100, height, 50);
            PRISM_POSITION(vertices[3], 100, height, 50);
            PRISM_POSITION(vertices[4], 100, 0, -50);
            PRISM_POSITION(vertices[5], -100, 0, -50);
            PRISM_POSITION(vertices[6], -100, height, -50);
            PRISM_POSITION(vertices[7], 100, height, -50);
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
