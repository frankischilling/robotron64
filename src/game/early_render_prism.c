#include "../../include/early_render_effects_internal.h"

/* Nonmatching candidate; see docs/render-submission-effects.md. */
int func_8000C75C(void *state)
{
    EarlyGameActor *actor = state;
    RendererDrawState draw;
    int position[3];
    int red;
    int green;
    int blue;
    int random;
    int depth;
    int radius;
    int angle;
    int theta;
    int x;
    int y;
    int z;
    int vertex;

    func_8004729C(1);
    D_80123AE4 = func_80047048();
    if (D_80123AE4 == -1) {
        return 1;
    }
    position[0] = actor->position.value[0] * 1400.0f / D_8008F970;
    position[1] = actor->position.value[2] * 1400.0f / D_8008F970;
    position[2] = actor->position.value[1] * 1400.0f / D_8008F970;
    position[0] *= 12;
    position[2] *= 12;
    position[0] = (position[0] - D_800C8BD8.position[0]) >> 1;
    position[1] = (700 - D_800C8BD8.position[1]) >> 1;
    position[2] = (position[2] - D_800C8BD8.position[2]) >> 1;
    func_8004D4B4(draw.projectedPosition, &D_800CD250, position);
    func_80047D88(&draw, &D_800CD250);
    random = func_8000A21C(0, 55);
    blue = random + 200;
    green = random + 100;
    red = random + 100;
    vertex = 0;
    if (((actor->angle08 >> 10) & 1) == 0) {
        for (depth = -950; depth <= 950; depth += 950) {
            for (angle = 12288; angle >= 0; angle -= 4096) {
                if (depth == 0) {
                    D_800CDBD0[D_80123AE4 + vertex].color.color[2] = blue;
                    D_800CDBD0[D_80123AE4 + vertex].color.color[1] = green;
                    D_800CDBD0[D_80123AE4 + vertex].color.color[0] = red;
                    D_800CDBD0[D_80123AE4 + vertex].color.color[3] = 128;
                    radius = func_8000A21C(60, 90);
                } else {
                    D_800CDBD0[D_80123AE4 + vertex].color.color[2] = 100;
                    D_800CDBD0[D_80123AE4 + vertex].color.color[0] = 50;
                    D_800CDBD0[D_80123AE4 + vertex].color.color[1] = 50;
                    D_800CDBD0[D_80123AE4 + vertex].color.color[3] = 128;
                    radius = 60;
                }
                theta = angle / 4;
                x = func_8003CC88(theta) * radius >> 12;
                y = func_8003CC58(theta) * radius >> 12;
                z = depth * (255 - actor->field4C) >> 8;
                D_800CDBD0[D_80123AE4 + vertex].color.position[0] = x;
                D_800CDBD0[D_80123AE4 + vertex].color.position[2] = z;
                D_800CDBD0[D_80123AE4 + vertex].color.position[1] = y;
                vertex++;
            }
        }
    } else {
        for (depth = -950; depth <= 950; depth += 950) {
            for (angle = 12288; angle >= 0; angle -= 4096) {
                if (depth == 0) {
                    D_800CDBD0[D_80123AE4 + vertex].color.color[2] = blue;
                    D_800CDBD0[D_80123AE4 + vertex].color.color[1] = green;
                    D_800CDBD0[D_80123AE4 + vertex].color.color[0] = red;
                    D_800CDBD0[D_80123AE4 + vertex].color.color[3] = 128;
                    radius = func_8000A21C(60, 90);
                } else {
                    D_800CDBD0[D_80123AE4 + vertex].color.color[2] = 100;
                    D_800CDBD0[D_80123AE4 + vertex].color.color[0] = 50;
                    D_800CDBD0[D_80123AE4 + vertex].color.color[1] = 50;
                    D_800CDBD0[D_80123AE4 + vertex].color.color[3] = 128;
                    radius = 60;
                }
                theta = angle / 4;
                z = func_8003CC88(theta) * radius >> 12;
                y = func_8003CC58(theta) * radius >> 12;
                x = depth * (255 - actor->field4C) >> 8;
                D_800CDBD0[D_80123AE4 + vertex].color.position[2] = z;
                D_800CDBD0[D_80123AE4 + vertex].color.position[0] = x;
                D_800CDBD0[D_80123AE4 + vertex].color.position[1] = y;
                vertex++;
            }
        }
    }
    FRAME_COMMAND(0x040030BF, &D_800CDBD0[D_80123AE4]);
    RENDERER_QUAD(0, 4, 5, 1);
    RENDERER_QUAD(1, 5, 6, 2);
    RENDERER_QUAD(2, 6, 7, 3);
    RENDERER_QUAD(3, 7, 4, 0);
    RENDERER_QUAD(4, 8, 9, 5);
    RENDERER_QUAD(5, 9, 10, 6);
    RENDERER_QUAD(6, 10, 11, 7);
    RENDERER_QUAD(7, 11, 8, 4);
    func_80047094(12);
    return 0;
}
