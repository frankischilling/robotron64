#include "../../include/model_geometry_internal.h"

void func_8003F650(FixedMatrix *matrix)
{
    int cosineX;
    int sineX;
    int cosineY;
    int sineY;
    int cosineZ;
    int sineZ;
    int negativeSineX;

    cosineX = func_8004DB60(-D_800C8BD8.angle[0]);
    sineX = func_8004DB88(-D_800C8BD8.angle[0]);
    cosineY = func_8004DB60(-D_800C8BD8.angle[1]);
    sineY = func_8004DB88(-D_800C8BD8.angle[1]);
    cosineZ = func_8004DB60(-D_800C8BD8.angle[2]);
    sineZ = func_8004DB88(-D_800C8BD8.angle[2]);
    negativeSineX = -sineX;
    matrix->m[0][2] = sineY;
    matrix->m[0][0] = (cosineY * cosineZ) >> 15;
    matrix->m[0][1] = (-cosineY * sineZ) >> 15;
    matrix->m[1][0] = ((cosineX * sineZ) >> 15) + ((sineX * ((sineY * cosineZ) >> 15)) >> 15);
    matrix->m[1][1] = ((cosineX * cosineZ) >> 15) + ((negativeSineX * ((sineY * sineZ) >> 15)) >> 15);
    matrix->m[1][2] = (negativeSineX * cosineY) >> 15;
    matrix->m[2][0] = ((sineX * sineZ) >> 15) + ((-cosineX * ((sineY * cosineZ) >> 15)) >> 15);
    matrix->m[2][1] = ((sineX * cosineZ) >> 15) + ((cosineX * ((sineY * sineZ) >> 15)) >> 15);
    matrix->m[2][2] = (cosineX * cosineY) >> 15;
}
