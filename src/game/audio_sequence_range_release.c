#include "../../include/audio_sequence_internal.h"

int func_8005D95C(int first, int count)
{
    int index;
    int released;

    released = 0;
    if (D_80192BC0) {
        index = first;
        if (count == 0) {
            return 0;
        }
        while (count--) {
            released = 1;
            func_8005D610(index);
            ++index;
        }
    }
    return released;
}
