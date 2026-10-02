#include "../../include/actor_behavior_internal.h"
#include "../../include/save_game.h"
#include "../../include/game_memory.h"
#include "../../include/actor_motion_internal.h"
extern int D_800AD288, D_8009EFA0, D_800BA74C;
extern unsigned char D_800A4560[], D_800A4570[], D_8009AFC8[];
void func_80029154(ActorBehaviorActorInternal *);
void func_80029210(ActorBehaviorActorInternal *);
void func_80032F70(void);
int func_80039D4C(int object, int value);
struct SessionSetupCommand;
void func_8002E65C(struct SessionSetupCommand *);
void func_80036B00(int, ActorBehaviorActorInternal *, int *);
void func_800354C8(ActorBehaviorActorInternal *actor, ActorBehaviorActorInternal *other)
{
    int handled = 0;
    int speed;
    GamePlayerState *owner;
    int i;
    if (D_800AD288 != 3) return;
    owner = (GamePlayerState *)actor->field3C;
    /* Pinned IDO retains the widened increment for the modulo operation.
     * The retail byte-255 case produces one; see the recovery document. */
    owner->saved.unknown00[3]++;
    owner->saved.unknown00[3] %= 5;
    if (actor->flags14 & 0x40) { actor->flags14 &= ~0x40; actor->callback44(actor); }
    actor->flags14 |= 0x40, actor->callback44 = func_80029154, actor->timer0E = 999;
    actor->field48 = D_8009EFA0;
    switch (other->kind1C) {
    case 0:
        switch (other->resource24->actorKind) {
        case 0: case 1: case 2: case 3: case 4: default:
            *(TextValue3 *)other->position = *(TextValue3 *)actor->position;
            other->angle08 = actor->angle08;
            func_800290B0(other->objectIndex, other->position);
            other->field2C = speed = 0;
            other->field6C = func_8003CC88(other->angle08) * speed / 4096;
            other->field70 = func_8003CC58(other->angle08) * speed / 4096;
            func_80039514(other->objectIndex, other->angle08);
            func_80027AB8((GameActor *)other, 4, 1);
            actor->field48 = D_8009EFA0;
            break;
        case 5:
            *(TextValue3 *)actor->position = *(TextValue3 *)other->position;
            actor->angle08 = other->angle08;
            func_800290B0(actor->objectIndex, actor->position);
            actor->field2C = speed = 0;
            actor->field6C = func_8003CC88(actor->angle08) * speed / 4096;
            actor->field70 = func_8003CC58(actor->angle08) * speed / 4096;
            func_80039514(actor->objectIndex, actor->angle08);
            func_8003B520(&actor->resource24->animation.tracks[1]->field08, D_800A4560, 8);
            func_80027AB8((GameActor *)actor, 1, 1);
            func_80027AB8((GameActor *)other, 3, 1);
            other->field2C = speed = 0;
            other->field6C = func_8003CC88(other->angle08) * speed / 4096;
            other->field70 = func_8003CC58(other->angle08) * speed / 4096;
            func_80039514(other->objectIndex, other->angle08);
            if (other->flags14 & 0x40) { other->flags14 &= ~0x40; other->callback44(other); }
            other->flags14 |= 0x40, other->callback44 = func_8002BF88, other->timer0E = 999;
            other->field4C = 500; handled = 1; break;
        case 6:
            other->angle08 = 1024; actor->angle08 = other->angle08;
            actor->field2C = speed = 0;
            actor->field6C = func_8003CC88(actor->angle08) * speed / 4096;
            actor->field70 = func_8003CC58(actor->angle08) * speed / 4096;
            func_80039514(actor->objectIndex, actor->angle08);
            func_8003B520(&actor->resource24->animation.tracks[1]->field08, &actor->resource24->animation.tracks[0]->field08, 8);
            func_80027AB8((GameActor *)actor, 1, 1);
            func_80027AB8((GameActor *)other, 3, 1);
            other->field2C = speed = 0;
            other->field6C = func_8003CC88(other->angle08) * speed / 4096;
            other->field70 = func_8003CC58(other->angle08) * speed / 4096;
            func_80039514(other->objectIndex, other->angle08);
            func_80039D4C(other->objectIndex, 1);
            if (other->flags14 & 0x40) { other->flags14 &= ~0x40; other->callback44(other); }
            other->flags14 |= 0x40, other->callback44 = func_80029210, other->timer0E = 999;
            func_80039DCC(actor->objectIndex, 108);
            func_80039C5C(actor->objectIndex, other->objectIndex);
            func_80039D4C(actor->objectIndex, 1);
            handled = 1; break;
        case 7:
            other->angle08 = func_8003CD4C(actor->position[1] - other->position[1], actor->position[0] - other->position[0]);
            actor->angle08 = 1024; other->angle08 = actor->angle08;
            actor->field2C = speed = 0;
            actor->field6C = func_8003CC88(actor->angle08) * speed / 4096;
            actor->field70 = func_8003CC58(actor->angle08) * speed / 4096;
            func_80039514(actor->objectIndex, actor->angle08);
            func_8003B520(&actor->resource24->animation.tracks[1]->field08, &actor->resource24->animation.tracks[0]->field08, 8);
            actor->resource24->animation.tracks[1]->frameDuration /= 4;
            func_80027AB8((GameActor *)actor, 1, 1);
            func_80039D4C(actor->objectIndex, 1); func_80036B00(190, actor, 0);
            func_80027AB8((GameActor *)other, 3, 1);
            other->field2C = speed = 0;
            other->field6C = func_8003CC88(other->angle08) * speed / 4096;
            other->field70 = func_8003CC58(other->angle08) * speed / 4096;
            func_80039514(other->objectIndex, other->angle08);
            func_80039D4C(other->objectIndex, 1);
            if (other->flags14 & 0x40) { other->flags14 &= ~0x40; other->callback44(other); }
            other->flags14 |= 0x40, other->callback44 = func_80029210, other->timer0E = 999;
            func_80039DCC(actor->objectIndex, 110);
            func_80039C5C(actor->objectIndex, other->objectIndex);
            func_80039D4C(actor->objectIndex, 1);
            handled = 1; break;
        case 8:
            actor->angle08 = 1024; other->angle08 = actor->angle08;
            actor->field2C = speed = 0;
            actor->field6C = func_8003CC88(actor->angle08) * speed / 4096;
            actor->field70 = func_8003CC58(actor->angle08) * speed / 4096;
            func_80039514(actor->objectIndex, actor->angle08);
            func_8003B520(&actor->resource24->animation.tracks[1]->field08, D_8009AFC8, 8);
            func_80027AB8((GameActor *)actor, 1, 1);
            func_80027AB8((GameActor *)other, 3, 1);
            other->field2C = speed = 0;
            other->field6C = func_8003CC88(other->angle08) * speed / 4096;
            other->field70 = func_8003CC58(other->angle08) * speed / 4096;
            func_80039514(other->objectIndex, other->angle08);
            func_80039D4C(other->objectIndex, 1);
            func_80039DCC(actor->objectIndex, 109);
            func_80039C5C(actor->objectIndex, other->objectIndex);
            func_80039D4C(actor->objectIndex, 1);
            handled = 1; break;
        }
        break;
    case 1:
        func_8003B520(&actor->resource24->animation.tracks[1]->field08, D_800A4570, 8);
        func_80027AB8((GameActor *)actor, 1, 1);
        handled = 1; break;
    case 8: break;
    }
    if (!handled) {
        func_8003B520(&actor->resource24->animation.tracks[1]->field08, D_8009AFC8, 8);
        func_80027AB8((GameActor *)actor, 1, 1);
    }
    actor->field6C = 0; actor->field70 = 0;
    if (D_800BA74C == -1 && (D_800AD138.saved.extra48 != 3 || D_8009B190[D_800AD138.saved.playerChoices38[0]].saved.active + D_8009B190[D_800AD138.saved.playerChoices38[1]].saved.active < 2)) {
        func_80039BFC(owner->saved.actor08->objectIndex, 0);
        func_80032F70(); func_8002E65C((struct SessionSetupCommand *)other);
    } else if (D_800AD138.saved.extra48 == 3) {
        D_800AD138.saved.selection34 = owner - D_8009B190;
        for (i = 0; i < D_800AD138.saved.mode; i++) {
            D_800AD138.saved.selection34++;
            if (D_800AD138.saved.selection34 >= D_800AD138.saved.mode) D_800AD138.saved.selection34 = 0;
            D_800AD138.saved.currentPlayer = D_800AD138.saved.playerChoices38[D_800AD138.saved.selection34];
            if (D_8009B190[D_800AD138.saved.currentPlayer].saved.active > 0) break;
        }
    }
    func_80039E0C(actor->objectIndex, 9);
}
