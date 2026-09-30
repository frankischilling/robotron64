#include "../../include/actor_behavior_internal.h"
#include "../../include/save_game.h"
#include "../../include/scene_definition.h"

void func_8001B324(ActorBehaviorActorInternal *actor)
{
    int state = actor->state21;

    actor->state21 = 2;
    if (actor->kind1C == 0) {
        if (state == 0) {
            D_800AD138.activeBehaviorActors[actor->resource24->actorKind]--;
        }
        switch (actor->resource24->actorKind) {
            case 17:
            case 18:
            case 19:
            case 20:
                D_800B8F78.unknown0C--;
                break;
            case 9:
            case 10:
            case 11:
            case 12:
                D_800B8F78.unknown08--;
                break;
        }
    }
}
