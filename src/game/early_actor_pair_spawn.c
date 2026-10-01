#include "../../include/early_game_state.h"
#include "../../include/early_game_more.h"
#include "../../include/early_game_medium_next.h"
#include "../../include/object_recovery.h"

extern EarlyGameActor *D_800AD1B8;
extern int D_80073588;
extern int D_80073574[];
extern int D_80097350;
extern TextGlyphResource D_800B4B00;

EarlyGameActor *func_8000F564(int value)
{
    int random;
    /* The retail code leaves position[2] unwritten before both allocations. */
    int position[3];
    EarlyGameActor *actor;

    D_80073588 = value;
    if (D_80097350 == 0) {
        position[0] = D_800AD1B8->position.value[0] +
                      ((func_8004CDE8() >> 3) % 10000) - 5000;
        position[1] = D_800AD1B8->position.value[1] +
                      ((func_8004CDE8() >> 3) % 10000) - 5000;
    } else {
        random = func_8004CDE8();
        position[0] = D_800AD1B8->position.value[0] +
            ((func_8003CC88(D_80073574[D_80097350] + D_800AD1B8->angle08) *
              8000) / 4096) + ((random >> 3) % 1000) - 500;
        random = func_8004CDE8();
        position[1] = D_800AD1B8->position.value[1] +
            ((func_8003CC58(D_80073574[D_80097350] + D_800AD1B8->angle08) *
              8000) / 4096) + ((random >> 3) % 1000) - 500;
    }
    actor = (EarlyGameActor *)func_800283D4(9, &D_800B4B00, position);
    if (actor != 0) {
        actor->field54 = 0;
        func_8001B3DC(actor);
    }
    actor = (EarlyGameActor *)func_800283D4(9, &D_800B4B00, position);
    if (actor != 0) {
        actor->resource24->callback54(actor, 1);
        actor->position.value[2] = 0;
        actor->field54 = value;
        func_80009F90(actor, 0);
        func_80009F90(actor, 0);
    }
    return actor;
}
