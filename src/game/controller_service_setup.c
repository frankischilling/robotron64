#include "../../include/controller_services.h"
#include "../../include/debug_output.h"

void func_8004F4D8(void)
{
    int port;
    int result;

    osCreateMesgQueue(&D_80141228, &D_80141240, 1);
    func_800640D0(5, &D_80141228, (OSMesg)1);
    osCreateMesgQueue(&D_80141210, &D_80141244, 1);
    osCreateThread(&D_80141248, 8, (void (*)(void *))func_8004F06C, 0,
                   D_801413F8 + 1024, 15);
    osStartThread(&D_80141248);
    func_80063D10(&D_80141228, &D_8013D9D0, D_801433F8);
    func_80061A00(&D_80141228, &D_8013D9D1);
    for (port = 0; port != 4; port++) {
        D_8008D4E4[port] = 0;
        D_80143408[port] = 0;
        D_8008D4F4[port] = 0;
        if (D_8013D9D1 & (1 << port)) {
            result = func_80061D70(&D_80141228, &D_8013D9D8[port], port);
            if (result == SDK_PFS_ERR_ID_FATAL || result == SDK_PFS_ERR_DEVICE) {
                D_8013D9D1 &= ~(1 << port);
                if (func_80063B40(&D_80141228, &D_8013D9D8[port], port) == 0) {
                    func_80048DC0(D_80095BB0, port);
                    D_8008D4E4[port] = 1;
                }
            }
        }
    }
}

int func_8004F6B4(void)
{
    int port;
    int result;
    int state;

    func_80063D10(&D_80141228, &D_8013D9D0, D_801433F8);
    func_80061A00(&D_80141228, &D_8013D9D1);
    state = 0;
    for (port = 0; port != 4; port++) {
        D_8008D4E4[port] = 0;
        D_80143408[port] = 0;
        D_8008D4F4[port] = 0;
        if (D_8013D9D1 & (1 << port)) {
            result = func_80061D70(&D_80141228, &D_8013D9D8[port], port);
            if (result == 0 && port == 0) {
                state = 1;
            }
            if (result == SDK_PFS_ERR_ID_FATAL || result == SDK_PFS_ERR_DEVICE) {
                D_8013D9D1 &= ~(1 << port);
                if (port == 0) {
                    if (func_80063B40(&D_80141228, &D_8013D9D8[port], port) == 0) {
                        func_80048DC0(D_80095BC8, port);
                        state = -2;
                        D_8008D4E4[port] = 1;
                    } else {
                        state = -1;
                    }
                }
            }
        } else if (port == 0) {
            state = 0;
        }
    }
    return state;
}
