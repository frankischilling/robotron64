#include "../../include/scene_commands_internal.h"
#include "../../include/object_helpers.h"

extern int D_80075930;
extern float D_FLT_80075934;
extern float D_FLT_80075938;
extern float D_FLT_8007593C;
extern unsigned int D_8009EF94;
extern int D_800AD288;
extern int D_800AD2A8;
extern unsigned char D_800917C0[];
extern unsigned char D_800917E0[];

void func_800314FC(unsigned char *path);

void func_8001F90C(void)
{
    float horizontal;
    float vertical;

    if (D_800B8F68.resource != -1 && D_800B8F68.resource != 0) {
        if (D_800B8F68.flags & 2) {
            func_800314FC(func_800383C4(D_800B8F68.resource));
        }
        if (D_800B8F68.flags & 1) {
            if (func_8003C5E4(func_800383C4(D_800B8F68.resource)) == 0) {
                func_8001C2C4(D_800917C0, func_800383C4(D_800B8F68.resource));
                D_800B8F68.resource = 0;
            } else {
                D_800B8F68.resource = -1;
            }
        }
    }
    if (D_800B8F68.resource != 0 && (D_800B8F68.flags & 1)) {
        switch (D_800B8F68.mode) {
        case 0:
            if (D_800B8F68.scrolling == 0) {
                func_8003A28C(&horizontal);
                func_8003C5EC(0, (int)((horizontal + 0.1f) * 240.0f) - 100, 0, 0);
                break;
            }
            func_8003A28C(&horizontal);
            func_8003A29C(&vertical);
            if (D_800AD280 == 9 && D_800AD288 == 3) {
                if (D_FLT_80075938 < 0.6f) {
                    D_FLT_80075938 += D_FLT_8007593C;
                }
            } else if (D_FLT_80075938 > 0.0f) {
                D_FLT_80075938 -= D_FLT_8007593C * 5.0f;
            }
            D_FLT_80075934 -= D_FLT_80075938 * D_8009EF94;
            if (D_FLT_80075934 < 0.0f) {
                D_FLT_80075934 += 480.0f;
            }
            D_80075930 = (int)(horizontal * 100.0f + D_FLT_80075934);
            if (D_80075930 < 0) {
                D_80075930 += 480;
            } else if (D_80075930 >= 480) {
                D_80075930 -= 480;
            }
            func_8003C5EC((int)(vertical * 150.0f), D_80075930, 0, 1);
            break;
        case 9:
            func_8003C5EC(0, D_800AD2A8, 0, 0);
            break;
        case 10:
            func_8003C5EC(0, 0, 0, 0);
            break;
        default:
            func_8001C49C(D_800917E0);
            break;
        }
    } else {
        func_8003C5F4(D_800BA764);
    }
}
