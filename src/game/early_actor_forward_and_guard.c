#include "../../include/early_game_state.h"
#include "../../include/actor_damage_internal.h"
#include "../../include/actor_collision_separation_internal.h"


int func_80015B5C(EarlyGameActor *actor, int value, int fifth, int sixth)
{
    func_80018E1C((ActorBehaviorActorInternal *)actor,
                   (ActorBehaviorActorInternal *)value,
                   100, 1, (int *)fifth, (int *)sixth);
    if (actor->animation1F != 1 && !(actor->flags14 & 0x4400)) {
        func_80035244((ActorBehaviorActorInternal *)actor,
                      (ActorBehaviorActorInternal *)value);
    }
    return 0;
}
