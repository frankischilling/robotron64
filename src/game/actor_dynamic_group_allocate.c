#include "../../include/actor_setup_internal.h"
#include "../../include/actor_dynamic_pool_internal.h"
#include "../../include/debug_output.h"
#include "../../include/game_memory.h"
#include "../../include/heap.h"

extern int D_800AE4F8;
extern int D_800BA74C;
extern char D_8008F990[];

void func_8000CEC0(ActorDynamicCommand *command)
{
    int value = command->value04;

    D_800BA74C = D_800AE4F8++;
    if (D_800AE4F8 >= 11) func_8001C0D0(D_8008F990);
    D_800AE4F4 = func_8004DD6C(9096);
    func_8003B694(D_800AE4F4, 0, 9096);
    ((ActorDynamicPool *)D_800AE4F4)->groupCount = 0;
    ((ActorDynamicPool *)D_800AE4F4)->parameterCount = 0;
    ((ActorDynamicPool *)D_800AE4F4)->pairGroupCount = 0;
    ((ActorDynamicPool *)D_800AE4F4)->value00 = value;
}
