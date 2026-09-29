#include "../../include/early_game_state.h"
#include "../../include/scalar_math.h"

extern int D_8009EFA0;
extern void func_80029210(EarlyGameActor *actor);
extern void func_800290B0(int object, int *position);

void func_80015554(EarlyGameActor *actor)
{
    unsigned int flags;

    func_80027AB8((GameActor *)actor, 6, 1);
    actor->position = actor->owner3C->actor10->position;
    func_800290B0(actor->objectIndex0C, &actor->position.x);

    flags = actor->flags14;
    actor->field48 = D_8009EFA0;
    if (flags & 0x40) {
        actor->flags14 = flags & ~0x40;
        actor->callback44(actor);
        flags = actor->flags14;
    }
    actor->flags14 = flags | 0x40, actor->callback44 = func_80029210,
        actor->timer0E = 999;
}

int func_80015614(EarlyGameActor *first, EarlyGameActor *second,
                  int third, int fourth)
{
    if (first->angle08 == 0) {
        return func_8004CEF0(second->position.x - first->position.x) < 500;
    }
    return func_8004CEF0(second->position.y - first->position.y) < 500;
}
