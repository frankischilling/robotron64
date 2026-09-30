#include "../../include/early_game_medium_next.h"
#include "../../include/game_memory.h"
#include "../../include/platform_services.h"

extern unsigned char D_800903A0[];
extern unsigned char D_8009E590[];
extern int D_8009E588;
extern int D_8009E574;
extern int D_8009E57C;
extern int D_8009E584;

void func_8001B870(void)
{
    void *data;
    int size;

    data = func_8003C64C(D_800903A0, &size);
    func_8003B520(D_8009E590, data, 0x320);
    func_8003C698(data);
    D_8009E588 = 0;
    D_8009E574 = 0;
    D_8009E57C = 0;
    D_8009E584 = 0;
}
