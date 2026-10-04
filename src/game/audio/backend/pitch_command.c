#include "../../../../include/audio_backend_internal.h"
#include "../../audio_pitch_scale.c"

void func_8005BA24(AudioVoice *voice)
{
    static int D_80192AE4;
    static int D_80192AE8;
    static AudioStatusRecord *D_80192AEC;
    static short D_80192AF0;
    static float D_80192AF4;
    static int D_80192AF8;

    D_80192AF0 = (voice->command[2] << 8) | voice->command[1];
    if (D_80192AF0 == voice->property06) {
        return;
    }
    D_80192AE4 = voice->hardwareVoiceCount;
    voice->property06 = D_80192AF0;
    if (D_80192AE4) {
        D_80192AE8 = D_80192820;
        D_80192AEC = D_8019281C;
        while (D_80192AE8--) {
            if (D_80192AEC->active && D_80192AEC->voiceIndex == voice->index) {
                if (voice->property06 == 0) {
                    D_80192AF8 = 0;
                } else if (voice->property06 > 0) {
                    D_80192AF8 = D_80192AEC->region->pitchUp * voice->property06 * 0.0122;
                } else {
                    D_80192AF8 = D_80192AEC->region->pitchDown * voice->property06 * 0.0122;
                }
                D_80192AF4 = func_8005B000(D_80192AEC->wave->tuning + D_80192AF8 +
                    (D_80192AEC->key - D_80192AEC->region->rootKey) * 100 - D_80192AEC->region->detune);
                func_80066680(D_8008F160, &D_80190200[D_80192AEC->index], D_80192AF4);
                if (!--D_80192AE4) break;
            }
            D_80192AEC++;
        }
    }
}
