#ifndef ROBOTRON_PLAYER_BEHAVIOR_INTERNAL_H
#define ROBOTRON_PLAYER_BEHAVIOR_INTERNAL_H

#include "actor_behavior_internal.h"
#include "actor_resource_5c_internal.h"
#include "early_game_state.h"
#include "early_input_internal.h"
#include "sound_bridge_internal.h"

/* The session and each player's input at +0x34 share this 40-byte prefix.
 * The final word is outside EarlyPlayerInputState's 36-byte sampling view. */
typedef struct PlayerBehaviorInput {
    EarlyPlayerInputState input;
    int selection24;
} PlayerBehaviorInput;

/* Runtime view of the existing 0xDB4-byte GamePlayerState allocation.
 * These fields come from func_80033974's original loads and stores. */
typedef struct PlayerBehaviorState {
    unsigned char unknown00[4];
    unsigned char idle04;
    unsigned char unknown05[3];
    ActorBehaviorActorInternal *actor08;
    ActorBehaviorActorInternal *actor0C;
    unsigned char unknown10[0xC];
    int active1C;
    unsigned char unknown20[0x14];
    EarlyPlayerInputState input34;
    unsigned char unknown58[0x14];
    int selection6C;
    int selection70;
    int selection74;
    int count78;
    int value7C;
    int blend80;
    int direction84;
    int direction88;
    unsigned int timestamp8C;
    int unknown90;
    unsigned int timestamp94;
    unsigned int timestamp98;
    int charge9C;
    unsigned char unknownA0[0xCCC];
    int levelD6C;
    int valueD70;
    unsigned char unknownD74[0x40];
} PlayerBehaviorState;

typedef char PlayerBehaviorInputMustBe40Bytes[
    sizeof(PlayerBehaviorInput) == 0x28 ? 1 : -1];
typedef char PlayerBehaviorStateMustBe3508Bytes[
    sizeof(PlayerBehaviorState) == sizeof(GamePlayerState) ? 1 : -1];

/* The projectile owner view is defined in actor_behavior_more_internal.h.
 * Its global declarations use a different view of the same player storage. */
typedef struct ActorBehaviorPlayerInternal ActorBehaviorPlayerInternal;

extern ActorResource5CInternal D_8009AA00[16];
extern ActorResource5CInternal D_800AC998[11];
extern ActorBehaviorActorInternal *D_800AA708;
extern ActorBehaviorActorInternal *D_800BEF60;
extern int D_800BEF64;
extern int D_80073A40, D_8007BB18, D_8007C334, D_80097644;
extern int D_800AD288, D_800B6FD0, D_800BA74C, D_800BA784;
extern unsigned char D_800A4538[32];
extern unsigned char D_80094218[];

void func_80017F9C(ActorBehaviorActorInternal *actor);
void func_80029194(ActorBehaviorActorInternal *actor);
void func_800290B0(int object, int *position);
void func_80032F70(void);
GameActor *func_800330F8(PlayerBehaviorState *player,
                       ActorBehaviorActorInternal *actor,
                       int *x, int *y, int speed);
int func_800338CC(int value, int bits);
void func_800338F0(int *selection);
void func_80035E3C(ActorBehaviorActorInternal *actor, int speed,
                   EarlyPlayerInputState *input);
EarlyGameActor *func_80038D8C(EarlyGamePosition *position, int kind,
                            ActorBehaviorPlayerInternal *owner, int angle);
int func_800393FC(int object);
void func_8003945C(int object, int value);
int func_8004CDE8(void);

void func_80033974(ActorBehaviorActorInternal *actor, int unused);

#endif
