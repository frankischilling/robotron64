#include "../../include/audio_callbacks.h"

void func_80052700(void)
{
    D_80190260.next = 0;
    D_80190260.callback = func_80052754;
    D_80190260.argument = D_80190274;
    D_80190260.fieldC = 0;
    D_80190260.field10 = 0;
    func_80066310(D_8008F160, &D_80190260);
}
