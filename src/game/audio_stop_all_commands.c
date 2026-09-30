#include "../../include/audio_commands.h"

void func_80054268(void)
{
    func_80054178(0, 0);
}

void func_8005428C(int argument)
{
    func_80054178(1, argument);
}

void func_800542B0(void)
{
    func_80054304(0, 0);
}

void func_800542D4(void)
{
    int argument;

    func_800593F4(&argument, 4);
    func_80054304(1, argument);
}
