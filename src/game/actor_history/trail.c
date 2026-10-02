#include "../../../include/actor_history_internal.h"
#include "../../../include/object_history_internal.h"
#include "../../../include/renderer_draw_state_internal.h"
#include "../../../include/graphics_state_internal.h"
#include "../../../include/early_game_helpers.h"
#include "../../../include/palette.h"

int func_80047048(void);
int func_80047094(int count);
int func_80039E3C(int object);
void func_8000B06C(int *first, int *second, int *third, int *fourth);
extern int D_80123AE4;

/* Excluded candidate; see docs/projectile-trail-and-arena.md. */
int func_8004E364(GameActor *actor)
{
    ActorHistoryProjectile *projectile;
    ActorHistoryPoint *history;
    ActorHistoryPoint *record;
    RendererDrawState draw;
    ActorHistoryPoint previousLeft;
    ActorHistoryPoint previousRight;
    ActorHistoryPoint right;
    ActorHistoryPoint left;
    ActorHistoryPoint position;
    ActorHistoryPoint points[16];
    FixedMatrix matrix;
    PaletteColor color;
    int firstVertex;
    int span;
    int index;
    int end;
    int count;
    int fade;
    int red;
    int green;
    int blue;
    int x;
    int y;
    int dx;
    int dy;

    projectile = (ActorHistoryProjectile *)actor;
    history = projectile->history54;
    if (D_8009EF94 == 0) return 0;
    if (D_8008D494[(history - D_8013EC00) / 16] == 0) return 0;
    if (func_80039E3C(projectile->objectIndex0C) == 0) return 0;
    func_8004729C(1);
    D_80123AE4 = func_80047048();
    firstVertex = D_80123AE4;
    if (firstVertex == -1) return 1;
    func_8004DB34(&matrix);
    draw.projectedPosition[0] = 0;
    draw.projectedPosition[1] = 0;
    draw.projectedPosition[2] = 0;
    func_80047D88(&draw, &matrix);
    func_8003C14C(&color, 1);
    green = color.green;
    blue = color.blue;
    fade = 16;
    D_80123AE8 = 128;
    red = color.red;
    if ((unsigned int)projectile->value48 < 21U) {
        red = 255;
        green = 0;
        blue = 0;
    }
    span = 400U / D_8009EF94;
    index = projectile->historyIndex4C - 1;
    if (projectile->historyIndex4C < 2) return 0;
    if (span < 5) span = 5;
    if (span >= 15) span = 14;
    end = projectile->historyIndex4C - span;
    count = 1;
    for (; end < index; index--) {
        if (index >= 0) {
            record = &history[index & 15];
            position.value[0] = (record->value[0] - D_800C8BD8.position[0]) >> 1;
            position.value[1] = (record->value[1] - D_800C8BD8.position[1]) >> 1;
            position.value[2] = (record->value[2] - D_800C8BD8.position[2]) >> 1;
            func_8004D4B4(points[count].value, &D_800CD250, position.value);
            count++;
        }
    }
    points[0] = points[1];
    points[count] = points[count - 1];
    for (index = 1; index < count; index++) {
        func_8000A200((red * fade) >> 4, (green * fade) >> 4, (blue * fade) >> 4);
        x = points[index].value[0];
        y = points[index].value[1];
        dx = ((points[index - 1].value[0] - x) +
              (x - points[index + 1].value[0])) >> 1;
        dy = ((points[index - 1].value[1] - y) +
              (y - points[index + 1].value[1])) >> 1;
        left.value[0] = x - dy;
        left.value[1] = y + dx;
        left.value[2] = points[index].value[2];
        right.value[0] = x + dy;
        right.value[1] = y - dx;
        right.value[2] = points[index].value[2];
        if (index >= 2) {
            func_8000B06C(left.value, right.value, previousLeft.value, previousRight.value);
        }
        previousLeft = left;
        previousRight = right;
        fade--;
    }
    func_80047094(D_80123AE4 - firstVertex);
    return 0;
}
