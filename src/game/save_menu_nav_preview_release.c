#include "../../include/save_menu_nav_internal.h"

void func_80026044(void)
{
    SaveMenuActorInternal *actor;

    actor = D_800AEE98.previewActor1C;
    if (actor != 0) {
        actor->state21 = 2;
        D_800AEE98.previewActor1C = 0;
    }
}
