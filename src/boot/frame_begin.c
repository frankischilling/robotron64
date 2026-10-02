#include "../../include/frame.h"
#include "../../include/renderer_setup_internal.h"

extern unsigned char D_80137F58[];
extern void *D_8013823C;
extern void *D_80138240;
extern void *D_80138260[2];
extern int D_8007D910;
extern int D_8007D914;
extern int D_80138250;
extern volatile int D_80138270;
extern volatile int D_80138274;
extern volatile int D_8013826C;
extern unsigned int D_80138244;
extern unsigned short D_8007D6D0[];
extern unsigned char D_00200000[];

void func_8004717C(int);
unsigned int func_800606A0(void *);

#define FRAME_COLOR16 ((((D_80138270 << 8) & 0xF800) | \
                       ((D_80138274 << 3) & 0x07C0) | \
                       ((D_8013826C >> 2) & 0x003E)) | 1)

void func_80048510(void)
{
    D_8013823C = D_80137F58;
    D_8007D910 ^= 1;
    func_8004717C(D_8007D910);
    if (D_8007D910) {
        D_80138278 = (FrameCommand *)0x803CE000;
    } else {
        D_80138278 = (FrameCommand *)0x803E7000;
    }
    D_80138254 = D_80138278;
    FRAME_COMMAND(0xBC000006, 0);
    FRAME_COMMAND(0xBC000406, func_800606A0(D_80138240));
    FRAME_COMMAND(0x06000000, D_8007CB58);
    FRAME_COMMAND(0x06000000, D_8007CB18);
    FRAME_COMMAND(0xB7000000, 1);
    FRAME_COMMAND(0xBA000C02, 0);
    FRAME_COMMAND(0xBA000E02, 0x8000);
    FRAME_COMMAND(0xFD100000, D_8007D6D0);
    FRAME_COMMAND(0xE8000000, 0);
    FRAME_COMMAND(0xF5000100, 0x07000000);
    FRAME_COMMAND(0xE6000000, 0);
    FRAME_COMMAND(0xF0000000, 0x073FC000);
    FRAME_COMMAND(0xE7000000, 0);
    FRAME_COMMAND(0xFE000000, D_00200000);
    FRAME_COMMAND(0xBA001402, 0x300000);
    FRAME_COMMAND(0xFF10013F, D_00200000);
    FRAME_COMMAND(0xF7000000, 0xFFFCFFFC);
    FRAME_COMMAND(0xF64FC3BC, 0);
    FRAME_COMMAND(0xE7000000, 0);
    FRAME_COMMAND(0xBA001402, 0x300000);
    FRAME_COMMAND(0xFF10013F, (unsigned int)D_80138260[D_8007D914] - 0x80000000);

    switch ((D_80138250 + 6) / 10) {
    default:
        D_80138270 = 48; D_80138270 = 0; D_80138274 = 0; D_8013826C = 0;
        break;
    case 6:
    case 7:
        D_80138274 = 48; D_8013826C = 48; D_80138270 = 0; D_8013826C = 0; D_80138274 = 0;
        break;
    case 3:
        D_80138270 = 48; D_8013826C = 48; D_80138274 = 0; D_8013826C = 0; D_80138270 = 0;
        break;
    case 2:
        D_80138270 = 48; D_80138274 = 48; D_8013826C = 0; D_80138274 = 0; D_80138270 = 0;
        break;
    }
    {
        unsigned int color = FRAME_COLOR16;
        D_80138244 = (color << 16) | color;
    }
    FRAME_COMMAND(0xF7000000, D_80138244);
    FRAME_COMMAND(0xF64FC3BC, 0);
    FRAME_COMMAND(0xE7000000, 0);
    FRAME_COMMAND(0xBA001402, 0);
    D_80138270 = 255; D_80138274 = 255; D_8013826C = 255;
}
