#include "../../include/actor_history_internal.h"

GameActor *func_8004E1C0(GameActor *parent, int angleOffset, int unusedKind)
{
    struct { int x; int z; } velocity;
    ActorHistoryProjectile *projectile;
    ActorHistoryProjectile *origin;
    int slot;
    unsigned char *flag;
    origin = (ActorHistoryProjectile *)parent;
    flag = D_8008D494;
    for (slot = 0; slot != 24; slot++, flag++) {
        if (*flag == 0) break;
    }
    if (slot >= 24) return 0;
    projectile = (ActorHistoryProjectile *)func_800283D4(5, &D_800ACC1C, origin->position60);
    if (projectile == 0) return 0;
    projectile->position60[0] = origin->position60[0];
    projectile->position60[1] = origin->position60[1];
    projectile->position60[2] = origin->position60[2];
    projectile->callback00 = func_8004E364;
    projectile->angle08 = origin->angle08 + angleOffset;
    projectile->parent3C = parent;
    projectile->value2C = 20;
    velocity.x = func_8003CC88(projectile->angle08) * 20 / 4096;
    projectile->velocity6C = velocity.x;
    velocity.z = func_8003CC58(projectile->angle08) * 20 / 4096;
    projectile->velocity70 = velocity.z;
    func_80039514(projectile->objectIndex0C, projectile->angle08);
    projectile->callback5C = func_8004DEE0;
    *flag = 1;
    projectile->history54 = &D_8013EC00[slot * 16];
    projectile->value48 = 180;
    projectile->historyIndex4C = 0;
    projectile->historyState50 = 1;
    return (GameActor *)projectile;
}
