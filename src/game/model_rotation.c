#include "../../include/model_geometry_internal.h"

void func_8003D2C0(int x, int y, int z, FixedMatrix *matrix)
{
    int cosineX;
    int sineX;
    int cosineY;
    int sineY;
    int cosineZ;
    int sineZ;

    cosineX = func_8004DB60(x);
    sineX = func_8004DB88(x);
    cosineY = func_8004DB60(y);
    sineY = func_8004DB88(y);
    cosineZ = func_8004DB60(z);
    sineZ = func_8004DB88(z);
    matrix->m[0][0] = (cosineZ * cosineY) >> 15;
    matrix->m[0][1] = ((((sineY * sineX) >> 15) * cosineZ) >> 15) - ((sineZ * cosineX) >> 15);
    matrix->m[0][2] = ((((sineY * cosineX) >> 15) * cosineZ) >> 15) + ((sineZ * sineX) >> 15);
    matrix->m[1][0] = (sineZ * cosineY) >> 15;
    matrix->m[1][1] = ((((sineY * sineX) >> 15) * sineZ) >> 15) + ((cosineZ * cosineX) >> 15);
    matrix->m[1][2] = ((((sineY * cosineX) >> 15) * sineZ) >> 15) - ((cosineZ * sineX) >> 15);
    matrix->m[2][0] = -sineY;
    matrix->m[2][1] = (cosineY * sineX) >> 15;
    matrix->m[2][2] = (cosineY * cosineX) >> 15;
}
