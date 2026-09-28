#include "../../include/save_menu_nav_internal.h"

void func_80025E68(SaveMenuActorInternal *actor)
{
    func_80027AB8((GameActor *)actor, 0, 1);
    if (actor->flags14 & 0x40) {
        actor->flags14 &= ~0x40;
        actor->callback44(actor);
    }
    actor->flags14 |= 0x40, actor->callback44 = func_80025D9C,
        actor->value0E = 0x3E7;
}
