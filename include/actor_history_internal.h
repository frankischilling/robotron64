#ifndef ROBOTRON_ACTOR_HISTORY_INTERNAL_H
#define ROBOTRON_ACTOR_HISTORY_INTERNAL_H

#include "actor_projectile_internal.h"
#include "object_recovery.h"

/* Sixteen twelve-byte positions belong to each of the 24 history slots. */
typedef struct ActorHistoryPoint {
    int value[3];
} ActorHistoryPoint;

/* The observed projectile prefix ends after its two planar velocity words. */
typedef struct ActorHistoryProjectile {
    int (*callback00)(GameActor *);
    unsigned char unknown04[4];
    short angle08;
    short unknown0A;
    short objectIndex0C;
    unsigned char unknown0E[0x1E];
    int value2C;
    unsigned char unknown30[0xC];
    GameActor *parent3C;
    unsigned char unknown40[8];
    int value48;
    int historyIndex4C;
    int historyState50;
    ActorHistoryPoint *history54;
    int unknown58;
    void (*callback5C)(GameActor *, int);
    int position60[3];
    int velocity6C;
    int velocity70;
} ActorHistoryProjectile;

typedef char ActorHistoryPointMustBe12Bytes[
    sizeof(ActorHistoryPoint) == 12 ? 1 : -1];
typedef char ActorHistoryProjectilePrefixMustBe116Bytes[
    sizeof(ActorHistoryProjectile) == 0x74 ? 1 : -1];

extern unsigned char D_8008D494[24];
extern ActorHistoryPoint D_8013EC00[24 * 16];
extern TextGlyphResource D_800ACC1C;

int func_8004E364(GameActor *actor);
void func_8004DEE0(GameActor *actor, int unused);

#endif
