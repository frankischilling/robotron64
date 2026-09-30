#include "../../include/sdk_matrix.h"

void func_80061210(float matrix[4][4], float x, float y, float z)
{
    func_80068350(matrix);
    matrix[3][0] = x;
    matrix[3][1] = y;
    matrix[3][2] = z;
}

void func_80061258(SdkMatrix *fixed, float x, float y, float z)
{
    float matrix[4][4];

    func_80061210(matrix, x, y, z);
    func_80068250(matrix, fixed);
}
