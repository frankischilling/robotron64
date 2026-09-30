#include "../../include/audio_properties_internal.h"

void func_800545F0(unsigned char code)
{
    static unsigned char D_801902F8;
    static unsigned char D_801902F9;
    static AudioCallbackRecord *D_801902FC;

    if (func_80052AA8()) {
        func_8005895C();
        D_801902F9 = D_801902EC->callbackCount;
        if (D_801902F9 != 0) {
            D_801902F8 = D_8008D857;
            D_801902FC = D_801902EC->callbacks;
            while (D_801902F8--) {
                if (D_801902FC->active != 0) {
                    if (D_801902FC->code == code) {
                        D_801902FC->active = 0;
                        D_801902EC->callbackCount--;
                        break;
                    }
                    if (--D_801902F9 == 0) {
                        break;
                    }
                }
                D_801902FC++;
            }
        }
        func_8005899C();
    }
}
