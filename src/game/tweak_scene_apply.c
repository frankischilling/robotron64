#include "../../include/tweak_internal.h"

/* Hit-count fields for the five pickup resources are exempt from level overrides. */
extern int D_8009AA58;
extern int D_8009AAB4;
extern int D_8009AB10;
extern int D_8009ABC8;
extern int D_8009AB6C;

void func_800377E4(void)
{
    int index;

    func_80037A20();
    for (index = 0; index < D_800BA778; index++) {
        if (&D_8009AA58 == D_8009F030[D_800B9A78.tweaks[index].variable].target ||
            &D_8009AAB4 == D_8009F030[D_800B9A78.tweaks[index].variable].target ||
            &D_8009AB10 == D_8009F030[D_800B9A78.tweaks[index].variable].target ||
            &D_8009ABC8 == D_8009F030[D_800B9A78.tweaks[index].variable].target ||
            &D_8009AB6C == D_8009F030[D_800B9A78.tweaks[index].variable].target) {
            continue;
        }
        *D_8009F030[D_800B9A78.tweaks[index].variable].target = D_800B9A78.tweaks[index].value;
    }
    func_80037700();
    func_80038228();
}
