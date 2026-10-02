#include "../../include/renderer_image_setup_internal.h"

/* Nonmatching candidate; see docs/render-submission-effects.md. */
void func_8004AFA4(unsigned char *address)
{
    RendererDrawState draw;

    draw.scale[0] = D_8008CB34;
    draw.scale[1] = D_8008CB34;
    draw.scale[2] = D_8008CB34;
    draw.angle[0] = 0;
    draw.angle[1] = 0;
    draw.angle[2] = 0;
    draw.projectedPosition[0] = D_8013D9A0;
    draw.projectedPosition[1] = D_8013D9A4;
    draw.projectedPosition[2] = D_8013D9A8;
    func_80047570(&draw);
    func_8004729C(15);
    func_8004ABC8();
    FRAME_COMMAND(0xBA001301, 0);
    FRAME_COMMAND(0xBA000E02, 0);
    FRAME_COMMAND(0xB900031D, 0x00553078);
    D_80123AE8 = 128;
    func_8004B098(address, 40);
}
