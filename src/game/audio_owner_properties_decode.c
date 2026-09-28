#include "audio_properties_internal.h"

void func_80055AAC(void)
{
    int ownerTag;
    AudioProperties properties;

    func_800593F4(&ownerTag, 4);
    func_800593F4(&properties, sizeof(AudioProperties));
    func_80055AE8(ownerTag, &properties);
}
