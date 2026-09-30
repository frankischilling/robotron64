#include "../../include/audio_property_pipeline_internal.h"

void func_80058248(void)
{
    int handle;
    int slot;
    int value;
    void (*callback)(AudioVoice *, int);

    func_800593F4(&handle, 4);
    func_800593F4(&slot, 4);
    func_800593F4(&value, 4);
    func_800593F4(&callback, 4);
    func_800582A8(handle, slot, value, callback);
}
