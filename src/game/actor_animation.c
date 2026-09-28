#include "../../include/actor.h"

extern char D_800938E0[];
extern int D_80075A18;

extern int func_8003614C(int sound, int value, int enabled, int extra);

void func_80027AB8(GameActor *actor, unsigned char animation, int reset)
{
    ActorAnimation *track;

    track = actor->resource->animation.tracks[animation];
    if (track == 0) {
        animation = 0;
        track = actor->resource->animation.tracks[0];
        if (track == 0) {
            func_8001C0D0(D_800938E0, actor->kind, D_80075A18);
        }
    }

    actor->animationIndex = animation;
    if (reset != 0) {
        actor->frame = 0x100;
    }
    func_80039DCC(actor->objectIndex, track->frameIndex);
    func_8003947C(actor->objectIndex, track->objectIndex);
    if (track->sound != 0xFF) {
        int sound = track->sound;
        if (track->soundMode == 0) {
            func_8003614C(sound, 0, 1, 0);
        }
    }
}
