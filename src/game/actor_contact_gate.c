#include "../../include/actor_behavior_internal.h"

/* Excluded from the retail build until the complete procedure matches. */
typedef struct ActorContactPoint {
    int value[3];
} ActorContactPoint;

/* Only the shared kind byte and the signed halfword at 0x5A are used here. */
typedef struct ActorContactResource {
    unsigned char unknown00[2];
    unsigned char kind02;
    unsigned char unknown03[0x57];
    short value5A;
} ActorContactResource;

extern int D_800BA74C;
extern int D_800B8F60;
void func_80018E1C(ActorBehaviorActorInternal *first,
                   ActorBehaviorActorInternal *second, int firstValue,
                   int secondValue, ActorContactPoint *firstPosition,
                   ActorContactPoint *secondPosition);

#define CONTACT_ABSOLUTE(value) \
    ((value) < 0 ? (value) * -1 : (value))

int func_8001669C(ActorBehaviorActorInternal *first,
                  ActorBehaviorActorInternal *second,
                  ActorContactPoint *firstInput, ActorContactPoint *secondInput)
{
    ActorBehaviorActorInternal *saved;
    ActorContactPoint temporary;
    ActorContactPoint firstPosition;
    ActorContactPoint secondPosition;
    short firstKind;
    short secondKind;

    firstPosition = *firstInput;
    secondPosition = *secondInput;
    if (D_800BA74C != -1) {
        return 0;
    }
    firstKind = ((ActorContactResource *)first->resource24)->kind02;
    if (firstKind == 33 || firstKind == 34) {
        switch (firstKind) {
        case 33:
        case 34:
            break;
        default:
            return 0;
        }
    }
    if ((firstKind >= 17 && firstKind < 21) ||
        ((secondKind = ((ActorContactResource *)second->resource24)->kind02) >= 17 &&
         secondKind < 21)) {
        return 0;
    }
    if (secondKind < firstKind) {
        temporary = firstPosition;
        firstPosition = secondPosition;
        secondPosition = temporary;
        saved = first;
        first = second;
        second = saved;
        firstKind = ((ActorContactResource *)first->resource24)->kind02;
    }
    if (firstKind == 5 && first->animation1F != 3) {
        first->flags14 |= 2;
    }
    if (((ActorContactResource *)second->resource24)->kind02 == 5 &&
        second->animation1F != 3) {
        second->flags14 |= 2;
    }
    if (CONTACT_ABSOLUTE(first->position[2] - second->position[2]) >
        CONTACT_ABSOLUTE(D_800B8F60 / 2)) {
        return 0;
    }
    if (second->field28 && first->field28) {
        return 0;
    }
    func_80018E1C(first, second,
                  ((ActorContactResource *)first->resource24)->value5A,
                  ((ActorContactResource *)second->resource24)->value5A,
                  &firstPosition, &secondPosition);
    return 0;
}
