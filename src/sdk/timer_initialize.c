#include "../../include/sdk_timers.h"

SdkTime D_80196450;

void func_800684D0(void)
{
    D_80196450 = 0;
    D_80196458 = 0;
    D_8019645C = 0;
    D_8008F240->next = D_8008F240->previous = D_8008F240;
    D_8008F240->interval = D_8008F240->value = 0;
    D_8008F240->queue = 0;
    D_8008F240->message = 0;
}
