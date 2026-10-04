#include "../../../../include/audio_synthesis_internal.h"
#include "../../../../include/sdk_pi_dma.h"

void func_80051C00(SdkAudioSynthConfig *configuration, AudioSettings *settings)
{
    unsigned int index;
    float samples;

    samples = configuration->outputRate / settings->frameRate;
    D_801901F4 = (unsigned int)samples;
    if ((float)D_801901F4 < samples) D_801901F4++;
    if (D_801901F4 & 15) D_801901F4 = (D_801901F4 & ~15) + 16;
    D_801901F0 = D_801901F4 - 16;
    D_801901F8 = D_801901F4 + D_8008D834 + 16;
    D_80190200 = func_80065730(0, 0, configuration->heap, 1, D_8008D83C * sizeof(SdkAudioVoice));
    func_800518F0((unsigned char *)D_80190200, 0, D_8008D83C * sizeof(SdkAudioVoice));
    D_80190204 = func_80065730(0, 0, configuration->heap, 1, D_8008D83C);
    func_800518F0(D_80190204, 0, D_8008D83C);
    D_801901EC = func_80065730(0, 0, configuration->heap, 1, D_8008D828 * sizeof(AudioDmaBuffer));
    func_800518F0((unsigned char *)D_801901EC, 0, D_8008D828 * sizeof(AudioDmaBuffer));
    D_801901EC->previous = 0;
    D_801901EC->next = 0;
    for (index = 0; index < D_8008D828 - 1; index++) {
        func_80065AE0((AudioLink *)&D_801901EC[index + 1], (AudioLink *)&D_801901EC[index]);
        D_801901EC[index].data = func_80065730(0, 0, configuration->heap, 1, D_8008D830);
        func_800518F0(D_801901EC[index].data, 0, D_8008D830);
    }
    D_801901EC[index].data = func_80065730(0, 0, configuration->heap, 1, D_8008D830);
    func_800518F0(D_801901EC[index].data, 0, D_8008D830);
    for (index = 0; index < 2; index++) {
        D_80190180.commands[index] = func_80065730(0, 0, configuration->heap, 1, settings->bufferSize * sizeof(SdkAudioCommand));
        func_800518F0(D_80190180.commands[index], 0, settings->bufferSize * sizeof(SdkAudioCommand));
    }
    D_801901FC = settings->bufferSize;
    for (index = 0; index < 3; index++) {
        D_80190180.records[index] = func_80065730(0, 0, configuration->heap, 1, sizeof(AudioRspRecord));
        func_800518F0((unsigned char *)D_80190180.records[index], 0, sizeof(AudioRspRecord));
        D_80190180.records[index]->data = func_80065730(0, 0, configuration->heap, 1, D_801901F8 * 4);
        func_800518F0(D_80190180.records[index]->data, 0, D_801901F8 * 4);
    }
    D_80190220 = func_80065730(0, 0, configuration->heap, 1, D_8008D82C * sizeof(SdkPiDmaMessage));
    func_800518F0((unsigned char *)D_80190220, 0, D_8008D82C * sizeof(SdkPiDmaMessage));
    D_80190224 = func_80065730(0, 0, configuration->heap, 1, D_8008D82C * sizeof(OSMesg));
    func_800518F0((unsigned char *)D_80190224, 0, D_8008D82C * sizeof(OSMesg));
    osCreateMesgQueue(&D_80190208, D_80190224, D_8008D82C);
    func_80065B3C(&D_80190194, configuration);
}
