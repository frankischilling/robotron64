#include "../../include/early_bonus_internal.h"

int func_8003614C(int sound, int mode, int value, int extra);

void func_8000F318(ActorBehaviorActorInternal *actor)
{
    int period;
    int kind;
    int index;
    unsigned int flags;

    if (D_800AD138.saved.level < 170 || D_800AD138.animationIndex9C >= 4) {
        period = 2;
    } else {
        period = 3;
    }
    kind = D_80073570++ % period;
    if (kind == 0) {
        kind = 9;
        func_8003614C(13, 0, 1, 0);
    } else if (kind == 1) {
        kind = 4;
        func_8003614C(13, 0, 1, 0);
        D_8009734C = 3;
        D_80097344 = D_8009EFA0;
    } else {
        kind = 6;
        func_8003614C(13, 0, 1, 0);
    }
    if (kind == 9) {
        D_80097348 = 30;
        D_80097340 = D_8009EFA0;
    } else {
        for (index = 0; index < 10; index++) {
            if (kind == 6) index += 2;
            func_8000F030(actor, index, kind);
        }
    }
    flags = actor->flags14;
    if (flags & 0x40) {
        actor->flags14 = flags & ~0x40;
        actor->callback44(actor);
        flags = actor->flags14;
    }
    actor->flags14 = flags | 0x40, actor->callback44 = func_8000FBC0,
        actor->timer0E = 999;
}
