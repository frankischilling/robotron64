#include "../../include/audio_control.h"
#include "../../include/audio_file_services_internal.h"
#include "../../include/audio_host_internal.h"
extern AudioFileCursor *D_8008D7B0;
extern int D_8008D7B8;
extern AudioRecordTable D_80190280;
extern unsigned int D_801902A8[7];
extern AudioContext D_801902C8;
extern unsigned int D_8008D83C, D_8008D848, D_8008D84C, D_8008D850;
extern unsigned int D_8008D854, D_8008D858, D_8008D85C;
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
    D_801902EC->unknown07[0] = D_8008D83C;
    D_801902EC->unknown00 = (unsigned int)&D_8008D86C;
    D_801902EC->table = &D_80190280;
    D_801902EC->unknown14 = (unsigned int)D_801902A8;
    if (func_80058B20(D_801902EC->table, 32, D_8008D7B0) != 32) {
        func_80052A00(2);
        return 0;
    }
    if (D_801902EC->table->unknown00[0] != *((const int *)D_80095CB0) ||
        D_801902EC->table->unknown00[1] != 2) {
        return 0;
    }
    if (func_80058B20(D_801902A8, 24, D_8008D7B0) != 24) {
        func_80052A00(2);
        return 0;
    }
    func_80058BBC(D_8008D7B0);
    ((unsigned int *)D_801902EC->unknown14)[6] = 8;
    bytes = D_801902EC->table->unknown00[6] + 8;
    D_801902EC->instances = (AudioInstance *)bytes;
    bytes += D_8008D844 * sizeof(AudioInstance);
    D_801902EC->voices = (AudioVoice *)bytes;
    bytes += D_8008D848 * sizeof(AudioVoice);
    D_801902EC->statusRecords = (AudioStatusRecord *)bytes;
    bytes += D_801902EC->unknown07[0] * sizeof(AudioStatusRecord);
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
    D_801902EC->unknown0B = D_8008D85C;
    for (index = 0; index < D_8008D848; index++) {
        bytes += D_801902EC->unknown0B * sizeof(unsigned char *);
    }
    bytes += bytes & 1;
    bytes += bytes & 2;
    return bytes;
}
