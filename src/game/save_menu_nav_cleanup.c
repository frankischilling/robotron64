#include "../../include/save_menu_nav_internal.h"

void func_8002606C(int restoreCamera, int releasePreview)
{
    SaveMenuNodeInternal *node;

    if (D_800AEE98.menu04 != 0) {
        if (D_800AEE98.menu04->textSlot04 != -1) {
            func_80000ACC(&D_800AEE98.menu04->textSlot04);
        }
        node = D_800AEE98.menu04->child20;
        if (node != 0) {
            do {
                if (node->textSlot10 != -1) {
                    func_80000ACC(&node->textSlot10);
                }
                node = node->next18;
            } while (node != 0);
        }
        if (D_800AEE98.previewActor1C != 0 && releasePreview != 0) {
            func_80026044();
        }
        if (restoreCamera != 0) {
            func_80039F10(D_800AEE98.cameraX2C, D_800AEE98.cameraY30,
                          D_800AEE98.cameraZ34);
            func_80039FCC(D_800AEE98.cameraAngleX38, D_800AEE98.cameraAngleY3C,
                          D_800AEE98.cameraAngleZ40);
        }
        if (D_800AEE98.actor20 != 0) {
            D_800AEE98.actor20->state21 = 2;
        }
        D_800AEE98.menu04 = 0;
    }
}
