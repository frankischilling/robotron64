#include "../../include/audio_commands.h"

extern unsigned char D_8008DA24;

unsigned char func_80054C24(void)
{
    return D_8008DA24;
}

void func_80054C34(unsigned char value)
{
    D_8008DA24 = value;
}
