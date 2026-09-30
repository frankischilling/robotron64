#include "../../include/audio_file_services_internal.h"

void func_8005CCC0(int error)
{
    if (D_80192BB0 != 0) {
        D_80192BB0(D_80192BB4, error);
    }
}

void func_8005CCF8(AudioLoadErrorCallback callback, int argument)
{
    D_80192BB0 = callback;
    D_80192BB4 = argument;
}

int func_8005CD0C(void)
{
    return D_80192BA8;
}

int func_8005CD1C(int index)
{
    if (index < 0 || index >= D_80192BA8) {
        return 0;
    }
    return 1;
}

int func_8005CD48(void)
{
    if (D_80192BAC == 0) {
        D_80192BB8 = func_80058B0C(D_80192BA4);
        if (D_80192BB8 == 0) {
            func_8005CCC0(1);
            return 0;
        }
    }
    ++D_80192BAC;
    return 1;
}

void func_8005CDB8(void)
{
    if (D_80192BAC == 1) {
        func_80058BBC(D_80192BB8);
    }
    if (D_80192BAC > 0) {
        --D_80192BAC;
    }
}
