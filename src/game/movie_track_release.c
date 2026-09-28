#include "../../include/movie.h"
#include "../../include/actor.h"

void func_80003D74(void)
{
    int index;
    int animation;

    for (index = 0; index < D_800B14A8->pairCount; index++) {
        if (D_800B14A8->pairs[index].identifier != -1) {
            func_80003CF8(D_800B14A8->pairs[index].track);
        }
    }
    for (index = 0; index < D_800B14A8->propCount; index++) {
        if (D_800B14A8->props[index].actor != 0) {
            for (animation = 0; animation < 10; animation++) {
                if (D_800B14A8->props[index].actor->resource->animation.tracks[animation] != 0) {
                    if (D_800B14A8->props[index].actor->resource->animation.tracks[animation]->track != -1) {
                        func_80003CF8(D_800B14A8->props[index].actor->resource->animation.tracks[animation]->track);
                    }
                }
            }
            D_800B14A8->props[index].actor->resource->flags06.bits.loaded = 0;
        }
    }
}
