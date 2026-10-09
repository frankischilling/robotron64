#ifndef ROBOTRON_SAVE_GAME_H
#define ROBOTRON_SAVE_GAME_H

#include "destination_format.h"

#include "pak_file.h"
#include "scene_definition.h"

typedef struct SavedPlayerState {
    unsigned char unknown00[5];
    unsigned char selection05;
    unsigned char unknown06[2];
    struct GameActor *actor08;
    unsigned char unknown0C[0xC];
    int value18;
    int active;
    unsigned char unknown20[4];
    int value24;
    unsigned char unknown28[0xC];
    int field34;
    unsigned char unknown38[0x34];
    int field6C;
    int field70;
    int field74;
    unsigned char unknown78[0x28];
} SavedPlayerState;

typedef struct GamePlayerState {
    SavedPlayerState saved;
    unsigned char unknownA0[0xCCC];
    int level;
    int valueD70;
    unsigned char unknownD74[0x40];
} GamePlayerState;

typedef struct SavedSessionState {
    unsigned char unknown00[0x1C];
    unsigned int flags1C;
    unsigned char unknown20[4];
    int selection;
    int level;
    int mode;
    int currentPlayer;
    int selection34;
    int playerChoices38[2];
    unsigned char unknown40[8];
    int extra48;
} SavedSessionState;

struct EarlyAnimationRecord;
struct EarlyGameActor;
struct EarlySceneResourceRecord;

typedef struct GameSessionState {
    SavedSessionState saved;
    int value4C;
    unsigned char unknown50[4];
    int parameterIndex54;
    int value58;
    unsigned char unknown5C[0xC];
    unsigned int timestamp68;
    int parameterStart6C;
    unsigned char unknown70[0x10];
    struct EarlyGameActor *animationActor80;
    struct EarlySceneResourceRecord *animationResources84;
    unsigned char unknown88[4];
    int value8C;
    int animationReady90;
    unsigned char unknown94[4];
    int animationDistance98;
    int animationIndex9C;
    int animationLimitA0;
    unsigned char unknownA4[4];
    int animationStateA8;
    int animationMovementAC;
    int animationCallbackB0;
    struct EarlyAnimationRecord *animationRecordsB4;
    short activeBehaviorActors[36];
    short activeSceneActors[8];
    short unknownCounters110[11];
    short randomSpawnActors[16];
} GameSessionState;

typedef struct GameOptionConfiguration {
    int field00;
    int field04;
    int field08;
    int field0C;
    int field10;
    int field14;
} GameOptionConfiguration;

typedef struct SavedOptions {
    unsigned char configuration[0x18];
    int audio18;
    int audio1C;
    int playerField34[2];
} SavedOptions;

typedef struct SavedGameSlot {
    SavedSessionState session;
    SavedPlayerState players[2];
    int playerLevels[2];
    SavedOptions options;
} SavedGameSlot;

typedef struct GameSaveData {
    unsigned char signature[0x14];
    unsigned char configuration[0x190];
    unsigned char unknown1A4[4];
    int occupied[8];
    SavedGameSlot slots[8];
    SavedOptions options;
    unsigned int checksum;
    unsigned char unknownFD4[0x2C];
} GameSaveData;

typedef union GameSaveImage {
    GameSaveData data;
    unsigned int words[1024];
} GameSaveImage;

typedef char SavedPlayerStateMustBe160Bytes[sizeof(SavedPlayerState) == 0xA0 ? 1 : -1];
typedef char GamePlayerStateMustBe3508Bytes[sizeof(GamePlayerState) == 0xDB4 ? 1 : -1];
typedef char SavedSessionStateMustBe76Bytes[sizeof(SavedSessionState) == 0x4C ? 1 : -1];
typedef char GameSessionStateMustBe328Bytes[sizeof(GameSessionState) == 0x148 ? 1 : -1];
typedef char SavedOptionsMustBe40Bytes[sizeof(SavedOptions) == 0x28 ? 1 : -1];
typedef char GameOptionConfigurationMustBe24Bytes[
    sizeof(GameOptionConfiguration) == 0x18 ? 1 : -1];
typedef char SavedGameSlotMustBe444Bytes[sizeof(SavedGameSlot) == 0x1BC ? 1 : -1];
typedef char GameSaveDataMustBe4096Bytes[sizeof(GameSaveData) == 0x1000 ? 1 : -1];
typedef char GameSaveImageMustBe4096Bytes[sizeof(GameSaveImage) == 0x1000 ? 1 : -1];

extern GamePlayerState D_8009B190[2];
extern GameSessionState D_800AD138;
extern int D_800AD280;
extern int D_800AD284;
extern GameOptionConfiguration D_800AD2F8;
extern int D_800AD310;
extern int D_800AD314;
extern GameSaveImage D_800AD318;
extern unsigned char D_80075D88[0x14];
extern unsigned char D_80075DA0[0x190];
extern int D_80075FB8;
extern unsigned int D_80077C00;
extern int D_80077C04;
extern int D_80077C08;
extern int D_8009EFA4;
extern int D_800BAE88;
extern int D_800BB158;
extern unsigned char D_800BB160[8][20];
extern unsigned char *D_800BB200[8];

extern unsigned char D_80093FE4[];
extern unsigned char D_80093FF0[];
extern unsigned char D_80093FF4[];
extern unsigned char D_80093FF8[];
extern unsigned char D_80094000[];
extern unsigned char D_80094004[];
extern unsigned char D_80094018[];

void func_8002FE00(SavedOptions *options);
void func_8002FE68(SavedGameSlot *slot);
void func_8002FF40(SavedOptions *options);
void func_8002FFC8(SavedGameSlot *slot);
void func_80030054(void);
int func_800301A4(int reportErrors, int restoreOptions);
int func_80030420(int clearFailedSlot);
void func_800305F8(int *selection);

void func_8001A2C4(void);
void func_8001C2C4(unsigned char *format, ...);
void func_800214D4(int mode);
unsigned char *func_80021B20(int level);
void func_800278AC(int first, int second, void (*callback)(void));
void func_80027940(unsigned char **labels, int count);
void func_8003BF64();
#endif
