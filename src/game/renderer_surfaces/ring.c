#include "../../../include/renderer_surfaces_internal.h"

/* Complete candidate; excluded until all compiled instructions match. */
void func_800428C0(int unused)
{
    RendererPosition first;
    RendererPosition second;
    RendererPosition third;
    RendererPosition fourth;
    int radius;
    int segment;
    int base;

    FRAME_COMMAND(0xE7000000, 0);
    FRAME_COMMAND(0xFCFFFFFF, 0xFFFCF87C);
    FRAME_COMMAND(0xB900031D, 0x004049D8);
    FRAME_COMMAND(0xBA001001, 0);
    FRAME_COMMAND(0xBA000C02, 0x2000);
    FRAME_COMMAND(0xBA001301, 0x80000);
    FRAME_COMMAND(0xBA000E02, 0);
    FRAME_COMMAND(0xBB000001, 0x80008000);
    func_80042830(D_800C8DFC);
    D_80123AE4 = func_80047048();
    if (D_80123AE4 != -1) {
        base = D_80123AE4;
        for (radius = 0; radius != 9000; radius += 2250) {
            for (segment = 1; segment < 9; segment++) {
                first[0] = func_8004DBB0(radius, (segment * 2 - 1) << 12);
                first[1] = 0;
                first[2] = func_8004DBE4(radius, (segment * 2 - 1) << 12);
                second[0] = func_8004DBB0(radius, (segment * 2 + 1) << 12);
                second[1] = 0;
                second[2] = func_8004DBE4(radius, (segment * 2 + 1) << 12);
                third[0] = func_8004DBB0(radius + 2500, (segment * 2 + 1) << 12);
                third[1] = 0;
                third[2] = func_8004DBE4(radius + 2500, (segment * 2 + 1) << 12);
                fourth[0] = func_8004DBB0(radius + 2500, (segment * 2 - 1) << 12);
                fourth[1] = 0;
                fourth[2] = func_8004DBE4(radius + 2500, (segment * 2 - 1) << 12);
                func_80042BDC(first, second, third, fourth);
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
