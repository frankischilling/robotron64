#include "../../include/save_menu_internal.h"

typedef struct SaveMenuContinueCodeStorage {
    unsigned int unknown00[2];
    SaveMenuContinueCode code;
} SaveMenuContinueCodeStorage;

void func_800312B0(GamePlayerState *player, unsigned char *text)
{
    SaveMenuContinueCodeStorage storage;
    unsigned char *packed;
    int index;

    storage.code.unused = 0;
    storage.code.option08 = D_800AD2F8.field08;
    storage.code.option0C = D_800AD2F8.field0C;
    storage.code.level = D_800AD138.saved.level;
    storage.code.value18 = player->saved.value18 / 1000;
    storage.code.value1C = player->saved.active;
    storage.code.checksum =
        (storage.code.value1C + storage.code.value18 + storage.code.level +
         storage.code.option0C + storage.code.option08) & 7;

    packed = (unsigned char *)&storage.code;
    for (index = 0; index < 5; index++) {
        text[0] = func_80030FEC(*packed & 0xF);
        text[1] = func_80030FEC((unsigned int)*packed >> 4);
        packed++;
        text += 2;
    }
    *text = 0;
}
