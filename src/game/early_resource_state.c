#include "../../include/early_resource_state.h"
#include "../../include/actor_resource_internal.h"

typedef char EarlyResourceStateLayoutMustBe104Bytes[
    sizeof(ActorResource68Internal) == 0x68 ? 1 : -1];

extern int D_8009EFA0;

void func_8001ADA0(int mode, int index)
{
    ActorResource68Internal *entry;

    switch (mode) {
    default:
    case 1:
        entry = &D_800AF1F0[index];
        entry->updateTime60 = D_8009EFA0;
        entry->current18 = entry->speed;
        entry->rate1A = 750;
        return;
    case 0:
        entry = &D_800AF1F0[index];
        entry->updateTime60 = D_8009EFA0;
        entry->current18 =
            entry->current18 < entry->step10 * 2 + entry->speed
                ? entry->current18
                : entry->step10 * 2 + entry->speed;
        entry->rate1A = 750;
        return;
    case 2:
        entry = &D_800AF1F0[index];
        if ((unsigned int)D_800B0090 <
            (unsigned int)(D_8009EFA0 - entry->updateTime60)) {
            entry->updateTime60 += D_800B0090;
            if (entry->current18 < entry->step10 * 15 + entry->speed) {
                entry->current18 += entry->step10;
                entry->rate1A = entry->rate1A * 3 / 4;
            }
        }
        return;
    }
}

void func_8001AEEC(int mode)
{
    func_8001ADA0(mode, 0);
    func_8001ADA0(mode, 1);
    func_8001ADA0(mode, 2);
    func_8001ADA0(mode, 3);
    func_8001ADA0(mode, 4);
}
