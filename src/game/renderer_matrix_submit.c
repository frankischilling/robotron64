#include "../../include/renderer_draw_state_internal.h"
#include "../../include/graphics_state_internal.h"

static const unsigned char D_800953E0[] = "MAX NUMBER OF ROT_MATS EXCCEDED %d MAX=%d %s %d\n";
static const unsigned char D_80095414[] = "matrix.c";

int func_80047D88(RendererDrawState *draw, FixedMatrix *matrix)
{
    short *values;

    if (draw->projectedPosition[0] > 32000) {
        draw->projectedPosition[0] = 32000;
    }
    if (draw->projectedPosition[1] > 32000) {
        draw->projectedPosition[1] = 32000;
    }
    if (draw->projectedPosition[2] > 32000) {
        draw->projectedPosition[2] = 32000;
    }
    if (draw->projectedPosition[0] < -32000) {
        draw->projectedPosition[0] = -32000;
    }
    if (draw->projectedPosition[1] < -32000) {
        draw->projectedPosition[1] = -32000;
    }
    if (draw->projectedPosition[2] < -32000) {
        draw->projectedPosition[2] = -32000;
    }
    values = (short *)&D_80126B90[D_8007D6A8][D_8007D910];
    values[0] = matrix->m[0][0] >> 15;
    values[1] = matrix->m[1][0] >> 15;
    values[2] = matrix->m[2][0] >> 15;
    values[3] = 0;
    values[4] = matrix->m[0][1] >> 15;
    values[5] = matrix->m[1][1] >> 15;
    values[6] = matrix->m[2][1] >> 15;
    values[7] = 0;
    values[8] = matrix->m[0][2] >> 15;
    values[9] = matrix->m[1][2] >> 15;
    values[10] = matrix->m[2][2] >> 15;
    values[11] = 0;
    values[12] = draw->projectedPosition[0];
    values[13] = draw->projectedPosition[1];
    values[14] = draw->projectedPosition[2];
    values[15] = 1;
    values += 16;
    values[0] = matrix->m[0][0] << 1;
    values[1] = matrix->m[1][0] << 1;
    values[2] = matrix->m[2][0] << 1;
    values[3] = 0;
    values[4] = matrix->m[0][1] << 1;
    values[5] = matrix->m[1][1] << 1;
    values[6] = matrix->m[2][1] << 1;
    values[7] = 0;
    values[8] = matrix->m[0][2] << 1;
    values[9] = matrix->m[1][2] << 1;
    values[10] = matrix->m[2][2] << 1;
    values[11] = 0;
    values[12] = 0;
    values[13] = 0;
    values[14] = 0;
    values[15] = 0;

    FRAME_COMMAND(0x01020040, (unsigned int)&D_80126B90[D_8007D6A8][D_8007D910] - 0x80000000);
    D_8007D6A8++;
    if (D_8007D6A8 >= 250) {
        func_800496E0((unsigned char *)D_800953E0, D_8007D6A8, 250, D_80095414, 0x13B);
    }
    return D_8007D6A8 - 1;
}
