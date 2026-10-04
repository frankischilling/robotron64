#include "../../../include/save_menu_legacy_internal.h"
#include "../../../include/controller_services.h"
#include "../../../include/controller_pak_menu_internal.h"
#include "../../../include/menu_label_internal.h"
#include "../../../include/game_memory.h"

int func_800267BC(void)
{
    unsigned char name[32];
    unsigned int pages;
    int freePages;
    int status;
    int slot;
    unsigned char *label;

    D_80077A94 = -1;
    status = func_8004FC98(1);
    if (status == 1) {
        freePages = func_8004F990();
        if (freePages != -1) {
            D_80077A94 = 0;
            for (slot = 0; slot < PAK_MENU_FILE_COUNT; slot++) {
                if (func_8004FB48(slot, &pages, name)) {
                    label = D_800BAF08[slot].name;
                    D_800BB0E8[D_80077A94] = &D_800BAF08[slot];
                    func_800363D0(label, D_80093838, pages);
                    func_8003B520(label, name,
                        func_8003B4FC(name) > 32 ? 32 : func_8003B4FC(name));
                    D_80077A94++;
                }
            }
            if (D_80077A94 == 0) {
                func_800363D0(D_800BAEA0, D_80093850, 16, freePages);
            } else if (func_8004C3AC((int)D_80093870, D_80093878)) {
                func_800363D0(D_800BAEA0, D_8009387C, freePages);
            } else {
                func_800363D0(D_800BAEA0, D_8009389C, 16, freePages);
            }
            D_800761F4 = 1;
            func_800263E0(D_800BAEA0, (unsigned char **)D_800BB0E8,
                D_80077A94, -1, 0, 0, func_800266BC,
                (void (*)(int))func_8002674C, 210);
            return 1;
        }
    } else if (status == -1) {
        return -1;
    } else if (status == -2) {
        return -2;
    }
    return 0;
}
