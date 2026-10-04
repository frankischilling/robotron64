#include "../../include/audio_loader_internal.h"
static const char D_80095CB0[] = "SN64";

int func_80052D70(unsigned char *source)
{
    unsigned int bytes;
    unsigned int index;

    if (!source) {
        return 0;
    }
    D_8008D7B0 = func_80058B0C((unsigned int)source);
    if (!D_8008D7B0) {
        func_80052A00(1);
        return D_8008D7B8;
    }
    D_801902EC = &D_801902C8;
    D_801902EC->hardwareVoiceCapacity = D_8008D83C;
    D_801902EC->ticks = &D_8008D86C;
    D_801902EC->table = &D_80190280;
    D_801902EC->patchBank = &D_801902A8;
    if (func_80058B20(D_801902EC->table, 32, D_8008D7B0) != 32) {
        func_80052A00(2);
        return 0;
    }
    if (D_801902EC->table->signature != *((const int *)D_80095CB0) ||
        D_801902EC->table->version != 2) {
        return 0;
    }
    if (func_80058B20(&D_801902A8, 24, D_8008D7B0) != 24) {
        func_80052A00(2);
        return 0;
    }
    func_80058BBC(D_8008D7B0);
    D_801902EC->patchBank->data = (unsigned char *)8;
    bytes = D_801902EC->table->dataSize + 8;
    D_801902EC->instances = (AudioInstance *)bytes;
    bytes += D_8008D844 * sizeof(AudioInstance);
    D_801902EC->voices = (AudioVoice *)bytes;
    bytes += D_8008D848 * sizeof(AudioVoice);
    D_801902EC->statusRecords = (AudioStatusRecord *)bytes;
    bytes += D_801902EC->hardwareVoiceCapacity * sizeof(AudioStatusRecord);
    D_801902EC->callbacks = (AudioCallbackRecord *)bytes;
    bytes += D_8008D854 * sizeof(AudioCallbackRecord);
    D_801902EC->voiceIndexCount = D_8008D858;
    for (index = 0; index < D_8008D844; index++) {
        bytes += D_8008D84C;
        bytes += bytes & 1;
        bytes += bytes & 2;
        bytes += D_8008D850;
        bytes += bytes & 1;
        bytes += bytes & 2;
        bytes += D_801902EC->voiceIndexCount;
        bytes += bytes & 1;
        bytes += bytes & 2;
    }
    D_801902EC->returnStackCapacity = D_8008D85C;
    for (index = 0; index < D_8008D848; index++) {
        bytes += D_801902EC->returnStackCapacity * sizeof(unsigned char *);
    }
    bytes += bytes & 1;
    bytes += bytes & 2;
    return bytes;
}
