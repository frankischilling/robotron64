#include "../../include/model_geometry_internal.h"

FixedMatrix D_800CD250;

void func_8003F480(void)
{
    int negativeSineX;
    int negativeCosineX;
    int sinYCosZ;
    int cosXSinZ;
    int sinXSinYCosZ;
    int sinYSinZ;
    int cosXCosZ;
    int negativeSinXSinYSinZ;
    int negativeSinXCosY;
    int fractionBits = 15;
    int cosineX;
    int sineX;
    int cosineY;
    int sineY;
    int cosineZ;
    int sineZ;
    /* Retain the consumed shift copy and declaration order for IDO allocation. */
    int rowFractionBits;

    cosineX = func_8004DB60(-D_800C8BD8.angle[0]);
    sineX = func_8004DB88(-D_800C8BD8.angle[0]);
    cosineY = func_8004DB60(-D_800C8BD8.angle[1]);
    sineY = func_8004DB88(-D_800C8BD8.angle[1]);
    cosineZ = func_8004DB60(-D_800C8BD8.angle[2]);
    sineZ = func_8004DB88(-D_800C8BD8.angle[2]);
    negativeSineX = -sineX;
    negativeCosineX = -cosineX;
    D_800CD250.m[0][0] = ((cosineY * cosineZ) >> fractionBits);
    D_800CD250.m[0][1] = ((-cosineY * sineZ) >> fractionBits);
    D_800CD250.m[0][2] = sineY;
    sinYCosZ = (sineY * cosineZ) >> fractionBits;
    rowFractionBits = fractionBits;
    cosXSinZ = (cosineX * sineZ) >> rowFractionBits;
    sinXSinYCosZ = (sineX * sinYCosZ) >> rowFractionBits;
    D_800CD250.m[1][0] = cosXSinZ + sinXSinYCosZ;
    sinYSinZ = (sineY * sineZ) >> rowFractionBits;
    cosXCosZ = (cosineX * cosineZ) >> rowFractionBits;
    negativeSinXSinYSinZ = (negativeSineX * sinYSinZ) >> rowFractionBits;
    D_800CD250.m[1][1] = cosXCosZ + negativeSinXSinYSinZ;
    negativeSinXCosY = (negativeSineX * cosineY) >> rowFractionBits;
    D_800CD250.m[1][2] = negativeSinXCosY;
    D_800CD250.m[2][0] = ((sineX * sineZ) >> rowFractionBits) +
        ((negativeCosineX * sinYCosZ) >> rowFractionBits);
    D_800CD250.m[2][1] = ((sineX * cosineZ) >> rowFractionBits) +
        ((cosineX * sinYSinZ) >> rowFractionBits);
    D_800CD250.m[2][2] = ((cosineX * cosineY) >> rowFractionBits);
}
