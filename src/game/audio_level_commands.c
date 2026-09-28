#include "../../include/audio_commands.h"

extern unsigned char D_8008DA1C;
extern unsigned char D_8008DA20;

unsigned char func_80054720(void)
{
    if (func_80052AA8() == 0) {
        return 0;
    }
    return D_8008DA1C;
}

unsigned char func_80054758(void)
{
    if (func_80052AA8() == 0) {
        return 0;
    }
    return D_8008DA20;
}

void func_80054790(unsigned char value)
{
    func_8005895C();
    func_800592F0(2);
    func_80059348(&value, 1);
    func_8005899C();
}

void func_800547CC(void)
{
    unsigned char value;

    func_800593F4(&value, 1);
    func_800547FC(value);
}
