#include "../../include/controller_services.h"
#include "../../include/save_game.h"

int func_8004FA14(int slot)
{
    unsigned int pages;
    int index;
    unsigned char name[100];

    func_8004FB48(slot, &pages, name);
    if (D_80143450[slot].gameCode == 0x4E525845 &&
        D_80143450[slot].companyCode == 0x345A) {
        for (index = 0; index < 8; index++) {
            D_800AD318.data.occupied[index] = 0;
        }
    }
    if (func_800643E0(&D_8013D9D8[0], D_80143450[slot].companyCode,
                     D_80143450[slot].gameCode,
                     (unsigned char *)D_80143450[slot].gameName,
                     (unsigned char *)D_80143450[slot].extension) != 0) {
        return 0;
    }
    return 1;
}
