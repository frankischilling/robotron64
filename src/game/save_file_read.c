#include "../../include/save_game.h"
#include "../../include/game_memory.h"

int func_800301A4(int reportErrors, int restoreOptions)
{
    int status;
    int result;
    unsigned int checksum;
    int index;

    D_80077C04 = 0;
    result = 0;
    status = func_8004C378(0, 0);
    if (status == 1) {
        status = func_8004C3AC(0, D_80094000);
        if (status != 1) {
            if (reportErrors != 0) {
                if (status == -1) {
                    result = -4;
                } else {
                    result = -3;
                }
            }
        } else {
            if (func_8004C564(&D_800AD318, 0x100, 0x10, status) != 0x1000) {
                if (reportErrors != 0) {
                    result = -1;
                }
            } else {
                func_8004C648(status);
                checksum = 0x12345678;
                for (index = 0; index < 1011; index++) {
                    checksum += D_800AD318.words[index];
                }
                if (checksum != D_800AD318.data.checksum) {
                    func_8001C2C4(D_80094004, &D_800AD318);
                    result = -1;
                } else {
                    if (checksum != D_80077C00) {
                        D_80077C04 = 1;
                        if (D_80077C00 != 0xFFFFFFFF) {
                            D_80075FB8 = 3;
                            D_800BAE88 = D_8009EFA4;
                        }
                    }
                    D_80077C00 = checksum;
                    func_8003B520(D_80075D88, D_800AD318.data.signature, 0x14);
                    func_8003B520(D_80075DA0, D_800AD318.data.configuration, 0x190);
                    if (restoreOptions != 0) {
                        func_8002FF40(&D_800AD318.data.options);
                    }
                    func_80030054();
                    result = 1;
                }
            }
        }
    } else if (reportErrors != 0) {
        if (status == -1) {
            result = -4;
        } else {
            result = -2;
        }
    }
    if (result != 1) {
        for (index = 0; index < 8; index++) {
            D_800AD318.data.occupied[index] = 0;
        }
        if (result == -3 || result == -2) {
            D_80077C08 ^= 1;
        }
    }
    func_80030054();
    return result;
}
