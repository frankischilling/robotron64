#include "../../include/actor.h"

extern GameActor *D_800AA708;
extern int D_800A4620;
extern int D_800AEEB4;
extern int D_800ACD90[11];

extern void func_8002606C(int value, int enabled);
extern void func_80001360(void);
extern void func_80028274(GameActor *actor, GameActor *previous);
extern void func_80039358(void);
extern void func_800420B0(void);

void func_800281C4(void)
{
    GameActor *actor;

    func_8002606C(0, 1);
    func_80001360();
    actor = D_800AA708;
    while (actor != 0) {
        func_80028274(actor, 0);
        actor = actor->next;
    }
    func_8003B694(D_800ACD90, 0, 44);
    func_80039358();
    D_800A4620 = 0;
    D_800AEEB4 = 0;
}

void func_8002824C(void)
{
    func_800281C4();
    func_800420B0();
}
