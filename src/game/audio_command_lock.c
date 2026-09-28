#include "../../include/audio_commands.h"

extern int D_8008D878;
extern unsigned int D_80190338;

unsigned int func_8005D9E0(void);
void func_8005DA00(unsigned int state);

void func_8005895C(void)
{
    int depth = D_8008D878++;

    if (depth == 0) {
        D_80190338 = func_8005D9E0();
    }
}

void func_8005899C(void)
{
    D_8008D878--;
    if (D_8008D878 == 0) {
        func_8005DA00(D_80190338);
    }
}
