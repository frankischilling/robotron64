#include "../../include/actor.h"
#include "../../include/object_history.h"

extern GameActor *D_800AA708;
extern int D_800A4620;
extern int D_800ACD90[];

extern int func_800392F4(int object);

void func_80028274(GameActor *actor, GameActor *previous)
{
    unsigned char actorKind;

    func_800392F4(actor->objectIndex);
    if (previous != 0) {
        previous->next = actor->next;
    } else {
        D_800AA708 = actor->next;
    }
    if (actor->next == 0 && previous == 0) {
        D_800AA708 = 0;
    }

    if (actor->kind == 5) {
        actorKind = actor->resource->actorKind;
        if (actorKind == 7 || actorKind == 8) {
            func_8004E168(actor);
            actorKind = actor->resource->actorKind;
        }
        D_800ACD90[actorKind]--;
    }

    actor->kind = 11;
    D_800A4620--;
}
