/* Excluded candidate: the complete instruction comparison still differs. */
#include "../../../include/actor_spawn_callback_internal.h"
#include "../../../include/early_game_helpers.h"
#include "../../../include/early_game_state.h"

extern ActorSpawnChildResourceInternal D_800ACCD4;
extern ActorSpawnChildResourceInternal D_800ACB08;

GameActor *func_8000F030(ActorBehaviorActorInternal *actor, int index, int kind)
{
    TextGlyphResource *resource;
    ActorBehaviorActorInternal *child;

    resource = (TextGlyphResource *)&D_800AC998[kind];
    child = (ActorBehaviorActorInternal *)func_800283D4(5,
                resource, actor->position);
    if (child != 0) {
        child->position[2] = -1000;
        if (resource == (TextGlyphResource *)&D_800ACB08) {
            ((ActorSpawnDrawPrefixInternal *)child)->draw00 = func_8000CE34(4);
        } else if (resource == (TextGlyphResource *)&D_800ACCD4) {
            ((EarlyGameActor *)child)->callback00 = func_80005560;
        } else {
            float scale;

            scale = (child->resource24->scale << 13) / 40960.0f;
            func_800399E4(child->objectIndex,
                         scale);
            func_80036ED0((int)child);
        }
        child->position[2] = -1000;
        {
            ActorBehaviorActorInternal *target;
            int angle;
            int movement;

            if (resource == (TextGlyphResource *)&D_800ACCD4) {
                angle = actor->angle08;
                movement = child->resource24->speed / 4;
            } else {
                target = D_8009B190[D_800AD168].actor08;
                angle = (func_8003CD4C(target->position[1] - actor->position[1],
                                       target->position[0] - actor->position[0]) +
                         (func_8004CDE8() >> 3) % 1024 + index * 80 - 912) & 4095;
                movement = ((func_8004CEF0(target->position[0] - actor->position[0]) +
                             func_8004CEF0(target->position[1] - actor->position[1])) /
                             3000 + 1) * child->resource24->speed / 60 * 7 / 10;
            }
            child->field2C = movement;
            child->field6C = func_8003CC88(angle) * movement / 4096;
            child->field70 = func_8003CC58(angle) * movement / 4096;
            func_80039514(child->objectIndex, angle);
            child->field3C = (int)actor;
            func_80039BE4(child->objectIndex, 3);
        }
    }
    return (GameActor *)child;
}
