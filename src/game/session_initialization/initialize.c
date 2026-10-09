#include "../../../include/game_initializer_internal.h"
#include "../../../include/save_game.h"
#include "../../../include/actor_resource_internal.h"
#include "../../../include/actor_dynamic_pool_internal.h"
#include "../../../include/control_setup_internal.h"
#include "../../../include/platform_services.h"
#include "../../../include/controller_services.h"
#include "../../../include/scene_commands_internal.h"
#include "../../../include/script_service_internal.h"
#include "../../../include/game_memory.h"
#include "../../../include/session_setup_internal.h"

extern int D_8007C334, D_8007CCA0, D_800AE4F8, D_800AD120, D_800AD128;
extern int D_800BAE90, D_800736A8, D_80075FC4;
void func_800256C0(void);
void func_80002EE0(void);
void func_8002818C(void);
void func_80031564(void);
void func_8001DE60(int value);
void func_80019E40(void);
void func_80025D5C(void);
void func_800360B0(void);
void func_800387C8(void);
void func_800361FC(void);
void func_8003CC30(void);
void func_8001288C(int value);
void func_8001B870(void);
void func_80032540(void);
void func_8001CD60(void);
void func_8002FD44(int value);
void func_80037A20(void);
void func_8003C5D4(void);
void func_8001A1F0(GameSessionState *session);
void func_8001DE54(void);
void func_8001CE68(void);
void func_8001D3F0(int value);
void func_8003BF6C(void);
void func_800314FC(unsigned char *path);
void func_80031C10(void);



void func_8002205C(unsigned char *script)
{
    /* Retail initializes these three bytes, though this body never reads them. */
    unsigned char mode[3] = "AM";
    int index;
    int size;
    int status;
    int handle;
    void *data;

    for (index = 0; index < 11; index++) {
        D_8009AA00[index].value58 = 1;
    }
    D_8007CCA0 = 0;
    D_800AD128 = 0;
    func_800256C0();
    func_80002EE0();
    func_8002818C();
    func_80031564();
    func_8001DE60(0);
    func_80019E40();
    func_80025D5C();
    func_800360B0();
    func_800387C8();
    func_800361FC();
    func_8003CC30();
    func_8001288C(1);
    D_800AE4F8 = 0;
    func_8003C5CC(1);
    D_800AC970 = 0;
    D_800AD138.saved.currentPlayer = 0;
    D_800AD120 = 0;
    func_8001F2CC((unsigned char *)"SHELL\\BFFSCR.BFF", 0);
    func_8001B870();
    data = func_8003C64C((unsigned char *)"LEVELNOS.DAT", &size);
    func_8003B520(D_800BA7A8, data, 0x370);
    func_8003C698(data);
    func_80032540();
    func_8001CD60();
    func_8001CD1C(script);
    func_8002FD44(0);
    func_800301A4(0, 1);
    func_80037A20();
    D_800B9A78.valueCDC = D_800AD134;
    D_800B9A78.valueCE0 = D_800AD130;
    D_800B9A78.valueCE4 = D_800AD12C;
    D_800AC998[2].speed /= 5;
    *(short *)&D_800AC998[2].unknown0C[0xC] /= 5;
    D_800AE4F4 = 0;
    func_8001F2CC((unsigned char *)"SHELL\\BFFSHELL.LST", 1);
    D_800BAE90 = 1;
    func_8003C5D4();
    func_8001A1F0(&D_800AD138);
    status = func_8004FC98(0);
    if (status == 0) {
        D_80075FC4 = 4;
    } else if (status == -2) {
        D_80075FC4 = 6;
    } else if (status == -1) {
        D_80075FC4 = 5;
    } else if (status == 1) {
        handle = func_8004C3AC((int)"robo64", (unsigned char *)"rb");
        if ((unsigned int)func_8004F990() < 16U && handle == 0) {
            D_80075FC4 = 2;
        }
        if (func_8004F9D4() == 16 && handle == 0) {
            D_80075FC4 = 2;
        }
        if (D_800AD138.saved.flags1C & 0x100) {
            D_80075FC4 = 1;
        }
    }
    if ((D_8007C334 & 1) && D_80075FC4 == 0) {
        D_80075FC4 = 3;
        D_800AD138.saved.selection = 0xFFFF;
        D_800AD280 = 5;
        D_800AD28C = 0;
    } else {
        D_800AD138.saved.selection = 0xFFFF;
        D_800AD280 = 5;
        D_800AD28C = 0;
    }
    func_8001DE54();
    func_8001CE68();
    func_8001D3F0(1);
    func_8003BF6C();
    func_800314FC((unsigned char *)"PALETTES\\GAMEPAL.BMP");
    func_80031C10();
    D_800AC998[4].value58 /= 3;
    *(short *)&D_8009AA00[0].unknown0C[0x1A] = *(short *)&D_800AF1F0[5].unknown1C[10];
    *(short *)&D_8009AA00[1].unknown0C[0x1A] = *(short *)&D_800AF1F0[5].unknown1C[10];
    *(short *)&D_8009AA00[6].unknown0C[0x1A] = *(short *)&D_800AF1F0[5].unknown1C[10];
    *(short *)&D_8009AA00[10].unknown0C[0x1A] = *(short *)&D_800AF1F0[5].unknown1C[10];
    D_800736A8 = D_8009EA18[0].resources[0].resource.playbackSpeed;
    D_800AD138.animationLimitA0 = 5;
    D_800AD138.animationIndex9C = 4;
    if (!(D_8007C334 & 2)) {
        D_800771B0 = &D_80077148;
    }
    if (!(D_8007C334 & 4)) {
        if (!(D_8007C334 & 2)) {
            D_80077138 = &D_800770D0;
        }
        D_80077128[15] = '1';
        D_80077100[15] = '2';
    } else if (!(D_8007C334 & 8)) {
        D_80077138 = &D_800770D0;
    }
}
