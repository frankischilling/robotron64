#include "../../include/audio_commands.h"

void func_80053EBC(int index)
{
    func_80053DAC(index, 0, 0);
}

void func_80053EE0(int index, int argument)
{
    func_80053DAC(index, 1, argument);
}

void func_80053F04(void)
{
    int index;

    func_800593F4(&index, 4);
    func_80053F78(index, 0, 0);
}

void func_80053F38(void)
{
    int index;
    int argument;

    func_800593F4(&argument, 4);
    func_800593F4(&index, 4);
    func_80053F78(index, 1, argument);
}
