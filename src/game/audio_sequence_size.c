#include "../../include/audio_sequence_internal.h"

int func_8005D4C8(int index)
{
    int bytes;
    int result;
    AudioSequenceEntry *entry;

    result = 0;
    if (D_80192BC0) {
        if (!func_8005CD1C(index)) {
            return 0;
        }
        entry = (AudioSequenceEntry *)D_80192BA0->table->slots + index;
        if (D_8008D858 < entry->trackCount) {
            return 0;
        }
        if (entry->tracks == 0) {
            bytes = entry->trackCount * sizeof(AudioSequenceTrack);
            bytes += bytes & 1;
            bytes += bytes & 2;
            bytes += bytes & 4;
            result = entry->dataBytes + bytes;
        }
    }
    return result;
}
