#include "../../include/early_game_state.h"
#include "../../include/object_recovery.h"

#include "../../include/early_session_state.h"
#include "../../include/early_game_more.h"

void func_8000E5C8(EarlyGameActor *actor, int initialize)
{
    if (initialize != 0) {
        actor->field5C = (int)func_8000E5C8;
        actor->field4C = 0;
        actor->field50 = 4096;
        actor->field6C = 0;
        actor->field70 = 0;
        actor->field74 = 0;
    } else {
        func_800399E4(actor->objectIndex0C,
            (float)(actor->field50 * actor->resource24->scale0C) / 40960.0f);
        actor->field50 -= D_8009EF94 * 15;
        if (actor->field50 < 0) {
            actor->field50 = 0;
        }
        actor->field4C += D_8009EF94;
        actor->angle08 += actor->field4C / 4;
        actor->angle08 &= 4095;
        func_80039514(actor->objectIndex0C, actor->angle08);
        if (actor->field50 < 700) {
            func_8000E6F0((GameActor *)actor);
        }
    }
}
