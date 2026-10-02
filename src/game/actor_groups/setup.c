#include "../../../include/early_parameter_internal.h"

ActorBehaviorActorInternal *func_8001AF44(int kind, int *position,
                                       ActorBehaviorActorInternal *parent);
void func_8000E7E0(int *destination, int *source, int angle);
void func_8000DFEC(EarlyGameActor *actor, int unused);
void func_800290B0(int object, int *position);

void func_8000E108(int index, ActorDynamicFirstGroup *group,
                  ActorDynamicParameter *parameter, int unused,
                  int offsetX, int offsetY)
{
    int position[3];
    ActorDynamicPairGroup *path;
    EarlyGameActor *parent;
    EarlyGameActor *actor;
    int first[3];
    int second[3];
    int i;
    int *actorPosition;
    int *spawnCoordinates;

    spawnCoordinates = position;
    parent = 0;
    path = &D_800AE4F4->pairGroups[parameter->value08];
    i = 0;
    while (i < group->count) {
        spawnCoordinates[0] = group->entries[i].x + offsetX;
        spawnCoordinates[1] = group->entries[i].y + offsetY;
        spawnCoordinates[2] = 0;
        actor = (EarlyGameActor *)func_8001AF44(group->entries[i].resourceIndex,
                                              spawnCoordinates, 0);
        if (actor != 0) {
            if (i != 0) {
                actor->field5C = (int)func_8000DFEC;
                actor->field4C = group->entries[i].x;
                actor->field50 = group->entries[i].y;
                actor->owner3C = (EarlyGameActorOwner *)parent;
                actor->angle08 = parent->angle08;
                actor->field54 = index;
                func_8000DFEC(actor, 0);
                actor->field6C = 0;
            } else {
                actor->field5C = (int)func_8000E894;
                actor->field4C = 0;
                actor->field50 = 0;
                actor->field54 = index;
                parent = actor;
                first[0] = path->pairs[0].index;
                first[1] = path->pairs[0].value;
                func_8000E7E0(first, first, parameter->value10);
                second[0] = path->pairs[1].index;
                second[1] = path->pairs[1].value;
                func_8000E7E0(second, second, parameter->value10);
                actor->angle08 = func_8003CD4C(second[1] - first[1],
                                              second[0] - first[0]);
                actorPosition = actor->position.value;
                actorPosition[0] = first[0];
                actorPosition[1] = first[1];
                func_800290B0(actor->objectIndex0C, actorPosition);
                func_80015184(19, actorPosition);
                actor->field6C = 0;
            }
            actor->field70 = 0;
            actor->field74 = 0;
            actor->field28 = (int)parameter;
        }
        i++;
    }
}
