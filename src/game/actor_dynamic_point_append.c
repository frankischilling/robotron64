#include "../../include/actor_setup_internal.h"
#include "../../include/actor_dynamic_pool_internal.h"
#include "../../include/debug_output.h"
#include "../../include/object_recovery.h"

extern char D_8008F9A8[];
extern unsigned char D_8008F9C0[];

void func_8000D090(ActorDynamicPointCommand *command)
{
    ActorDynamicPairGroup *group;
    int x;
    int y;
    int adjustedX;
    int adjustedY;
    int dx;
    int dy;

    x = command->x;
    y = command->y;
    group = &D_800AE4F4->pairGroups[D_800AE4F4->pairGroupCount];
    if (group->count >= 50) {
        func_8001C0D0(D_8008F9A8);
    }
    adjustedX = x;
    adjustedY = y;
    func_8000DFB0(&adjustedX, &adjustedY);
    group->pairs[group->count].index = adjustedX;
    group->pairs[group->count].value = adjustedY;
    if (group->count > 0) {
        dx = group->pairs[group->count].index - group->pairs[group->count - 1].index;
        dy = group->pairs[group->count].value - group->pairs[group->count - 1].value;
        group->distances[group->count - 1] = func_8003CCE8(dx * dx + dy * dy);
        if ((unsigned int)group + group->count * sizeof(*group) == 200) {
            func_8001C49C(D_8008F9C0);
        }
    }
    group->count++;
}
