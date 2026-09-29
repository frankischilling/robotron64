#include "../../include/pi.h"
#include "../../include/scheduler.h"

extern unsigned int D_8008F1C0;
extern OSMesg D_80196410[1];
extern OSMesgQueue D_80196418;

void func_800677D0(void)
{
    D_8008F1C0 = 1;
    osCreateMesgQueue(&D_80196418, D_80196410, 1);
    func_800635A0(&D_80196418, 0, 0);
}

void func_80067820(void)
{
    OSMesg token;

    if (!D_8008F1C0) {
        func_800677D0();
    }
    func_80062240(&D_80196418, &token, 1);
}

void func_80067864(void)
{
    func_800635A0(&D_80196418, 0, 0);
}
