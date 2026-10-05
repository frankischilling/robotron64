#include "../../../include/actor_damage_internal.h"
#include "../../../include/early_game_state.h"

typedef struct ActorDamageOwner {
    unsigned char unknown00[12];
    ActorBehaviorActorInternal *actor0C;
} ActorDamageOwner;

extern int D_8007D8FC;
extern int D_800B6FD0;
extern int D_8009EFA0;

int func_80035244(ActorBehaviorActorInternal *actor, ActorBehaviorActorInternal *other)
{
    int previous = 0;
    /* This initialized test preserves IDO register allocation. */
    if (!previous) {
    }
    previous = actor->unknown10[0];
    if (D_8007D8FC != 0) {
        return 0;
    }
    if (other->kind1C != 0 || other->resource24->actorKind < 5 ||
        other->resource24->actorKind >= 9) {
        func_80015130((EarlyGameActor *)other, (EarlyGameActor *)actor);
    } else {
        actor->unknown10[0] -= other->unknown10[0];
    }
    func_80035190(((ActorDamageOwner *) actor->field3C)->actor0C, actor->unknown10[0], previous);
    if (actor->unknown10[0] <= 0 || actor->countdown54 >= D_800B6FD0) {
        func_80039C1C(actor->objectIndex, 200, 200, 200);
        func_800354C8(actor, other);
        return 1;
    }
    actor->flags14 |= 0x4000;
    actor->field48 = D_8009EFA0;
    return 0;
}
