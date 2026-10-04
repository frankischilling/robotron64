#include "../../../../include/audio_synthesis_internal.h"

extern int D_8008D79C;
extern int D_8008D7A4;

void func_80051A0C(AudioSettings *settings)
{
    SdkAudioSynthConfig configuration;
    int index;
    int offset;
    /* Preserve the observed unused 32-byte gap in the 128-byte frame. */
    unsigned int frameReserve[8];

    osCreateMesgQueue(&D_80190228, D_80190240, 8);
    D_8008D79C = 0;
    D_8008D7A0 = 0;
    func_8005AD88((int)settings->romBase);
    configuration.maxVirtualVoices = D_8008D83C;
    configuration.maxPhysicalVoices = D_8008D83C;
    configuration.maxUpdates = D_8008D840;
    configuration.dma = (AudioDmaFactory)func_8005254C;
    configuration.effectType = settings->effectType;
    func_8005AD50(settings->frequency);
    configuration.outputRate = func_80065950(settings->frequency);
    configuration.heap = settings->heap;
    if (configuration.effectType == 6) {
        settings->effectParameters[1] = func_800519C0(settings->effectParameters[1], (float)settings->frequency);
        offset = 2;
        for (index = 0; index < settings->effectParameters[0]; index++) {
            settings->effectParameters[offset] = func_800519C0(settings->effectParameters[offset], (float)settings->frequency);
            offset++;
            settings->effectParameters[offset] = func_800519C0(settings->effectParameters[offset], (float)settings->frequency);
            offset += 7;
        }
        configuration.parameters = settings->effectParameters;
    }
    func_80051C00(&configuration, settings);
    func_80052700();
    func_80052BA4();
    D_8008D7A4 = 1;
}
