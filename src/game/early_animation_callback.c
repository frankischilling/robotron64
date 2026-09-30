#include "../../include/early_session_state.h"

extern int D_8009EFA0;
void func_8000FBC0(ActorBehaviorActorInternal *actor);

void func_8000ECE4(EarlyGameActor *actor, int animation,
                   ActorBehaviorCallbackInternal callback, int timer, int value)
{
    D_800AD138.value8C = value;
    func_80027AB8((GameActor *)actor, animation, 1);
    if (callback != 0) {
        if (actor->flags14 & 0x40) {
            actor->flags14 &= ~0x40;
            actor->callback44((ActorBehaviorActorInternal *)actor);
        }
        actor->flags14 |= 0x40;
        actor->callback44 = callback;
        actor->timer0E = timer;
    } else {
        if (actor->flags14 & 0x40) {
            actor->flags14 &= ~0x40;
            actor->callback44((ActorBehaviorActorInternal *)actor);
        }
        actor->flags14 |= 0x40, actor->callback44 = func_8000FBC0,
            actor->timer0E = 999;
    }
    actor->field48 = D_8009EFA0;
}
