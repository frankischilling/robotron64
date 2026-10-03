#include "../../../include/renderer_image_setup_internal.h"

/* Named values are used in the renderer packets, draw state and image call. */
void func_8004ACA4(unsigned char *address)
{
    int rendererMode = 15;
    unsigned int perspectiveCommand = 0xBA001301;
    int texturePerspective = 0;
    int angle = 0;
    int alpha = 255;
    int extent = 20;
    RendererDrawState draw;

    func_8004729C(rendererMode);
    func_8004ABC8();
    FRAME_COMMAND(perspectiveCommand, texturePerspective);
    draw.scale[0] = D_8008CB34;
    draw.scale[1] = D_8008CB34;
    draw.scale[2] = D_8008CB34;
    draw.angle[0] = angle;
    draw.angle[1] = angle;
    draw.angle[2] = angle;
    draw.projectedPosition[0] = D_8013D9A0;
    draw.projectedPosition[1] = D_8013D9A4;
    draw.projectedPosition[2] = D_8013D9A8;
    func_80047570(&draw);
    func_80049AD8(D_8007D6D0);
    D_80123AE8 = alpha;
    func_8004AD64(address, extent);
}
