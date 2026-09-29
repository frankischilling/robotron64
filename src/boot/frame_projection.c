#include "../../include/frame.h"

extern void *D_8013823C;

float func_8004CE08(float x, float y);
void func_80060980(void *matrix, unsigned short *perspNorm, float fovy,
                   float aspect, float near, float far, float scale);

void func_800493F4(int value)
{
    float fovy;
    unsigned short perspNorm;

    fovy = func_8004CE08(480.0f, (float)value) * 360.0 / 4096.0;
    func_80060980((unsigned char *)D_8013823C + 0x100, &perspNorm, fovy,
                  1.3333334f, 100.0f, 50000.0f, 1.0f);
    FRAME_COMMAND(0xBC00000E, perspNorm);
    FRAME_COMMAND(0x01030040, (unsigned int)D_8013823C + 0x80000100);
    FRAME_COMMAND(0x01010040, (unsigned int)D_8013823C + 0x80000080);
}
