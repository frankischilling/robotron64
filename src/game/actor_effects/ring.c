#include "../../../include/early_render_effects_internal.h"
#include "../../../include/object.h"
#include "../../../include/palette.h"

/* Excluded research: this complete callback still differs from retail. */
int func_80006240(EarlyGameActor *actor)
{
    ObjectRecord *object;
    int state;
    PaletteColor color;
    int position[3];
    int red;
    int green;
    int blue;
    int alpha;
    int radius;
    int angle;
    int index;
    int vertexIndex;
    int cosine;
    int sine;
    int x;
    int z;
    unsigned int a;
    unsigned int b;
    unsigned int c;
    unsigned int d;
    unsigned int flag;

    func_8004729C(1);
    D_80123AE4 = func_80047048();
    if (D_80123AE4 == -1) {
        return 1;
    }
    state = actor->field4C;
    func_8003C14C(&color, 1);
    red = color.red;
    green = color.green;
    blue = color.blue;
    object = &D_800BF918[actor->objectIndex0C];
    position[0] = (object->position[0] - D_800C8BD8.position[0]) >> 1;
    position[1] = (object->position[1] - D_800C8BD8.position[1]) >> 1;
    position[2] = (object->position[2] - D_800C8BD8.position[2]) >> 1;
    func_8004D4B4((int *)object->unknown60, &D_800CD250, position);
    func_80047D88((RendererDrawState *)&object->draw38, &D_800CD250);
    alpha = 208 - state * 10;
    if (alpha < 10) {
        alpha = 10;
    }
    radius = state * 150 + 150;
    for (angle = 0, index = 0; angle < 4096; angle += 256, index += 2) {
        D_800CDBD0[D_80123AE4 + index].color.color[0] = red;
        D_800CDBD0[D_80123AE4 + index].color.color[1] = green;
        D_800CDBD0[D_80123AE4 + index].color.color[3] = alpha;
        D_800CDBD0[D_80123AE4 + index + 1].color.color[0] = red;
        D_800CDBD0[D_80123AE4 + index + 1].color.color[1] = green;
        D_800CDBD0[D_80123AE4 + index + 1].color.color[3] = alpha;
        D_800CDBD0[D_80123AE4 + index].color.color[2] = blue;
        D_800CDBD0[D_80123AE4 + index + 1].color.color[2] = blue;
        /* Preserve the position index across both trigonometric calls. */
        vertexIndex = index;
        cosine = func_8003CC88(angle);
        x = cosine * radius >> 12;
        sine = func_8003CC58(angle);
        z = sine * radius >> 12;
        D_800CDBD0[D_80123AE4 + vertexIndex].color.position[2] = z;
        D_800CDBD0[D_80123AE4 + vertexIndex].color.position[1] = 100;
        D_800CDBD0[D_80123AE4 + vertexIndex].color.position[0] = x;
        D_800CDBD0[D_80123AE4 + vertexIndex + 1].color.position[1] = 300;
        D_800CDBD0[D_80123AE4 + vertexIndex + 1].color.position[2] = z;
        D_800CDBD0[D_80123AE4 + vertexIndex + 1].color.position[0] = x;
    }
    FRAME_COMMAND(0x040081FF, &D_800CDBD0[D_80123AE4]);
    for (index = 0; index < 16; index++) {
        a = index * 2 + 2;
        b = index * 2 + 3;
        c = index * 2 + 1;
        d = index * 2;
        flag = (d << 1) & 255;
        FRAME_COMMAND((((a & 31) * 2 & 255) << 16) | (((b & 31) * 2 & 255) << 8) | ((c & 31) * 2 & 255) | 0xB1000000,
                      (((a & 31) * 2 & 255) << 16) | (((c & 31) * 2 & 255) << 8) | flag);
        FRAME_COMMAND((((c & 31) * 2 & 255) << 16) | (((b & 31) * 2 & 255) << 8) | ((a & 31) * 2 & 255) | 0xB1000000,
                      (((c & 31) * 2 & 255) << 16) | (((a & 31) * 2 & 255) << 8) | flag);
    }
    func_80047094(32);
    return 0;
}
