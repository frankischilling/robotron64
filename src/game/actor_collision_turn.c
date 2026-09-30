#include "../../include/actor_collision_services.h"
#include "../../include/early_game_state.h"
#include "../../include/save_game.h"

#include "../../include/early_game_more.h"

void func_8001A410(ActorBehaviorActorInternal *first,
                  ActorBehaviorActorInternal *second)
{
    func_80009F90((EarlyGameActor *)first, 3);
    if (first->resource24->actorKind == 11 || first->resource24->actorKind == 12) {
        first->state21 = 2;
    } else {
        func_80027AB8((GameActor *)first, 1, 1);
        first->angle08 = (second->angle08 + 0x800) & 0xFFF;
        first->field2C = 0;
        func_8003CC88(first->angle08);
        first->field6C = 0;
        func_8003CC58(first->angle08);
        first->field70 = 0;
        func_80039514(first->objectIndex, first->angle08);
        first->field34 = -1;
        if (first->flags14 & 0x40) {
            first->flags14 &= ~0x40;
            first->callback44(first);
        }
        first->flags14 |= 0x40, first->callback44 = func_8001B324,
            first->timer0E = 999;
    }
    D_800AD138.randomSpawnActors[first->resource24->actorKind]--;
}
