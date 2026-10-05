#include "../../../include/renderer_color_gradient_internal.h"

void func_8004729C(int mode);
int func_80047048(void);
int func_80047094(int count);

/* Keep each RGBA update in one packet for pinned IDO scheduling. */
#define GRADIENT_COLOR(vertex, r, g, b) { \
    (vertex).color.color[0] = (r); \
    (vertex).color.color[1] = (g); \
    (vertex).color.color[2] = (b); \
    (vertex).color.color[3] = 255; \
}

void func_80040F5C(int r1, int g1, int b1, int r2, int g2, int b2, int mode)
{
    func_8004729C(2);
    FRAME_COMMAND(0xB7000000, 4);
    FRAME_COMMAND(0xFCFFFFFF, 0xFFFE793C);
    if (mode) {
        FRAME_COMMAND(0xB900031D, 0x0050007B);
    } else {
        FRAME_COMMAND(0xB900031D, 0x005049D8);
    }

    D_80123AE4 = func_80047048();
    if (D_80123AE4 != -1) {
        D_800CDBD0[D_80123AE4 + 0].color.position[0] = -D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 0].color.position[1] = -D_8007CCAC;
        D_800CDBD0[D_80123AE4 + 0].color.position[2] = 32000;
        D_800CDBD0[D_80123AE4 + 1].color.position[2] = 32000;
        D_800CDBD0[D_80123AE4 + 1].color.position[0] = -D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 1].color.position[1] = D_8007CCAC;
        D_800CDBD0[D_80123AE4 + 2].color.position[0] = D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 2].color.position[1] = D_8007CCAC;
        D_800CDBD0[D_80123AE4 + 2].color.position[2] = 32000;
        D_800CDBD0[D_80123AE4 + 3].color.position[0] = D_8007CCA8;
        D_800CDBD0[D_80123AE4 + 3].color.position[1] = -D_8007CCAC;
        D_800CDBD0[D_80123AE4 + 3].color.position[2] = 32000;

        GRADIENT_COLOR(D_800CDBD0[D_80123AE4 + 0], r2, g2, b2);
        GRADIENT_COLOR(D_800CDBD0[D_80123AE4 + 1], r1, g1, b1);
        GRADIENT_COLOR(D_800CDBD0[D_80123AE4 + 2], r1, g1, b1);
        GRADIENT_COLOR(D_800CDBD0[D_80123AE4 + 3], r2, g2, b2);

        FRAME_COMMAND(0x0400103F, &D_800CDBD0[D_80123AE4]);
        FRAME_COMMAND(0xB1020406, 0x00020600);
        func_80047094(4);
    }
}
