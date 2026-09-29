#include "../../include/audio_sequence_internal.h"

int func_8005D2E4(AudioContext *context, unsigned int address, int keepOpen, AudioRecordSlot *table)
{
    int bytes;
    unsigned int expectedBytes;
    unsigned int actualBytes;

    D_80192BC0 = 0;
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
        D_80192BA8 = D_80192B80.sequenceCount;
        bytes = D_80192B80.tableBytes;
        D_80192BA0->table->slots = table;
        if (D_80192B80.storageMode == 0) {
            expectedBytes = D_80192B80.tableBytes;
            actualBytes = func_80058B20(D_80192BA0->table->slots, expectedBytes, D_80192BB8);
            if (expectedBytes != actualBytes) {
                func_8005CCC0(2);
                return 0;
            }
            D_80192BBC = D_80192B80.tableBytes + sizeof(AudioSequenceFileHeader);
        } else {
            if (func_800588D4(D_80192B80.storageMode, D_80192BA4,
                              sizeof(AudioSequenceFileHeader),
                              (int)D_80192BA0->table->slots, D_80192B80.tableBytes) < 0) {
                return 0;
            }
            D_80192BBC = D_80192B80.packedTableBytes + sizeof(AudioSequenceFileHeader);
        }
        if (keepOpen != 1) {
            func_8005CDB8();
        }
        D_80192BC0 = 1;
    }
    return bytes;
}
