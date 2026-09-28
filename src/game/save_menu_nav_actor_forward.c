#include "../../include/save_menu_nav_internal.h"

void func_80025D9C(SaveMenuActorInternal *actor)
{
    if ((unsigned int)(D_8009EFA4 - D_800AEE98.timestamp00) >= 0x3A99U) {
        func_80027AB8((GameActor *)actor, 5, 1);
    } else {
        func_80027AB8((GameActor *)actor,
                      D_80077A8C[(unsigned int)(func_8004CDE8() >> 3) % 5U], 1);
    }
    if (actor->flags14 & 0x40) {
        actor->flags14 &= ~0x40;
        actor->callback44(actor);
    }
    actor->flags14 |= 0x40, actor->callback44 = func_80025E68,
        actor->value0E = 0x3E7;
}
