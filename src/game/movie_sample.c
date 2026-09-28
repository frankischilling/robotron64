#include "../../include/movie.h"

void func_80004098(int frame, int index, float *position, int *pitch, int *yaw, int *roll)
{
    MovieTrackState *track = &D_800B00B8[index];
    int *integers = track->integerChannels + frame * track->integerChannelCount;
    float *floats = track->floatChannels + frame * track->floatChannelCount;

    if (track->constantFields & 1) {
        position[0] = track->position[0];
    } else {
        position[0] = floats[track->channel[0]];
    }
    if (track->constantFields & 2) {
        position[1] = track->position[1];
    } else {
        position[1] = floats[track->channel[1]];
    }
    if (track->constantFields & 4) {
        position[2] = track->position[2];
    } else {
        position[2] = floats[track->channel[2]];
    }
    if (track->constantFields & 8) {
        *pitch = track->angle[0];
    } else {
        *pitch = integers[track->channel[3]];
    }
    if (track->constantFields & 0x10) {
        *yaw = track->angle[1];
    } else {
        *yaw = integers[track->channel[4]];
    }
    if (track->constantFields & 0x20) {
        *roll = track->angle[2];
    } else {
        *roll = integers[track->channel[5]];
    }
}
