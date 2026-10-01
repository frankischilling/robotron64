#include "../../include/actor_history_internal.h"
#include "../../include/actor_behavior_more_internal.h"
#include "../../include/early_game_state.h"
void func_8000A2E0(EarlyGameActor *first, EarlyGameActor *second, int *distance, int *angle);
void func_8000E6F0(GameActor *actor);
void func_8004DEE0(GameActor *actor, int unused)
{
    ActorBehaviorActorInternal *playerActor;
    ActorHistoryProjectile *projectile;
    ActorHistoryPoint *point;
    ActorHistoryPoint *history;
    int distance;
    int angle;
    int index;
    projectile = (ActorHistoryProjectile *)actor;
    if (D_8009EF94 != 0) {
        playerActor = D_8009B190[D_800AD168].actor08;
        if (--projectile->value48 == 0) {
            projectile->callback00 = 0;
            func_8000E6F0(actor);
            return;
        }
        projectile->historyState50--;
        if (projectile->historyState50 < 0 && (unsigned int)projectile->value48 < 120U) {
            projectile->historyState50 = 1;
            func_8000A2E0((EarlyGameActor *)playerActor,
                           (EarlyGameActor *)actor, &distance, &angle);
            if (angle > 0) projectile->angle08 += 300;
            else projectile->angle08 -= 300;
            projectile->angle08 &= 0xfff;
            projectile->value2C = 30;
            projectile->velocity6C = func_8003CC88(projectile->angle08) * 30 / 4096;
            projectile->velocity70 = func_8003CC58(projectile->angle08) * 30 / 4096;
            func_80039514(projectile->objectIndex0C, projectile->angle08);
        }
        history = projectile->history54;
        index = projectile->historyIndex4C;
        point = (ActorHistoryPoint *)((char *)history + (index & 15) * 12);
        /* Retain the intermediate coordinate stores emitted by IDO. */
        do {
            point->value[0] = (int)((float)projectile->position60[0] * 1400.0f / 60000.0f);
            point->value[1] = (int)((float)projectile->position60[2] * 1400.0f / 60000.0f);
            point->value[2] = (int)((float)projectile->position60[1] * 1400.0f / 60000.0f);
            point->value[0] *= 12;
            point->value[1] *= 12;
        } while (0);
        point->value[2] *= 12;
        point->value[1] = 400;
        projectile->historyIndex4C++;
    }
}
