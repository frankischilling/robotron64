#include "../../include/early_game_state.h"
#include "../../include/object.h"

extern TextGlyphResource D_800B49A0;
extern int func_80018E1C(int first, int second, int third, int fourth,
                         int fifth, int sixth);

void func_80015184(int index, int *position)
{
    EarlyGameActor *actor;

    actor = (EarlyGameActor *)func_800283D4(
        9, &D_800B1BE8[index], position);
    if (actor != 0) {
        actor->resource24->callback54(actor, 1);
        actor->position.value[2] = -0x49A;
        func_80039BE4(actor->objectIndex0C, 3);
        actor->callback00 = func_80005560;
    }
}

void func_80015218(EarlyGameActor *source)
{
    EarlyGameActor *actor;

    actor = (EarlyGameActor *)func_800283D4(
        9, &D_800B49A0, source->position.value);
    if (actor != 0) {
        actor->resource24->callback54(actor, 1);
        actor->angle08 = source->angle08 % 0x1000;
        actor->callback00 = func_80005560;
        func_80039514(actor->objectIndex0C, actor->angle08);
    }
}

int func_800152AC(int first, int second, int third, int fourth)
{
    func_80018E1C(first, second, 10, 10, third, fourth);
    return 0;
}
