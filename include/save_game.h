#ifndef ROBOTRON_SAVE_GAME_H
#define ROBOTRON_SAVE_GAME_H

#include "pak_file.h"
#include "scene_definition.h"

typedef struct SavedPlayerState {
    unsigned char unknown00[5];
    unsigned char selection05;
    unsigned char unknown06[0x12];
    int value18;
    int active;
    unsigned char unknown20[0x14];
    int field34;
    unsigned char unknown38[0x68];
} SavedPlayerState;

typedef struct GamePlayerState {
    SavedPlayerState saved;
    unsigned char unknownA0[0xCCC];
    int level;
    unsigned char unknownD70[0x44];
} GamePlayerState;

typedef struct SavedSessionState {
    unsigned char unknown00[0x24];
    int selection;
    int level;
    int mode;
    int currentPlayer;
    unsigned char unknown34[0x18];
} SavedSessionState;

typedef struct GameSessionState {
    SavedSessionState saved;
    unsigned char unknown4C[0xB4];
    short activeSceneActors[16];
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

typedef union GameSaveImage {
    struct {
        unsigned char signature[0x14];
        unsigned char configuration[0x190];
        unsigned char unknown1A4[4];
        int occupied[8];
        SavedGameSlot slots[8];
        SavedOptions options;
        unsigned int checksum;
        unsigned char unknownFD4[0x2C];
    } data;
    unsigned int words[1024];
} GameSaveImage;

typedef char SavedPlayerStateMustBe160Bytes[sizeof(SavedPlayerState) == 0xA0 ? 1 : -1];
typedef char GamePlayerStateMustBe3508Bytes[sizeof(GamePlayerState) == 0xDB4 ? 1 : -1];
typedef char SavedSessionStateMustBe76Bytes[sizeof(SavedSessionState) == 0x4C ? 1 : -1];
typedef char SavedOptionsMustBe40Bytes[sizeof(SavedOptions) == 0x28 ? 1 : -1];
typedef char GameOptionConfigurationMustBe24Bytes[
    sizeof(GameOptionConfiguration) == 0x18 ? 1 : -1];
typedef char SavedGameSlotMustBe444Bytes[sizeof(SavedGameSlot) == 0x1BC ? 1 : -1];
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
void func_800363D0(unsigned char *destination, unsigned char *format, ...);
void func_8003BF64();
#endif
