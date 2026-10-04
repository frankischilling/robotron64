#include "../../../../include/audio_loader_internal.h"
static const char D_80095CB8[] = "SN64";

int func_8005303C(unsigned char *source, unsigned char *allocation, unsigned int size)
{
    /* Preserve the untouched 12-byte tail of the observed 56-byte frame. */
    unsigned int frameReserve[3];
    unsigned int cursor;
    unsigned int length;
    unsigned int received;
    unsigned int count;
    unsigned char *indices;
    int index;

    if (D_8008D7B8) func_80052CF4();
    if (!allocation) {
        D_8008D7C0 = 1;
        D_8008D7C4 = func_8005892C(size);
        if (!D_8008D7C4) return D_8008D7B8;
    } else {
        D_8008D7C0 = 0;
        D_8008D7C4 = allocation;
    }
    D_8008D7CC = size;
    func_80052A38(D_8008D7C4, D_8008D7CC);
    if (!func_80052A84()) {
        func_80052CA4();
        return D_8008D7B8;
    }
    if (!source) {
        func_80052CA4();
        return D_8008D7B8;
    }
    D_8008D7B0 = func_80058B0C((unsigned int)source);
    if (!D_8008D7B0) {
        func_80052A00(1);
        func_80052CA4();
        return D_8008D7B8;
    }
    D_801902EC = &D_801902C8;
    D_801902EC->hardwareVoiceCapacity = D_8008D83C;
    D_801902EC->ticks = &D_8008D86C;
    D_801902EC->table = &D_80190280;
    D_801902EC->patchBank = &D_801902A8;
    if (func_80058B20(D_801902EC->table, 32, D_8008D7B0) != 32) {
        func_80052A00(2);
        func_80052CA4();
        return 0;
    }
    if (D_801902EC->table->signature != *(const int *)D_80095CB8 ||
        D_801902EC->table->version != 2) {
        func_80052CA4();
        return 0;
    }
    if (func_80058B20(&D_801902A8, 24, D_8008D7B0) != 24) {
        func_80052A00(2);
        func_80052CA4();
        return 0;
    }
    cursor = (unsigned int)D_8008D7C4;
    cursor += cursor & 1;
    cursor += cursor & 2;
    cursor += cursor & 4;
    D_801902EC->patchBank->data = (unsigned char *)cursor;
    cursor += D_801902EC->table->dataSize;
    length = D_801902EC->table->dataSize;
    if (D_801902EC->table->storageMode == 0) {
        received = func_80058B20(D_801902EC->patchBank->data, length, D_8008D7B0);
        if (length != received) {
            func_80052A00(2);
            func_80052CA4();
            return 0;
        }
        func_80058BBC(D_8008D7B0);
    } else {
        func_80058BBC(D_8008D7B0);
        if (func_800588D4(D_801902EC->table->storageMode, (int)source, 56,
                         (int)D_801902EC->patchBank->data,
                         D_801902EC->table->dataSize) < 0) return 0;
    }
    D_801902EC->instances = (AudioInstance *)cursor;
    cursor += D_8008D844 * sizeof(AudioInstance);
    D_801902EC->voices = (AudioVoice *)cursor;
    cursor += D_8008D848 * sizeof(AudioVoice);
    D_801902EC->statusRecords = (AudioStatusRecord *)cursor;
    cursor += D_801902EC->hardwareVoiceCapacity * sizeof(AudioStatusRecord);
    for (index = 0; index < D_801902EC->hardwareVoiceCapacity; index++) {
        D_801902EC->statusRecords[index].unknown01 = 1;
        D_801902EC->statusRecords[index].index = index;
    }
    D_801902EC->callbacks = (AudioCallbackRecord *)cursor;
    cursor += D_8008D854 * sizeof(AudioCallbackRecord);
    D_801902EC->voiceIndexCount = D_8008D858;
    for (index = 0; index < D_8008D844; index++) {
        D_801902EC->instances[index].gates = (unsigned char *)cursor;
        cursor += D_8008D84C;
        cursor += cursor & 1;
        cursor += cursor & 2;
        D_801902EC->instances[index].iterations = (unsigned char *)cursor;
        cursor += D_8008D850;
        cursor += cursor & 1;
        cursor += cursor & 2;
        count = D_801902EC->voiceIndexCount;
        D_801902EC->instances[index].voiceIndices = (unsigned char *)cursor;
        indices = (unsigned char *)cursor;
        cursor += count;
        cursor += cursor & 1;
        cursor += cursor & 2;
        while (count--) *indices++ = 255;
    }
    D_801902EC->returnStackCapacity = D_8008D85C;
    for (index = 0; index < D_8008D848; index++) {
        D_801902EC->voices[index].index = index;
        D_801902EC->voices[index].returnStackStart = (unsigned char **)cursor;
        cursor += D_801902EC->returnStackCapacity * sizeof(unsigned char *);
        D_801902EC->voices[index].returnStackEnd = (unsigned char **)cursor;
    }
    cursor += cursor & 1;
    cursor += cursor & 2;
    D_8008D800[0]->initialize(D_801902EC);
    D_8008D800[1]->initialize(D_801902EC);
    D_8008D7C8 = (unsigned char *)cursor;
    D_8008D7B8 = 1;
    func_8005894C();
    return 1;
}
