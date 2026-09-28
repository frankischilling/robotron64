#include "../../include/controller_services.h"

int func_8004FC98(int retry)
{
    int result;
    int slot;

    func_80063D10(&D_80141228, &D_8013D9D0, D_80143790);
    func_80061A00(&D_80141228, &D_8013D9D1);
    result = func_80061D70(&D_80141228, &D_8013D9D8[0], 0);
    if (result != 0) {
        if (retry != 0) {
            if (result == SDK_PFS_ERR_ID_FATAL || result == SDK_PFS_ERR_DEVICE) {
                if (func_80063B40(&D_80141228, &D_8013D9D8[0], 0) == 0) {
                    return -2;
                }
                return -1;
            }
            if (func_80061D70(&D_80141228, &D_8013D9D8[0], 0) != 0) {
                return 0;
            }
        } else {
            if (result == SDK_PFS_ERR_ID_FATAL || result == SDK_PFS_ERR_DEVICE) {
                if (func_80063B40(&D_80141228, &D_8013D9D8[0], 0) == 0) {
                    return -2;
                }
                return -1;
            }
            return 0;
        }
    }
    for (slot = 0; slot < 16; slot++) {
        D_80143650[slot] = func_800649F0(&D_8013D9D8[0], slot, D_80143450 + slot);
    }
    return 1;
}
