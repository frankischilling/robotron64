#include "../../include/scene_commands_internal.h"

GameActor *func_8001F240(TextGlyphResource *resource, int *position)
{
    GameActor *actor;

    actor = func_800283D4(3, resource, position);
    if (actor == 0) {
        return 0;
    }
    D_800AD138.activeSceneActors[resource->actorKind]++;
    func_8002A808(actor, 1);
    return actor;
}
