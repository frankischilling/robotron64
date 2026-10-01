#include "../../include/model_geometry_internal.h"

void func_8003F480(void)
{
    int cosineX;
    int sineX;
    int cosineY;
    int sineY;
    int cosineZ;
    int sineZ;

    cosineX = func_8004DB60(-D_800C8BD8.angle[0]);
    sineX = func_8004DB88(-D_800C8BD8.angle[0]);
    cosineY = func_8004DB60(-D_800C8BD8.angle[1]);
    sineY = func_8004DB88(-D_800C8BD8.angle[1]);
    cosineZ = func_8004DB60(-D_800C8BD8.angle[2]);
    sineZ = func_8004DB88(-D_800C8BD8.angle[2]);
    D_800CD250.m[0][0] = (cosineY * cosineZ) >> 15;
    D_800CD250.m[0][1] = (-cosineY * sineZ) >> 15;
    D_800CD250.m[0][2] = sineY;
    D_800CD250.m[1][0] = ((cosineX * sineZ) >> 15) +
        ((sineX * ((sineY * cosineZ) >> 15)) >> 15);
    D_800CD250.m[1][1] = ((cosineX * cosineZ) >> 15) +
        ((-sineX * ((sineY * sineZ) >> 15)) >> 15);
    D_800CD250.m[1][2] = (-sineX * cosineY) >> 15;
    D_800CD250.m[2][0] = ((sineX * sineZ) >> 15) +
        ((-cosineX * ((sineY * cosineZ) >> 15)) >> 15);
    D_800CD250.m[2][1] = ((sineX * cosineZ) >> 15) +
        ((cosineX * ((sineY * sineZ) >> 15)) >> 15);
    D_800CD250.m[2][2] = (cosineX * cosineY) >> 15;
}
