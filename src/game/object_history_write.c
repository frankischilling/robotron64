#include "../../include/object_history_internal.h"

void func_8004E820(EarlyGameActor *actor)
{
    ObjectHistoryRecord *history;
    ObjectHistoryRecord *record;
    int index;

    history = D_8013FE00 + actor->field50 * 16;

    if (history != 0) {
        index = actor->field4C;
        record = history;
        record += index & 15;
        record->x = (float)actor->position.value[0] * 1400.0f / 60000.0f;
        record->y = (float)actor->position.value[2] * 1400.0f / 60000.0f;
        record->z = (float)actor->position.value[1] * 1400.0f / 60000.0f;
        record->x *= 12;
        record->y *= 12;
        record->z *= 12;
        record->angle = actor->angle08;
        actor->field4C++;
    }
}
