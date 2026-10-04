#include "../../include/audio_commands.h"

extern int D_8008D7B4;
extern int D_8008D7B8;
extern int D_8008D7BC;
extern int D_8008D7C0;
extern unsigned char *D_8008D7C4;
extern unsigned char *D_8008D7C8;
extern AudioErrorCallback D_8008D7D0;
extern void *D_8008D7D4;
extern int D_8008D864;
extern AudioContext *D_801902EC;

void func_8005891C(void);
void func_80058924(void);
void func_80058938(void *allocation);
void func_80058940(void);
void func_80058ADC(void);
void func_80058AF4(void);
int func_8005CD0C(void);

void func_80052A00(int error)
{
    if (D_8008D7D0 != 0) {
        D_8008D7D0(D_8008D7D4, error);
    }
}

void func_80052A38(unsigned char *destination, unsigned int count)
{
    while (count--) {
        *destination++ = 0;
    }
}

void func_80052A60(AudioErrorCallback callback, void *argument)
{
    D_8008D7D0 = callback;
    D_8008D7D4 = argument;
}

AudioContext *func_80052A74(void)
{
    return D_801902EC;
}

int func_80052A84(void)
{
    if (D_8008D7B4 == 0) {
        return 0;
    }
    return 1;
}

int func_80052AA8(void)
{
    if (D_8008D7B8 == 0) {
        return 0;
    }
    return 1;
}

int func_80052ACC(int index)
{
    if (index < 0 || index >= func_8005CD0C()) {
        return 0;
    }
    if (D_801902EC->table->slots[index].value == 0) {
        return 0;
    }
    return 1;
}

void func_80052B40(void)
{
    if (D_8008D7BC == 0) {
        D_8008D7BC = 1;
    }
}

void func_80052B64(void)
{
    func_80058ADC();
}

void func_80052B84(void)
{
    func_80058AF4();
}

int func_80052BA4(void)
{
    int changed = 0;

    if (D_8008D7B4 == 0) {
        func_80058940();
        if (D_8008D864 == 0) {
            func_80052B64();
        }
        func_8005891C();
        D_8008D7B4 = 1;
        changed = 1;
    }
    return changed;
}

void func_80052C08(int release)
{
    if (func_80052A84()) {
        if (D_8008D7B4 != 0) {
            if (D_8008D7B8 != 0) {
                func_80052CF4();
            }
            func_80058924();
            D_8008D7B4 = 0;
            if (release | D_8008D864) {
                func_80052B84();
            }
        }
    }
}

void *func_80052C84(void)
{
    return D_8008D7C4;
}

void *func_80052C94(void)
{
    return D_8008D7C8;
}

void func_80052CA4(void)
{
    if (D_8008D7C0 != 0) {
        if (D_8008D7C4 != 0) {
            func_80058938(D_8008D7C4);
            D_8008D7C4 = 0;
        }
        D_8008D7C0 = 0;
    }
}

void func_80052CF4(void)
{
    if (D_8008D7B8 != 0) {
        func_80054268();
        func_80058940();
        D_8008D800[0]->release(D_801902EC);
        D_8008D800[1]->release(D_801902EC);
        func_80052CA4();
        D_8008D7B8 = 0;
    }
}
