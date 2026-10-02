#include "../../../include/controller_services.h"

void func_8004F850(void)
{
    int strength;
    int port;

    if (D_8008D4E4[0] != 0) {
        port = 0;
        strength = D_8008D510;
        if (strength > 70) {
            if (D_80143408[port] == 0) {
                func_8004F178(port);
            }
        } else if (strength < 6) {
            if (D_80143408[port] != 0) {
                func_8004F1B4(port);
            }
        } else {
            if (D_8008D4F4[port] >= 256) {
                D_8008D4F4[port] = D_8008D4F4[port] - 256;
                if (D_80143408[port] == 0) {
                    func_8004F178(port);
                }
            } else {
                D_8008D4F4[port] = D_8008D4F4[port] +
                    strength * strength * strength / 512 + 4;
                if (D_80143408[port] != 0) {
                    func_8004F1B4(port);
                }
            }
        }
    }
}
