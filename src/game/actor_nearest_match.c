#include "../../include/actor_motion_internal.h"

GameActor *func_80027D8C(ActorMotionPositionInternal *position, int kind,
                         int immediate, int actorKindLimit, int animation)
{
    GameActor *actor;
    GameActor *best;
    int bestDistance;
    int x;
    int y;
    int distance;

    actor = D_800AA708;
    bestDistance = 0x7FFFFFFF;
    best = 0;
    while (actor != 0) {
        if (actor->kind == kind &&
            (actorKindLimit == 0 || actor->resource->actorKind < actorKindLimit) &&
            (animation == 0xDEAD || actor->animationIndex == animation)) {
            if (immediate != 0) {
                return actor;
            }
            x = actor->position[0] - position->x;
            y = actor->position[1] - position->y;
            x = func_8004CEF0(x);
            y = func_8004CEF0(y);
            distance = x + y;
            if (distance < bestDistance) {
                bestDistance = distance;
                best = actor;
            }
        }
        actor = actor->next;
    }
    return best;
}
