#include "../../include/audio_control.h"

extern unsigned int D_8008D83C;
extern unsigned int D_8008D848;
extern char D_80190340[128];
extern char D_801903C0[128];
extern char D_80190440[128];
extern char D_801904C0[128];

char *func_80058C00(void)
{
    AudioContext *context;
    int count;
    int index;

    context = func_80052A74();
    if (D_8008D844 >= 128U) {
        count = 127;
    } else {
        count = D_8008D844;
    }
    if (context != 0) {
        for (index = 0; index < count; index++) {
            if (context->instances[index].active) {
                D_80190340[index] = '1';
            } else {
                D_80190340[index] = '0';
            }
        }
        D_80190340[count] = 0;
    }
    return D_80190340;
}

char *func_80058DA0(void)
{
    AudioContext *context;
    int count;
    int index;

    context = func_80052A74();
    if (D_8008D848 >= 128U) {
        count = 127;
    } else {
        count = D_8008D848;
    }
    if (context != 0) {
        for (index = 0; index < count; index++) {
            if (context->voices[index].flag80) {
                D_801903C0[index] = '1';
            } else {
                D_801903C0[index] = '0';
            }
        }
        D_801903C0[count] = 0;
    }
    return D_801903C0;
}

int func_80058F3C(int index)
{
    AudioContext *context;

    context = func_80052A74();
    if (context != 0) {
        return context->voices[index].parameter0D;
    }
    return -1;
}

char *func_80058F88(void)
{
    AudioContext *context;
    int count;
    int index;

    context = func_80052A74();
    if (D_8008D83C >= 128U) {
        count = 127;
    } else {
        count = D_8008D83C;
    }
    if (context != 0) {
        for (index = 0; index < count; index++) {
            if (context->statusRecords[index].active) {
                D_80190440[index] = '1';
            } else {
                D_80190440[index] = '0';
            }
        }
        D_80190440[count] = 0;
    }
    return D_80190440;
}

char *func_80059124(void)
{
    AudioContext *context;
    int count;
    int index;

    context = func_80052A74();
    if (D_8008D83C >= 128U) {
        count = 127;
    } else {
        count = D_8008D83C;
    }
    if (context != 0) {
        for (index = 0; index < count; index++) {
            if (context->statusRecords[index].flag40) {
                D_801904C0[index] = '1';
            } else {
                D_801904C0[index] = '0';
            }
        }
        D_801904C0[count] = 0;
    }
    return D_801904C0;
}
