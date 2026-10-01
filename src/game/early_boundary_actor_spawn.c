#include "../../include/early_game_state.h"
#include "../../include/early_game_more.h"

extern TextGlyphResource D_800B2480;
void func_800077F4(EarlyGameActor *actor);

EarlyGameActor *func_8000A074(ActorBehaviorActorInternal *source)
{
    EarlyGameActor *actor;
    int product;

    actor = (EarlyGameActor *)func_800283D4(9, &D_800B2480, source->position);
    if (actor == 0) {
        return 0;
    }
    actor->position.value[2] = 0;
    if (source->position[0] <= source->unknown00[3] - 30000) {
        func_80039514(actor->objectIndex0C, 0);
        actor->position.value[0] = -30000;
        actor->angle08 = 0;
    } else if (source->position[0] >= 30000 - source->unknown00[3]) {
        func_80039514(actor->objectIndex0C, 0);
        actor->position.value[0] = 30000;
        actor->angle08 = 0;
    } else if (source->position[1] <= source->unknown00[3] - 30000) {
        func_80039514(actor->objectIndex0C, 1024);
        actor->position.value[1] = -30000;
        actor->angle08 = 1024;
    } else if (source->position[1] >= 30000 - source->unknown00[3]) {
        func_80039514(actor->objectIndex0C, 1024);
        actor->position.value[1] = 30000;
        actor->angle08 = 1024;
    } else {
        product = source->position[1] * source->position[0];
        actor->angle08 = 512 +
            ((product < 0 ? -1 : (product > 0 ? 1 : 0)) > 0 ? 0 : 1024);
        func_80039514(actor->objectIndex0C, actor->angle08);
    }
    actor->callback00 = func_800077F4;
    actor->field5C = (int)func_80009F58;
    actor->field50 = 240;
    return actor;
}
