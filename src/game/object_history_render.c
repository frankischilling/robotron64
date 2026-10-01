#include "../../include/object_history_internal.h"
#include "../../include/renderer_draw_state_internal.h"
#include "../../include/graphics_state_internal.h"
#include "../../include/early_game_helpers.h"

void func_8004E968(ObjectDrawResource *resource, int frame, int duration)
{
    ObjectHistoryRecord *history;
    ObjectHistoryRecord *record;
    int color;
    int index;
    int position[3];
    int size;
    RendererDrawState draw;

    func_8004729C(1);
    history = &D_8013FE00[resource->historySlot50 * 16];
    color = resource->type->variant - 4;
    func_8000A200(D_8008D4C0[color][0], D_8008D4C0[color][1],
                  D_8008D4C0[color][2]);
    if (history != 0) {
        if (resource->mode1F == 1) {
            size = ((duration - frame) * 16) / duration;
        } else {
            size = 16;
        }
        for (index = resource->historyCount4C - 1; resource->historyCount4C - 16 < index; index -= 2) {
            if (index < 0) {
                break;
            }
            record = history;
            record += index & 15;
            position[0] = record->x;
            position[1] = record->y;
            position[2] = record->z;
            position[0] = (position[0] - D_800C8BD8.position[0]) >> 1;
            position[1] = (position[1] - D_800C8BD8.position[1]) >> 1;
            position[2] = (position[2] - D_800C8BD8.position[2]) >> 1;
            func_8004D4B4(draw.projectedPosition, &D_800CD250, position);
            func_80047D88(&draw, &D_800CD250);
            func_8000A910(record->angle, size);
            size--;
            if (size < 0) {
                size = 0;
            }
        }
    }
}
