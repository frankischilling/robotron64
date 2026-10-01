#include "../../include/early_game_state.h"
#include "../../include/scene_player_runtime_internal.h"
#include "../../include/scene_counter_internal.h"
#include "../../include/scene_audio.h"

extern TextGlyphResource D_8009B0E0;
extern int D_8009D118;
extern int D_8009EFA0;
extern unsigned char D_8008FDC8[];
void func_8001C0D0(unsigned char *format, ...);

int func_800152E8(EarlyGameActor *actor, EarlyGameActor *pickup,
                  int unused2, int unused3)
{
    int sound;
    int kind;
    int result = 0;
    EarlyGameActor *shield;
    ScenePlayerRuntime *player;

    player = (ScenePlayerRuntime *)actor->owner3C;
    if (pickup->animation1F != 3) {
        kind = ((TextGlyphResource *)pickup->resource24)->actorKind;
        switch (kind) {
        case 11:
        case 12:
        case 13:
        case 14:
        case 15:
            player->field01 |= 1 << (kind + 21);
            sound = 98;
            break;
        case 6:
            shield = player->field0C;
            if (shield == 0) {
                shield = (EarlyGameActor *)func_800283D4(6, &D_8009B0E0,
                                                        actor->position.value);
                player->field0C = shield;
            }
            if (shield != 0) {
                shield->owner3C = (EarlyGameActorOwner *)player;
                player->actor08->unknown10[0] += D_8009D118 << 8;
                result = 32;
                sound = 106;
            }
            break;
        case 5:
            func_80037050(1, (SceneBucketCounter *)player);
            result = 32;
            sound = 98;
            break;
        case 0:
            sound = 108;
            break;
        case 1:
            sound = 108;
            break;
        case 2:
            sound = 108;
            break;
        case 3:
            sound = 108;
            break;
        case 4:
            sound = 108;
            break;
        case 8:
        case 9:
        case 10:
            if (player->field70 != 0) {
                if (player->field74 == 0) {
                    player->field74 = kind;
                }
            } else {
                player->field70 = kind;
            }
            break;
        case 7:
            player->field7C++;
            sound = 108;
            break;
        default:
            func_8001C0D0(D_8008FDC8);
            break;
        }
        if (kind != 10 && kind != 8 && kind != 9 && kind != 6 && kind != 5 &&
            kind != 7 && kind < 11) {
            player->field6C = kind;
            player->field78 = 0;
        }
        if (result != 32) {
            func_80027AB8((GameActor *)pickup, 3, 1);
            pickup->field48 = D_8009EFA0;
        }
        func_8003614C(sound, 0, 1, 0);
    }
    return (unsigned char)result;
}
