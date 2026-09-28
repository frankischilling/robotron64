#include "../../include/audio_properties_internal.h"

void func_80057D08(void)
{
    int handle;
    int slot;
    unsigned char first;
    unsigned char second;

    func_800593F4(&handle, 4);
    func_800593F4(&slot, 4);
    func_800593F4(&first, 1);
    func_800593F4(&second, 1);
    func_80057D68(handle, slot, first, second);
}
