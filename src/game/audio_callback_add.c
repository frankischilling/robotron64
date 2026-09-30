#include "../../include/audio_properties_internal.h"

void func_800544F0(unsigned char code, AudioEventCallback callback)
{
    static unsigned char D_801902F0;
    static unsigned char D_801902F1;
    static AudioCallbackRecord *D_801902F4;

    if (func_80052AA8()) {
        func_8005895C();
        D_801902F1 = D_801902EC->callbackCount;
        D_801902F0 = D_8008D857;
        if (D_801902F1 != D_801902F0) {
            D_801902F4 = D_801902EC->callbacks;
            while (D_801902F0--) {
                if (D_801902F4->active == 0) {
                    D_801902F4->code = code;
                    D_801902F4->value = 0;
                    D_801902F4->callback = callback;
                    D_801902EC->callbackCount++;
                    break;
                }
                D_801902F4++;
            }
        }
        func_8005899C();
    }
}
