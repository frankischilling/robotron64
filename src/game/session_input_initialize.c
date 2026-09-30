#include "../../include/early_game_medium.h"
#include "../../include/platform_services.h"
#include "../../include/save_game.h"

extern EarlyPointerState D_8009B1C4;
extern EarlyPointerState D_8009BF78;
void func_8001BF48(int *state);

void func_8001A2C4(void)
{
    func_8001A170(&D_8009B1C4, 0, 0);
    func_8001A170(&D_8009BF78, 0, 2);
    func_8001A170((EarlyPointerState *)&D_800AD138, 0, 0);
    func_8001BF48((int *)&D_8009B1C4);
    func_8001BF48((int *)&D_8009BF78);
    func_8001BF48((int *)&D_800AD138);
    func_8003C5C4();
}
