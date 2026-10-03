#include "../../../include/actor_behavior_internal.h"
#include "../../../include/scene_counter_internal.h"

extern int D_8009EFA0;
extern int D_800B6FD0;
extern int D_800B8F60;
extern int D_800BA74C;

void func_80015BD4(void *state);
void func_8001B4F8(ActorBehaviorActorInternal *actor, int value);
int func_80035244(ActorBehaviorActorInternal *actor, ActorBehaviorActorInternal *other);

int func_80015BF8(ActorBehaviorActorInternal *first,
                  ActorBehaviorActorInternal *second,
                  int *unusedFirstPosition, int *unusedSecondPosition)
{
    int savedCounter = second->field3C;
    int enabled = 1;
    short angle;
    int firstMagnitude;

    if (second->animation1F == 1) goto done;
    if (second->flags14 & 0x4400) goto done;

    switch (first->resource24->actorKind) {
    case 6:
        angle = func_8003CD4C(second->position[1] - first->position[1],
                             second->position[0] - first->position[0]);
        if ((func_8004CEF0(angle - first->angle08) & 2047) > 700) enabled = 0;
        break;
    case 7:
        angle = func_8003CD4C(second->position[1] - first->position[1],
                             second->position[0] - first->position[0]);
        if ((func_8004CEF0(angle - first->angle08) & 2047) > 1000) enabled = 0;
        break;
    case 8:
        angle = func_8003CD4C(second->position[1] - first->position[1],
                             second->position[0] - first->position[0]);
        if ((func_8004CEF0(angle - first->angle08) & 2047) > 850) enabled = 0;
        break;
    case 1:
        firstMagnitude = func_8004CEF0(first->position[2]);
        if (firstMagnitude > func_8004CEF0(D_800B8F60 / 2)) enabled = 0;
        break;
    case 33:
        if (first->animation1F != 3 && first->animation1F != 6 &&
            (unsigned int)(D_8009EFA0 - first->countdown54) > 500) {
            second->countdown54++;
            first->field3C = (int)second;
            func_80027AB8((GameActor *)first, 6, 1);
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
            first->flags14 |= 0x40,
                first->callback44 = (ActorBehaviorCallbackInternal)func_80015BD4,
                first->timer0E = 999;
        }
        if (second->countdown54 < D_800B6FD0) enabled = 0;
        break;
    }
    if (enabled) {
        func_80035244(second, first);
        if (first->unknown10[0] <= 0 || D_800BA74C != -1) {
            if (D_800BA74C == -1) {
                func_80037144(*(short *)((unsigned char *)first->resource24 + 4),
                              (SceneBucketCounter *)savedCounter);
            }
            func_8001B4F8(first, 0);
        }
    }
done:
    return 0;
}
