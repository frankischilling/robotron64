#include "../../include/fixed_math.h"
#include "../../include/sdk_matrix.h"

void func_80048020(FixedMatrix *matrix, SdkMatrix *output)
{
    short *values = (short *)output;

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
    values[12] = 0;
    values[13] = 0;
    values[14] = 0;
    values[15] = 1;
    values[16] = matrix->m[0][0] << 1;
    values[17] = matrix->m[1][0] << 1;
    values[18] = matrix->m[2][0] << 1;
    values[19] = 0;
    values[20] = matrix->m[0][1] << 1;
    values[21] = matrix->m[1][1] << 1;
    values[22] = matrix->m[2][1] << 1;
    values[23] = 0;
    values[24] = matrix->m[0][2] << 1;
    values[25] = matrix->m[1][2] << 1;
    values[26] = matrix->m[2][2] << 1;
    values[27] = 0;
    values[28] = 0;
    values[29] = 0;
    values[30] = 0;
    values[31] = 0;
}
