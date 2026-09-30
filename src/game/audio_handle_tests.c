#include "../../include/audio_control.h"

int func_80059500(int index, int unused1, int unused2)
{
    return func_80052ACC(index);
}

int func_80059524(int unused0, int unused1)
{
    return func_80052AA8();
}

int func_80059548(int first, int second, int unused)
{
    if (func_80052ACC(first) != 0) {
        return func_80052ACC(second);
    }
    /* The retail false path falls through with the first helper's zero in v0. */
}
