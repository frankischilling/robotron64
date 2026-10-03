#include "../../include/renderer_draw_state_internal.h"
#include "../../include/graphics_state_internal.h"

extern unsigned char D_800953A0[];
extern unsigned char D_800953D4[];

int func_80047A08(RendererDrawState *draw, FixedMatrix *input)
{
    /* These constants retain the pinned compiler's frame and scheduling. */
    int fractionBits = 15;
    int fractionShift = 1;
    int projectionLimit = 32000;
    int matrixCapacity = 250;
    unsigned int matrixCommand = 0x01020040;
    unsigned int physicalBias = 0x80000000;
    int scaleX;
    int scaleY;
    int scaleZ;
    FixedMatrix matrix;
    int scaleShift = 4;
    short *values;

    if (draw->projectedPosition[0] > projectionLimit) {
        draw->projectedPosition[0] = projectionLimit;
    }
    if (draw->projectedPosition[1] > projectionLimit) {
        draw->projectedPosition[1] = projectionLimit;
    }
    if (draw->projectedPosition[2] > projectionLimit) {
        draw->projectedPosition[2] = projectionLimit;
    }
    if (draw->projectedPosition[0] < -projectionLimit) {
        draw->projectedPosition[0] = -projectionLimit;
    }
    if (draw->projectedPosition[1] < -projectionLimit) {
        draw->projectedPosition[1] = -projectionLimit;
    }
    if (draw->projectedPosition[2] < -projectionLimit) {
        draw->projectedPosition[2] = -projectionLimit;
    }
    scaleX = draw->scale[0];
    scaleY = draw->scale[1];
    scaleZ = draw->scale[2];
    matrix.m[0][0] = (input->m[0][0] * scaleX) >> scaleShift;
    matrix.m[0][1] = (input->m[0][1] * scaleX) >> scaleShift;
    matrix.m[0][2] = (input->m[0][2] * scaleX) >> scaleShift;
    matrix.m[1][0] = (input->m[1][0] * scaleY) >> scaleShift;
    matrix.m[1][1] = (input->m[1][1] * scaleY) >> scaleShift;
    matrix.m[1][2] = (input->m[1][2] * scaleY) >> scaleShift;
    matrix.m[2][0] = (input->m[2][0] * scaleZ) >> scaleShift;
    matrix.m[2][1] = (input->m[2][1] * scaleZ) >> scaleShift;
    matrix.m[2][2] = (input->m[2][2] * scaleZ) >> scaleShift;

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
    values[0] = matrix.m[0][0] << fractionShift;
    values[1] = matrix.m[1][0] << fractionShift;
    values[2] = matrix.m[2][0] << fractionShift;
    values[3] = 0;
    values[4] = matrix.m[0][1] << fractionShift;
    values[5] = matrix.m[1][1] << fractionShift;
    values[6] = matrix.m[2][1] << fractionShift;
    values[7] = 0;
    values[8] = matrix.m[0][2] << fractionShift;
    values[9] = matrix.m[1][2] << fractionShift;
    values[10] = matrix.m[2][2] << fractionShift;
    values[11] = 0;
    values[12] = 0;
    values[13] = 0;
    values[14] = 0;
    values[15] = 0;
    FRAME_COMMAND(matrixCommand, (unsigned int)&D_80126B90[D_8007D6A8][D_8007D910] - physicalBias);
    D_8007D6A8++;
    if (D_8007D6A8 >= matrixCapacity) {
        func_800496E0(D_800953A0, D_8007D6A8, matrixCapacity, D_800953D4, 247);
    }
    return D_8007D6A8 - 1;
}
