#include "../../include/controller_services.h"

void func_8004F1EC(void)
{
    int port;
    int result;

    func_80063D10(&D_80141228, &D_8013D9D0, D_801433F8);
    func_80061A00(&D_80141228, &D_8013D9D1);
    for (port = 0; port < 4; port++) {
        if ((D_8013D9D0 >> port) & 1) {
            if ((D_801433F8[port].type & 4) &&
                (D_801433F8[port].status & 1)) {
                result = func_80061D70(&D_80141228, &D_8013D9D8[port], port);
                if (result == SDK_PFS_ERR_ID_FATAL || result == SDK_PFS_ERR_DEVICE) {
                    D_8013D9D1 &= ~(1 << port);
                }
            }
        }
    }
}
