#include "../../include/model_geometry_internal.h"

/* Excluded candidate; see docs/renderer-inverse-camera.md. */
void func_8003F480(void)
{
    int sinYCosZ;
    int cosXSinZ;
    int sinXSinYCosZ;
    int sinYSinZ;
    int cosXCosZ;
    int negativeSinXCosY;
    int sinXSinZ;
    int sinXCosZ;
    int cosXSinYSinZ;
    int fractionBits = 15;
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
    D_800CD250.m[0][0] = ((cosineY * cosineZ) >> fractionBits);
    D_800CD250.m[0][1] = ((-cosineY * sineZ) >> fractionBits);
    D_800CD250.m[0][2] = sineY;
    sinYCosZ = (sineY * cosineZ) >> fractionBits;
    cosXSinZ = (cosineX * sineZ) >> fractionBits;
    sinXSinYCosZ = (sineX * sinYCosZ) >> fractionBits;
    D_800CD250.m[1][0] = cosXSinZ + sinXSinYCosZ;
    sinYSinZ = (sineY * sineZ) >> fractionBits;
    cosXCosZ = (cosineX * cosineZ) >> fractionBits;
    D_800CD250.m[1][1] = cosXCosZ + ((-sineX * sinYSinZ) >> fractionBits);
    negativeSinXCosY = (-sineX * cosineY) >> fractionBits;
    D_800CD250.m[1][2] = negativeSinXCosY;
    sinXSinZ = (sineX * sineZ) >> fractionBits;
    D_800CD250.m[2][0] = sinXSinZ + ((-cosineX * sinYCosZ) >> fractionBits);
    sinXCosZ = (sineX * cosineZ) >> fractionBits;
    cosXSinYSinZ = (cosineX * sinYSinZ) >> fractionBits;
    D_800CD250.m[2][1] = sinXCosZ + cosXSinYSinZ;
    D_800CD250.m[2][2] = ((cosineX * cosineY) >> fractionBits);
}
