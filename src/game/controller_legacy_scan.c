#include "../../include/controller_legacy.h"

void func_8004C0D4(void)
{
    int port;
    int bit;
    int result;

    func_80061A00(&D_80141228, &D_8013D9D1);
    for (port = 0; port < 4; port++) {
        bit = 1 << port;
        if (D_8013D9D1 & bit) {
            result = func_80061D70(&D_80141228, &D_8013D9D8[port], port);
            if (result == SDK_PFS_ERR_ID_FATAL || result == SDK_PFS_ERR_DEVICE) {
                D_8013D9D1 &= ~(1 << port);
            }
        }
    }
}
