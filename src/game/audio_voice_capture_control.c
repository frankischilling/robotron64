#include "../../include/audio_voice_capture_internal.h"

void func_8005AD88(int value)
{
    D_80192A98 = value;
}

void func_8005AD94(int categories)
{
    D_8008DA2C = &D_80192890;
    if (D_8008DA2C != 0) {
        D_8008DA2C->count = 0;
        D_8008DA2C->categoryMask = categories;
    }
}

void func_8005ADC4(void)
{
    D_8008DA2C = 0;
}
