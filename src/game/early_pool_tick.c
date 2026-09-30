#include "../../include/actor_setup_internal.h"
#include "../../include/actor_dynamic_pool_internal.h"
#include "../../include/actor_behavior_internal.h"
#include "../../include/early_pool_tick.h"

struct SessionSetupCommand;
void func_8002E65C(struct SessionSetupCommand *command);
extern int D_800AD28C;

extern int D_800972BC;
extern int D_8009EFA0;
extern int D_800AD288;

void func_8000D3E8(void)
{
    switch (D_800AE300.state00) {
        case 1:
            D_800AE300.timer98 = ((ActorDynamicPool *)D_800AE4F4)->value00 * 1000;
            D_800AE300.state00 = 2;
            D_800AE300.start9C = D_8009EFA0;
            func_8000E328();
            D_800972BC = 3000;
            break;
        case 2:
            D_800972BC -= D_8009EF94;
            if (D_800972BC < 0) D_800AE300.state00 = 0;
            break;
        default:
            D_800AE300.timer98 -= D_8009EF94;
            func_8000E3B4();
            if (D_800AE300.timer98 <= 0) {
                func_8002E65C(0);
                D_800AE300.timer98 = 0;
                D_800AD288 = 7;
                D_800AD28C = 0;
            }
            break;
    }
}
