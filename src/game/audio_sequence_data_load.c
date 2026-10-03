#include "../../include/audio_sequence_internal.h"

int func_8005CE0C(int index, unsigned char *memory)
{
    int trackIndex;
    int trackCount;
    unsigned int expectedBytes;
    unsigned int actualBytes;
    unsigned char *destination;
    unsigned char *data;
    unsigned int offset;
    AudioSequenceEntry *entry;

    destination = memory;
    if (D_80192BC0) {
        if (!func_8005CD1C(index)) {
            return 0;
        }
        entry = &((AudioSequenceEntry *)D_80192BA0->table->slots)[index];
        trackCount = entry->trackCount;
        if (D_8008D858 < trackCount) {
            return 0;
        }
        offset = entry->fileOffset + D_80192BBC;
        entry->tracks = (AudioSequenceTrack *)memory;
        memory += entry->trackCount * sizeof(AudioSequenceTrack);
        memory += (unsigned int)memory & 1;
        memory += (unsigned int)memory & 2;
        memory += (unsigned int)memory & 4;
        data = memory;
        memory += entry->dataBytes;
        if (entry->storageMode == 0) {
            if (!func_8005CD48()) {
                func_8005CCC0(1);
                return 0;
            }
            if (func_80058B74(D_80192BB8, offset, 0) != 0) {
                func_8005CCC0(3);
                return 0;
            }
            expectedBytes = entry->dataBytes;
            actualBytes = func_80058B20(data, expectedBytes, D_80192BB8);
            if (expectedBytes != actualBytes) {
                func_8005CCC0(2);
                return 0;
            }
            func_8005CDB8();
        } else {
            if (func_800588D4(entry->storageMode, D_80192BA4,
                              offset, (int)data, entry->dataBytes) < 0) {
                return 0;
            }
        }
        for (trackIndex = 0; trackIndex < trackCount; trackIndex++) {
            entry->tracks[trackIndex].header = (AudioSequenceHeader *)data;
            data += sizeof(AudioSequenceHeader);
            entry->tracks[trackIndex].labels = (unsigned int *)data;
            data += entry->tracks[trackIndex].header->labelCount * sizeof(unsigned int);
            entry->tracks[trackIndex].commands = data;
            data += entry->tracks[trackIndex].header->commandBytes;
        }
    }
    return memory - destination;
}
