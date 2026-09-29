#include "../../include/audio_sequence_internal.h"

int func_8005D220(AudioContext *context, unsigned int address)
{
    int bytes;

    D_80192BA4 = address;
    bytes = 0;
    D_80192BA0 = context;
    if (D_80192BA0 != 0) {
        if (!func_8005CD48()) {
            func_8005CCC0(1);
            return 0;
        }
        if (func_80058B74(D_80192BB8, 0, 0) != 0) {
            func_8005CCC0(3);
            return 0;
        }
        if (func_80058B20(&D_80192B80, sizeof(AudioSequenceFileHeader), D_80192BB8) !=
            sizeof(AudioSequenceFileHeader)) {
            func_8005CCC0(2);
            return 0;
        }
        bytes = D_80192B80.tableBytes;
        func_8005CDB8();
    }
    return bytes;
}
