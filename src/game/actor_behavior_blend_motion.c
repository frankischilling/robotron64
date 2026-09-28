#include "../../include/actor_behavior_internal.h"

void func_8002A5DC(ActorBehaviorActorInternal *actor, int duration)
{
    int remaining;
    int previousAngle;
    int angle;
    int previousValue;

    previousAngle = actor->previousAngle0A;
    angle = actor->angle08;
    if (angle - previousAngle >= 0x801) {
        previousAngle += 0x1000;
    }
    if (previousAngle - angle >= 0x801) {
        angle += 0x1000;
    }

    actor->parameter38 -= D_8009EF94;
    if (actor->parameter38 < 0) {
        actor->parameter38 = 0;
    }

    remaining = duration - actor->parameter38;
    previousValue = func_8003CC88(previousAngle);
    actor->field6C =
        (func_8003CC88(angle) * remaining * actor->field30 +
         actor->parameter38 * previousValue * actor->field30) /
        (duration << 12);

    previousValue = func_8003CC58(previousAngle);
    actor->field70 =
        (func_8003CC58(angle) * remaining * actor->field2C +
         actor->parameter38 * previousValue * actor->field2C) /
        (duration << 12);

    func_80039514(actor->objectIndex,
                  (actor->parameter38 * previousAngle + remaining * angle) /
                      duration);
}
