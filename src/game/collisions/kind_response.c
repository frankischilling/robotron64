#include "../../../include/actor_collision_services.h"

extern int D_800B8F60;
extern void func_8001B4F8(ActorBehaviorActorInternal *, ActorBehaviorActorInternal *);
#define COLLISION_ABS(value) ((value) < 0 ? -(value) : (value))

int func_80016950(ActorBehaviorActorInternal *first,
                 ActorBehaviorActorInternal *second,
                 int *firstPosition, int *secondPosition)
{
    unsigned char firstKind;
    unsigned int difference;

    if (func_80015614((EarlyGameActor *)second, (EarlyGameActor *)first,
                    (int)secondPosition, (int)firstPosition) == 0) return 0;
    firstKind = first->resource24->actorKind;
    if (firstKind == 27) {
        func_80018CC8(first, second, (int)firstPosition, (int)secondPosition);
        return 0;
    } else if (firstKind == 1) {
        /* Both threshold paths return zero; retain the retail calculation. */
        if (COLLISION_ABS(first->position[2]) > COLLISION_ABS(D_800B8F60 / 2)) return 0;
    } else {
        switch (second->resource24->actorKind) {
        case 8:
        case 9:
            func_80018CC8(first, second, (int)firstPosition, (int)secondPosition);
            first->flags14 |= 2;
            break;
        case 10:
        case 13:
            difference = firstPosition[0] - secondPosition[0];
            if (difference == 0) difference++;
            first->position[0] += (unsigned int)(D_8009EF94 * 1000) / difference;
            difference = firstPosition[1] - secondPosition[1];
            if (difference == 0) difference++;
            first->position[1] += (unsigned int)(D_8009EF94 * 1000) / difference;
            break;
        default:
            switch (firstKind) {
            case 0: case 1: case 2: case 3: case 4:
                func_8001B4F8(first, 0);
                if (second->resource24->actorKind != 12) {
                    func_8001A410(second, first);
                }
                break;
            case 13: case 14: case 15: case 16: case 29: case 30:
                if (second->resource24->actorKind == 13 || second->resource24->actorKind == 10) {
                    func_80018CC8(first, second, (int)firstPosition, (int)secondPosition);
                }
                break;
            case 5: case 6: case 7: case 8: case 25: case 26: case 27: case 28:
                func_8001A410(second, first);
                break;
            case 9: case 10: case 11: case 12: case 17: case 18: case 19: case 20:
                break;
            case 31: case 32: case 33: case 34: case 35:
            default:
                func_80018CC8(first, second, (int)firstPosition, (int)secondPosition);
                break;
            }
            break;
        }
    }
    return 0;
}
