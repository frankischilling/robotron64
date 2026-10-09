#include "../../include/script_service_internal.h"
#include "../../include/game_memory.h"
#include "../../include/platform_services.h"

int func_8001C8C4(unsigned char *name)
{
    ScriptedFile *file;
    int handle;

    file = D_80097650;
    handle = 0;
    for (;;) {
        if (file->flags.bits.registered && func_8003B768(file->name, name) == 0) {
            func_8001C49C(D_80090510, handle, name);
            return handle;
        }
        handle++;
        file++;
        if (handle == 100) {
            func_8001C0D0((char *)D_8009054C, name);
            return 0xFFFF;
        }
    }
}

void *func_8001C968(int handle)
{
    if (D_80097650[handle].flags.bits.registered) {
        if (!D_80097650[handle].flags.bits.loaded) {
            D_80097650[handle].data =
                func_8003C64C(D_80097650[handle].path, &D_80097650[handle].size);
            D_80097650[handle].flags.bits.loaded = 1;
            func_8001C49C(D_80090584, handle, D_80097650[handle].data);
        }
        return D_80097650[handle].data;
    }
    return 0;
}

void *func_8001C9FC(int handle)
{
    if (D_80097650[handle].flags.bits.registered &&
        D_80097650[handle].flags.bits.loaded) {
        func_8001C49C(D_800905B8, D_80097650[handle].data, handle);
        return D_80097650[handle].data;
    }
    func_8001C0D0((char *)D_800905F8, handle);
    return 0;
}

void func_8001CA78(int handle)
{
    if (D_80097650[handle].flags.bits.registered &&
        D_80097650[handle].flags.bits.loaded) {
        func_8001C49C(D_80090630, handle);
        func_8003C698(D_80097650[handle].data);
        D_80097650[handle].flags.bits.loaded = 0;
    }
}

void func_8001CAF4(int handle)
{
    func_8001C49C(D_80090660, handle);
    func_8001CA78(handle);
    D_80097650[handle].flags.bits.registered = 0;
}
