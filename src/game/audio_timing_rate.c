#include "../../include/audio_properties_internal.h"

short func_800589DC(void)
{
    return 120;
}

int func_800589E4(short time, short scale, short value)
{
    return (unsigned long long)value * 65536 * scale / 60 / time;
}
