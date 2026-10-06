#include "../../include/early_game_state.h"
#include "../../include/object_helpers.h"

#include "../../include/early_pool_tick.h"

extern EarlyGameActor *D_800AA708;
extern int D_8009EFA0;
int func_80039EA0(int first, int second);
void func_80039FCC(int x, int y, int z);
void func_80039F10(float x, float y, float z);
void func_80022050(int value);
int func_80039E5C(int object, int value);
int func_80037408(int value);

void func_8000D4F8(void)
{
    int index;
    int pair;
    EarlyGameActor *actor;

    func_80039EA0(0, 0);
    func_80039FCC(0, 0, 0);
    func_80039F10(0.0f, 0.0f, 0.0f);
    func_8003A1E4(500.0f);
    for (index = 0; index < 10; index++) {
        D_800AE300.indices1C4[index] = -1;
    }
    for (index = 0; index != 9; index++) {
        for (pair = 0; pair < 4; pair++) {
            D_800AE300.groupsA4[index][pair].value = 0;
            D_800AE300.groupsA4[index][pair].index = -1;
        }
    }
    D_800AE300.enabled1EC = 1;
    D_800AE300.sentinel1F0 = 0xBEEF;
    D_800AE300.frameA0 = D_8009EFA0;
    func_80022050(0);
    for (actor = D_800AA708; actor != 0; actor = actor->next78) {
        func_80039E5C(actor->objectIndex0C, 0);
    }
    func_80037408(0);
}
