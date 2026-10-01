#include "../../include/object_history.h"
#include "../../include/actor_history_internal.h"

void func_8004E168(GameActor *effect)
{
    int index;

    index = ((effect->history - (unsigned char *)D_8013EC00) / 12) / 16;
    if ((index >= 0) && (index < 24)) {
        D_8008D494[index] = 0;
        effect->history_index = 0;
        effect->history_state = 0;
    }
}
