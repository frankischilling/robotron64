#include "../../include/audio_properties_internal.h"

int func_80056580(int index)
{
    if (!func_80052ACC(index)) {
        return 0;
    }
    return func_8005396C(&D_801902EC->table->slots[index], index, 0, 1, 0);
}
