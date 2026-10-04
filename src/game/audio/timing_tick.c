#include "../../../include/audio_host_internal.h"

int func_80058A58(void)
{
    volatile unsigned int *time = &D_8008D86C;

    D_8008D868++;
    D_8008D874 += 0x85555;
    *time += D_8008D874 >> 16;
    D_8008D874 &= 0xFFFF;
    if (D_8008D870) {
        func_80059438();
        func_8005A9AC();
    }
    return 0;
}
