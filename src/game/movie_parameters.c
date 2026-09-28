#include "../../include/movie.h"

void func_80002F28(float *output, float value, float *initial, int field)
{
    *output = value;
    if (*initial == -1.0f) {
        *initial = *output;
        return;
    }
    if (*initial != *output) {
        if (D_800972A0->constantFields & (1U << field)) {
            D_800972A0->floatChannelCount++;
        }
        D_800972A0->constantFields &= ~(1U << field);
    }
}

void func_80002FC4(int *output, int value, int *initial, int field)
{
    *output = value;
    if (*initial == -1) {
        *initial = *output;
        return;
    }
    if (*initial != *output) {
        if (D_800972A0->constantFields & (1U << field)) {
            D_800972A0->integerChannelCount++;
        }
        D_800972A0->constantFields &= ~(1U << field);
    }
}
