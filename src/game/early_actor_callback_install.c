#include "../../include/early_game_state.h"
#include "../../include/text.h"

extern int D_8007596C;

void func_8001B468(EarlyGameActor *actor)
{
    func_80039DCC(actor->objectIndex0C, D_8007596C);
    if (actor->flags14 & 0x40) {
        actor->flags14 &= ~0x40;
        actor->callback44((ActorBehaviorActorInternal *)actor);
    }
    actor->flags14 |= 0x40, actor->callback44 = func_8001B324,
        actor->timer0E = 999;
}
