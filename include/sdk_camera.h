#ifndef ROBOTRON_SDK_CAMERA_H
#define ROBOTRON_SDK_CAMERA_H

#include "sdk_matrix.h"
#include "sdk_float_math.h"

typedef struct SdkLightData {
    unsigned char color[3];
    char padding03;
    unsigned char colorCopy[3];
    char padding07;
    signed char direction[3];
    char padding0B;
} SdkLightData;

typedef union SdkLight {
    SdkLightData value;
    long long alignment[2];
} SdkLight;

typedef struct SdkLookAt {
    SdkLight lights[2];
} SdkLookAt;

typedef union SdkHilite {
    struct {
        int x1;
        int y1;
        int x2;
        int y2;
    } coordinates;
    long long alignment[2];
} SdkHilite;

typedef char SdkLightMustBe16Bytes[sizeof(SdkLight) == 16 ? 1 : -1];
typedef char SdkLookAtMustBe32Bytes[sizeof(SdkLookAt) == 32 ? 1 : -1];
typedef char SdkHiliteMustBe16Bytes[sizeof(SdkHilite) == 16 ? 1 : -1];

#define SDK_CAMERA_FRACTION(value) \
    ((int)(((value) * 128.0) < 127.0 ? ((value) * 128.0) : 127.0) & 0xFF)

void func_80060750(float matrix[4][4], unsigned short *normalization,
                   float fieldOfView, float aspect, float nearPlane,
                   float farPlane, float scale);
void func_80060980(SdkMatrix *matrix, unsigned short *normalization,
                   float fieldOfView, float aspect, float nearPlane,
                   float farPlane, float scale);
void func_800609E0(float matrix[4][4], SdkLookAt *lookAt, SdkHilite *hilite,
                   float eyeX, float eyeY, float eyeZ,
                   float atX, float atY, float atZ,
                   float upX, float upY, float upZ,
                   float light1X, float light1Y, float light1Z,
                   float light2X, float light2Y, float light2Z,
                   int textureWidth, int textureHeight);
void func_8006114C(SdkMatrix *matrix, SdkLookAt *lookAt, SdkHilite *hilite,
                   float eyeX, float eyeY, float eyeZ,
                   float atX, float atY, float atZ,
                   float upX, float upY, float upZ,
                   float light1X, float light1Y, float light1Z,
                   float light2X, float light2Y, float light2Z,
                   int textureWidth, int textureHeight);
void func_800612B0(float matrix[4][4], float roll, float pitch, float yaw);
void func_800613FC(SdkMatrix *matrix, float roll, float pitch, float yaw);

#endif
