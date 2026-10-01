#include "../../include/save_menu_internal.h"
#include "../../include/game_memory.h"

extern unsigned char D_8009404C[];
extern unsigned char D_80094054[];
extern unsigned char D_80094064[];
void func_8002606C(int restoreCamera, int releasePreview);
void func_80032D00(void);
void func_80032D28(int player, int initializeOnly, int offset);

int func_80031080(GamePlayerState *player, unsigned char *text)
{
    SaveMenuContinueCode code;
    unsigned char *invalid;
    unsigned char *packed;
    int index;
    int low;
    int high;
    unsigned int checksum;

    invalid = D_8009404C;
    for (index = 0; index < func_8003B4FC(invalid); index++) {
        if (func_8003B4C0(text, invalid[index]) != 0) {
            return 0;
        }
    }
    packed = (unsigned char *)&code;
    for (index = 0; index != 5; index++) {
        low = func_80031034(*text++);
        high = func_80031034(*text++);
        *packed++ = (high << 4) + low;
    }
    checksum = (code.value1C + code.value18 + code.level +
                code.option0C + code.option08) & 7;
    if (code.checksum == checksum) {
        if (code.value1C != 0 && code.value1C < 127 &&
            code.level < 210 && code.option08 < 3 &&
            code.option0C < 10) {
            func_8002606C(0, 0);
            func_80032D00();
            func_80032D28(0, 1, 0);
            player->level = D_800AD138.saved.level = code.level;
            player->saved.value18 = code.value18 * 1000;
            player->saved.active = code.value1C;
            D_800AD2F8.field0C = code.option0C;
            D_800AD2F8.field08 = code.option08;
            D_800AD138.saved.selection34 = 0;
            D_800AD138.saved.currentPlayer = D_800AD138.saved.playerChoices38[D_800AD138.saved.selection34];
            D_800AD138.saved.mode = 1;
            func_8001C49C(D_80094054);
            func_800214D4(1);
            func_8003B520(D_8009B190[0].unknownA0, &D_800B9A78, 0xD14);
            return 1;
        }
    } else {
        func_8001C49C(D_80094064, code.checksum, checksum);
    }
    return 0;
}
