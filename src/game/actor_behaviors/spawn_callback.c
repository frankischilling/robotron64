#include "../../../include/actor_spawn_callback_internal.h"

void func_80029760(ActorBehaviorActorInternal *actor)
{
    ActorBehaviorActorInternal *child;
    int count;
    int kind;
    int index;
    int movement;
    int resourceKind;

    resourceKind = actor->resource24->actorKind;
    if (resourceKind == 24) {
        if (D_800C8B7C + 1 < 50) {
            if (((func_8004CDE8() >> 3) % 255 & 7U) != 0) {
                child = func_8001AF44(33, actor->position, 0);
            } else {
                child = func_8001AF44(34, actor->position, 0);
            }
            if (child != 0) {
                child->angle08 = (func_8004CDE8() >> 3) % 4096;
                child->field2C = child->resource24->speed;
                child->field6C = func_8003CC88(child->angle08) * child->resource24->speed / 4096;
                child->field70 = func_8003CC58(child->angle08) * child->resource24->speed / 4096;
                func_80039514(child->objectIndex, child->angle08);
                func_8003614C(99, 0, 1, 0);
            }
        }
    } else {
        count = resourceKind == 22 ? 2 : 1;
        kind = resourceKind != 23 ? 5 : 6;
        for (index = 0; index < count; index++) {
            if (D_800ACD90[kind] < D_800AC978) {
                child = (ActorBehaviorActorInternal *)func_800283D4(5,
                    (TextGlyphResource *)&D_800AC998[kind], actor->position);
                if (child != 0) {
                    func_80027AB8((GameActor *)child, 6, 1);
                    if (child->flags14 & 0x40) {
                        child->flags14 &= ~0x40;
                        child->callback44(child);
                    }
                    child->flags14 |= 0x40, child->callback44 = func_80029210,
                        child->timer0E = 999;
                    child->angle08 = actor->angle08 + index * 0x800;
                    if (actor->resource24->actorKind == 22) {
                        child->angle08 += 0x400;
                    }
                    movement = child->resource24->speed;
                    if (D_800AD300 == 0) {
                        movement = (movement << 2) / 10;
                    }
                    child->field2C = movement;
                    child->field6C = func_8003CC88(child->angle08) * movement / 4096;
                    child->field70 = func_8003CC58(child->angle08) * movement / 4096;
                    func_80039514(child->objectIndex, child->angle08);
                    if (kind == 5) {
                        ((ActorSpawnDrawPrefixInternal *)child)->draw00 = func_8000C2F4;
                    }
                    child->field3C = (int)actor;
                    if (actor->resource24->actorKind == 23) {
                        func_80036ED0((int)child);
                    }
                }
            }
        }
    }
    if (actor->flags14 & 0x40) {
        actor->flags14 &= ~0x40;
        actor->callback44(actor);
    }
    actor->flags14 |= 0x40, actor->callback44 = func_80029210,
        actor->timer0E = 999;
}
