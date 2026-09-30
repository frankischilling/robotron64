#ifndef ROBOTRON_SCENE_BACKGROUND_INTERNAL_H
#define ROBOTRON_SCENE_BACKGROUND_INTERNAL_H

typedef struct SceneBackgroundRecord {
    unsigned char kind;
    unsigned char texture;
    unsigned char colors;
    unsigned char unknown03[13];
} SceneBackgroundRecord;

typedef struct BackgroundColorRecord {
    unsigned char first[3];
    unsigned char second[3];
} BackgroundColorRecord;

typedef char SceneBackgroundRecordMustBe16Bytes[
    sizeof(SceneBackgroundRecord) == 16 ? 1 : -1];
typedef char BackgroundColorRecordMustBe6Bytes[
    sizeof(BackgroundColorRecord) == 6 ? 1 : -1];

/* Record strides are confirmed; complete table allocations remain unresolved. */
extern int D_800AD160;
extern SceneBackgroundRecord D_80074C08[];
extern BackgroundColorRecord D_80074BC4[];
extern int D_8007BB18;
extern int D_800ACE18, D_800ACE1C, D_800ACE24;
extern int D_800ACE2C, D_800ACE34, D_800ACE40;

void func_80022BFC(void);

#endif
