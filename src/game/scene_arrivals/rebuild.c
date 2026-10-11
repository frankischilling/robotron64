#include "../../../include/scene_commands_internal.h"
#include "../../../include/actor_resource_internal.h"
#include "../../../include/actor_behavior_internal.h"
#include "../../../include/actor_motion_internal.h"

extern GameActor D_800A4628[];

void func_80020F8C(void)
{
    int index;
    int slot;
    int playerPresent = 0;
    int secondaryCount = 0;
    unsigned int counts[36];
    unsigned int sceneCounts[8];
    unsigned int behaviorCounts[11];
    int resourceCount = 0;
    unsigned char present[200];
    unsigned char kinds[200];
    GameActor *poolActor;
    unsigned char values[200];
    unsigned char *flag;
    unsigned char *value;
    ActorBehaviorActorInternal *actor;
    unsigned int *entry;
    unsigned char kind;
    flag = present;
    value = values;
    while (value < (values + 200))
    {
        *(flag++) = 0;
        *(value++) = 0;
    }

    func_8003B694(counts, 0, sizeof(counts));
    func_8003B694(sceneCounts, 0, sizeof(sceneCounts));
    func_8003B694(behaviorCounts, 0, sizeof(behaviorCounts));
    for (actor = (ActorBehaviorActorInternal *) D_800AA708; actor != 0; actor = actor->next78)
    {
        switch (actor->kind1C)
        {
        case 7:
            kind = actor->resource24->actorKind;
            if (kind < 11)
            {
                behaviorCounts[kind]++;
            }
            break;

        case 0:
            kind = actor->resource24->actorKind;
            if ((((actor->field28 == 0) && (kind != 33)) && (kind != 34)) && (kind != 4))
            {
                entry = &counts[kind];
                (*entry)++;
                poolActor = (GameActor *) actor;
                if ((kind >= 9) && (kind < 13))
                {
                    slot = poolActor - D_800A4628;
                    present[slot]++;
                    values[slot] += actor->value22;
                    kinds[slot] = kind;
                }
                else if (((kind >= 13) && (kind < 17)) && (actor->field3C != 0))
                {
                    slot = ((GameActor *) actor->field3C) - D_800A4628;
                    present[slot]++;
                    values[slot]++;
                    kinds[slot] = kind - 4;
                }
                else if ((entry >= (&counts[17])) && (entry < (&counts[21])))
                {
                    D_800B8F78.secondaryLimits[secondaryCount++] = actor->value22;
                }
            }
            break;

        case 1:
            kind = actor->resource24->actorKind;
            if (((kind != 10) && (kind != 13)) && (actor->field3C == 0))
            {
                func_8001FCE4(1, 1, kind, 1, 1, 1, actor->position[0], actor->position[1]);
            }
            break;

        case 3:
            if (actor->resource24->actorKind < 4)
            {
                sceneCounts[actor->resource24->actorKind]++;
            }
            break;

        case 8:
            playerPresent = 1;
            actor->state21 = 2;
            break;

        }

    }

    for (index = 9; index < 17; index++)
    {
        counts[index] = 0;
    }

    for (index = 0; index < 200; index++)
    {
        if (present[index] != 0)
        {
            D_800B8F78.resourceLimits[resourceCount++] = values[index];
            counts[kinds[index]]++;
        }
    }

    if (playerPresent)
    {
        func_8001FCE4(1, 8, 0, 1, 2000, 1, -1, -1);
    }
    for (index = 0; index < 36; index++)
    {
        if (counts[index])
        {
            func_8001FCE4(1, 0, index, 1, D_800AF1F0[index].arrivalDelay / 100, counts[index], -1, -1);
        }
    }

    for (index = 0; index < 8; index++)
    {
        if (sceneCounts[index])
        {
            func_8001FCE4(1, 3, index, 1, 0, sceneCounts[index], -1, -1);
        }
    }

    for (index = 0; index < 11; index++)
    {
        if (behaviorCounts[index])
        {
            func_8001FCE4(1, 7, index, 1, 0, behaviorCounts[index], -1, -1);
        }
    }

}
