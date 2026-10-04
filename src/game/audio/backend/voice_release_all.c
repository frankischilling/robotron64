#include "../../../../include/audio_backend_internal.h"
#include "../../audio_voice_capture_append.c"

void func_8005B854(AudioVoice *voice)
{
    static int D_80192AD0;
    static int D_80192AD4;
    static AudioStatusRecord *D_80192AD8;
    static AudioInstance *D_80192ADC;

    D_80192AD0 = voice->hardwareVoiceCount;
    if (D_80192AD0) {
        D_80192AD4 = D_80192820;
        D_80192AD8 = D_8019281C;
        while (D_80192AD4--) {
            if (D_80192AD8->active && D_80192AD8->voiceIndex == voice->index) {
                if (D_8008DA2C && !D_80192AD8->flag40 && !D_80192AD8->pedalPending) {
                    D_80192ADC = &D_80192814[voice->instanceIndex];
                    func_8005AEA8(voice, D_80192ADC->index, D_80192AD8->voiceIndex,
                        D_80192AD8->key, D_80192AD8->velocity, D_80192AD8->region, D_80192AD8->wave);
                }
                func_8005C4F8(D_80192AD8, D_8008DA28);
                if (!--D_80192AD0) break;
            }
            D_80192AD8++;
        }
    }
}
