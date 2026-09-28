#include "../../include/controller_input.h"
#include "../../include/scalar_math.h"

extern int D_8007C334;
extern int D_8007CCA0;

void func_8001276C(int advance, int unused);

int func_8003C1A8(int port, int mode)
{
    int result;
    int triggers;

    result = 0;
    triggers = 0;
    D_8007C334 = func_8004F330(port);
    if ((1 << port) & D_8007C334) {
        if (func_8004CEF0(D_8013DBB8[port]) >
            func_8004CEF0(D_8013DBC8[port]) * 8) {
            D_8013DBC8[port] = 0;
        }
        if (func_8004CEF0(D_8013DBC8[port]) >
            func_8004CEF0(D_8013DBB8[port]) * 8) {
            D_8013DBB8[port] = 0;
        }
        if (mode == 0) {
            if (D_8013DBB8[port] > 20) {
                result = 2;
            }
            if (D_8013DBB8[port] < -20) {
                result |= 1;
            }
            if (D_8013DBC8[port] > 20) {
                result |= 4;
            }
            if (D_8013DBC8[port] < -20) {
                result |= 8;
            }
        } else {
            if (D_8013DBB8[port] > 20) {
                result = 0x20;
            }
            if (D_8013DBB8[port] < -20) {
                result |= 0x10;
            }
            if (D_8013DBC8[port] > 20) {
                result |= 0x40;
            }
            if (D_8013DBC8[port] < -20) {
                result |= 0x80;
            }
        }
        if (D_8013DBD8[port] & 8) {
            result |= 0x40;
        }
        if (D_8013DBD8[port] & 4) {
            result |= 0x80;
        }
        if (D_8013DBD8[port] & 2) {
            result |= 0x10;
        }
        if (D_8013DBD8[port] & 1) {
            result |= 0x20;
        }
        if (D_8013DBD8[port] & 0x800) {
            result |= 4;
        }
        if (D_8013DBD8[port] & 0x400) {
            result |= 8;
        }
        if (D_8013DBD8[port] & 0x200) {
            result |= 1;
        }
        if (D_8013DBD8[port] & 0x100) {
            result |= 2;
        }
        if (D_8013DBD8[port] & 0x1000) {
            result |= 0x100;
        }
        if (D_8013DBD8[port] & 0x8000) {
            result |= 0x800;
        }
        if (D_8013DBD8[port] & 0x4000) {
            result |= 0x1000;
        }
        if (D_8013DBF8[port] & 0x20) {
            triggers = 1;
        }
        if (D_8013DBF8[port] & 0x10) {
            triggers |= 2;
        }
        if ((triggers & 3) == 3) {
            D_8007CCA0 ^= 1;
        } else if (triggers == 1) {
            func_8001276C(1, 0);
        } else if (triggers == 2) {
            func_8001276C(1, 0);
        }
    }
    return result;
}
