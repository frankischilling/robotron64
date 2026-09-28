#include "audio_properties_internal.h"

void func_80055A60(int ownerTag, AudioProperties *properties)
{
    func_8005895C();
    func_800592F0(11);
    func_80059348(&ownerTag, 4);
    func_80059348(properties, sizeof(AudioProperties));
    func_8005899C();
}
