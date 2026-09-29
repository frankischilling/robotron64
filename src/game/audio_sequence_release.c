#include "../../include/audio_sequence_internal.h"

int func_8005D610(int index)
{
    int result;
    AudioSequenceEntry *entry;

    result = 0;
    if (D_80192BC0) {
        if (!func_8005CD1C(index)) {
            return 0;
        }
        entry = (AudioSequenceEntry *)D_80192BA0->table->slots + index;
        if (entry->tracks != 0) {
            entry->tracks = 0;
            result = 1;
        }
    }
    return result;
}
