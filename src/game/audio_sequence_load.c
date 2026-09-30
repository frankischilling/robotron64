#include "../../include/audio_sequence_internal.h"

int func_8005D584(int index, unsigned char *destination)
{
    int result;

    result = 0;
    if (D_80192BC0) {
        if (!func_8005CD1C(index)) {
            return 0;
        }
        if (((AudioSequenceEntry *)D_80192BA0->table->slots)[index].tracks == 0) {
            result = func_8005CE0C(index, destination);
        }
    }
    return result;
}
