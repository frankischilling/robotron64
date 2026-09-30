#include "../../include/renderer_geometry_internal.h"

#include "../../include/renderer_texture_index.h"

int func_80005814(int table, int texture, int value)
{
    func_8004729C(15);
    FRAME_COMMAND(0xE7000000, 0);
    FRAME_COMMAND(0xBA000C02, 0x2000);
    FRAME_COMMAND(0xBA001001, 0);
    FRAME_COMMAND(0xBA001301, 0x80000);
    func_80049AD8(D_8007D6D0);
    func_8004AD64(D_8007BAC4[table].data + (texture << 10), value);
    return 0;
}
