#include "../../include/actor_animation_state.h"
#include "../../include/actor_motion_internal.h"
#include "../../include/actor_position_pairs.h"
#include "../../include/game_memory.h"

extern int D_800BB130;
extern int D_800BB134;

void func_80029FD8(void)
{
    GameActor *actor;
    int remaining;

    func_8003B694(D_800A4580, 0, sizeof(D_800A4580));
    actor = D_800AA708;
    D_800BB130 = 0;
    while (actor != 0) {
        if (actor->animationIndex == 9) {
            remaining = 300 - (int)((unsigned int)D_8009EFA0 - (unsigned int)actor->field48);
            if (actor->flags & 0x8000) {
                if (remaining > 0) {
                    func_80027B9C(actor, actor->unknown20,
                                 ((300 - remaining) << 10) / 300, 10);
                } else {
                    func_80039E5C(actor->objectIndex, 0);
                    actor->frame = 0x100;
                }
            } else if (remaining > 0) {
                func_80027B9C(actor, actor->unknown20,
                             (remaining << 10) / 300, 10);
            } else if (actor->unknown20 == 2) {
                func_80027B9C(actor, 0, 0, 10);
            } else if (actor->kind == 0 && actor->resource->actorKind == 1) {
                func_80027AB8(actor, 8, 1);
            } else {
                func_80027AB8(actor, 0, 1);
                actor->field48 = D_8009EFA0;
                ((void (*)(GameActor *, int))actor->field5C)(actor, 1);
            }
        } else if (actor->kind != 0 ||
                   (unsigned int)(D_8009EFA0 -
                       D_800AD138.timestamp68) >= 1301) {
            ((void (*)(GameActor *, int))actor->field5C)(actor, 0);
        }
        actor = actor->next;
    }
    D_800BB134 = D_800BB130;
}
