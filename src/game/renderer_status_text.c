#include "../../include/graphics_state_internal.h"
#include "../../include/renderer_debug_text.h"
#include "../../include/game_memory.h"

extern int D_80075FB8;
extern unsigned int D_800BAE88;
extern unsigned int D_8009EFA4;
void func_800493F4(int value);
void func_80049DB0(void);

void func_8004B340(void)
{
    int i;
    int x;
    unsigned char *message = (unsigned char *)"new controller pak";

    switch (D_80075FB8) {
        case 0:
        case 1:
        case 2:
            break;
        case 3:
            if (D_8009EFA4 - D_800BAE88 < 5000) {
                FRAME_COMMAND(0xE7000000, 0);
                func_80048D9C();
                func_800493F4(400);
                func_80049BAC();
                x = 50;
                for (i = 0; i < func_8003B4FC(message); i++) {
                    func_80049DD8(x * 2, -78, 200);
                    if (message[i] != ' ') func_80049E3C(message[i]);
                    x -= 6;
                }
            }
            break;
    }
    func_80049DB0();
}
