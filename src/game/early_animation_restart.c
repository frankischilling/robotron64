#include "../../include/early_game_state.h"
#include "../../include/early_game_more.h"

void func_8000FBC0(ActorBehaviorActorInternal *actor);

void func_8000F4E0(EarlyGameActor *actor)
{
    func_80009F90(actor, 0);
    if (actor->flags14 & 0x40) {
        actor->flags14 &= ~0x40;
        actor->callback44((ActorBehaviorActorInternal *)actor);
    }
    actor->flags14 |= 0x40, actor->callback44 = func_8000FBC0,
        actor->timer0E = 999;
}
