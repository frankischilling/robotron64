#include "../../include/actor_setup_internal.h"
#include "../../include/actor_dynamic_pool_internal.h"

void func_8000CF9C(ActorDynamicFirstCommand *command)
{
    int resource;
    int x;
    int y;
    ActorDynamicFirstEntry *entry;

    resource = command->resourceIndex;
    x = command->x;
    y = command->y;
    entry = &D_800AE4F4->firstGroups[D_800AE4F4->groupCount].entries[
        D_800AE4F4->firstGroups[D_800AE4F4->groupCount].count];
    entry->resourceIndex = resource;
    entry->x = x * 200;
    entry->y = y * 200;
    D_800AE4F4->firstGroups[D_800AE4F4->groupCount].count++;
}
