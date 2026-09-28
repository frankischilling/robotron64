#include "../../include/movie.h"
#include "../../include/game_memory.h"
#include "../../include/scalar_math.h"
#include "../../include/text.h"

extern char D_8008F840[];
extern char D_8008F858[];
extern char D_8008F878[];
extern char D_8008F898[];
extern int D_8009EFB4;
extern int D_800B1BE0;

void func_80003040(int *command)
{
    int index;

    func_8003B694(D_800B14A8, 0, sizeof(MovieConfig));
    for (index = 0; index < 5; index++) {
        D_800B14A8->pairs[index].identifier = -1;
    }
    D_800B14A8->field04 = command[1];
    D_800B14A8->field2C = command[2];
    D_800B14A8->field24 = command[3];
    D_800B14A8->field20 = command[4];
    D_800B14A8->field1C = command[5];
    D_800B14A8->field08 = command[6];
    D_800B14A8->field0C = -1;
    D_800B14A8->field14 = -1;
    D_800B14A8->indexedCount = 0;
    D_800B14A8->colorCount = 0;
    D_800B14A8->colorCycleCount = 0;
    D_800B14A8->field30 = 0;
    D_800B14A8->field6C = 0;
}

void func_80003184(int *command)
{
    int identifier = command[1];
    int mode = command[2];

    if (D_800B14A8->propCount < MOVIE_PROP_COUNT) {
        D_800B14A8->props[D_800B14A8->propCount].identifier = identifier;
        D_800B14A8->props[D_800B14A8->propCount].mode = mode;
        D_800B14A8->props[D_800B14A8->propCount].hasPosition = 0;
        D_800B14A8->props[D_800B14A8->propCount].actor = 0;
        D_800B14A8->propCount++;
    } else {
        func_8001C0D0(D_8008F840);
    }
}

void func_80003278(int *command)
{
    int prop = command[1];
    int x = command[2];
    int y = command[3];
    int z = command[4];

    D_800B14A8->props[prop].hasPosition = 1;
    D_800B14A8->props[prop].position.value[0] = x;
    D_800B14A8->props[prop].position.value[1] = y;
    D_800B14A8->props[prop].position.value[2] = z;
}

void func_800032EC(int *command)
{
    int prop;
    int value;
    int frame;

    prop = command[1];
    frame = command[2];
    value = command[3];

    if (D_800B14A8->props[prop].primaryFrameCount == MOVIE_PRIMARY_FRAME_COUNT) {
        func_8001C0D0(D_8008F858, prop);
    }
    D_800B14A8->props[prop].primaryFrames[D_800B14A8->props[prop].primaryFrameCount] = frame;
    D_800B14A8->props[prop].primaryValues[D_800B14A8->props[prop].primaryFrameCount] = value;
    D_800B14A8->props[prop].primaryFrameCount++;
}

void func_800033C8(int *command)
{
    D_800B14A8->pairs[D_800B14A8->pairCount].identifier = command[1];
    D_800B14A8->pairCount++;
}

void func_80003408(int *command)
{
    if (D_800B14A8->colorCycleCount >= MOVIE_COLOR_CYCLE_COUNT) {
        func_8001C0D0(D_8008F878);
    }
    D_800B14A8->colorCycleFirst[D_800B14A8->colorCycleCount] = command[1];
    D_800B14A8->colorCycleSecond[D_800B14A8->colorCycleCount] = command[2];
    D_800B14A8->colorCycleCount++;
}

void func_800034A8(int *command)
{
    int first = command[1];
    int second = command[2];

    D_800B14A8->indexed[D_800B14A8->indexedCount].field04 = second;
    D_800B14A8->indexed[D_800B14A8->indexedCount].field00 = first;
    D_800B14A8->indexedCount++;
}

void func_80003510(int *command)
{
    int first = command[1];
    int second = command[2];
    int duration;
    PaletteColor color;

    color.red = command[3];
    color.green = command[4];
    color.blue = command[5];
    duration = command[6];
    D_800B14A8->colors[D_800B14A8->colorCount].field04 = first;
    D_800B14A8->colors[D_800B14A8->colorCount].field08 = second;
    D_800B14A8->colors[D_800B14A8->colorCount].color = color;
    D_800B14A8->colors[D_800B14A8->colorCount].rate =
        (func_8004CEF0(0x19000) * D_800B14A8->field04) / (duration << 8);
    D_800B14A8->colorCount++;
}

void func_80003654(int *command)
{
    D_800B14A8->field14 = command[1];
    D_800B14A8->field18 = command[2];
}

void func_8000367C(int *command)
{
    D_800B14A8->field0C = command[1];
    D_800B14A8->field10 = command[2];
}

void func_800036A4(int *command)
{
    int identifier;
    int first;
    int third;
    int second;
    int fourth;

    identifier = command[1];
    first = command[2];
    second = command[3];
    third = command[4];
    fourth = command[5];

    if (D_800B14A8->stringCount == MOVIE_STRING_COUNT) {
        func_8001C0D0(D_8008F898);
    }
    D_800B14A8->strings[D_800B14A8->stringCount].identifier = identifier;
    D_800B14A8->strings[D_800B14A8->stringCount].field0C = first;
    D_800B14A8->strings[D_800B14A8->stringCount].field10 = third;
    D_800B14A8->strings[D_800B14A8->stringCount].field14 = second;
    D_800B14A8->strings[D_800B14A8->stringCount].field18 = fourth;
    D_800B14A8->stringCount++;
}

void func_800037DC(int *command)
{
    D_800B1BE0 = 0;
    D_8009EFB4 = 1;
}
