#ifndef ROBOTRON_ACTOR_ANIMATION_STATE_H
#define ROBOTRON_ACTOR_ANIMATION_STATE_H

#include "actor_behavior_internal.h"
#include "save_game.h"

extern int D_8009EFA0;
extern int D_800B00A0;
extern unsigned int D_800B1BDC;
extern unsigned char D_8009AFC0[];
extern TextGlyphResource D_8009F928;

int func_8004CDE8(void);
void func_8003945C(int object, int value);
ActorBehaviorActorInternal *func_8001A350(TextGlyphResource *resource, int *position);
void func_80029210(ActorBehaviorActorInternal *actor);
void func_80029D6C(ActorBehaviorActorInternal *actor);

void func_80029194(ActorBehaviorActorInternal *actor);
void func_800294A4(ActorBehaviorActorInternal *actor);
void func_80029B80(ActorBehaviorActorInternal *actor);
void func_80029C48(ActorBehaviorActorInternal *actor);
void func_80029D98(ActorBehaviorActorInternal *actor);
void func_80029E5C(ActorBehaviorActorInternal *actor);
void func_80035CC8(int mode);

#endif
