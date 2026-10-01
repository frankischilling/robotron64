#include "../../include/audio_properties_internal.h"

extern AudioContext *D_8008D9C0;


static unsigned char D_80192764;
static short D_80192766;
static unsigned char D_80192768;
static unsigned char D_80192769;

void func_80059898(AudioVoice *voice)
{
}

void func_800598A0(AudioVoice *voice)
{
    D_80192764 = voice->property04 =
        (unsigned char)((voice->command[2] << 8) | voice->command[1]);
}

void func_800598C8(AudioVoice *voice)
{
}

void func_800598D0(AudioVoice *voice)
{
    D_80192766 = voice->property06 =
        (voice->command[2] << 8) | voice->command[1];
}

void func_800598F4(AudioVoice *voice)
{
}

void func_800598FC(AudioVoice *voice)
{
}

void func_80059904(AudioVoice *voice)
{
    D_80192768 = voice->parameter0D = voice->command[1];
}

void func_80059920(AudioVoice *voice)
{
    D_80192769 = voice->parameter0E = voice->command[1];
}

void func_8005993C(AudioVoice *voice)
{
}

void func_80059944(AudioVoice *voice)
{
}

void func_8005994C(AudioVoice *voice)
{
}

void func_80059954(AudioVoice *voice)
{
}

void func_8005995C(AudioVoice *voice)
{
}

void func_80059964(AudioVoice *voice)
{
    static unsigned char D_8019276A;
    static unsigned char D_8019276B;
    static AudioCallbackRecord *D_8019276C;

    D_8019276B = D_8008D9C0->callbackCount;
    if (D_8019276B != 0) {
        D_8019276A = D_8008D857;
        D_8019276C = D_8008D9C0->callbacks;
        while (D_8019276A--) {
            if (D_8019276C->active != 0) {
                if (voice->command[1] == (*D_8019276C).code) {
                    D_8019276C->value = (voice->command[3] << 8) | voice->command[2];
                    D_8019276C->callback(D_8019276C->code, D_8019276C->value);
                    break;
                }
                if (--D_8019276B == 0) {
                    break;
                }
            }
            D_8019276C++;
        }
    }
}
