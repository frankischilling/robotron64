#include "../../../include/early_parameter_internal.h"
#include "../../../include/geometry_bridge_internal.h"
void func_8000E7E0(int *destination, int *source, int angle);
void func_8000E5C8(EarlyGameActor *actor, int initialize);

/* Excluded candidate; complete instruction comparison still differs. */
void func_8000E894(EarlyGameActor *actor, int unused)
{
    int speed;
    ActorDynamicPairGroup *path;
    int index;
    int step;
    ActorDynamicParameter *parameter;
    int distance;
    GeometryPoint first;
    GeometryPoint second;
    int heading;
    int progress;
    parameter = (ActorDynamicParameter *) actor->field28;
    speed = (parameter->value0C * 15) / 100;
    path = &D_800AE4F4->pairGroups[parameter->value08];
    speed /= 2;
    index = actor->field4C;
    progress = actor->field50;
    step = speed * 60;
    for (;;) {
        distance = path->distances[index];
        if (step < distance - progress) {
            break;
        }
        step -= distance;
        step += progress;
        index++;
        if (index >= path->count - 1) {
            func_8000E5C8(actor, 1);
            return;
        }
        progress = 0;
    }
    progress += step;
    actor->field4C = index;
    actor->field50 = progress;
    first.x = path->pairs[index].index;
    first.y = path->pairs[index].value;
    second.x = path->pairs[index + 1].index;
    second.y = path->pairs[index + 1].value;
    func_8000E7E0((int *)&first, (int *)&first, parameter->value10);
    func_8000E7E0((int *)&second, (int *)&second, parameter->value10);
    actor->position.value[0] = first.x +
        ((second.x - first.x) * progress) / path->distances[index];
    actor->position.value[1] = first.y +
        ((second.y - first.y) * progress) / path->distances[index];
    distance = second.x - first.x;
    heading = func_8003CD4C(second.y - first.y, distance);
    actor->angle08 = heading;
    func_80039514(actor->objectIndex0C, actor->angle08);
    actor->field6C = 0;
    actor->field70 = 0;
    actor->field74 = 0;
}
