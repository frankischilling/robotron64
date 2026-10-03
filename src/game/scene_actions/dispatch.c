#include "../../../include/scene_action_internal.h"

void func_8001B8D8(int *selection, ScenePlayerRuntime *player)
{
    EarlyGameActor *created;
    int action;

    if (*selection == -1) {
        return;
    }
    switch (*selection) {
    case 0:
        D_80073A40 = 1;
        D_8007BB18 = 1;
        D_80097644 = D_8009EFA0;
        break;
    case 1:
        if (D_800AD280 == 5) {
            D_8009E57C = 1;
            func_80022528(0, 0, 0);
        }
        break;
    case 2:
        if (D_800AD280 == 5) {
            D_800AD30C = 50;
            func_800278AC(0, 0, 0);
            func_8003614C(0, 0, 1, 0);
            func_80026178(D_80076E44, 1);
        }
        break;
    case 3:
        if (D_800AD280 == 5) {
            D_8009E574 = 1;
            D_80076FF4 = D_80076FB4;
            func_800278AC(0, 0, 0);
            func_8003614C(0, 0, 1, 0);
            func_80026178(D_80076E44, 1);
        }
        break;
    case 4:
        if (D_800AD280 == 5) {
            D_80097640 &= 1;
            D_80097640++;
        }
        break;
    case 5:
        action = 0;
applyPickup:
        if (D_800AD280 == 9 && D_800AD288 == 3 && D_800AD284 == 0 &&
            D_800BAE8C++ < 5) {
            func_8003614C(0, 0, 1, 0);
            if (action == 7) {
                player->field7C++;
            } else if (action == 6) {
                created = player->field0C;
                if (created == 0) {
                    created = (EarlyGameActor *)func_800283D4(6, D_8009AFD8,
                                                           player->actor08->position);
                    player->field0C = created;
                }
                if (created != 0) {
                    ((ActorBehaviorActorInternal *)created)->field3C = (int)player;
                    player->actor08->unknown10[0] += D_8009D118 * 256;
                }
            } else {
                player->field6C = action;
                player->field78 = 0;
            }
        }
        break;
    case 6:
        action = 1;
        goto applyPickup;
    case 7:
        action = 2;
        goto applyPickup;
    case 10:
        action = 6;
        goto applyPickup;
    case 8:
        action = 3;
        goto applyPickup;
    case 9:
        action = 4;
        goto applyPickup;
    case 11:
        action = 7;
        goto applyPickup;
    case 12:
    case 13:
    default:
        break;
    }
    *selection = -1;
}
