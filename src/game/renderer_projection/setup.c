#include "../../../include/graphics_state_internal.h"
#include "../../../include/renderer_projection_internal.h"
#include "../../../include/fixed_math.h"
#include "../../../include/scalar_math.h"
#include "../../../include/runtime_angle.h"
#include "../../../include/early_render_internal.h"

extern float func_8004CEB0(float angle);
extern int D_8007D914;

/* Perspective, animated lighting and initial frame matrices. */
void func_80048DDC(void *base)
{
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
                   D_DBL_80095438) * 0.000244140625;
    D_FLT_8007D904 = 0.0f;
    D_FLT_8007D908 = func_8004CED0(D_80138268 * D_FLT_80095440) * D_DBL_80095448;
    D_FLT_8007D904 = func_8004CEB0(D_80138268 * D_FLT_80095450) * D_DBL_80095458;
    D_80138268 += 8;
    func_80060980((SdkMatrix *)((unsigned char *)base + (D_8007D914 << 6)), &D_8013D950,
                  fieldOfView, 1.3333333730697632f, 100.0f,
                  D_FLT_80095460, 1.0f);
    func_8006114C((SdkMatrix *)((unsigned char *)base + (D_8007D914 << 6) + 0x80),
                  ((SdkLookAt *)((unsigned char *)base + 0x1C0)),
                  (SdkHilite *)((unsigned char *)base + 0x200),
                  eyeX, eyeY, eyeZ, atX, atY, atZ, upX, upY, upZ,
                  D_FLT_8007D904, D_FLT_8007D908, light1Z, light2X, 0.0f, 0.0f, 32, 32);
    FRAME_COMMAND(0x03840010, ((SdkLookAt *)((unsigned char *)base + 0x1C0)));
    FRAME_COMMAND(0x03820010, (unsigned char *)base + 0x1D0);
    FRAME_COMMAND(0xBC00000E, D_8013D950);
    FRAME_COMMAND(0x01030040, (unsigned int)base + (D_8007D914 << 6) + 0x80000000);
    FRAME_COMMAND(0x01010040, (unsigned int)base + (D_8007D914 << 6) + 0x80000080);
    func_80061258((SdkMatrix *)((unsigned char *)base + 0x2A0), eyeX, eyeY, eyeZ);
    func_800613FC((SdkMatrix *)((unsigned char *)base + 0x260), eyeX, eyeY, eyeZ);
    {
        FrameCommand *command;
        FRAME_COMMAND_REUSE(command, 0x01020040, (unsigned int)base + 0x800002A0);
        FRAME_COMMAND_REUSE(command, 0x01000040, (unsigned int)base + 0x80000260);
    }
}
