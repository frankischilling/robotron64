#ifndef ROBOTRON_SCENE_DEFINITION_H
#define ROBOTRON_SCENE_DEFINITION_H

typedef struct SceneArrival {
    unsigned char trigger;
    unsigned char state;
    unsigned char resourceIndex;
    unsigned char category;
    short delay;
    short count;
    short x;
    short y;
} SceneArrival;

typedef struct SceneTweakOverride {
    short variable;
    short value;
} SceneTweakOverride;

typedef struct SceneDefinition {
    int positions[5][3];
    unsigned char positionEnabled[5];
    unsigned char unknown41[3];
    SceneArrival arrivals[256];
    int resourceC44;
    int valueC48;
    int valueC4C;
    int unknownC50;
    SceneTweakOverride tweaks[25];
    short effectFirst[4];
    short effectSecond[4];
    int arrivalCount;
    int unknownCCC;
    int valueCD0;
    int resourceCD4;
    int valueCD8;
    int valueCDC;
    int valueCE0;
    int valueCE4;
    int valueCE8;
    int unknownCEC;
    int valueCF0;
    int enabledCF4;
    int valueCF8;
    int effectCount;
    int tweakCount;
    int flagsD04;
    int flagD08;
    unsigned char unknownD0C[8];
} SceneDefinition;

typedef struct SceneResourceState {
    signed char flags00;
    unsigned char unknown01;
    short value02;
    short value04;
    short unknown06;
    int unknown08;
    int unknown0C;
    int resourceLimits[50];
    int secondaryLimits[50];
} SceneResourceState;

typedef char SceneArrivalMustBe12Bytes[sizeof(SceneArrival) == 0xC ? 1 : -1];
typedef char SceneDefinitionMustBe3348Bytes[sizeof(SceneDefinition) == 0xD14 ? 1 : -1];
typedef char SceneResourceStateMustBe416Bytes[sizeof(SceneResourceState) == 0x1A0 ? 1 : -1];

extern SceneDefinition D_800B9A78;
extern SceneResourceState D_800B8F78;

void func_80021B38(SceneDefinition *scene);

#endif
