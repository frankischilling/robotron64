#include "../../include/sdk_video_manager.h"

SdkVideoContext D_8008F1D0[2] = {0};
SdkVideoContext *D_8008F230 = &D_8008F1D0[0];
SdkVideoContext *D_8008F234 = &D_8008F1D0[1];
extern unsigned int D_80000300;
extern VideoMode D_8008F530;
extern VideoMode D_8008F580;
extern VideoMode D_8008F5D0;
void func_800674C0(void *destination, unsigned int size);
void func_8006AC90(void);

void func_80068050(void)
{
    func_800674C0(D_8008F1D0, sizeof(D_8008F1D0));
    D_8008F230 = &D_8008F1D0[0];
    D_8008F234 = &D_8008F1D0[1];
    D_8008F234->retraces = 1;
    D_8008F230->retraces = 1;
    D_8008F234->framebuffer = (void *)0x80000000;
    D_8008F230->framebuffer = (void *)0x80000000;
    if (D_80000300 == 0) {
        D_8008F234->mode = &D_8008F530;
    } else if (D_80000300 == 2) {
        D_8008F234->mode = &D_8008F580;
    } else {
        D_8008F234->mode = &D_8008F5D0;
    }
    D_8008F234->state = 0x20;
    D_8008F234->control = D_8008F234->mode->control;
    while (*(volatile unsigned int *)0xA4400010 > 10) {
    }
    *(volatile unsigned int *)0xA4400000 = 0;
    func_8006AC90();
}
