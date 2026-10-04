#include "../../../include/controller_services.h"

int func_8004C1E0(int port)
{
    static unsigned short polledButtons;
    int controller;
    int buttons;

    if (port < 0) {
        return 0;
    }
    func_80061FE0(&D_80141228);
    func_80062240(&D_80141228, 0, 1);
    func_800620A4(D_8013DBA0);
    for (controller = 0; controller < 4; controller++) {
        if (D_8013D9D0 & (1 << controller)) {
            polledButtons = D_8013DBA0[controller].buttons;
            buttons = polledButtons;
            D_8013DBD8[controller] = buttons;
            D_8013DBB8[controller] = D_8013DBA0[controller].stickX;
            D_8013DBC8[controller] = D_8013DBA0[controller].stickY;
            D_8013DBF8[controller] = (buttons ^ D_8013DBE8[controller]) &
                                   D_8013DBD8[controller];
            D_8013DBE8[controller] = buttons;
        }
    }
    return D_8013D9D0;
}
