#include "../../include/actor.h"

extern GameActor *D_800AA708;
extern void func_80028274(GameActor *actor, GameActor *previous);

void func_8002836C(void)
{
    GameActor *actor;
    GameActor *previous;

    actor = D_800AA708;
    previous = 0;
    while (actor != 0) {
        if (actor->state != 0) {
            func_80028274(actor, previous);
        } else {
            previous = actor;
        }
        actor = actor->next;
    }
}
