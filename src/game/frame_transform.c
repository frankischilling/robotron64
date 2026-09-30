#include "../../include/fixed_math.h"

void func_8004D4B4(int *output, FixedMatrix *matrix, int *position)
{
    output[0] = ((position[0] * matrix->m[0][0]) >> 15) +
                ((position[1] * matrix->m[0][1]) >> 15) +
                ((position[2] * matrix->m[0][2]) >> 15);
    output[1] = ((position[0] * matrix->m[1][0]) >> 15) +
                ((position[1] * matrix->m[1][1]) >> 15) +
                ((position[2] * matrix->m[1][2]) >> 15);
    output[2] = ((position[0] * matrix->m[2][0]) >> 15) +
                ((position[1] * matrix->m[2][1]) >> 15) +
                ((position[2] * matrix->m[2][2]) >> 15);
}
