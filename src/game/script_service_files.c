#include "../../include/script_service_internal.h"
#include "../../include/game_memory.h"

int func_8001C790(unsigned char *path)
{
    int handle;
    unsigned char *name;
    unsigned char *cursor;

    name = path;
    cursor = func_8003B4C0(name, '\\');
    while (cursor != 0) {
        name = cursor + 1;
        cursor = func_8003B4C0(name, '\\');
    }

    handle = 0;
    do {
        if (D_80097650[handle].flags.bits.registered &&
            func_8003B768(D_80097650[handle].name, name) != 0) {
            func_8001C0D0((char *)D_800904B0);
        }
        handle++;
    } while (handle < 100);

    for (handle = 0; handle < 100; handle++) {
        if (!D_80097650[handle].flags.bits.registered) {
            D_80097650[handle].flags.bits.registered = 1;
            func_8003B6E4(D_80097650[handle].name, name);
            func_8003B6E4(D_80097650[handle].path, path);
            func_8001C49C(D_800904D0, handle, name);
            return handle;
        }
    }
    return 0xFFFF;
}
