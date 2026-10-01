#include "../../include/early_render_effects_internal.h"
#include "../../include/object.h"

/* Nonmatching candidate; see docs/early-render-effects.md. */
int func_8000B9D4(EarlyGameActor *actor, int mode)
{
    int count;
    FixedMatrix matrix;
    int position[3];
    ObjectRecord *object;
    int radius;
    int brightness;
    int red;
    int green;
    int blue;
    int i;
    int angle;
    int x;
    int y;
    int next;
    int vertexIndex;
    count = mode * 2;
    func_8004DB34(&matrix);
    func_8004729C(1);
    D_80123AE4 = func_80047048();
    if (D_80123AE4 == -1) {
        return 1;
    }
    radius = 120;
    object = &D_800BF918[actor->objectIndex0C];
    position[0] = (object->position[0] - D_800C8BD8.position[0]) >> 1;
    position[1] = (object->position[1] - D_800C8BD8.position[1]) >> 1;
    position[2] = (object->position[2] - D_800C8BD8.position[2]) >> 1;
    func_8004D4B4((int *)object->unknown60, &D_800CD250, position);
    func_80047D88((RendererDrawState *)&object->draw38, &matrix);
    radius = func_8000A21C(100, 115) * radius / 100;
    brightness = func_8000A21C(200, 255);
    if (actor->field4C != 0) {
        brightness = 255;
    }
    red = D_80138270 * brightness >> 8;
    green = D_80138274 * brightness >> 8;
    blue = D_8013826C * brightness >> 8;
    D_800CDBD0[D_80123AE4].color.position[0] = 0;
    D_800CDBD0[D_80123AE4].color.position[1] = 0;
    D_800CDBD0[D_80123AE4].color.position[2] = 0;
    D_800CDBD0[D_80123AE4].color.color[0] = red;
    D_800CDBD0[D_80123AE4].color.color[1] = green;
    D_800CDBD0[D_80123AE4].color.color[2] = blue;
    D_800CDBD0[D_80123AE4].color.color[3] = 255;
    for (i = 0, vertexIndex = 1; vertexIndex <= count; i++, vertexIndex++) {
        angle = i * 4096 / count;
        x = func_8003CC88(angle) * radius >> 12;
        y = func_8003CC58(angle) * radius >> 12;
        if (i & 1) {
            x *= 2;
            y *= 2;
        }
        D_800CDBD0[D_80123AE4 + vertexIndex].color.position[0] = x;
        D_800CDBD0[D_80123AE4 + vertexIndex].color.position[1] = y;
        D_800CDBD0[D_80123AE4 + vertexIndex].color.position[2] = 0;
        D_800CDBD0[D_80123AE4 + vertexIndex].color.color[0] = red;
        D_800CDBD0[D_80123AE4 + vertexIndex].color.color[1] = 0;
        D_800CDBD0[D_80123AE4 + vertexIndex].color.color[2] = 0;
        D_800CDBD0[D_80123AE4 + vertexIndex].color.color[3] = 0;
    }
    FRAME_COMMAND(0x04000000 | (((count + 1) << 10 | (count * 16 + 15)) & 0xFFFF),
                  &D_800CDBD0[D_80123AE4]);
    for (i = 0; i < count; i++) {
        next = i + 2;
        if (i + 1 == count) {
            next = 1;
        }
        RENDERER_TRIANGLE(0, next, i + 1);
    }
    func_80047094(count + 1);
    return 0;
}
