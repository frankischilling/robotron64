#include "../../../include/early_render_effects_internal.h"

/* Excluded candidate. Retail ignores y and projects the disc onto ground level. */
void func_8000AC6C(int x, int y, int z, int black)
{
    RendererDrawState draw;
    int position[3];
    PaletteColor color;
    int count;
    int alpha;
    int index;
    int angle;
    int cosine;
    int sine;
    int next;

    count = 10;
    func_8004729C(2);
    func_8004729C(1);
    position[0] = (x - D_800C8BD8.position[0]) >> 1;
    position[1] = -D_800C8BD8.position[1] >> 1;
    position[2] = (z - D_800C8BD8.position[2]) >> 1;
    func_8004D4B4(draw.projectedPosition, &D_800CD250, position);
    func_80047D88(&draw, &D_800CD250);
    D_80123AE4 = func_80047048();
    if (D_80123AE4 != -1) {
        func_8003C14C(&color, 1);
        alpha = 0;
        if (black) {
            color.red = 0;
            color.green = 0;
            color.blue = 0;
            alpha = 160;
        }
        D_800CDBD0[D_80123AE4].color.position[0] = 0;
        D_800CDBD0[D_80123AE4].color.position[1] = 0;
        D_800CDBD0[D_80123AE4].color.position[2] = 0;
        D_800CDBD0[D_80123AE4].color.color[0] = color.red;
        D_800CDBD0[D_80123AE4].color.color[1] = color.green;
        D_800CDBD0[D_80123AE4].color.color[2] = color.blue;
        D_800CDBD0[D_80123AE4].color.color[3] = alpha;
        for (index = 1; index <= count; index++) {
            angle = (index - 1) * 4096 / count;
            cosine = func_8003CC88(angle);
            sine = func_8003CC58(angle);
            D_800CDBD0[D_80123AE4 + index].color.position[0] = cosine * 200 >> 12;
            D_800CDBD0[D_80123AE4 + index].color.position[1] = 0;
            D_800CDBD0[D_80123AE4 + index].color.position[2] = sine * 200 >> 12;
            D_800CDBD0[D_80123AE4 + index].color.color[3] = 160;
            D_800CDBD0[D_80123AE4 + index].color.color[0] = color.red;
            D_800CDBD0[D_80123AE4 + index].color.color[1] = color.green;
            D_800CDBD0[D_80123AE4 + index].color.color[2] = color.blue;
        }
        FRAME_COMMAND(0x04002CAF, &D_800CDBD0[D_80123AE4]);
        for (index = 1; index <= count; index++) {
            next = index == count ? 1 : index + 1;
            FRAME_COMMAND(0xBF000000, ((next & 127) << 9) | ((index & 127) << 1));
        }
        func_80047094(count + 1);
    }
}
