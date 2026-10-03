#include "../../../include/actor_behavior_internal.h"

/* Only the two fields touched by the boundary dispatcher are named here. */
typedef struct BoundaryPlayer {
    unsigned char unknown00[6];
    unsigned char count06;
    unsigned char unknown07[0x15];
    int count1C;
    unsigned char unknown20[0xD94];
} BoundaryPlayer;

typedef char BoundaryPlayerMustBe3508Bytes[
    sizeof(BoundaryPlayer) == 0xDB4 ? 1 : -1];

extern BoundaryPlayer D_8009B190[2];
extern ActorBehaviorActorInternal *D_800AA708;
extern int D_800BA784, D_800AD168;
extern unsigned int D_8009EFA0;

unsigned char D_8008FDE0[] = "Unknown type in bounds checking\n";

int func_80017F9C(ActorBehaviorActorInternal *actor);
int func_80018480(ActorBehaviorActorInternal *actor);
int func_800186D8(ActorBehaviorActorInternal *actor);
struct EarlyGameActor;
struct EarlyGameActor *func_8000A074(ActorBehaviorActorInternal *actor);
int func_8003614C(int sound, int parameter, int mode, int argument);
void func_8001C0D0(unsigned char *format, ...);

void func_800190F8(void)
{
    ActorBehaviorActorInternal *actor;

    for (actor = D_800AA708; actor; actor = actor->next78) {
        if (actor->field28 == 0 &&
            (actor->position[0] < actor->unknown00[3] - 30000 ||
             actor->position[0] > 30000 - actor->unknown00[3] ||
             actor->position[1] < actor->unknown00[3] - 30000 ||
             actor->position[1] > 30000 - actor->unknown00[3] ||
             (D_800BA784 &&
              func_8004CEF0(actor->position[1]) +
                  func_8004CEF0(actor->position[0]) >
                  42000 - actor->unknown00[3]))) {
            switch (actor->kind1C) {
            case 0:
                switch (actor->resource24->actorKind) {
                case 5:
                case 6:
                case 7:
                case 8:
                case 21:
                case 22:
                case 23:
                case 24:
                    func_800186D8(actor);
                    break;
                default:
                    actor->flags14 |= 2;
                    func_80017F9C(actor);
                    break;
                }
                break;
            case 2:
            case 6:
            case 7:
                func_80018480(actor);
                break;
            case 8:
                func_80018480(actor);
                break;
            case 1:
                if (actor->resource24->actorKind != 10 &&
                    actor->resource24->actorKind != 13) {
                    func_80017F9C(actor);
                }
                break;
            case 9:
                if (actor->resource24->actorKind == 23) {
                    actor->state21 = 2;
                    D_8009B190[D_800AD168].count06--;
                    D_8009B190[D_800AD168].count1C++;
                } else if (actor->resource24->actorKind != 188) {
                    func_80017F9C(actor);
                }
                break;
            case 5:
                switch (actor->resource24->actorKind) {
                case 5:
                case 7:
                case 8:
                    if (func_800186D8(actor)) {
                        func_8003614C(84, 0, 1, 0);
                    }
                    break;
                case 4:
                    func_80017F9C(actor);
                    break;
                case 6:
                    break;
                }
                break;
            case 4:
                if (actor->resource24->actorKind != 2 ||
                    D_8009EFA0 - actor->field48 > 200U) {
                    if ((actor->position[0] < actor->unknown00[3] - 30000 &&
                         actor->field6C) ||
                        (actor->position[0] > 30000 - actor->unknown00[3] &&
                         actor->field6C) ||
                        (actor->position[1] < actor->unknown00[3] - 30000 &&
                         actor->field70) ||
                        (actor->position[1] > 30000 - actor->unknown00[3] &&
                         actor->field70) ||
                        (D_800BA784 &&
                         func_8004CEF0(actor->position[1]) +
                             func_8004CEF0(actor->position[0]) >
                             42000 - actor->unknown00[3])) {
                        if (actor->flags14 & 0x100) {
                            actor->state21 = 2;
                        } else {
                            func_8000A074(actor);
                            actor->state21 = 1;
                        }
                    }
                }
                break;
            case 3:
                func_800186D8(actor);
                break;
            default:
                func_8001C0D0(D_8008FDE0);
                break;
            }
        }
    }
}
