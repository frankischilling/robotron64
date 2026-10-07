#ifndef ROBOTRON_MOVIE_H
#define ROBOTRON_MOVIE_H

#include "palette.h"

#define MOVIE_PROP_COUNT 10
#define MOVIE_PRIMARY_FRAME_COUNT 10
#define MOVIE_COLOR_CYCLE_COUNT 3
#define MOVIE_STRING_COUNT 7
#define MOVIE_FRAME_WORDS 13
#define MOVIE_TRACK_COUNT 25
#define MOVIE_CALLBACK_COUNT 3

struct GameActor;

typedef struct MovieIntegerPosition {
    int value[3];
} MovieIntegerPosition;

typedef struct MoviePairRecord {
    int identifier;
    int track;
} MoviePairRecord;

typedef struct MovieProp {
    short identifier;
    short mode : 15;
    short hasPosition : 1;
    MovieIntegerPosition position;
    struct GameActor *actor;
    int primaryFrameCount;
    int primaryFrames[MOVIE_PRIMARY_FRAME_COUNT];
    int primaryValues[MOVIE_PRIMARY_FRAME_COUNT];
} MovieProp;

typedef struct MovieIndexedRecord {
    int field00;
    int field04;
    int field08;
} MovieIndexedRecord;

typedef struct MovieColorRecord {
    PaletteColor color;
    int field04;
    int field08;
    int field0C;
    int rate;
} MovieColorRecord;

typedef struct MovieStringRecord {
    int identifier;
    int field04;
    int field08;
    int field0C;
    int field10;
    int field14;
    int field18;
} MovieStringRecord;

typedef struct MovieCallback {
    void (*handler)(int);
    int frame;
} MovieCallback;

typedef struct MovieConfig {
    int field00;
    int field04;
    int field08;
    int field0C;
    int field10;
    int field14;
    int field18;
    int field1C;
    int field20;
    int field24;
    int field28;
    int field2C;
    int field30;
    int pairCount;
    int field38;
    MoviePairRecord pairs[5];
    int propCount;
    int field68;
    int field6C;
    MovieProp props[MOVIE_PROP_COUNT];
    int colorCycleCount;
    int colorCycleFirst[MOVIE_COLOR_CYCLE_COUNT];
    int colorCycleSecond[MOVIE_COLOR_CYCLE_COUNT];
    int indexedCount;
    int colorCount;
    MovieIndexedRecord indexed[30];
    MovieColorRecord colors[3];
    MovieCallback callbacks[MOVIE_CALLBACK_COUNT];
    int stringCount;
    int callbackCount;
    MovieStringRecord strings[MOVIE_STRING_COUNT];
} MovieConfig;

typedef struct MovieTrackState {
    int channel[MOVIE_FRAME_WORDS];
    int identifier;
    unsigned char unknown38[0x3C];
    int active;
    int frameCount;
    int field7C;
    unsigned int trackedFields;
    int integerChannelCount;
    int floatChannelCount;
    unsigned int constantFields;
    float position[3];
    int angle[3];
    int unknownA8[6];
    int objectParameter;
    int *integerChannels;
    float *floatChannels;
} MovieTrackState;

typedef char MoviePropMustBe104Bytes[sizeof(MovieProp) == 0x68 ? 1 : -1];
typedef char MovieColorRecordMustBe20Bytes[sizeof(MovieColorRecord) == 0x14 ? 1 : -1];
typedef char MovieStringRecordMustBe28Bytes[sizeof(MovieStringRecord) == 0x1C ? 1 : -1];
typedef char MovieConfigMustBe1836Bytes[sizeof(MovieConfig) == 0x72C ? 1 : -1];
typedef char MovieTrackMustBe204Bytes[sizeof(MovieTrackState) == 0xCC ? 1 : -1];

extern MovieTrackState *D_800972A0;
extern MovieTrackState D_800B00B8[MOVIE_TRACK_COUNT];
extern MovieConfig *D_800B14A8;
extern MovieConfig D_800B14B0;

void func_80002EE0(void);
void func_80002F28(float *output, float value, float *initial, int field);
void func_80002FC4(int *output, int value, int *initial, int field);
void func_80003040(int *command);
void func_80003184(int *command);
void func_80003278(int *command);
void func_800032EC(int *command);
void func_800033C8(int *command);
void func_80003408(int *command);
void func_800034A8(int *command);
void func_80003510(int *command);
void func_80003654(int *command);
void func_8000367C(int *command);
void func_800036A4(int *command);
void func_800037DC(int *command);
void func_800037F8(float *uniform, float value, int argument, int *nextChannel,
                   int *channel, int field);
void func_80003898(int *uniform, int value, int argument, int *nextChannel,
                   int *channel, int field);
void func_8000392C(int field, int channel, float *frameField, int stride);
void func_800039D4(int field, int channel, int *frameField, int stride);
int func_80003A7C(int identifier, unsigned char *name);
void func_80003CF8(int index);
void func_80003ECC(int frame, int index);
void func_80004098(int frame, int index, float *position, int *pitch, int *yaw, int *roll);
void func_8000440C(void (*handler)(int), int frame);
void func_80004C3C(int eraseScreen);
int func_80005354(void);
void func_800044AC(unsigned char *filename);
void func_800045E4(unsigned char *filename, int background, short red, short green, short blue);
void func_8000544C(void);

#endif
