#include "../../include/renderer_draw_state_internal.h"
#include "../../include/graphics_state_internal.h"

static const unsigned char D_80095360[] = "MAX NUMBER OF ROT_MATS EXCCEDED %d MAX=%d %s %d\n";
static const unsigned char D_80095394[] = "matrix.c";

int func_80047570(RendererDrawState *draw)
{
    int cosineX;
    int sineX;
    int cosineY;
    int sineY;
    int cosineZ;
    int sineZ;
    int scaleX;
    int scaleY;
    int scaleZ;
    FixedMatrix matrix;
    int fractionBits;
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
    fractionBits = 15;
    cosineX = func_8004DB60(draw->angle[0]);
    sineX = func_8004DB88(draw->angle[0]);
    cosineY = func_8004DB60(draw->angle[1]);
    sineY = func_8004DB88(draw->angle[1]);
    cosineZ = func_8004DB60(draw->angle[2]);
    sineZ = func_8004DB88(draw->angle[2]);
    scaleX = draw->scale[0];
    scaleY = draw->scale[1];
    scaleZ = draw->scale[2];
    matrix.m[0][0] = (((cosineZ * cosineY) >> fractionBits) * scaleX) >> 4;
    matrix.m[0][1] = ((((((sineY * sineX) >> fractionBits) * cosineZ) >> fractionBits) -
                       ((sineZ * cosineX) >> fractionBits)) * scaleX) >> 4;
    matrix.m[0][2] = ((((((sineY * cosineX) >> fractionBits) * cosineZ) >> fractionBits) +
                       ((sineZ * sineX) >> fractionBits)) * scaleX) >> 4;
    matrix.m[1][0] = (((sineZ * cosineY) >> fractionBits) * scaleY) >> 4;
    matrix.m[1][1] = ((((((sineY * sineX) >> fractionBits) * sineZ) >> fractionBits) +
                       ((cosineZ * cosineX) >> fractionBits)) * scaleY) >> 4;
    matrix.m[1][2] = ((((((sineY * cosineX) >> fractionBits) * sineZ) >> fractionBits) -
                       ((cosineZ * sineX) >> fractionBits)) * scaleY) >> 4;
    matrix.m[2][0] = (-sineY * scaleZ) >> 4;
    matrix.m[2][1] = (((cosineY * sineX) >> fractionBits) * scaleZ) >> 4;
    matrix.m[2][2] = (((cosineY * cosineX) >> fractionBits) * scaleZ) >> 4;

    values = (short *)&D_80126B90[D_8007D6A8][D_8007D910];
    values[0] = matrix.m[0][0] >> fractionBits;
    values[1] = matrix.m[1][0] >> fractionBits;
    values[2] = matrix.m[2][0] >> fractionBits;
    values[3] = 0;
    values[4] = matrix.m[0][1] >> fractionBits;
    values[5] = matrix.m[1][1] >> fractionBits;
    values[6] = matrix.m[2][1] >> fractionBits;
    values[7] = 0;
    values[8] = matrix.m[0][2] >> fractionBits;
    values[9] = matrix.m[1][2] >> fractionBits;
    values[10] = matrix.m[2][2] >> fractionBits;
    values[11] = 0;
    values[12] = draw->projectedPosition[0];
    values[13] = draw->projectedPosition[1];
    values[14] = draw->projectedPosition[2];
    values[15] = 1;
    values += 16;
    values[0] = matrix.m[0][0] << 1;
    values[1] = matrix.m[1][0] << 1;
    values[2] = matrix.m[2][0] << 1;
    values[3] = 0;
    values[4] = matrix.m[0][1] << 1;
    values[5] = matrix.m[1][1] << 1;
    values[6] = matrix.m[2][1] << 1;
    values[7] = 0;
    values[8] = matrix.m[0][2] << 1;
    values[9] = matrix.m[1][2] << 1;
    values[10] = matrix.m[2][2] << 1;
    values[11] = 0;
    values[12] = 0;
    values[13] = 0;
    values[14] = 0;
    values[15] = 0;
    FRAME_COMMAND(0x01020040, (unsigned int)&D_80126B90[D_8007D6A8][D_8007D910] - 0x80000000);
    D_8007D6A8++;
    if (D_8007D6A8 >= 250) {
        func_800496E0((unsigned char *)D_80095360, D_8007D6A8, 250, D_80095394, 160);
    }
    return D_8007D6A8 - 1;
}
