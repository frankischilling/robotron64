#include "../../include/early_render_effects_internal.h"

/* Nonmatching candidate; see docs/early-render-effects.md. */
void func_8000B5AC(void)
{
    FixedMatrix identity;
    FixedMatrix rotation;
    int position[3];
    RendererDrawState draw;
    int firstVertex;
    int ring;
    int color;
    int nextColor;
    int lastColor;
    int angle;
    int nextAngle;
    int x0;
    int y0;
    int x1;
    int y1;
    int z0;
    int z1;
    int red;
    int green;
    int blue;

    func_8004DB34(&identity);
    func_8004D154(&rotation, &identity, D_800730D8);
    D_800730D8 += 16;
    position[0] = -D_800C8BD8.position[0] >> 1;
    position[1] = -D_800C8BD8.position[1] >> 1;
    position[2] = -D_800C8BD8.position[2] >> 1;
    func_8004D4B4(draw.projectedPosition, &D_800CD250, position);
    func_80047D88(&draw, &rotation);
    func_8004729C(1);
    FRAME_COMMAND(0xB6000000, 0x2000);
    D_80123AE4 = func_80047048();
    if (D_80123AE4 == -1) {
        return;
    }
    z0 = 100;
    z1 = 2100;
    firstVertex = D_80123AE4;
    for (ring = 0; ring < 16; ring++) {
        color = ring;
        nextColor = color + 1;
        lastColor = color + 2;
        for (angle = 0; angle < 4096; angle += 256) {
            nextAngle = angle + 256;
            D_800CDBD0[D_80123AE4 + 0].color.color[3] = 128;
            D_800CDBD0[D_80123AE4 + 1].color.color[3] = 128;
            D_800CDBD0[D_80123AE4 + 2].color.color[3] = 128;
            D_800CDBD0[D_80123AE4 + 3].color.color[3] = 128;
            D_800CDBD0[D_80123AE4 + 0].color.color[0] = D_800730E0[color & 7][0];
            D_800CDBD0[D_80123AE4 + 0].color.color[1] = D_800730E0[color & 7][1];
            D_800CDBD0[D_80123AE4 + 0].color.color[2] = D_800730E0[color & 7][2];
            red = D_800730E0[nextColor & 7][0];
            green = D_800730E0[nextColor & 7][1];
            blue = D_800730E0[nextColor & 7][2];
            D_800CDBD0[D_80123AE4 + 1].color.color[0] = red;
            D_800CDBD0[D_80123AE4 + 3].color.color[0] = red;
            D_800CDBD0[D_80123AE4 + 1].color.color[1] = green;
            D_800CDBD0[D_80123AE4 + 3].color.color[1] = green;
            D_800CDBD0[D_80123AE4 + 1].color.color[2] = blue;
            D_800CDBD0[D_80123AE4 + 3].color.color[2] = blue;
            D_800CDBD0[D_80123AE4 + 2].color.color[0] = D_800730E0[lastColor & 7][0];
            D_800CDBD0[D_80123AE4 + 2].color.color[1] = D_800730E0[lastColor & 7][1];
            D_800CDBD0[D_80123AE4 + 2].color.color[2] = D_800730E0[lastColor & 7][2];
            x0 = func_8003CC88(angle) * 1000 >> 12;
            y0 = func_8003CC58(angle) * 1000 >> 12;
            x1 = func_8003CC88(nextAngle) * 1000 >> 12;
            y1 = func_8003CC58(nextAngle) * 1000 >> 12;
            D_800CDBD0[D_80123AE4 + 0].color.position[0] = x0;
            D_800CDBD0[D_80123AE4 + 0].color.position[1] = y0;
            D_800CDBD0[D_80123AE4 + 1].color.position[0] = x1;
            D_800CDBD0[D_80123AE4 + 1].color.position[1] = y1;
            D_800CDBD0[D_80123AE4 + 2].color.position[0] = x1;
            D_800CDBD0[D_80123AE4 + 2].color.position[1] = y1;
            D_800CDBD0[D_80123AE4 + 3].color.position[0] = x0;
            D_800CDBD0[D_80123AE4 + 3].color.position[1] = y0;
            D_800CDBD0[D_80123AE4 + 0].color.position[2] = z0;
            D_800CDBD0[D_80123AE4 + 1].color.position[2] = z0;
            D_800CDBD0[D_80123AE4 + 2].color.position[2] = z1;
            D_800CDBD0[D_80123AE4 + 3].color.position[2] = z1;
            FRAME_COMMAND(0x0400103F, &D_800CDBD0[D_80123AE4]);
            FRAME_COMMAND(0xB1020406, 0x00020600);
            D_80123AE4 += 4;
            color++;
            nextColor++;
            lastColor++;
        }
        func_80047094(D_80123AE4 - firstVertex);
        z0 += 2000;
        z1 += 2000;
    }
    FRAME_COMMAND(0xB7000000, 0x2000);
}
