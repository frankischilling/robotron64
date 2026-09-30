#include "../../include/actor_animation_state.h"

GameSessionState D_800AD138;

ActorBehaviorActorInternal *func_8001A350(TextGlyphResource *resource, int *position)
{
    ActorBehaviorActorInternal *actor;
    int random;

    actor = (ActorBehaviorActorInternal *)func_800283D4(1, resource, position);
    if (actor != 0) {
        random = func_8004CDE8();
        actor->frame18 = ((random >> 3) % func_80039CD0(actor->objectIndex)) << 8;
        D_800AD138.randomSpawnActors[resource->actorKind]++;
    }
    return actor;
}
