#include "../../include/early_game_medium_next.h"
#include "../../include/early_game_state.h"
#include "../../include/actor.h"

extern TextGlyphResource D_800B26E8;

void func_8001B3DC(EarlyGameActor *source)
{
    EarlyGameActor *actor;

    actor = (EarlyGameActor *)func_800283D4(
        9, &D_800B26E8, source->position.value);
    if (actor != 0) {
        actor->resource24->callback54(actor, 1);
        actor->position.value[2] = 0;
        actor->field54 = 0;
        actor->callback00 = func_80005560;
    }
}
