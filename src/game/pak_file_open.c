#include "../../include/pak_file.h"
#include "../../include/controller_services.h"
#include "../../include/save_game.h"

int func_8004C3AC(int device, unsigned char *mode)
{
    int result;

    if (D_8008D350++ >= 2) {
        if (*mode == 'w') {
            D_80075FB8 = 2;
        } else {
            D_80075FB8 = 1;
        }
    }
    result = func_80062380(&D_8013D9D8[0], 0x345A, 0x4E525845,
                          func_8004C65C(D_8009561C), D_80095624, &D_8013DB78);
    if (result == SDK_PFS_ERR_INVALID) {
        if (*mode == 'w') {
            func_80062540(&D_8013D9D8[0], 0x345A, 0x4E525845,
                          func_8004C65C(D_80095628), D_80095630, 0x1000, &D_8013DB78);
            result = func_80062380(&D_8013D9D8[0], 0x345A, 0x4E525845,
                                  func_8004C65C(D_80095634), D_8009563C, &D_8013DB78);
            if (result == SDK_PFS_ERR_ID_FATAL || result == SDK_PFS_ERR_DEVICE) {
                D_80075FB8 = 0;
                return -1;
            }
            if (result == SDK_PFS_ERR_INVALID) {
                D_80075FB8 = 0;
                return 0;
            }
            return 1;
        }
        D_80075FB8 = 0;
        return 0;
    }
    if (result == SDK_PFS_ERR_ID_FATAL || result == SDK_PFS_ERR_DEVICE) {
        return -1;
    }
    return 1;
}
