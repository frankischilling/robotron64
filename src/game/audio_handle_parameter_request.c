#include "../../include/audio_property_pipeline_internal.h"

void func_800581DC(int handle, int slot, int value,
                   void (*callback)(AudioVoice *, int))
{
    func_8005895C();
    func_800592F0(4);
    func_80059348(&handle, 4);
    func_80059348(&slot, 4);
    func_80059348(&value, 4);
    func_80059348(&callback, 4);
    func_8005899C();
}
