#include "../../include/early_game_state.h"
#include "../../include/actor_position_pairs.h"
#include "../../include/actor_resource_internal.h"

typedef struct ValueActorOwner {
    unsigned char unknown00[8];
    EarlyGameActor *primary08;
    EarlyGameActor *secondary0C;
} ValueActorOwner;

extern int D_8009EFA0;
void func_800290B0(int object, int *position);

void func_80035360(EarlyGameActor *actor, int value)
{
    EarlyGameActor *primary;
    int index;

    primary = ((ValueActorOwner *)actor->owner3C)->primary08;
    actor->position = primary->position;
    func_800290B0(actor->objectIndex0C, actor->position.value);
    func_80027A10(actor, primary);
    func_80039514(actor->objectIndex0C, D_8009EFA0 * 20);
    value = primary->value10[0] / 256;
    index = value >= 4 ? 3 : value;
    index = 3 - index;
    if (index != ((TextGlyphResource *)actor->resource24)->actorKind) {
        if (index != 0) {
            actor->state21 = 2;
            ((ValueActorOwner *)primary->owner3C)->secondary0C =
                (EarlyGameActor *)func_800283D4(6, &D_8009AFD8[index], actor->position.value);
            if (((ValueActorOwner *)primary->owner3C)->secondary0C != 0) {
                ((ValueActorOwner *)primary->owner3C)->secondary0C->owner3C = actor->owner3C;
            } else {
                ((ValueActorOwner *)primary->owner3C)->secondary0C = 0;
            }
        }
    }
}
