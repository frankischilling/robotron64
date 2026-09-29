#include "../../include/early_game_medium.h"

extern void func_80029E5C(EarlyGameActor *actor);

int func_80017C10(EarlyGameActor *actor, EarlyGameActor *other,
                  int unused2, int unused3)
{
    unsigned int flags;

    if (((TextGlyphResource *)other->resource24)->actorKind == 8 &&
        ((TextGlyphResource *)actor->resource24)->actorKind < 4) {
        flags = actor->flags14;
        if (flags & 0x40) {
            actor->flags14 = flags & ~0x40;
            actor->callback44(actor);
            flags = actor->flags14;
        }
        actor->flags14 = flags | 0x40, actor->callback44 = func_80029E5C,
            actor->timer0E = 999;
        func_80027AB8((GameActor *)actor, 3, 1);
        actor->field6C = 0;
        actor->field70 = 0;
    }
    return 0;
}
