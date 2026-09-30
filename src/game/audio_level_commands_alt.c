#include "../../include/audio_commands.h"

void func_800549DC(unsigned char value)
{
    func_8005895C();
    func_800592F0(3);
    func_80059348(&value, 1);
    func_8005899C();
}

void func_80054A18(void)
{
    unsigned char value;

    func_800593F4(&value, 1);
    func_80054A48(value);
}
