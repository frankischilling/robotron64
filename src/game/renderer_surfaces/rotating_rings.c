#include "../../../include/renderer_color_wave_internal.h"
#include "../../../include/fixed_math.h"

int func_8000A21C(int minimum, int maximum);
int func_80047048(void);
int func_80047094(int count);

void func_80040968(void)
{
    int red;
    int green;
    int blue;
    int x;
    int y;
    int depth;
    int first;
    int alpha;
    unsigned int vertexLoad;
    unsigned int triangle;
    unsigned int indices;
    int sine;
    int cosine;
    int colorRange;
    int offset;
    int radius;
    int angle;
    int phase;
    RendererVertex *vertex;

    depth = 32000;
    alpha = 255;
    colorRange = 128;
    func_8004729C(2);
    FRAME_COMMAND(0xB7000000, 4);
    FRAME_COMMAND(0xFCFFFFFF, 0xFFFE793C);
    FRAME_COMMAND(0xB900031D, 0x005049D8);
    first = D_80123AE4 = func_80047048();
    if (D_80123AE4 != -1) {
        vertex = &D_800CDBD0[first];
        for (offset = 24000, radius = 19210; offset != 0; offset -= 2000, radius -= 1600) {
            for (angle = 0; angle < 4096; angle += 1024) {
                phase = offset + D_800CD2B4.time + angle;
                sine = func_8004DB88(phase);
                x = (sine * radius) >> 15;
                vertex->color.position[0] = x;
                cosine = func_8004DB60(phase);
                y = (cosine * radius) >> 15;
                vertex->color.position[1] = y;
                vertex->color.position[2] = depth;
                red = func_8000A21C(0, colorRange);
                vertex->color.color[0] = red;
                green = func_8000A21C(0, colorRange);
                vertex->color.color[1] = green;
                blue = func_8000A21C(0, colorRange);
                vertex->color.color[2] = blue;
                vertex->color.color[3] = alpha;
                vertex++;
                D_80123AE4++;
            }
            /* Retail submits the pointer beyond the four vertices just written. */
            vertexLoad = 0x0400103F;
            triangle = 0xBF000000;
            indices = 0x00000204;
            FRAME_COMMAND(vertexLoad, vertex);
            FRAME_COMMAND(triangle, indices);
            indices = 0x00060004;
            FRAME_COMMAND(triangle, indices);
        }
        func_80047094(D_80123AE4 - first);
    }
}
