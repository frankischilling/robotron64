#include "../../include/movie.h"
#include "../../include/actor.h"

extern int D_8009EFA0;

void func_80004258(int frame, int index, GameActor *actor)
{
    MovieTrackState *track;
    int pitch;
    int yaw;
    int roll;
    int kind;
    int *integers;
    float position[3];

    if (actor != 0) {
        track = &D_800B00B8[index];
        integers = track->integerChannels + frame * track->integerChannelCount;
        func_80004098(frame, index, position, &pitch, &yaw, &roll);
        if (actor->resource->actorKind == 0x83) {
            position[1] -= 5.0f;
        }
        kind = actor->resource->actorKind;
        if (kind == 0x84 || kind == 0x86) {
            position[1] += 16.0f;
        }
        func_80039614(actor->objectIndex, position);
        if (actor->resource->actorKind != 0x83) {
            func_800396F4(actor->objectIndex, pitch);
            func_80039514(actor->objectIndex, 0x400 - yaw);
            func_80039740(actor->objectIndex, roll);
        } else {
            func_80039514(actor->objectIndex, -D_8009EFA0);
        }
        if (track->trackedFields & 0x1000) {
            func_80039E5C(actor->objectIndex,
                         track->constantFields & 0x1000 ? track->objectParameter
                                                       : integers[track->channel[12]]);
        }
    }
}
