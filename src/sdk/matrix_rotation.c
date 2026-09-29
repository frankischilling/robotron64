#include "../../include/sdk_camera.h"

void func_800612B0(float matrix[4][4], float roll, float pitch, float yaw)
{
    static float degreesToRadians = 3.1415926 / 180.0;
    float sineRoll, sinePitch, sineYaw;
    float cosineRoll, cosinePitch, cosineYaw;

    roll *= degreesToRadians;
    pitch *= degreesToRadians;
    yaw *= degreesToRadians;
    sineRoll = func_80063230(roll);
    cosineRoll = func_800633F0(roll);
    sinePitch = func_80063230(pitch);
    cosinePitch = func_800633F0(pitch);
    sineYaw = func_80063230(yaw);
    cosineYaw = func_800633F0(yaw);
    func_80068350(matrix);
    matrix[0][0] = cosinePitch * cosineYaw;
    matrix[0][1] = cosinePitch * sineYaw;
    matrix[0][2] = -sinePitch;
    matrix[1][0] = sineRoll * sinePitch * cosineYaw - cosineRoll * sineYaw;
    matrix[1][1] = sineRoll * sinePitch * sineYaw + cosineRoll * cosineYaw;
    matrix[1][2] = sineRoll * cosinePitch;
    matrix[2][0] = cosineRoll * sinePitch * cosineYaw + sineRoll * sineYaw;
    matrix[2][1] = cosineRoll * sinePitch * sineYaw - sineRoll * cosineYaw;
    matrix[2][2] = cosineRoll * cosinePitch;
}

void func_800613FC(SdkMatrix *matrix, float roll, float pitch, float yaw)
{
    float temporary[4][4];

    func_800612B0(temporary, roll, pitch, yaw);
    func_80068250(temporary, matrix);
}
