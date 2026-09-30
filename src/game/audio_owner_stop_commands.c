#include "audio_properties_internal.h"

void func_80055E68(int ownerTag)
{
    func_80055D58(ownerTag, 0, 0);
}

void func_80055E8C(int ownerTag, int argument)
{
    func_80055D58(ownerTag, 1, argument);
}

void func_80055EB0(void)
{
    int ownerTag;

    func_800593F4(&ownerTag, 4);
    func_80055F24(ownerTag, 0, 0);
}

void func_80055EE4(void)
{
    int ownerTag;
    int argument;

    func_800593F4(&argument, 4);
    func_800593F4(&ownerTag, 4);
    func_80055F24(ownerTag, 1, argument);
}
