#include "../../include/graphics_state_internal.h"
#include "../../include/sdk_camera.h"
#include "../../include/fixed_math.h"
#include "../../include/scalar_math.h"
#include "../../include/runtime_angle.h"

extern float func_8004CEB0(float angle);
extern int D_80138268;
extern float D_FLT_8007D904, D_FLT_8007D908;
extern FixedMatrix D_800CD250;
extern SdkMatrix D_8013D958;

void func_8004913C(void)
{
    unsigned short normalization;
    float eyeX = 0.0f;
    float eyeY = 0.0f;
    float eyeZ = 0.0f;
    float atX = 0.0f;
    float atY = 0.0f;
    float atZ = 400.0f;
    float upX = 0.0f;
    float upY = 1.0f;
    float upZ = 0.0f;
    float light1Z = -70.0f;
    float fieldOfView;
    float light2X = 100.0f;

    fieldOfView = (func_8004CE08(480.0f, D_800C8BD8.unknown00[0]) *
                   360.0) * 0.000244140625;
    D_FLT_8007D904 = 0.0f;
    D_FLT_8007D908 = func_8004CED0(D_80138268 * 0.0061359182f) * 75.0;
    D_FLT_8007D904 = func_8004CEB0(D_80138268 * 0.0061359182f) * 75.0;
    D_80138268 += 8;
    func_80060980((SdkMatrix *)D_8013823C, &normalization,
                  fieldOfView, 1.3333333730697632f, 100.0f,
                  50000.0f, 1.0f);
    func_8006114C((SdkMatrix *)((unsigned char *)D_8013823C + 0x80),
                  (SdkLookAt *)((unsigned char *)D_8013823C + 0x1C0),
                  (SdkHilite *)((unsigned char *)D_8013823C + 0x200),
                  eyeX, eyeY, eyeZ, atX, atY, atZ, upX, upY, upZ,
                  D_FLT_8007D904, D_FLT_8007D908, light1Z, light2X, 0.0f, 0.0f, 32, 32);
    func_80048020(&D_800CD250, &D_8013D958);
    FRAME_COMMAND(0x03840010, (unsigned char *)D_8013823C + 0x1C0);
    FRAME_COMMAND(0x03820010, (unsigned char *)D_8013823C + 0x1D0);
    FRAME_COMMAND(0xBC00000E, normalization);
    FRAME_COMMAND(0x01030040, (unsigned char *)D_8013823C - 0x80000000);
    FRAME_COMMAND(0x01010040, (unsigned char *)&D_8013D958 - 0x80000000);
}
