#include "../../../include/actor_collision_services.h"
#include "../../../include/early_parameter_internal.h"
#include "../../../include/actor_resource_5c_internal.h"

extern int D_800B8F60;
extern int D_800BA74C;
extern int D_800B6FD4;
extern int D_8009EFA0;
extern int D_800AC988;
int func_8003614C(int sound, int unused, int enabled, int fourth);
void func_8001B4F8(ActorBehaviorActorInternal *first, ActorBehaviorActorInternal *second);
void func_8002937C(ActorBehaviorActorInternal *actor);

unsigned char func_80016C1C(ActorBehaviorActorInternal *first,
                            ActorBehaviorActorInternal *second,
                            int *firstPosition, int *secondPosition)
{
    unsigned char result = 0;
    int kind;
    SceneBucketCounter *counter;
    int position[3];
    ActorBehaviorActorInternal *extra;
    unsigned char *color;
    short firstAngle;

    counter = (SceneBucketCounter *)second->field3C;
    if ((second->flags14 & 0x100) == 0) {
        position[0] = (secondPosition[0] + firstPosition[0]) / 2;
        position[1] = (secondPosition[1] + firstPosition[1]) / 2;
        position[2] = 0;
        kind = first->resource24->actorKind;
        switch (kind) {
        case 5: case 6: case 7: case 8:
            color = D_80073950[kind];
            func_80039C1C(first->objectIndex, color[0], color[1], color[2]);
            func_80015130((EarlyGameActor *)first, (EarlyGameActor *)second);
            if (first->unknown10[0] <= 0) {
                first->unknown10[0] = 3072;
                if (D_800AD138.value4C != 0) {
                    D_800AD138.value58--;
                    if (D_800AD138.value58 > 0) {
                        func_80037144(1000, counter);
                        extra = (ActorBehaviorActorInternal *)func_800283D4(9, &D_800B1BE8[10], position);
                        if (extra != 0) {
                            ((EarlyGameActorResource *)extra->resource24)->callback54((EarlyGameActor *)extra, 1);
                            extra->field48 -= D_800B6FD4 / 5;
                        }
                    }
                }
            }
            if (second->resource24->actorKind == 3) {
                func_80009F90((EarlyGameActor *)second, 0);
                result = 32;
            }
            func_80015184(143, position);
            if (D_800BA74C == -1) func_80037144(*(short *)((unsigned char *)first->resource24 + 4), counter);
            if (first->animation1F != 3) {
                first->countdown54 = second->field6C;
                first->field58 = second->field70;
                first->field6C += first->countdown54 / 30;
                first->field70 += first->field58 / 30;
            }
            second->field6C /= 2;
            second->field70 /= 2;
            first->field48 = D_8009EFA0;
            first->flags14 |= 0x10;
            firstAngle = first->angle08;
            second->angle08 = (second->angle08 + (firstAngle - second->angle08) / 2 + 2048) & 4095;
            second->field2C = second->resource24->speed / 2;
            second->field6C = func_8003CC88(second->angle08) * (second->resource24->speed / 2) / 4096;
            second->field70 = func_8003CC58(second->angle08) * (second->resource24->speed / 2) / 4096;
            func_80039514(second->objectIndex, second->angle08);
            second->field48 = D_8009EFA0;
            second->field48 -= (int)((unsigned int)((ActorResource5CInternal *)second->resource24)->value58 -
                                      (unsigned int)D_800AC988);
            second->flags14 |= 0x100;
            goto done;
        case 17: case 18: case 19: case 20:
            if (first->animation1F == 8) {
                func_8003614C(62, 0, 1, 0);
                func_80015184(19, secondPosition);
                goto done;
            }
            break;
        case 15: case 16:
            if (first->frame18 >= 1280 && first->frame18 <= 1792) goto done;
            break;
        case 11: case 12:
            if (first->frame18 >= 2048 && first->frame18 <= 2560) goto done;
            break;
        case 33: case 34:
            if (second->resource24->actorKind != 3 && second->resource24->actorKind != 1 &&
                second->resource24->actorKind != 2) goto done;
            break;
        case 1:
            if ((first->position[2] < 0 ? -first->position[2] : first->position[2]) >
                (D_800B8F60 / 2 < 0 ? -(D_800B8F60 / 2) : D_800B8F60 / 2)) {
                if (second->resource24->actorKind != 1 && second->resource24->actorKind != 2) goto done;
            }
            break;
        case 35:
            if (first->animation1F != 6) goto done;
            break;
        }
        func_80015130((EarlyGameActor *)first, (EarlyGameActor *)second);
        if (D_800BA74C != -1) func_8000EAF8((EarlyGameActor *)first, counter);
        if (first->unknown10[0] <= 0) {
            if (D_800BA74C == -1) func_80037144(*(short *)((unsigned char *)first->resource24 + 4), counter);
            func_8001B4F8(first, second);
        } else {
            color = D_80073950[first->resource24->actorKind];
            func_80039C1C(first->objectIndex, color[0], color[1], color[2]);
            func_80015184(19, position);
            if (first->resource24->actorKind == 2) {
                func_80027AB8((GameActor *)first, 8, 1);
                first->field2C = 0;
                func_8003CC88(first->angle08);
                first->field6C = 0;
                func_8003CC58(first->angle08);
                first->field70 = 0;
                func_80039514(first->objectIndex, first->angle08);
                if (first->flags14 & 0x40) {
                    first->flags14 &= ~0x40;
                    first->callback44(first);
                }
                first->flags14 |= 0x40, first->callback44 = func_8002937C, first->timer0E = 999;
            } else if ((first->resource24->actorKind >= 26 && first->resource24->actorKind < 29) ||
                       first->resource24->actorKind == 2) {
                func_80027AB8((GameActor *)first, 8, 1);
                first->field2C = 0;
                func_8003CC88(first->angle08);
                first->field6C = 0;
                func_8003CC58(first->angle08);
                first->field70 = 0;
                func_80039514(first->objectIndex, first->angle08);
                if (first->flags14 & 0x40) {
                    first->flags14 &= ~0x40;
                    first->callback44(first);
                }
                first->flags14 |= 0x40, first->callback44 = func_8002937C, first->timer0E = 999;
            } else {
                first->frame18 = (func_80039CD0(first->objectIndex) / 3) << 9;
            }
        }
        if (second->unknown10[0] <= 0) result = 32;
    } else {
        result = 32;
    }
done:
    return result;
}
