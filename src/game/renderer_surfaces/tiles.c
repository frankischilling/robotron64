#include "../../../include/renderer_surfaces_internal.h"

/* Complete candidate; excluded until all compiled instructions match. */
void func_80042E2C(int unused)
{
    int x;
    int z;
    int base;

    FRAME_COMMAND(0xE7000000, 0);
    func_8004729C(1);
    FRAME_COMMAND(0xFCFFFFFF, 0xFFFCF87C);
    FRAME_COMMAND(0xB900031D, 0x004049D8);
    FRAME_COMMAND(0xBA001001, 0);
    FRAME_COMMAND(0xBA000C02, 0x2000);
    FRAME_COMMAND(0xBA001301, 0x80000);
    FRAME_COMMAND(0xBA000E02, 0);
    FRAME_COMMAND(0xBB000001, 0x80008000);
    func_80042830(D_800C8DFC);
    base = D_80123AE4 = func_80047048();
    if (base != -1) {
        for (z = -2; z < 3; z++) {
            for (x = -2; x < 3; x++) {
                func_80043070(x * 3320, z * 3320);
            }
        }
        func_80047094(D_80123AE4 - base);
        FRAME_COMMAND(0xE7000000, 0);
        FRAME_COMMAND(0xFCFFFFFF, 0xFFFE793C);
        FRAME_COMMAND(0xBA001301, 0);
        FRAME_COMMAND(0x06000000, D_8007CA70);
        func_80046AD0();
    }
}
