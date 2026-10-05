#include "../../../include/renderer_color_gradient_internal.h"

int func_80047048(void);
int func_80047094(int count);

#define BORDER_COLOR(vertex, r, g, b) { \
    (vertex).color.color[0] = (r); \
    (vertex).color.color[1] = (g); \
    (vertex).color.color[2] = (b); \
    (vertex).color.color[3] = 255; \
}

void func_80041180(int r1, int g1, int b1, int r2, int g2, int b2)
{
    int first;

    func_8004729C(2);
    FRAME_COMMAND(0xBA000602, 0);
    FRAME_COMMAND(0xB7000000, 4);
    FRAME_COMMAND(0xFCFFFFFF, 0xFFFE793C);
    FRAME_COMMAND(0xB900031D, 0x00552078);
    first = D_80123AE4 = func_80047048();
    if (first != -1) {
        D_800CDBD0[D_80123AE4 + 0].color.position[0] = -D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 0].color.position[1] = D_8007CCAC;
        D_800CDBD0[D_80123AE4 + 0].color.position[2] = 32000;
        D_800CDBD0[D_80123AE4 + 1].color.position[0] = D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 1].color.position[1] = D_8007CCAC;
        D_800CDBD0[D_80123AE4 + 1].color.position[2] = 32000;
        D_800CDBD0[D_80123AE4 + 2].color.position[0] = D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 2].color.position[1] = 2000;
        D_800CDBD0[D_80123AE4 + 2].color.position[2] = 32000;
        D_800CDBD0[D_80123AE4 + 3].color.position[1] = 2000;
        D_800CDBD0[D_80123AE4 + 3].color.position[0] = -D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 3].color.position[2] = 32000;
        D_800CDBD0[D_80123AE4 + 4].color.position[1] = -2000;
        D_800CDBD0[D_80123AE4 + 4].color.position[0] = -D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 4].color.position[2] = 32000;
        D_800CDBD0[D_80123AE4 + 5].color.position[0] = D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 5].color.position[1] = -2000;
        D_800CDBD0[D_80123AE4 + 5].color.position[2] = 32000;
        D_800CDBD0[D_80123AE4 + 6].color.position[0] = D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 6].color.position[1] = -D_8007CCAC;
        D_800CDBD0[D_80123AE4 + 6].color.position[2] = 32000;
        D_800CDBD0[D_80123AE4 + 7].color.position[1] = -D_8007CCAC;
        D_800CDBD0[D_80123AE4 + 7].color.position[0] = -D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 7].color.position[2] = 32000;
        D_800CDBD0[D_80123AE4 + 8].color.position[1] = -2000;
        D_800CDBD0[D_80123AE4 + 8].color.position[0] = -D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 8].color.position[2] = 32000;
        D_800CDBD0[D_80123AE4 + 9].color.position[0] = D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 9].color.position[1] = -2000;
        D_800CDBD0[D_80123AE4 + 9].color.position[2] = 32000;
        D_800CDBD0[D_80123AE4 + 10].color.position[0] = D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 10].color.position[1] = 2000;
        D_800CDBD0[D_80123AE4 + 10].color.position[2] = 32000;
        D_800CDBD0[D_80123AE4 + 11].color.position[1] = 2000;
        D_800CDBD0[D_80123AE4 + 11].color.position[0] = -D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 11].color.position[2] = 32000;

        BORDER_COLOR(D_800CDBD0[D_80123AE4 + 0], r1, g1, b1);
        BORDER_COLOR(D_800CDBD0[D_80123AE4 + 1], r1, g1, b1);
        BORDER_COLOR(D_800CDBD0[D_80123AE4 + 2], r2, g2, b2);
        BORDER_COLOR(D_800CDBD0[D_80123AE4 + 3], r2, g2, b2);
        BORDER_COLOR(D_800CDBD0[D_80123AE4 + 4], r2, g2, b2);
        BORDER_COLOR(D_800CDBD0[D_80123AE4 + 5], r2, g2, b2);
        BORDER_COLOR(D_800CDBD0[D_80123AE4 + 6], r1, g1, b1);
        BORDER_COLOR(D_800CDBD0[D_80123AE4 + 7], r1, g1, b1);
        BORDER_COLOR(D_800CDBD0[D_80123AE4 + 8], r2, g2, b2);
        BORDER_COLOR(D_800CDBD0[D_80123AE4 + 9], r2, g2, b2);
        BORDER_COLOR(D_800CDBD0[D_80123AE4 + 10], r2, g2, b2);
        BORDER_COLOR(D_800CDBD0[D_80123AE4 + 11], r2, g2, b2);

        FRAME_COMMAND(0x040030BF, &D_800CDBD0[D_80123AE4]);
        FRAME_COMMAND(0xB1020406, 0x00020600);
        FRAME_COMMAND(0xB10A0C0E, 0x000A0E08);
        FRAME_COMMAND(0xB1121416, 0x00121610);
        func_80047094(12);
    }
}
