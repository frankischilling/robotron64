#include "../../../include/renderer_color_wave_internal.h"
int func_80047048(void);
int func_80047094(int count);

int func_8000A21C(int minimum,int maximum);
int func_8004DB88(int angle);
void func_80045124(unsigned int first,unsigned int second,unsigned int third,unsigned int fourth);

void func_80040BA0(int horizontal, int vertical)
{
    int time;
    int y;
    int x;
    int red;
    int blue;
    int green;
    RendererVertex *vertex;
    RendererVertex *start;
    int first;
    int dx;
    int dy;
    int columns;
    unsigned int quad;
    unsigned int second;
    unsigned int third;
    unsigned int last;

    time = D_800CD2B4.time;
    columns = horizontal * 2 + 1;
    dx = D_8007CCA8 / horizontal;
    dy = D_8007CCAC / vertical;
    func_8004729C(2);
    FRAME_COMMAND(0xB7000000, 4);
    FRAME_COMMAND(0xFCFFFFFF, 0xFFFE793C);
    /* Reuse this scalar for the allocation sentinel and then the second corner. */
    second = -1;
    FRAME_COMMAND(0xB900031D, 0x00552078);
    first = D_80123AE4 = func_80047048();
    if (first != second) {
        vertex = start = &D_800CDBD0[first];
        for (y = -vertical; y <= vertical; y++) {
            for (x = -horizontal; x <= horizontal; x++) {
                /* The channel bound is consumed before blue receives its color. */
                blue = 64;
                func_8004DB88(time / 2);
                func_8004DB88(time + 512);
                func_8004DB88(time / 3);
                time += 40;
                green = func_8000A21C(0, blue);
                blue = func_8000A21C(0, 64);
                red = func_8000A21C(0, 64);
                vertex->color.position[0] = dx * x;
                vertex->color.position[1] = dy * y;
                vertex->color.position[2] = 32000;
                vertex->color.color[1] = green;
                vertex->color.color[2] = blue;
                vertex->color.color[0] = red;
                vertex->color.color[3] = 128;
                vertex++;
                D_80123AE4++;
            }
        }
        func_80047094(D_80123AE4 - first);
        for (y = -vertical; y < vertical; y++) {
            for (x = -horizontal; x < horizontal; x++) {
                quad = (unsigned int)(start + x + horizontal + (y + vertical) * columns);
                second = quad + 16;
                last = quad + columns * 16;
                third = last + 16;
                func_80045124((unsigned int)quad, (unsigned int)second, (unsigned int)third, (unsigned int)last);
            }
        }
        FRAME_COMMAND(0xB900031D, 0x00552078);
    }
}
