#ifndef ROBOTRON_ACTOR_H
#define ROBOTRON_ACTOR_H

#include "text.h"

/* The actor allocator clears 0x7C bytes and advances its pool by that stride. */
typedef struct GameActor {
    short unknown00[6];
    short objectIndex;
    short unknown0E[3];
    unsigned int flags;
    int frame;
    unsigned char kind;
    unsigned char unknown1D[2];
    unsigned char animationIndex;
    unsigned char unknown20;
    unsigned char state;
    unsigned char unknown22[2];
    TextGlyphResource *resource;
    unsigned char unknown28[0xC];
    int field34;
    unsigned char unknown38[0x10];
    int field48;
    int history_index;
    int history_state;
    unsigned char *history;
    int field58;
    int field5C;
    int position[3];
    unsigned char unknown6C[8];
    int field74;
    struct GameActor *next;
} GameActor;

typedef char GameActorMustBe124Bytes[sizeof(GameActor) == 0x7C ? 1 : -1];

GameActor *func_800283D4(int kind, TextGlyphResource *resource, int *position);
int func_8001CF68(TextGlyphResource *resource, int mode);
void func_80027AB8(GameActor *actor, unsigned char animation, int reset);
void func_8002818C(void);
void func_800281C4(void);
void func_8002824C(void);
void func_80028274(GameActor *actor, GameActor *previous);
void func_8002836C(void);

#endif
