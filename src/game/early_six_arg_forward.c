#include "../../include/early_game_helpers.h"
#include "../../include/actor_collision_separation_internal.h"


int func_80016914(int first, int second, int third, int fourth)
{
    func_80018E1C((ActorBehaviorActorInternal *)first,
                   (ActorBehaviorActorInternal *)second,
                   100, 0, (int *)third, (int *)fourth);
    return 0;
}
