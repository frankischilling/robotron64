#include "../../include/movie.h"
#include "../../include/game_memory.h"

void func_800037F8(float *uniform, float value, int argument, int *nextChannel,
                   int *channel, int field)
{
    if (*uniform == -1.0f || !(D_800972A0->trackedFields & (1U << field))) {
        *uniform = value;
        D_800972A0->constantFields |= 1U << field;
        return;
    }
    if (!(D_800972A0->constantFields & (1U << field))) {
        *channel = *nextChannel;
        (*nextChannel)++;
    }
}

void func_80003898(int *uniform, int value, int argument, int *nextChannel,
                   int *channel, int field)
{
    if (*uniform == -1 || !(D_800972A0->trackedFields & (1U << field))) {
        *uniform = value;
        D_800972A0->constantFields |= 1U << field;
        return;
    }
    if (!(D_800972A0->constantFields & (1U << field))) {
        *channel = *nextChannel;
        (*nextChannel)++;
    }
}

void func_8000392C(int field, int channel, float *frameField, int stride)
{
    float *output = D_800972A0->floatChannels + channel;
    int frame;

    if (!(D_800972A0->constantFields & (1U << field))) {
        for (frame = 0; frame < D_800972A0->frameCount; frame++) {
            func_8003B520(output, frameField, sizeof(float));
            output += stride;
            frameField += MOVIE_FRAME_WORDS;
        }
    }
}

void func_800039D4(int field, int channel, int *frameField, int stride)
{
    int *output = D_800972A0->integerChannels + channel;
    int frame;

    if (!(D_800972A0->constantFields & (1U << field))) {
        for (frame = 0; frame < D_800972A0->frameCount; frame++) {
            func_8003B520(output, frameField, sizeof(int));
            output += stride;
            frameField += MOVIE_FRAME_WORDS;
        }
    }
}
