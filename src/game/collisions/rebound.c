#include "../../../include/actor_collision_services.h"
#include "../../../include/scene_counter_internal.h"

extern int D_800BA74C;
int func_8004CDE8(void);
int func_8003614C(int sound, int unused, int enabled, int fourth);
void func_800162F8(EarlyGameActor *actor);

unsigned char func_8001631C(ActorBehaviorActorInternal *first,
                            ActorBehaviorActorInternal *second,
                            int *firstPosition, int *secondPosition)
{
    int position[3];
    int result = 0;

    switch (first->resource24->actorKind) {
    case 14: case 15:
        func_80027AB8((GameActor *)first, 3, 1);
        if (first->flags14 & 0x40) {
            first->flags14 &= ~0x40;
            first->callback44(first);
        }
        first->flags14 |= 0x40, first->callback44 = (ActorBehaviorCallbackInternal)func_800162F8,
            first->timer0E = 999;
        break;
    case 11:
        if (second->resource24->actorKind == 1 || second->resource24->actorKind == 2) goto collide;
        break;
    case 12:
        if ((second->flags14 & 0x100) == 0) func_8003614C(84, 0, 1, 0);
        second->flags14 &= ~0x100;
        second->angle08 = (func_8004CDE8() >> 3) % 4096;
        second->field2C = second->resource24->speed * 7 / 10;
        second->field6C = func_8003CC88(second->angle08) * 7 * second->resource24->speed / 10 / 4096;
        second->field70 = func_8003CC58(second->angle08) * 7 * second->resource24->speed / 10 / 4096;
        func_80039514(second->objectIndex, second->angle08);
        break;
    default:
        if ((second->flags14 & 0x100) == 0) {
collide:
            func_80015130((EarlyGameActor *)second, (EarlyGameActor *)first);
            if (first->unknown10[0] <= 0) {
                if (D_800BA74C != -1) func_80037144(*(short *)((unsigned char *)first->resource24 + 4),
                                                   (SceneBucketCounter *)second->field3C);
                func_8001A410(first, second);
            } else {
                position[0] = (secondPosition[0] + firstPosition[0]) / 2;
                position[1] = (secondPosition[1] + firstPosition[1]) / 2;
                position[2] = 0;
                func_80015184(19, position);
            }
            if (second->unknown10[0] == 0) result = 32;
        } else result = 32;
        break;
    case 8: case 9: case 13:
        break;
    }
    return result;
}
