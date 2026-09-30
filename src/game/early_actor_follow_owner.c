#include "../../include/early_session_state.h"
#include "../../include/early_game_more.h"

void func_8000E720(int *destination, int *source, int angle);
void func_800290B0(int object, int *position);

void func_8000DFEC(EarlyGameActor *actor, int unused)
{
    EarlyGameActor *parent;
    EarlyGamePosition position;

    parent = (EarlyGameActor *)actor->owner3C;
    if (parent != 0) {
        if (parent->state21 == 2) {
            func_8000E6F0((GameActor *)actor);
        } else if (parent->field5C == (int)func_8000E5C8) {
            func_8000E5C8(actor, 1);
        } else if (parent->field5C == (int)func_8000EAE4) {
            func_8000E6F0((GameActor *)actor);
        } else {
            actor->angle08 = parent->angle08;
            position.value[0] = actor->field4C;
            position.value[1] = actor->field50;
            position.value[2] = 0;
            func_8000E720(position.value, position.value, actor->angle08);
            actor->position.value[0] = position.value[0] + parent->position.value[0];
            actor->position.value[1] = position.value[1] + parent->position.value[1];
            actor->position.value[2] = position.value[2] + parent->position.value[2];
            func_800290B0(actor->objectIndex0C, actor->position.value);
            func_80039514(actor->objectIndex0C, actor->angle08);
            actor->field6C = 0;
            actor->field70 = 0;
            actor->field74 = 0;
        }
    }
}
