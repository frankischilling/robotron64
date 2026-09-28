#include "../../include/movie.h"
#include "../../include/actor.h"
#include "../../include/frame.h"
#include "../../include/object_helpers.h"
#include "../../include/scene_audio.h"

extern MovieIntegerPosition D_80072BF0;
extern int D_8007BB18;
extern int D_8009EFA8;
extern int D_800ACE18, D_800ACE1C, D_800ACE24, D_800ACE2C, D_800ACE34, D_800ACE40;
extern int D_800B1BE0;
extern int D_800B6FCC;

unsigned char *func_800383C4(int identifier);
int func_8001CF68(TextGlyphResource *resource, int mode);
void func_80039434(int object, int mode);
void func_80039EA0(int value, int mode);
int func_80031658(PaletteColor *color, int start, int rate);
void func_80031C44(int first, int second);
void func_800465B0(int red, int green, int blue);
int func_8004CDE8(void);
/* This target call passes a third argument unused by the recovered body. */
void func_80051680();

void func_800045E4(unsigned char *filename, int background, short red, short green, short blue)
{
    int index;
    MovieIntegerPosition position = D_80072BF0;

    func_800044AC(filename);
    D_800B14A8->field6C = 0;
    D_800B14A8->field28 = 0;
    D_800B14A8->field68 = 0;
    D_800B14A8->callbackCount = 0;
    D_800B1BE0 = 0;
    if (background >= 0) {
        D_8007BB18 = background;
        D_800ACE18 = 0x80;
        D_800ACE24 = 0;
        D_800ACE34 = 0;
        D_800ACE1C = 0;
        D_800ACE2C = 0;
        D_800ACE40 = 0x80;
    }
    func_800465B0(red, green, blue);
    if (D_800B14A8->pairCount >= 2) {
        D_800B14A8->field38 = (func_8004CDE8() >> 3) % D_800B14A8->pairCount;
    } else {
        D_800B14A8->field38 = 0;
    }
    if (D_800B14A8->pairs[D_800B14A8->field38].identifier != -1) {
        D_800B14A8->pairs[D_800B14A8->field38].track =
            func_80003A7C(D_800B14A8->pairs[D_800B14A8->field38].identifier,
                           func_800383C4(D_800B14A8->pairs[D_800B14A8->field38].identifier));
    }
    for (index = 0; index < D_800B14A8->stringCount; index++) {
        func_8003BCC4(func_800383C4(D_800B14A8->strings[index].identifier));
        func_80000518(func_800383C4(D_800B14A8->strings[index].identifier));
        D_800B14A8->strings[index].field04 =
            func_80000918(func_800383C4(D_800B14A8->strings[index].identifier),
                           D_800B14A8->strings[index].field10, 10, 0);
        func_80000568(func_800383C4(D_800B14A8->strings[index].identifier));
        D_800B14A8->strings[index].field08 =
            func_80003A7C(D_800B14A8->strings[index].field0C,
                           func_800383C4(D_800B14A8->strings[index].field0C));
    }
    for (index = 0; index < D_800B14A8->propCount; index++) {
        func_8001CF68(&D_800B1BE8[D_800B14A8->props[index].identifier], 1);
    }
    for (index = 0; index < D_800B14A8->propCount; index++) {
        if (D_800B14A8->props[index].hasPosition) {
            position = D_800B14A8->props[index].position;
        } else {
            position.value[2] = 0;
            position.value[1] = 0;
            position.value[0] = 0;
        }
        D_800B14A8->props[index].actor =
            func_800283D4(9, &D_800B1BE8[D_800B14A8->props[index].identifier], position.value);
        if (D_800B14A8->props[index].actor != 0) {
            func_80027AB8(D_800B14A8->props[index].actor, D_800B14A8->props[index].mode, 1);
            D_800B14A8->props[index].actor->flags |= 0x20;
            if (D_800B14A8->props[index].actor->resource->animation.tracks[
                    D_800B14A8->props[index].mode]->track != -1) {
                func_80039434(D_800B14A8->props[index].actor->objectIndex, 1);
            } else if (!D_800B14A8->props[index].hasPosition) {
                func_80039434(D_800B14A8->props[index].actor->objectIndex, 2);
            }
        }
    }
    for (index = 0; index < D_800B14A8->colorCycleCount; index++) {
        func_80031C44(D_800B14A8->colorCycleFirst[index], D_800B14A8->colorCycleSecond[index]);
    }
    func_80039EA0(0, 0);
    func_8003A1E4((float)D_800B14A8->field1C);
    for (index = 0; index < D_800B14A8->indexedCount; index++) {
        D_800B14A8->indexed[index].field08 = 0;
    }
    for (index = 0; index < D_800B14A8->colorCount; index++) {
        if (D_800B14A8->colors[index].field04 == 0) {
            if (D_800B14A8->stringCount != 5 || D_8009EFA8 == 0) {
                func_80031658(&D_800B14A8->colors[index].color,
                               D_800B14A8->colors[index].field08,
                               D_800B14A8->colors[index].rate);
            }
            D_800B14A8->colors[index].field0C = 1;
        } else {
            D_800B14A8->colors[index].field0C = 0;
        }
    }
    func_8001F8E8(D_800B14A8->field0C, D_800B14A8->field10, 10, 0, 0);
    func_8001F90C();
    if (D_800B14A8->field14 != -1) {
        func_80051680(D_800B14A8->field14, D_800B14A8->field18, 0);
    }
    D_800B6FCC = 1;
}
