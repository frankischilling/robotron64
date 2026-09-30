#include "../../include/audio_backend_internal.h"

void func_8005B66C(AudioContext *context)
{
}

void func_8005B674(AudioVoice *voice)
{
    static int D_80192AC0;
    static int D_80192AC4;
    static AudioStatusRecord *D_80192AC8;

    D_80192AC0 = D_80192810->activeStatusCount;
    if (D_80192AC0) {
        D_80192AC4 = D_80192820;
        D_80192AC8 = D_8019281C;
        while (D_80192AC4--) {
            if (D_80192AC8->active) {
                if (D_80192AC8->flag40 && D_80192AC8->time < *D_80192828) {
                    func_8005C3E4(D_80192AC8);
                } else if (D_80192AC8->flag20) {
                    if (D_80192AC8->time + D_80192AC8->region->attackTime < *D_80192828) {
                        func_8005C684(D_80192AC8);
                    }
                }
                if (!--D_80192AC0) {
                    break;
                }
            }
            D_80192AC8++;
        }
    }
}

void func_8005B7AC(AudioVoice *voice)
{
}

void func_8005B7B4(AudioVoice *voice)
{
}
