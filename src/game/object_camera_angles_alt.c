#include "../../include/object_helpers.h"
#include "../../include/frame.h"

extern float D_FLT_80094C4C;

void func_8003A128(int x, int y, int z)
{
    float scale = D_FLT_80094C4C;

    D_800C8B88.angle24[0] = x * scale / 2048;
    D_800C8BD8.angle[0] = x & 0xFFD;
    D_800C8BD8.angle[1] = y & 0xFFD;
    D_800C8BD8.angle[2] = z & 0xFFD;
    D_800C8B88.angle04[0] = D_800C8B88.angle24[0];
    D_800C8B88.angle24[1] = y * scale / 2048;
    D_800C8B88.angle04[1] = D_800C8B88.angle24[1];
    D_800C8B88.angle24[2] = z * scale / 2048;
    D_800C8B88.angle04[2] = D_800C8B88.angle24[2];
}
