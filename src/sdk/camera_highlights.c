#include "../../include/sdk_camera.h"

void func_800609E0(float matrix[4][4], SdkLookAt *lookAt, SdkHilite *hilite,
                   float eyeX, float eyeY, float eyeZ,
                   float atX, float atY, float atZ,
                   float upX, float upY, float upZ,
                   float light1X, float light1Y, float light1Z,
                   float light2X, float light2Y, float light2Z,
                   int textureWidth, int textureHeight)
{
    float length, lookX, lookY, lookZ, rightX, rightY, rightZ;
    float highlightX, highlightY, highlightZ;

    func_80068350(matrix);
    lookX = atX - eyeX;
    lookY = atY - eyeY;
    lookZ = atZ - eyeZ;
    length = -1.0 / func_80063220(lookX * lookX + lookY * lookY + lookZ * lookZ);
    lookX *= length;
    lookY *= length;
    lookZ *= length;

    rightX = upY * lookZ - upZ * lookY;
    rightY = upZ * lookX - upX * lookZ;
    rightZ = upX * lookY - upY * lookX;
    length = 1.0 / func_80063220(rightX * rightX + rightY * rightY + rightZ * rightZ);
    rightX *= length;
    rightY *= length;
    rightZ *= length;

    upX = lookY * rightZ - lookZ * rightY;
    upY = lookZ * rightX - lookX * rightZ;
    upZ = lookX * rightY - lookY * rightX;
    length = 1.0 / func_80063220(upX * upX + upY * upY + upZ * upZ);
    upX *= length;
    upY *= length;
    upZ *= length;

    length = 1.0 / func_80063220(light1X * light1X + light1Y * light1Y + light1Z * light1Z);
    light1X *= length;
    light1Y *= length;
    light1Z *= length;
    highlightX = light1X + lookX;
    highlightY = light1Y + lookY;
    highlightZ = light1Z + lookZ;
    length = func_80063220(highlightX * highlightX + highlightY * highlightY + highlightZ * highlightZ);
    if (length > 0.1) {
        length = 1.0 / length;
        highlightX *= length;
        highlightY *= length;
        highlightZ *= length;
        hilite->coordinates.x1 = textureWidth * 4 +
            (highlightX * rightX + highlightY * rightY + highlightZ * rightZ) * textureWidth * 2;
        hilite->coordinates.y1 = textureHeight * 4 +
            (highlightX * upX + highlightY * upY + highlightZ * upZ) * textureHeight * 2;
    } else {
        hilite->coordinates.x1 = textureWidth * 2;
        hilite->coordinates.y1 = textureHeight * 2;
    }

    length = 1.0 / func_80063220(light2X * light2X + light2Y * light2Y + light2Z * light2Z);
    light2X *= length;
    light2Y *= length;
    light2Z *= length;
    highlightX = light2X + lookX;
    highlightY = light2Y + lookY;
    highlightZ = light2Z + lookZ;
    length = func_80063220(highlightX * highlightX + highlightY * highlightY + highlightZ * highlightZ);
    if (length > 0.1) {
        length = 1.0 / length;
        highlightX *= length;
        highlightY *= length;
        highlightZ *= length;
        hilite->coordinates.x2 = textureWidth * 4 +
            (highlightX * rightX + highlightY * rightY + highlightZ * rightZ) * textureWidth * 2;
        hilite->coordinates.y2 = textureHeight * 4 +
            (highlightX * upX + highlightY * upY + highlightZ * upZ) * textureHeight * 2;
    } else {
        hilite->coordinates.x2 = textureWidth * 2;
        hilite->coordinates.y2 = textureHeight * 2;
    }

    lookAt->lights[0].value.direction[0] = SDK_CAMERA_FRACTION(rightX);
    lookAt->lights[0].value.direction[1] = SDK_CAMERA_FRACTION(rightY);
    lookAt->lights[0].value.direction[2] = SDK_CAMERA_FRACTION(rightZ);
    lookAt->lights[1].value.direction[0] = SDK_CAMERA_FRACTION(upX);
    lookAt->lights[1].value.direction[1] = SDK_CAMERA_FRACTION(upY);
    lookAt->lights[1].value.direction[2] = SDK_CAMERA_FRACTION(upZ);
    lookAt->lights[0].value.color[0] = 0;
    lookAt->lights[0].value.color[1] = 0;
    lookAt->lights[0].value.color[2] = 0;
    lookAt->lights[0].value.padding03 = 0;
    lookAt->lights[0].value.colorCopy[0] = 0;
    lookAt->lights[0].value.colorCopy[1] = 0;
    lookAt->lights[0].value.colorCopy[2] = 0;
    lookAt->lights[0].value.padding07 = 0;
    lookAt->lights[1].value.color[0] = 0;
    lookAt->lights[1].value.color[1] = 0x80;
    lookAt->lights[1].value.color[2] = 0;
    lookAt->lights[1].value.padding03 = 0;
    lookAt->lights[1].value.colorCopy[0] = 0;
    lookAt->lights[1].value.colorCopy[1] = 0x80;
    lookAt->lights[1].value.colorCopy[2] = 0;
    lookAt->lights[1].value.padding07 = 0;

    matrix[0][0] = rightX;
    matrix[1][0] = rightY;
    matrix[2][0] = rightZ;
    matrix[3][0] = -(eyeX * rightX + eyeY * rightY + eyeZ * rightZ);
    matrix[0][1] = upX;
    matrix[1][1] = upY;
    matrix[2][1] = upZ;
    matrix[3][1] = -(eyeX * upX + eyeY * upY + eyeZ * upZ);
    matrix[0][2] = lookX;
    matrix[1][2] = lookY;
    matrix[2][2] = lookZ;
    matrix[3][2] = -(eyeX * lookX + eyeY * lookY + eyeZ * lookZ);
    matrix[0][3] = 0;
    matrix[1][3] = 0;
    matrix[2][3] = 0;
    matrix[3][3] = 1;
}

void func_8006114C(SdkMatrix *matrix, SdkLookAt *lookAt, SdkHilite *hilite,
                   float eyeX, float eyeY, float eyeZ,
                   float atX, float atY, float atZ,
                   float upX, float upY, float upZ,
                   float light1X, float light1Y, float light1Z,
                   float light2X, float light2Y, float light2Z,
                   int textureWidth, int textureHeight)
{
    float temporary[4][4];

    func_800609E0(temporary, lookAt, hilite, eyeX, eyeY, eyeZ, atX, atY, atZ,
                  upX, upY, upZ, light1X, light1Y, light1Z,
                  light2X, light2Y, light2Z, textureWidth, textureHeight);
    func_80068250(temporary, matrix);
}
