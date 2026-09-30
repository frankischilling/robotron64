#include "../../include/save_menu_legacy_internal.h"
#include "../../include/controller_legacy.h"
#include "../../include/controller_services.h"
#include "../../include/pak_file.h"

void func_8002589C(int unused)
{
    int handle;
    int result;

    func_8004C0B0();
    func_800278AC(0, 0, 0);
    D_800AD138.saved.selection = 0xFFFF;
    D_800AD280 = 5;
    D_800AD28C = 0;
    func_8001A1F0(&D_800AD138);
    D_80075FC4 = 1;

    result = func_8004FC98(0);
    if (result == 0) {
        D_80075FC4 = 4;
    } else if (result == -2) {
        D_80075FC4 = 6;
    } else if (result == -1) {
        D_80075FC4 = 5;
    } else if (result == 1) {
        handle = func_8004C3AC((int)D_80092BD0, D_80092BD8);
        result = func_8004F990();
        if ((unsigned int)result < 0x10 && handle == 0) {
            D_80075FC4 = 2;
        }
        result = func_8004F9D4();
        if (result == 0x10 && handle == 0) {
            D_80075FC4 = 2;
        }
        if (D_800AD138.saved.flags1C & 0x100) {
            D_80075FC4 = 1;
        }
    }
}

void func_800259DC(int unused)
{
    func_80026178(D_8007683C, 0);
}

void func_80025A08(int unused)
{
    int handle;
    int result;

    func_800278AC(0, 0, 0);
    D_800AD138.saved.selection = 0xFFFF;
    D_800AD280 = 5;
    D_800AD28C = 0;
    func_8001A1F0(&D_800AD138);
    D_80075FC4 = 1;

    result = func_8004FC98(0);
    if (result == 0) {
        D_80075FC4 = 4;
    } else if (result == -2) {
        D_80075FC4 = 6;
    } else if (result == -1) {
        D_80075FC4 = 5;
    } else if (result == 1) {
        handle = func_8004C3AC((int)D_80092BDC, D_80092BE4);
        result = func_8004F990();
        if ((unsigned int)result < 0x10 && handle == 0) {
            D_80075FC4 = 2;
        }
        result = func_8004F9D4();
        if (result == 0x10 && handle == 0) {
            D_80075FC4 = 2;
        }
        if (D_800AD138.saved.flags1C & 0x100) {
            D_80075FC4 = 1;
        }
    }
}
