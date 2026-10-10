#include "../../include/movie.h"
#include "../../include/movie_literals.h"
#include "../../include/actor.h"
#include "../../include/palette_effects.h"

extern int D_800AD158, D_800AD280, D_8009EFA8;

int func_800360B8(unsigned char *label);
int func_8004CEF0(int value);
int func_80039CD0(int object);
int func_8003614C(int sound, int value, int enabled, int extra);
void func_80002D70(int slot, int index, int frame, int scale,
                   int unused0, int unused1, int unused2, int mode);

void func_80004C3C(int eraseScreen)
{
    int index;
    int triggerIndex;
    /* Movie start sets bit 0x20 before any configured primary-frame reads. */
    int wholeFrame;
    int finalFrame;
    int frameDuration;
    int previousFrame;
    ActorAnimation *animation;

    func_800360B8(D_8008F914);
    if (eraseScreen) {
        func_800360B8(D_8008F920);
    }
    if (D_800AD158 && !D_800B14A8->field6C && D_800AD280 != 12 &&
        D_800B14A8->field08 != -1) {
        switch (D_800B14A8->field08) {
        case 0:
            D_800B14A8->field6C = 1;
            if (!D_8009E578) {
                func_80031658(&D_80075990, -102400,
                    func_8004CEF0(-102400) * D_800B14A8->field04 / 10240);
            }
            break;
        case 1:
            D_800B14A8->field08 = 2;
            D_800B14A8->field28 = D_800B14A8->field2C << 8;
            break;
        }
    }
    if (func_80005354()) {
        return;
    }
    if (D_800B14A8->field08 == 2) {
        finalFrame = D_800B14A8->field30;
    } else {
        finalFrame = D_800B14A8->field2C;
    }
    for (index = 0; index < D_800B14A8->propCount; index++) {
        if (D_800B14A8->props[index].actor) {
            if (D_800B14A8->props[index].actor->flags & 0x20) {
                animation = D_800B14A8->props[index].actor->resource->animation.tracks[
                    D_800B14A8->props[index].actor->animationIndex];
                if (animation->frameDuration == 100 || animation->frameDuration == 0) {
                    frameDuration = 4;
                } else {
                    frameDuration = animation->frameDuration;
                }
                wholeFrame = D_800B14A8->field28 / (frameDuration << 6);
                if (wholeFrame >= finalFrame) {
                    if (wholeFrame / (finalFrame - D_800B14A8->field20) < D_800B14A8->field24) {
                        wholeFrame = wholeFrame % (finalFrame - D_800B14A8->field20) + D_800B14A8->field20;
                    } else {
                        wholeFrame = finalFrame - 1;
                    }
                }
                if (animation->loopIndex != -1) {
                    D_800B14A8->props[index].actor->frame =
                        (wholeFrame % func_80039CD0(D_800B14A8->props[index].actor->objectIndex)) << 8;
                } else {
                    D_800B14A8->props[index].actor->frame = wholeFrame << 8;
                }
            }
            for (triggerIndex = 0; triggerIndex < D_800B14A8->props[index].primaryFrameCount; triggerIndex++) {
                if (wholeFrame >= D_800B14A8->props[index].primaryFrames[triggerIndex]) {
                    func_80039E0C(D_800B14A8->props[index].actor->objectIndex,
                                   D_800B14A8->props[index].primaryValues[triggerIndex]);
                }
            }
        }
    }
    if (D_800B14A8->field28 < (finalFrame << 8)) {
        wholeFrame = D_800B14A8->field28 / 256;
    } else {
        if (D_800B14A8->field28 / 256 / (finalFrame - D_800B14A8->field20) < D_800B14A8->field24) {
            wholeFrame = D_800B14A8->field28 / 256 % (finalFrame - D_800B14A8->field20) + D_800B14A8->field20;
        } else {
            wholeFrame = D_800B14A8->field2C - 1;
        }
    }
    if (D_800B14A8->pairs[D_800B14A8->field38].identifier != -1) {
        func_80003ECC(wholeFrame, D_800B14A8->pairs[D_800B14A8->field38].track);
    }
    for (index = 0; index < D_800B14A8->stringCount; index++) {
        func_80002D70(D_800B14A8->strings[index].field04,
                       D_800B14A8->strings[index].field08, wholeFrame,
                       D_800B14A8->strings[index].field14, 0, 0, 0,
                       D_800B14A8->strings[index].field18);
    }
    for (index = 0; index < D_800B14A8->indexedCount; index++) {
        if (wholeFrame >= D_800B14A8->indexed[index].field04 &&
            !D_800B14A8->indexed[index].field08) {
            func_8003614C(D_800B14A8->indexed[index].field00, 0, 1, 0);
            D_800B14A8->indexed[index].field08 = 1;
        }
    }
    if (!D_800B14A8->field6C) {
        for (index = 0; index < D_800B14A8->colorCount; index++) {
            if ((D_800B14A8->stringCount != 5 ||
                 (D_800B14A8->colors[index].field08 == 102400 && !D_8009EFA8)) &&
                wholeFrame >= D_800B14A8->colors[index].field04 &&
                !D_800B14A8->colors[index].field0C) {
                func_80031658(&D_800B14A8->colors[index].color,
                               D_800B14A8->colors[index].field08,
                               D_800B14A8->colors[index].rate);
                D_800B14A8->colors[index].field0C = 1;
            }
        }
    }
    previousFrame = D_800B14A8->field28;
    D_800B14A8->field28 += D_800B14A8->field04 * D_8009EF94;
    for (index = 0; index < D_800B14A8->callbackCount; index++) {
        if (previousFrame < (D_800B14A8->callbacks[index].frame << 8) &&
            D_800B14A8->field28 >= (D_800B14A8->callbacks[index].frame << 8)) {
            D_800B14A8->callbacks[index].handler(0);
        }
    }
}
