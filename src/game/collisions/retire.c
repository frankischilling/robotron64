#include "../../../include/actor_behavior_internal.h"
#include "../../../include/early_pool_tick.h"
#include "../../../include/early_game_state.h"

extern int D_800BA74C;
extern TextGlyphResource D_8009F878;
extern const char D_80090200[28];
ActorBehaviorActorInternal *func_8001A350(TextGlyphResource *resource, int *position);
void func_8001B3DC(EarlyGameActor *actor);
void func_8001B448(void *actor, int value);
void func_8001B468(EarlyGameActor *actor);
void func_800366C8(ActorBehaviorActorInternal *actor);
void func_80036B00(int kind, ActorBehaviorActorInternal *actor, int *impulse);

void func_8001B4F8(ActorBehaviorActorInternal *actor, ActorBehaviorActorInternal *other)
{
    actor->unknown10[0] = 0;
    if (D_800BA74C != -1) {
        D_800AE300.retiredBehaviorCounts[actor->resource24->actorKind]++;
    }
    switch (actor->resource24->actorKind) {
    case 34:
        func_80009F90((EarlyGameActor *)actor, 0);
        break;
    case 4:
        func_8001A350(&D_8009F878, actor->position);
    case 0: case 1: case 2: case 3:
    case 13: case 14: case 15: case 16:
    case 21: case 22: case 23: case 24:
    case 30: case 31: case 32: case 33: case 35:
        func_80009F90((EarlyGameActor *)actor, 0);
        func_8001B3DC((EarlyGameActor *)actor);
        break;
    case 9: case 10: case 11: case 12:
        func_80039EB8(10, 5);
        func_800366C8(actor);
        func_80009F90((EarlyGameActor *)actor, 0);
        break;
    case 17: case 18: case 19: case 20:
        func_80039EB8(10, 5);
        func_800366C8(actor);
        func_8001B3DC((EarlyGameActor *)actor);
        if (actor->flags14 & 0x40) {
            actor->flags14 &= ~0x40;
            actor->callback44(actor);
        }
        actor->flags14 |= 0x40, actor->callback44 = (ActorBehaviorCallbackInternal)func_8001B468,
            actor->timer0E = 1;
        break;
    case 25: case 26: case 27: case 28:
        actor->flags14 &= ~0x40;
        if (other != 0) {
            func_80036B00(189, actor, &other->field6C);
        } else {
            func_80036B00(189, actor, 0);
        }
        func_8001B448(actor, 1);
        break;
    case 29:
        func_800366C8(actor);
        break;
    default:
        func_8001C0D0((char *)D_80090200);
    case 5: case 6: case 7: case 8:
        break;
    }
    if (actor->resource24->actorKind != 5) {
        func_80027AB8((GameActor *)actor, 1, 1);
        actor->field2C = 0;
        func_8003CC88(actor->angle08);
        actor->field6C = 0;
        func_8003CC58(actor->angle08);
        actor->field70 = 0;
        func_80039514(actor->objectIndex, actor->angle08);
        actor->field34 = -1;
    }
    if (actor->resource24->actorKind < 17 || actor->resource24->actorKind > 20) {
        if (actor->flags14 & 0x40) {
            actor->flags14 &= ~0x40;
            actor->callback44(actor);
        }
        actor->flags14 |= 0x40, actor->callback44 = func_8001B324,
            actor->timer0E = 999;
    }
}
