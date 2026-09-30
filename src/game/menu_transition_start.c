#include "../../include/save_menu_nav_internal.h"
#include "../../include/palette_effects.h"

SaveMenuNavigationStateInternal D_800AEE98;

void func_800278AC(int restoreCamera, int releasePreview, void (*callback)(void))
{
    if (D_800AEE98.menu04 != 0) {
        D_800AEE98.callback60 = callback;
        if (callback == 0) {
            func_8002606C(restoreCamera, releasePreview);
        } else {
            func_80000B7C(D_800AEE98.selected50->textSlot10, 0x100, 0);
            D_800AEE98.transition54 = 1;
            D_800AEE98.restoreCamera58 = restoreCamera;
            D_800AEE98.releasePreview5C = releasePreview;
            D_800AEE98.timestamp00 = D_8009EFA4;
            func_800315E4(4);
        }
    }
}
