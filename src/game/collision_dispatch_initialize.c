#include "../../include/early_game_state.h"
#include "../../include/early_game_helpers.h"
#include "../../include/early_game_more.h"
#include "../../include/early_game_medium.h"
#include "../../include/actor_collision_services.h"

typedef int (*CollisionHandler)(EarlyGameActor *, EarlyGameActor *, int *, int *);
CollisionHandler D_800974A0[10][10];
typedef char CollisionCallbackMatrixMustBe400Bytes[
    sizeof(D_800974A0) == 400 ? 1 : -1];
typedef struct ActorContactPoint ActorContactPoint;
extern int func_8001669C(ActorBehaviorActorInternal *, ActorBehaviorActorInternal *,
                         ActorContactPoint *, ActorContactPoint *);
extern int func_80016950(EarlyGameActor *, EarlyGameActor *, int *, int *);
extern int func_80015BF8(EarlyGameActor *, EarlyGameActor *, int *, int *);
extern int func_8001737C(EarlyGameActor *, EarlyGameActor *, int *, int *);
extern int func_8001567C(EarlyGameActor *, EarlyGameActor *, int *, int *);
extern unsigned char func_8001631C(EarlyGameActor *, EarlyGameActor *, int *, int *);
extern int func_80015F00(EarlyGameActor *, EarlyGameActor *, int *, int *);
extern int func_80015B5C(EarlyGameActor *, int, int, int);

void func_80019E40(void)
{
    int first;
    int second;
    CollisionHandler handler;

    for (first = 0; first < 10; first++) {
        for (second = 0; second < 10; second++) {
            D_800974A0[first][second] = 0;
        }
    }
    for (first = 0; first < 10; first++) {
        for (second = first; second < 10; second++) {
            handler = 0;
            switch (first) {
            case 0:
                switch (second) {
                case 0:
                    handler = (CollisionHandler)func_8001669C;
                    break;
                case 1:
                    handler = func_80016950;
                    break;
                case 2:
                    handler = func_80015BF8;
                    break;
                case 3:
                    handler = func_8001737C;
                    break;
                case 4:
                    handler = (CollisionHandler)func_80016C1C;
                    break;
                case 5:
                    handler = (CollisionHandler)func_80017364;
                    break;
                case 8:
                    handler = (CollisionHandler)func_80016914;
                    break;
                }
                break;
            case 1:
                switch (second) {
                case 2:
                    handler = func_8001567C;
                    break;
                case 3:
                    handler = (CollisionHandler)func_80017A2C;
                    break;
                case 4:
                    handler = (CollisionHandler)func_8001631C;
                    break;
                case 5:
                    handler = (CollisionHandler)func_80016618;
                    break;
                }
                break;
            case 2:
                switch (second) {
                case 2:
                    handler = (CollisionHandler)func_800152AC;
                    break;
                case 3:
                    handler = func_80015F00;
                    break;
                case 5:
                    handler = (CollisionHandler)func_800162AC;
                    break;
                case 7:
                    handler = (CollisionHandler)func_800152E8;
                    break;
                case 8:
                    handler = (CollisionHandler)func_80015B5C;
                    break;
                }
                break;
            case 3:
                switch (second) {
                case 4:
                    handler = (CollisionHandler)func_80017ACC;
                    break;
                case 5:
                    handler = (CollisionHandler)func_80017C10;
                    break;
                }
                break;
            case 4:
                switch (second) {
                case 5:
                    handler = (CollisionHandler)func_80017CDC;
                    break;
                case 8:
                    handler = func_80017E50;
                    break;
                }
                break;
            case 5:
                break;
            }
            D_800974A0[first][second] = handler;
            D_800974A0[second][first] = handler;
        }
    }
}
