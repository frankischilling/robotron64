#include "../../../include/early_bonus_internal.h"

/* The enclosing threshold table extent remains unknown. */
#define THRESHOLD(index) (((int *)((unsigned char *)D_800AD138.animationResources84 + 0x3C4))[(index)])

extern int D_80097350;
extern int D_800C8B7C;
extern EarlyAnimationRecord D_80073164[];
ActorBehaviorActorInternal *func_8001AF44(int kind, int *position, ActorBehaviorActorInternal *actor);
void func_80029154(ActorBehaviorActorInternal *actor);
void func_8000EE48(EarlyGameActor *actor);
void func_8000F4E0(EarlyGameActor *actor);
void func_80039EB8(int first, unsigned char second);

void func_8000FBC0(ActorBehaviorActorInternal *actor)
{
    int x;
    int y;
    int random;
    int index;
    int eligible;
    int angle;
    int timer;
    int kind;
    int divisor = 10000;
    int percent = 100;
    EarlyAnimationSlot *slot;
    ActorBehaviorCallbackInternal callback;

    D_800AD138.animationStateA8 = -1;
    D_800AD138.animationCallbackB0 = -1;
    D_800AD138.animationMovementAC = -1;
    D_800AD138.animationDistance98 = func_8003CCE8(
        (actor->position[0] - ((ActorBehaviorActorInternal *)D_8009B190[D_800AD138.saved.currentPlayer].saved.actor08)->position[0]) *
        (actor->position[0] - ((ActorBehaviorActorInternal *)D_8009B190[D_800AD138.saved.currentPlayer].saved.actor08)->position[0]) / divisor +
        (actor->position[1] - ((ActorBehaviorActorInternal *)D_8009B190[D_800AD138.saved.currentPlayer].saved.actor08)->position[1]) *
        (actor->position[1] - ((ActorBehaviorActorInternal *)D_8009B190[D_800AD138.saved.currentPlayer].saved.actor08)->position[1]) / divisor) * 100;
    if (D_8009B190[D_800AD138.saved.currentPlayer].saved.value24 / 256 <= THRESHOLD(D_800AD138.animationIndex9C)) {
        D_80097350 = D_800AD138.animationIndex9C;
        D_800AD138.animationStateA8 = 0;
        if (D_800AD138.animationIndex9C != 0) {
            func_8000ECE4((EarlyGameActor *)actor, D_800AD138.animationRecordsB4[D_800AD138.animationIndex9C].initialAnimation18,
                (ActorBehaviorCallbackInternal)func_8000EE48, 999, D_80073164[D_800AD138.animationIndex9C].movement24[0].choice.value09);
            func_8000F564(10);
        } else {
            func_8000ECE4((EarlyGameActor *)actor, D_800AD138.animationRecordsB4[D_800AD138.animationIndex9C].initialAnimation18,
                func_80029154, 999, D_80073164[D_800AD138.animationIndex9C].movement24[0].choice.value09);
            func_8000F564(30);
        }
    }
    random = (func_8004CDE8() >> 3) % percent;
    slot = D_800AD138.animationRecordsB4[D_800AD138.animationIndex9C].weighted6C;
    for (index = 0; D_800AD138.animationStateA8 == -1 && index < 5 && slot->choice.animation00 != -1; index++, slot++) {
        kind = slot->choice.callback08;
        eligible = 0;
        if ((kind != 1 || (D_8009734C == 0 && D_80097348 == 0)) && slot->choice.animation00 != -1) {
            switch (slot->choice.weight04 & 0xF0000000) {
            case 0x10000000:
                if (D_800AD138.animationDistance98 > 25000) eligible = 1;
                break;
            case 0x20000000:
                if (D_800AD138.animationDistance98 < 25000 && D_800AD138.animationDistance98 > 9000) eligible = 1;
                break;
            case 0x40000000:
                if (D_800AD138.animationDistance98 < 9000) eligible = 1;
                break;
            default:
                eligible = 1;
                break;
            }
        }
        if (eligible) random -= slot->choice.weight04 & 0x0FFFFFFF;
        if (random < 0) {
            callback = func_8000FBC0;
            timer = 999;
            D_800AD138.animationCallbackB0 = kind;
            switch (D_800AD138.animationCallbackB0) {
            case 1:
                callback = func_8000F318;
                timer = 1;
                break;
            case 4:
                callback = (ActorBehaviorCallbackInternal)func_8000F4E0;
                timer = 1;
                func_80039EB8(20, 2);
                break;
            case 2:
                if (D_800C8B7C + 1 < 50) func_8001AF44(33, actor->position, 0);
                break;
            }
            if (slot->choice.animation00 != (int)0xDEADBEEF) {
                func_8000ECE4((EarlyGameActor *)actor, slot->choice.animation00, callback, timer, slot->choice.value09);
                D_800AD138.animationStateA8 = 2;
                break;
            } else {
                random = (func_8004CDE8() >> 3) % percent;
            }
        }
    }
    if (D_800AD138.animationStateA8 == -1) {
        slot = D_800AD138.animationRecordsB4[D_800AD138.animationIndex9C].resetA8;
        for (index = 0; index < 3 && slot->reset.value00 != -1; index++, slot++) {
            if (slot->reset.enabled08 == 0 &&
                (D_8009B190[D_800AD138.saved.currentPlayer].saved.value24 / 256 - THRESHOLD(D_800AD138.animationIndex9C)) * 100 /
                    THRESHOLD(D_800AD138.animationIndex9C + 1) <= slot->reset.threshold04) {
                slot->reset.enabled08 = 1;
                func_8000ECE4((EarlyGameActor *)actor, slot->reset.value00, func_8000FBC0, 999, slot->reset.value09);
                D_800AD138.animationStateA8 = 3;
                break;
            }
        }
    }
    if (D_800AD138.animationStateA8 == -1) {
        y = ((ActorBehaviorActorInternal *)D_8009B190[D_800AD138.saved.currentPlayer].saved.actor08)->position[1] - actor->position[1];
        x = ((ActorBehaviorActorInternal *)D_8009B190[D_800AD138.saved.currentPlayer].saved.actor08)->position[0] - actor->position[0];
        angle = ((func_8003CD4C(y, x) + 256) & 0xE00) - actor->angle08;
        while (angle > 2047) angle -= 4096;
        while (angle < -2048) angle += 4096;
        if (func_8004CEF0(angle) >= 553 && func_8004CEF0(angle) < 1536) {
            if (D_800AD138.animationDistance98 > 9000 && func_8004CEF0(angle) > 668 && func_8004CEF0(angle) < 1380 &&
                (func_8004CDE8() >> 3) % 256 > 128) {
                if (angle > 0) D_800AD138.animationMovementAC = 5;
                else D_800AD138.animationMovementAC = 4;
            } else {
                if (angle > 0) D_800AD138.animationMovementAC = 3;
                else D_800AD138.animationMovementAC = 2;
            }
        } else {
            if (func_8004CEF0(angle) >= 1536) {
                if (D_800AD138.animationRecordsB4[D_800AD138.animationIndex9C].movement24[1].choice.animation00 != -1) D_800AD138.animationMovementAC = 1;
                else {
                    if (angle > 0) D_800AD138.animationMovementAC = 3;
                    else D_800AD138.animationMovementAC = 2;
                }
            } else if (D_800AD138.animationRecordsB4[D_800AD138.animationIndex9C].movement24[0].choice.animation00 != -1) D_800AD138.animationMovementAC = 0;
        }
        if (D_800AD138.animationMovementAC != -1) {
            D_800AD138.animationStateA8 = 1;
            slot = &D_800AD138.animationRecordsB4[D_800AD138.animationIndex9C].movement24[D_800AD138.animationMovementAC];
            func_8000ECE4((EarlyGameActor *)actor, slot->choice.animation00,
                func_8000FBC0, 999, slot->choice.value09);
        }
    }
}
