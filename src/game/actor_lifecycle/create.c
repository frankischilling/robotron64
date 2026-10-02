#include "../../../include/actor_lifecycle_internal.h"

ActorBehaviorActorInternal *func_8001AF44(int kind, int *position,
                                       ActorBehaviorActorInternal *parent)
{
    ActorBehaviorActorInternal *actor;
    int parentKind;
    short scale;

    parentKind = -1;
    if (parent != (ActorBehaviorActorInternal *)0xBEE0) {
        if (kind >= 21 && kind <= 24) {
            parentKind = kind - 4;
        } else if (kind >= 13 && kind <= 16) {
            parentKind = kind - 4;
        }
    } else {
        parent = 0;
    }
    if (parent == 0 && parentKind != -1) {
        for (parent = (ActorBehaviorActorInternal *)D_800AA708; parent != 0;
             parent = parent->next78) {
            if (parent->kind1C == 0 && parent->resource24->actorKind == parentKind) {
                break;
            }
        }
        if (parent == 0 && kind >= 13 && kind <= 16) {
            return 0;
        }
    }
    if (parent != 0) {
        position = parent->position;
    }
    actor = (ActorBehaviorActorInternal *)func_800283D4(0,
        (TextGlyphResource *)&D_800AF1F0[kind], position);
    if (actor == 0) {
        return 0;
    }
    func_80027AB8((GameActor *)actor, 9, 1);
    actor->mode20 = 1;
    switch (kind) {
    case 1:
        break;
    case 33:
    case 34:
        actor->position[2] = 0;
        actor->flags14 |= 2;
        actor->countdown54 = D_8009EFA0;
        break;
    case 9:
    case 10:
    case 11:
    case 12:
        actor->value22 = D_800B8F78.resourceLimits[D_800B8F78.unknown08];
        D_800B8F78.unknown08++;
        break;
    case 17:
    case 18:
    case 19:
    case 20:
        actor->value22 = D_800B8F78.secondaryLimits[D_800B8F78.unknown0C];
        D_800B8F78.unknown0C++;
        break;
    case 13:
    case 14:
    case 15:
    case 16:
    case 21:
    case 22:
    case 23:
    case 24:
        if (parent != 0) {
            scale = 0;
            func_800399E4(actor->objectIndex, (float)scale / 40960.0f);
            actor->field2C = 0;
            actor->field6C = func_8003CC88(actor->angle08) * 0 / 4096;
            actor->field70 = func_8003CC58(actor->angle08) * 0 / 4096;
            func_80039514(actor->objectIndex, actor->angle08);
            func_80027AB8((GameActor *)actor, 5, 1);
            actor->field3C = (int)parent;
            parent->field2C = 0;
            parent->field6C = func_8003CC88(parent->angle08) * 0 / 4096;
            parent->field70 = func_8003CC58(parent->angle08) * 0 / 4096;
            func_80039514(parent->objectIndex, parent->angle08);
            func_80027AB8((GameActor *)parent, 5, 1);
            if (kind >= 21 && kind <= 24) {
                if (parent->flags14 & 0x40) {
                    parent->flags14 &= ~0x40;
                    parent->callback44(parent);
                }
                parent->flags14 |= 0x40, parent->callback44 = func_80029C48,
                    parent->timer0E = 999;
            }
            if (kind >= 13 && kind <= 16) {
                if (parent->flags14 & 0x40) {
                    parent->flags14 &= ~0x40;
                    parent->callback44(parent);
                }
                parent->flags14 |= 0x40, parent->callback44 = func_80029B80,
                    parent->timer0E = 999;
            }
        }
        break;
    }
    D_800AD138.activeBehaviorActors[kind]++;
    if (D_800BA74C != -1) {
        D_800AE300.activeBehaviorActors[kind]++;
    }
    return actor;
}
