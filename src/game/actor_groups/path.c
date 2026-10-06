#include "../../../include/early_parameter_internal.h"
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
    int first[3];
    int second[3];
    int heading;
    int progress;
    parameter = (ActorDynamicParameter *) actor->field28;
    speed = (parameter->value0C * 15) / 100;
    path = &D_800AE4F4->pairGroups[parameter->value08];
    speed /= 2;
    index = actor->field4C;
    progress = actor->field50;
    step = speed * 60;
    repeat:
    distance = path->distances[index];

    if (step >= (distance - progress))
    {
      step -= distance;
      step += progress;
      index++;
      if (index >= (path->count - 1))
      {
        func_8000E5C8(actor, 1);
        return;
      }
      progress = 0;
      goto repeat;
    }
    progress += step;
    actor->field4C = index;
    actor->field50 = progress;
    first[0] = path->pairs[index].index;
    first[1] = path->pairs[index].value;
    second[0] = path->pairs[index + 1].index;
    second[1] = path->pairs[index + 1].value;
    func_8000E7E0(first, first, parameter->value10);
    func_8000E7E0(second, second, parameter->value10);
    actor->position.value[0] = first[0] + (((second[0] - first[0]) * progress) / path->distances[index]);
    actor->position.value[1] = first[1] + (((second[1] - first[1]) * progress) / path->distances[index]);
    distance = second[0] - first[0];
    heading = func_8003CD4C(second[1] - first[1], distance);
    actor->angle08 = heading;
    func_80039514(actor->objectIndex0C, actor->angle08);
    actor->field6C = 0;
    actor->field70 = 0;
    actor->field74 = 0;
}
