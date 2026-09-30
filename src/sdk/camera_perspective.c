#include "../../include/sdk_camera.h"

void func_80060750(float matrix[4][4], unsigned short *normalization,
                   float fieldOfView, float aspect, float nearPlane,
                   float farPlane, float scale)
{
    float cotangent;
    int row, column;

    func_80068350(matrix);
    fieldOfView *= 3.1415926 / 180.0;
    cotangent = func_800633F0(fieldOfView / 2) / func_80063230(fieldOfView / 2);
    matrix[0][0] = cotangent / aspect;
    matrix[1][1] = cotangent;
    matrix[2][2] = (nearPlane + farPlane) / (nearPlane - farPlane);
    matrix[2][3] = -1;
    matrix[3][2] = (2 * nearPlane * farPlane) / (nearPlane - farPlane);
    matrix[3][3] = 0;
    for (row = 0; row < 4; row++) {
        for (column = 0; column < 4; column++) {
            matrix[row][column] *= scale;
        }
    }
    if (normalization != 0) {
        if (nearPlane + farPlane <= 2.0) {
            *normalization = (unsigned short)0xFFFF;
        } else {
            *normalization = (unsigned short)((2.0 * 65536.0) / (nearPlane + farPlane));
            if (*normalization <= 0) {
                *normalization = (unsigned short)1;
            }
        }
    }
}

void func_80060980(SdkMatrix *matrix, unsigned short *normalization,
                   float fieldOfView, float aspect, float nearPlane,
                   float farPlane, float scale)
{
    float temporary[4][4];

    func_80060750(temporary, normalization, fieldOfView, aspect, nearPlane, farPlane, scale);
    func_80068250(temporary, matrix);
}
