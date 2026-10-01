#include "../../include/object_helpers.h"
#include "../../include/frame.h"

void func_80039FCC(int x, int y, int z)
{

    D_800C8B88.angle24[0] = x * 3.141592f / 2048;
    D_800C8BD8.angle[0] = x & 0xFFD;
    D_800C8BD8.angle[1] = (y + 0x800) & 0xFFD;
    D_800C8BD8.angle[2] = z & 0xFFD;
    D_800C8B88.angle04[0] = D_800C8B88.angle24[0];
    D_800C8B88.angle24[1] = y * 3.141592f / 2048;
    D_800C8B88.angle04[1] = D_800C8B88.angle24[1];
    D_800C8B88.angle24[2] = z * 3.141592f / 2048;
    D_800C8B88.angle04[2] = D_800C8B88.angle24[2];
}
