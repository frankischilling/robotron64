#include "../../include/actor_setup_internal.h"
#include "../../include/debug_output.h"
#include "../../include/actor_dynamic_pool_internal.h"

void func_8000D1FC(ActorDynamicCommand *command)
{
    ActorDynamicPairGroup *group;
    int value;

    value = command->value04;
    group = &((ActorDynamicPool *)D_800AE4F4)->pairGroups[((ActorDynamicPool *)D_800AE4F4)->pairGroupCount];

    if (group->count >= 50) func_8001C0D0(D_8008F9F4, group->count);
    group->pairs[group->count].index = -1;
    group->pairs[group->count].value = value * 10;
    group->count++;
}

char D_8008F9F4[] = "Too many path segments\n";
