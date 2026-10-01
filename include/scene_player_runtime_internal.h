#ifndef ROBOTRON_SCENE_PLAYER_RUNTIME_INTERNAL_H
#define ROBOTRON_SCENE_PLAYER_RUNTIME_INTERNAL_H

#include "actor_behavior_internal.h"

struct EarlyGameActor;

typedef struct ScenePlayerRuntime {
    unsigned char field00;
    unsigned char field01;
    unsigned char unknown02;
    unsigned char field03;
    unsigned char field04;
    unsigned char field05;
    unsigned char unknown06[2];
    ActorBehaviorActorInternal *actor08;
    struct EarlyGameActor *field0C;
    unsigned char unknown10[4];
    int field14;
    int field18;
    int field1C;
    unsigned char unknown20[0x14];
    unsigned char field34[0x38];
    int field6C;
    int field70;
    int field74;
    int field78;
    int field7C;
    int field80;
    int field84;
    int field88;
    int field8C;
    int field90;
    int field94;
    int field98;
    unsigned char unknown9C[0xDB4 - 0x9C];
} ScenePlayerRuntime;

typedef char ScenePlayerRuntimeMustBe3508Bytes[
    sizeof(ScenePlayerRuntime) == 0xDB4 ? 1 : -1];

#endif
