#include "../../include/early_game_medium_next.h"
#include "../../include/early_game_state.h"
#include "../../include/actor.h"

extern TextGlyphResource D_800B26E8;
extern void func_80005560(void);

void func_8001B3DC(EarlyGameActor *source)
{
    EarlyGameActor *actor;

    actor = (EarlyGameActor *)func_800283D4(
        9, &D_800B26E8, (int *)&source->position);
    if (actor != 0) {
        actor->resource24->callback54(actor, 1);
        actor->position.z = 0;
        actor->field54 = 0;
        actor->callback00 = (EarlyGameActorCallback)func_80005560;
    }
}
