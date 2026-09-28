#include "../../include/save_game.h"
#include "../../include/game_memory.h"

int func_80030420(int clearFailedSlot)
{
    int handle;
    int result;
    int word;

    if (func_8004C378(0, 0) != 0) {
        func_8003B520(D_800AD318.data.signature, D_80075D88, 0x14);
        func_8003B520(D_800AD318.data.configuration, D_80075DA0, 0x190);
        func_8002FE00(&D_800AD318.data.options);
        handle = func_8004C3AC(0, D_80094018);
        if (handle == 0) {
            return 0;
        }
        if (handle == -1) {
            return 0;
        }
        D_800AD318.data.checksum = 0x12345678;
        for (word = 0; word < 1011; word++) {
            D_800AD318.data.checksum += D_800AD318.words[word];
        }
        if (func_8004C5DC(&D_800AD318, 0x100, 0x10, handle) != 0x1000) {
            func_8004C648(handle);
            result = -3;
        } else {
            D_80077C00 = D_800AD318.data.checksum;
            func_8004C648(handle);
            result = 1;
        }
    } else {
        result = -2;
    }
    if (result <= 0 && clearFailedSlot != 0) {
        D_800AD318.data.occupied[D_800BB158] = 0;
        return result;
    }
    func_80030054();
    return result;
}
